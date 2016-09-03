//
//  WallPaperSevice.swift
//  TTGBingWallPaper
//
//  Created by tutuge on 16/8/28.
//  Copyright © 2016年 tutuge. All rights reserved.
//

import Foundation
import Cocoa

class WallPaperSevice {
    // Constant
    private static let MainFolderName = "TTGBingWallPaper"
    private static let ImagesFolderName = "BingWallPapers"

    private static let CurrentImageLocationUserDefaultKey = "CurrentImageLocationUserDefaultKey"
    private static let LastUpdateWallPaperTimeStampUserDefaultKey = "LastUpdateWallPaperTimeStampUserDefaultKey"
    private static let AutoUpdateSwitchUserDefaultKey = "AutoUpdateSwitchUserDefaultKey"
    
    private static let WallPaperUpdateDurationSeconds: NSTimeInterval = 12 * 3600;

    // Singleton
    static let sharedInstance = WallPaperSevice()

    /// Images location folder url
    var imagesFolderLocation: NSURL?

    // Current wallPaper image location
    var currentImageLocation: NSURL? {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(currentImageLocation?.absoluteString, forKey: WallPaperSevice.CurrentImageLocationUserDefaultKey)
        }
    }

    // Current Bing wall paper model
    var currentModel: WallPaper? {
        didSet {
            currentModel?.saveToLocal()
        }
    }
    
    // Current auto update switch state
    var currentAutoUpadteSwitchState: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: WallPaperSevice.AutoUpdateSwitchUserDefaultKey)
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(WallPaperSevice.AutoUpdateSwitchUserDefaultKey)
        }
    }

    // Last update time
    private var lastUpdateTime: NSTimeInterval {
        set {
            NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: WallPaperSevice.LastUpdateWallPaperTimeStampUserDefaultKey)
        }
        get {
            return NSUserDefaults.standardUserDefaults().doubleForKey(WallPaperSevice.LastUpdateWallPaperTimeStampUserDefaultKey)
        }
    }
    
    // Update timer
    private var updateTimer: NSTimer?
    
    // MARK: Public methods

    func setup() {
        // If first time launch
        if lastUpdateTime == 0 {
            currentAutoUpadteSwitchState = true
        }

        // Create folder
        let applicationSupportedFolderUrl = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first
        let mainFolderUrl = applicationSupportedFolderUrl?.URLByAppendingPathComponent(WallPaperSevice.MainFolderName, isDirectory: true)
        imagesFolderLocation = mainFolderUrl?.URLByAppendingPathComponent(WallPaperSevice.ImagesFolderName, isDirectory: true)

        guard let _ = imagesFolderLocation else {
            print("Create images folder url error.")
            exit(0)
        }

        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(imagesFolderLocation!, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Create images folder error: \(error)")
            exit(0)
        }

        // Get local WallPaper Model
        currentModel = WallPaper.getFromLocal()

        // Get local current wall paper image location
        if let location = NSUserDefaults.standardUserDefaults().objectForKey(WallPaperSevice.CurrentImageLocationUserDefaultKey) as? String {
            currentImageLocation = NSURL(string: location)
        }
    }
    
    /**
     Check if need to update wallpaper
     */
    @objc func checkIfNeedUpdateWallPaper() {
        // Cancel the timer first
        updateTimer?.invalidate()
        
        if currentAutoUpadteSwitchState == false {
            // No auto update
            return
        }
        
        let currentTime = NSDate().timeIntervalSince1970
        var nextUpdateDuration: NSTimeInterval = 0
        
        if currentTime - lastUpdateTime < WallPaperSevice.WallPaperUpdateDurationSeconds {
            // Not yet, continue the timer
            nextUpdateDuration = WallPaperSevice.WallPaperUpdateDurationSeconds - (currentTime - lastUpdateTime)
        } else {
            // Is time to update
            self.updateAndSetNewestBingWallPaper({ (success) in
                UserNotificationHelper.showWallPaperUpdateInfoWithModel()
            })
            lastUpdateTime = currentTime
            nextUpdateDuration = WallPaperSevice.WallPaperUpdateDurationSeconds
        }
        
        // Create timer
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(nextUpdateDuration, target: self, selector: #selector(checkIfNeedUpdateWallPaper), userInfo: nil, repeats: false)
    }

    /**
     Update and save newest wallpaper
     
     - parameter complete: complete callback
     */
    func updateAndSetNewestBingWallPaper(complete: ((success:Bool) -> Void)) {
        WallPaperAPIManager.getNewestBingWallPaper {
            (model) in
            self.updateWallPaperFromModel(model, complete: complete)
        }
    }

    /**
     Update and save random wallpaper
     
     - parameter complete: complete callback
     */
    func updateAndSetRandomBingWallPaper(complete: ((success:Bool) -> Void)) {
        WallPaperAPIManager.getRandomBingWallPaper {
            (model) in
            self.updateWallPaperFromModel(model, complete: complete)
        }
    }

    // MARK: Private methods
    
    /**
     Update local model and set new wallpaper
     
     - parameter model:    new wallpaper model
     - parameter complete: complete callback
     */
    private func updateWallPaperFromModel(model: WallPaper?, complete: ((success:Bool) -> Void)) {
        // Check model
        guard let _ = model else {
            print("Get newest wall paper data from bing failed.")
            complete(success: false)
            return
        }

        // Save model
        self.currentModel = model

        // Create Url
        let imageUrl = NSURL(string: model!.imageUrl)!

        // Download
        WallPaperDownloader.downloadImageFromUrl(imageUrl, complete: {
            (imageTempLocation, suggestedFilename) in

            // Check download file and name
            guard let _ = imageTempLocation, _ = suggestedFilename else {
                print("Download wall paper image failed.")
                complete(success: false)
                return
            }

            // Generate final location
            guard let imageFinalLocation = self.imagesFolderLocation?.URLByAppendingPathComponent(model!.startDate + "_" + suggestedFilename!) else {
                print("Create final image location url failed.")
                complete(success: false)
                return
            }

            // Delete old image file
            do {
                try NSFileManager.defaultManager().removeItemAtURL(imageFinalLocation)
            } catch {
            }

            // Save new image file
            do {
                try NSFileManager.defaultManager().moveItemAtURL(imageTempLocation!, toURL: imageFinalLocation)
            } catch let error {
                print("Move image to final location error: \(error)")
                complete(success: false)
                return
            }

            // Success

            // Save imageLocation
            self.currentImageLocation = imageFinalLocation

            // Set WallPaper
            let setWallPaperSuccess = WallPaperSevice.setWallPaperWithImagePath(self.currentImageLocation!)
            complete(success: setWallPaperSuccess)
        })
    }

    /**
     Set all Screen WallPaper
     
     - parameter imageLocationUrl: WallPaper Image Path
     
     - returns: Success
     */
    private static func setWallPaperWithImagePath(imageLocationUrl: NSURL) -> Bool {
        for screen in NSScreen.screens()! {
            do {
                try NSWorkspace.sharedWorkspace().setDesktopImageURL(imageLocationUrl, forScreen: screen,
                        options: NSWorkspace.sharedWorkspace().desktopImageOptionsForScreen(NSScreen.mainScreen()!)!)
            } catch let error {
                print("Set wall paper error: \(error)")
                return false
            }
        }

        return true
    }
}