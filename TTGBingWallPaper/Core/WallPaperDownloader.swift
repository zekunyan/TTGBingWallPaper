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
    static func downloadImageFromUrl(_ imageUrl: URL, complete: @escaping ((_ imageTempLocation:URL?, _ suggestFileName:String?) -> Void)) {
        URLSession.shared.downloadTask(with: imageUrl, completionHandler: {
            (tempLocationUrl, response, error) in
            complete(tempLocationUrl, response?.suggestedFilename)
        }) .resume()
    }
}
