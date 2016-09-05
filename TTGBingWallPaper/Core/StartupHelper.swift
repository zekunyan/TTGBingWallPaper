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

    static func itemReferencesInLoginItems() -> (existingReference:LSSharedFileListItemRef?, lastReference:LSSharedFileListItemRef?) {
        let appUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)

        if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef? {
            let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray

            if (loginItems.count > 0) {
                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as! LSSharedFileListItemRef

                for i in 0 ..< loginItems.count {
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                    if let itemURL = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
                        if (itemURL.takeRetainedValue() as NSURL).isEqual(appUrl) {
                            return (currentItemRef, lastItemRef)
                        }
                    }
                }

                // Not found
                return (nil, lastItemRef)
            } else {
                // Empty
                let virtualItem: LSSharedFileListItemRef = kLSSharedFileListItemBeforeFirst.takeRetainedValue()
                return (nil, virtualItem)
            }
        }
        return (nil, nil)
    }

    static func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)

        if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef? {
            if shouldBeToggled {
                if let appUrl: CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
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