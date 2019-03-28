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
    //'en-US', 'de-DE', 'en-AU', 'en-CA', 'en-NZ', 'en-UK', 'ja-JP', 'zh-CN'
    static let LocationMap:[String:String] = ["中国":"zh-CN","美国":"en-US","澳大利亚":"en-AU","英国":"en-UK","日本":"ja-JP","德国":"de-DE"]
    // Constant
    fileprivate static let MainFolderName = "TTGBingWallPaper"
    fileprivate static let ImagesFolderName = "BingWallPapers"
    
    fileprivate static let CurrentImageLocationUserDefaultKey = "CurrentImageLocationUserDefaultKey"
    fileprivate static let LastUpdateWallPaperTimeStampUserDefaultKey = "LastUpdateWallPaperTimeStampUserDefaultKey"
    fileprivate static let AutoUpdateSwitchUserDefaultKey = "AutoUpdateSwitchUserDefaultKey"
    fileprivate static let BingLocationSwitchUserDefaultKey = "BingLocationSwitchUserDefaultKey"
    
    fileprivate static let WallPaperUpdateDurationSeconds: TimeInterval = 12 * 3600;
    
    // Singleton
    static let sharedInstance = WallPaperSevice()
    
    /// Images location folder url
    var imagesFolderLocation: URL?
    
    // Current wallPaper image location
    var currentImageLocation: URL? {
        didSet {
            UserDefaults.standard.set(currentImageLocation?.absoluteString, forKey: WallPaperSevice.CurrentImageLocationUserDefaultKey)
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
            UserDefaults.standard.set(newValue, forKey: WallPaperSevice.AutoUpdateSwitchUserDefaultKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: WallPaperSevice.AutoUpdateSwitchUserDefaultKey)
        }
    }
    
    // bing location
    var currentBingLocationSwitchState: String {
        set {
            UserDefaults.standard.set(WallPaperSevice.LocationMap[newValue], forKey: WallPaperSevice.BingLocationSwitchUserDefaultKey)
        }
        get {
            return UserDefaults.standard.string(forKey: WallPaperSevice.BingLocationSwitchUserDefaultKey) ?? "zh-CN"
        }
    }
    
    // Last update time
    fileprivate var lastUpdateTime: TimeInterval {
        set {
            UserDefaults.standard.set(newValue, forKey: WallPaperSevice.LastUpdateWallPaperTimeStampUserDefaultKey)
        }
        get {
            return UserDefaults.standard.double(forKey: WallPaperSevice.LastUpdateWallPaperTimeStampUserDefaultKey)
        }
    }
    
    // Update timer
    fileprivate var updateTimer: Timer?
    
    // MARK: Public methods
    
    func setup() {
        // If first time launch
        if lastUpdateTime == 0 {
            currentAutoUpadteSwitchState = true
        }
        
        // Create folder
        let applicationSupportedFolderUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        let mainFolderUrl = applicationSupportedFolderUrl?.appendingPathComponent(WallPaperSevice.MainFolderName, isDirectory: true)
        imagesFolderLocation = mainFolderUrl?.appendingPathComponent(WallPaperSevice.ImagesFolderName, isDirectory: true)
        
        guard let _ = imagesFolderLocation else {
            print("Create images folder url error.")
            exit(0)
        }
        
        do {
            try FileManager.default.createDirectory(at: imagesFolderLocation!, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Create images folder error: \(error)")
            exit(0)
        }
        
        // Get local WallPaper Model
        currentModel = WallPaper.getFromLocal()
        
        // Get local current wall paper image location
        if let location = UserDefaults.standard.object(forKey: WallPaperSevice.CurrentImageLocationUserDefaultKey) as? String {
            currentImageLocation = URL(string: location)
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
        
        let currentTime = Date().timeIntervalSince1970
        var nextUpdateDuration: TimeInterval = 0
        
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
        updateTimer = Timer.scheduledTimer(timeInterval: nextUpdateDuration, target: self, selector: #selector(checkIfNeedUpdateWallPaper), userInfo: nil, repeats: false)
    }
    
    /**
     Update and save newest wallpaper
     
     - parameter complete: complete callback
     */
    func updateAndSetNewestBingWallPaper(_ complete: @escaping ((_ success:Bool) -> Void)) {
        WallPaperAPIManager.getNewestBingWallPaper {
            (model) in
            self.updateWallPaperFromModel(model, complete: complete)
        }
    }
    
    /**
     Update and save random wallpaper
     
     - parameter complete: complete callback
     */
    func updateAndSetRandomBingWallPaper(_ complete: @escaping ((_ success:Bool) -> Void)) {
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
    fileprivate func updateWallPaperFromModel(_ model: WallPaper?, complete: @escaping ((_ success:Bool) -> Void)) {
        // Check model
        guard let _ = model else {
            print("Get newest wall paper data from bing failed.")
            complete(false)
            return
        }
        
        // Save model
        self.currentModel = model
        
        // Create Url
        let imageUrl = URL(string: model!.imageUrl)!
        
        // Download
        WallPaperDownloader.downloadImageFromUrl(imageUrl, complete: {
            (imageTempLocation, suggestedFilename) in
            
            // Check download file and name
            guard let _ = imageTempLocation, let _ = suggestedFilename else {
                print("Download wall paper image failed.")
                complete(false)
                return
            }
            
            // Generate final location
            guard let imageFinalLocation = self.imagesFolderLocation?.appendingPathComponent(model!.startDate + "_" + suggestedFilename!) else {
                print("Create final image location url failed.")
                complete(false)
                return
            }
            
            // Delete old image file
            do {
                try FileManager.default.removeItem(at: imageFinalLocation)
            } catch {
            }
            
            // Save new image file
            do {
                try FileManager.default.moveItem(at: imageTempLocation!, to: imageFinalLocation)
            } catch let error {
                print("Move image to final location error: \(error)")
                complete(false)
                return
            }
            
            // Success
            
            // Save imageLocation
            self.currentImageLocation = imageFinalLocation
            
            // Set WallPaper
            let setWallPaperSuccess = WallPaperSevice.setWallPaperWithImagePath(self.currentImageLocation!)
            complete(setWallPaperSuccess)
        })
    }
    
    /**
     Set all Screen WallPaper
     
     - parameter imageLocationUrl: WallPaper Image Path
     
     - returns: Success
     */
    fileprivate static func setWallPaperWithImagePath(_ imageLocationUrl: URL) -> Bool {
        for screen in NSScreen.screens {
            do {
                try NSWorkspace.shared.setDesktopImageURL(imageLocationUrl, for: screen,
                                                          options: NSWorkspace.shared.desktopImageOptions(for: NSScreen.main!)!)
            } catch let error {
                print("Set wall paper error: \(error)")
                return false
            }
        }
        
        return true
    }
}
