//
//  WallPaperAPIManager.swift
//  TTGBingWallPaper
//
//  Created by tutuge on 16/8/28.
//  Copyright © 2016年 tutuge. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

class WallPaperAPIManager {
    static let BingHost = "http://www.bing.com"
    static let BingWallPaper = "http://www.bing.com/HPImageArchive.aspx"

    static func getNewestBingWallPaper(complete complete: (model:WallPaper?) -> Void) -> Void {
        let urlComponent = NSURLComponents(string: BingWallPaper)!

        urlComponent.queryItems = [
                NSURLQueryItem(name: "format", value: "js"),
                NSURLQueryItem(name: "idx", value: "-1"),
                NSURLQueryItem(name: "n", value: "1"),
        ]

        let url = urlComponent.URL!;

        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
            (data, response, error) in
            guard let _: NSData = data else {
                complete(model: nil)
                return
            }

            let json = JSON(data: data!)
            if json["images"].arrayValue.count > 0 {
                let model = WallPaper(jsonObject: json["images"].arrayValue.first!)
                complete(model: model)
            } else {
                complete(model: nil)
            }
        }).resume()
    }
}