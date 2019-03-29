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
    static let BingHost = "https://www.bing.com"
    static let BingWallPaper = "https://www.bing.com/HPImageArchive.aspx"
    
    /**
     Get random WallPaper Model
     
     - parameter complete: complete callback
     */
    static func getRandomBingWallPaper(complete: @escaping (_ model:WallPaper?) -> Void) -> Void {
        var urlComponent = URLComponents(string: BingWallPaper)!
        
        let idx = Int(arc4random_uniform(16)) - 1 // [-1, 15), -1=Newest
        urlComponent.queryItems = [
            URLQueryItem(name: "format", value: "js"),
            URLQueryItem(name: "idx", value: String(idx)),
            URLQueryItem(name: "n", value: "1"),
            URLQueryItem(name: "mkt", value: WallPaperSevice.sharedInstance.currentBingLocationSwitchState),
        ]
        
        getBingWallPaperWithUrl(urlComponent.url!, complete: complete)
    }
    
    /**
     Get newest WallPaper Model
     
     - parameter complete: complete callback
     */
    static func getNewestBingWallPaper(complete: @escaping (_ model:WallPaper?) -> Void) -> Void {
        var urlComponent = URLComponents(string: BingWallPaper)!
        
        urlComponent.queryItems = [
            URLQueryItem(name: "format", value: "js"),
            URLQueryItem(name: "idx", value: "-1"),
            URLQueryItem(name: "n", value: "1"),
            URLQueryItem(name: "mkt", value: WallPaperSevice.sharedInstance.currentBingLocationSwitchState),
        ]
        
        getBingWallPaperWithUrl(urlComponent.url!, complete: complete)
    }
    
    /**
     Private Get Bing WallPaper Model
     
     - parameter url:      url
     - parameter complete: complete callback
     */
    fileprivate static func getBingWallPaperWithUrl(_ url: URL, complete: @escaping (_ model:WallPaper?) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error)  in
            guard let _: Data = data else {
                complete(nil)
                return
            }
            do {
                let json = try JSON(data: data!)
                if json["images"].arrayValue.count > 0 {
                    let model = WallPaper(jsonObject: json["images"].arrayValue.first!)
                    complete(model)
                } else {
                    complete(nil)
                }
            }catch{}
            
        };
        task.resume();
    }
}
