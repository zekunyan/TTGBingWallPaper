//
//  StartupHelper.swift
//  BingWallPaper
//
//  Created by tutuge on 16/9/5.
//  Copyright © 2016年 tutuge. All rights reserved.
//

import Foundation

class StartupHelper {
    static func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }

    static func itemReferencesInLoginItems() -> (existingReference:LSSharedFileListItem?, lastReference:LSSharedFileListItem?) {
        let appUrl = URL(fileURLWithPath: Bundle.main.bundlePath)

        if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
            let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray

            if (loginItems.count > 0) {
                let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem

                for i in 0 ..< loginItems.count {
                    let currentItemRef: LSSharedFileListItem = loginItems.object(at: i) as! LSSharedFileListItem
                    if let itemURL = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
                        if (itemURL.takeRetainedValue() as URL) == appUrl {
                            return (currentItemRef, lastItemRef)
                        }
                    }
                }

                // Not found
                return (nil, lastItemRef)
            } else {
                // Empty
                let virtualItem: LSSharedFileListItem = kLSSharedFileListItemBeforeFirst.takeRetainedValue()
                return (nil, virtualItem)
            }
        }
        return (nil, nil)
    }

    static func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)

        if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
            if shouldBeToggled {
                if let appUrl: CFURL = URL(fileURLWithPath: Bundle.main.bundlePath) as CFURL? {
                    LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
                }
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef, itemRef);
                }
            }
        }
    }
}
