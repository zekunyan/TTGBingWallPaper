//
//  WallPaperDownloader.swift
//  TTGBingWallPaper
//
//  Created by tutuge on 16/8/28.
//  Copyright © 2016年 tutuge. All rights reserved.
//

import Foundation
import Cocoa

class WallPaperDownloader {
    static func downloadImageFromUrl(imageUrl: NSURL, complete: ((imageTempLocation:NSURL?, suggestFileName:String?) -> Void)) {
        NSURLSession.sharedSession().downloadTaskWithURL(imageUrl) {
            (tempLocationUrl, response, error) in
            complete(imageTempLocation: tempLocationUrl, suggestFileName: response?.suggestedFilename)
        }.resume()
    }
}