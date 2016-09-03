//
//  AppDelegate.swift
//  TTGBingWallPaper
//
//  Created by tutuge on 16/8/28.
//  Copyright © 2016年 tutuge. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        configStatusButton()
        configMenuItems()
        
        // Setup
        WallPaperSevice.sharedInstance.setup()
        
        // Update
        WallPaperSevice.sharedInstance.updateAndSetNewestBingWallPaper { (success) in}
    }
    
    // MARK: Config
    
    func configStatusButton() {
        if let button = statusItem.button {
            button.image = NSImage(named: "menu_icon")
        }
    }
    
    func configMenuItems() {
        let menu = NSMenu()
        
        // Refresh newest wall paper
        menu.addItem(NSMenuItem(title: "Newest", action: #selector(menuItemNewestWallPaperClick), keyEquivalent: "n"))
        
        // Refresh random wall paper
        menu.addItem(NSMenuItem(title: "Random", action: #selector(menuItemRandomWallPaperClick), keyEquivalent: "r"))
        
        // Copyright
        menu.addItem(NSMenuItem(title: "Copyright", action: #selector(menuItemCopyrightClick), keyEquivalent: ""))
        
        // Github
        menu.addItem(NSMenuItem(title: "Github", action: #selector(menuItemGithubClick), keyEquivalent: ""));
        
        // About
        menu.addItem(NSMenuItem(title: "About", action: #selector(menuItemAboutClick), keyEquivalent: ""))
        
        // Quit
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(menuItemQuitClick), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    // MARK: Actions
    
    func menuItemNewestWallPaperClick() {
        WallPaperSevice.sharedInstance.updateAndSetNewestBingWallPaper { (success) in
            UserNotificationHelper.show("Update !", subTitle: WallPaperSevice.sharedInstance.currentModel?.copyRight, content: "")
        }
    }

    func menuItemRandomWallPaperClick() {
        WallPaperSevice.sharedInstance.updateAndSetRandomBingWallPaper { (success) in
            UserNotificationHelper.show("Update !", subTitle: WallPaperSevice.sharedInstance.currentModel?.copyRight, content: "")
        }
    }
    
    func menuItemCopyrightClick() {
        if let copyrightUrl = NSURL(string: WallPaperSevice.sharedInstance.currentModel?.copyRightUrl ?? WallPaperAPIManager.BingHost) {
            NSWorkspace.sharedWorkspace().openURL(copyrightUrl)
        }
    }
    
    func menuItemGithubClick() {
        if let githubUrl = NSURL(string: "https://github.com/zekunyan/TTGBingWallPaper") {
            NSWorkspace.sharedWorkspace().openURL(githubUrl)
        }
    }
    
    func menuItemAboutClick() {
        let alert = NSAlert()
        alert.icon = NSImage.init(named: "AppIcon")
        alert.messageText = "Bing Wallpaper"
        alert.informativeText = "By tutuge.\nEmail: zekunyan@163.com\nGithub: https://github.com/zekunyan"
        alert.alertStyle = .InformationalAlertStyle
        alert.runModal()
    }
    
    func menuItemQuitClick() {
        NSApplication.sharedApplication().terminate(nil)
    }
}

