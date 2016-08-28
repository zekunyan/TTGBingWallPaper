//
//  WallPaperModel.swift
//  TTGBingWallPaper
//
//  Created by tutuge on 16/8/21.
//  Copyright © 2016年 tutuge. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

struct WallPaper {
    // Constant: UserDefault key
    private static let WallPaperModelUserDefaultKey = "WallPaperModelUserDefaultKey"

    // Original json object
    private let originalJson: JSON
    
    // Model property
    let startDate: String
    let endDate: String
    let imageUrl: String
    let copyRight: String
    let copyRightUrl: String
    
    init(jsonObject json: JSON) {
        
        // Set property
        startDate = json["startdate"].stringValue
        endDate = json["enddate"].stringValue
        copyRight = json["copyright"].stringValue
        copyRightUrl = json["copyrightlink"].stringValue

        // Check and set imageUrl
        let url = json["url"].stringValue
        imageUrl = url.containsString("http://") ? url : WallPaperAPIManager.BingHost.stringByAppendingString(url)
        
        // Save Json
        originalJson = json
    }
    
    func saveToLocal() {
        NSUserDefaults.standardUserDefaults().setObject(originalJson.dictionaryObject, forKey: WallPaper.WallPaperModelUserDefaultKey)
    }
    
    static func getFromLocal() -> WallPaper? {
        if let jsonDict = NSUserDefaults.standardUserDefaults().objectForKey(WallPaper.WallPaperModelUserDefaultKey) {
            return WallPaper(jsonObject: JSON(jsonDict))
        }
        return nil
    }
}