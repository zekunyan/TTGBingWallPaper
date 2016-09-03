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
    
    var autoUpdateMenuItem: NSMenuItem?
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Setup UI
        configStatusButton()
        configMenuItems()
        
        // Setup
        WallPaperSevice.sharedInstance.setup()
        
        // Update
        WallPaperSevice.sharedInstance.updateAndSetNewestBingWallPaper { (success) in}
        
        // Set Wake from sleep notification
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector:
            #selector(didWakeFromSleep), name: NSWorkspaceDidWakeNotification, object: nil)
        
        // Check if need update
        WallPaperSevice.sharedInstance.checkIfNeedUpdateWallPaper()
    }
    
    // MARK: Config
    
    func configStatusButton() {
        if let button = statusItem.button {
            button.image = NSImage(named: "menu_icon")
        }
    }
    
    func configMenuItems() {
        let menu = NSMenu()
        
        // Auto update 
        autoUpdateMenuItem = NSMenuItem(title: "Auto Update", action: #selector(menuItemAutoUpdateClick), keyEquivalent: "")
        autoUpdateMenuItem?.onStateImage = NSImage(named: "checked")
        autoUpdateMenuItem?.offStateImage = nil
        updateAutoUpdateMenuItemState()
        
        menu.addItem(autoUpdateMenuItem!)
        
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
    
    func menuItemAutoUpdateClick() {
        let state = WallPaperSevice.sharedInstance.currentAutoUpadteSwitchState
        
        UserNotificationHelper.show("Config change!", subTitle:  "Auto update: \(!state ? "ON" : "OFF")", content: "")
        
        WallPaperSevice.sharedInstance.currentAutoUpadteSwitchState = !state
        WallPaperSevice.sharedInstance.checkIfNeedUpdateWallPaper()
        
        updateAutoUpdateMenuItemState()
    }
    
    func menuItemNewestWallPaperClick() {
        WallPaperSevice.sharedInstance.updateAndSetNewestBingWallPaper { (success) in
            UserNotificationHelper.showWallPaperUpdateInfoWithModel()
        }
    }

    func menuItemRandomWallPaperClick() {
        WallPaperSevice.sharedInstance.updateAndSetRandomBingWallPaper { (success) in
            UserNotificationHelper.showWallPaperUpdateInfoWithModel()
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
        alert.icon = NSImage(named: "AppIcon")
        alert.messageText = "Bing Wallpaper"
        alert.informativeText = "By tutuge.\nEmail: zekunyan@163.com\nGithub: https://github.com/zekunyan"
        alert.alertStyle = .InformationalAlertStyle
        alert.runModal()
    }
    
    func menuItemQuitClick() {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // MARK: NSWorkspaceDidWakeNotification
    
    @objc private func didWakeFromSleep() {
        WallPaperSevice.sharedInstance.checkIfNeedUpdateWallPaper()
    }
    
    // MARK: Private methods
    
    private func updateAutoUpdateMenuItemState() {
        autoUpdateMenuItem?.state = Int(WallPaperSevice.sharedInstance.currentAutoUpadteSwitchState)
    }
}

