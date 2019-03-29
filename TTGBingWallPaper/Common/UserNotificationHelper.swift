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
        UserNotificationHelper.show(NSLocalizedString("UPDATE",comment:""),
                                    subTitle: "",
                                    content: WallPaperSevice.sharedInstance.currentModel?.copyRight)
    }
    
    static func show(_ title:String?, subTitle:String?, content:String?) {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications();
        
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = subTitle
        notification.informativeText = content
        
        notification.deliveryDate = Date(timeIntervalSinceNow: 0.5)
        
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
}
