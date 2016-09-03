//
//  UserNotificationHelper.swift
//  TTGBingWallPaper
//
//  Created by tutuge on 16/8/28.
//  Copyright © 2016年 tutuge. All rights reserved.
//

import Foundation

class UserNotificationHelper {
    static func showWallPaperUpdateInfoWithModel() {
        UserNotificationHelper.show("Update !",
                                    subTitle: WallPaperSevice.sharedInstance.currentModel?.copyRight,
                                    content: "")
    }
    
    static func show(title:String?, subTitle:String?, content:String?) {
        NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications();
        
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = subTitle
        notification.informativeText = content
        
        notification.deliveryDate = NSDate.init(timeIntervalSinceNow: 0.5)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notification)
    }
}