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
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    var autoUpdateMenuItem: NSMenuItem?
    var launchAtStartupMenuItem: NSMenuItem?
    var locationMenuItem: NSMenuItem?
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup
        WallPaperSevice.sharedInstance.setup()
        
        // Update
        WallPaperSevice.sharedInstance.updateAndSetNewestBingWallPaper { (success) in}
        
        // Set Wake from sleep notification
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didWakeFromSleep), name: NSWorkspace.didWakeNotification, object: nil)
        
        // Check if need update
        WallPaperSevice.sharedInstance.checkIfNeedUpdateWallPaper()
        
        // Setup UI
        configStatusButton()
        configMenuItems()
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
        menu.addItem(withTitle: "最新", action: #selector(menuItemNewestWallPaperClick), keyEquivalent: "n")
        // Refresh random wall paper
        menu.addItem(withTitle: "随机", action: #selector(menuItemRandomWallPaperClick), keyEquivalent: "r")
        // Copyright
        menu.addItem(withTitle: "图片信息", action: #selector(menuItemCopyrightClick), keyEquivalent: "i")
        
        
        // Sub menu
        let subMenu = NSMenu()
        WallPaperSevice.LocationMap .forEach { (_ key:String,_ value:String) in
            subMenu.addItem(withTitle: key, action: #selector(switchLocationMenuItemState), keyEquivalent: "")
        }
        
        locationMenuItem = NSMenuItem()
        locationMenuItem?.title = "国家与地区"
        locationMenuItem?.submenu = subMenu
        locationMenuItem?.keyEquivalent = "g"
        menu.addItem(locationMenuItem!)
        updateLocationMenuItemState()
        
        // Auto update
        autoUpdateMenuItem = NSMenuItem(title: "自动更新", action: #selector(menuItemAutoUpdateClick), keyEquivalent: "e")
        autoUpdateMenuItem?.toolTip = "Auto update newest Microsoft Bing Daily wallpaper."
        autoUpdateMenuItem?.onStateImage = NSImage(named: "checked")
        autoUpdateMenuItem?.offStateImage = nil
        updateAutoUpdateMenuItemState()
        menu.addItem(autoUpdateMenuItem!)
        
        // Launch at startup
        launchAtStartupMenuItem = NSMenuItem(title: "开机启动", action: #selector(menuItemLaunchAtStartupClick), keyEquivalent: "")
        launchAtStartupMenuItem?.toolTip = "Config BingWallPaper launch at startup."
        launchAtStartupMenuItem?.onStateImage = NSImage(named: "checked")
        launchAtStartupMenuItem?.offStateImage = nil
        updateLaunchAtStartupMenuItemState()
        menu.addItem(launchAtStartupMenuItem!)
        
        // Open WallPaper folder
        menu.addItem(withTitle: "壁纸下载", action: #selector(menuItemOpenWallPapersFolderClick), keyEquivalent: "f")
        
        // Github
        //subMenu.addItem(withTitle: "Github", action: #selector(menuItemGithubClick), keyEquivalent: "");
        
        // About
        menu.addItem(withTitle: "关于", action: #selector(menuItemAboutClick), keyEquivalent: "a")
        
        // Quit
        menu.addItem(withTitle: "退出", action: #selector(menuItemQuitClick), keyEquivalent: "q")
        
        statusItem.menu = menu
    }
    
    // MARK: Actions
    
    @objc func menuItemLaunchAtStartupClick() {
        StartupHelper.toggleLaunchAtStartup()
        updateLaunchAtStartupMenuItemState()
        
        UserNotificationHelper.show("Config changed !", subTitle: "Launch at startup: \(StartupHelper.applicationIsInStartUpItems() ? "ON" : "OFF")", content: "")
    }
    
    @objc func menuItemAutoUpdateClick() {
        let state = WallPaperSevice.sharedInstance.currentAutoUpadteSwitchState
        
        UserNotificationHelper.show("Config changed !", subTitle:  "Auto update: \(!state ? "ON" : "OFF")", content: "")
        
        WallPaperSevice.sharedInstance.currentAutoUpadteSwitchState = !state
        WallPaperSevice.sharedInstance.checkIfNeedUpdateWallPaper()
        
        updateAutoUpdateMenuItemState()
    }
    
    @objc func menuItemNewestWallPaperClick() {
        WallPaperSevice.sharedInstance.updateAndSetNewestBingWallPaper { (success) in
            UserNotificationHelper.showWallPaperUpdateInfoWithModel()
        }
    }
    
    @objc func menuItemRandomWallPaperClick() {
        WallPaperSevice.sharedInstance.updateAndSetRandomBingWallPaper { (success) in
            UserNotificationHelper.showWallPaperUpdateInfoWithModel()
        }
    }
    
    @objc func menuItemOpenWallPapersFolderClick() {
        if let folderPath = WallPaperSevice.sharedInstance.imagesFolderLocation {
            NSWorkspace.shared.open(folderPath as URL)
        }
    }
    
    @objc func menuItemCopyrightClick() {
        if let copyrightUrl = URL(string: WallPaperSevice.sharedInstance.currentModel?.copyRightUrl ?? WallPaperAPIManager.BingHost) {
            NSWorkspace.shared.open(copyrightUrl)
        }
    }
    
    @objc func menuItemGithubClick() {
        if let githubUrl = URL(string: "https://github.com/zekunyan/TTGBingWallPaper") {
            NSWorkspace.shared.open(githubUrl)
        }
    }
    
    @objc func menuItemAboutClick() {
        let contentTextView = NSTextView()
        
        contentTextView.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        contentTextView.string = "\nBy tutuge.\n\nEmail: zekunyan@163.com\n\nGithub: https://github.com/zekunyan"
        contentTextView.sizeToFit()
        
        contentTextView.drawsBackground = false
        contentTextView.font = NSFont.systemFont(ofSize: 14)
        
        contentTextView.isEditable = true
        contentTextView.enabledTextCheckingTypes = NSTextCheckingAllTypes
        contentTextView.checkTextInDocument(nil)
        contentTextView.isEditable = false
        
        let alert = NSAlert()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        alert.icon = NSImage(named: "AppIcon")
        alert.messageText = "BingWallPaper \(version)"
        alert.accessoryView = contentTextView
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    @objc func menuItemQuitClick() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: NSWorkspaceDidWakeNotification
    
    @objc fileprivate func didWakeFromSleep() {
        WallPaperSevice.sharedInstance.checkIfNeedUpdateWallPaper()
    }
    
    // MARK: Private methods
    
    fileprivate func updateAutoUpdateMenuItemState() {
        autoUpdateMenuItem?.state = NSControl.StateValue(rawValue: WallPaperSevice.sharedInstance.currentAutoUpadteSwitchState ? 1 : 0)
    }
    
    fileprivate func updateLaunchAtStartupMenuItemState() {
        launchAtStartupMenuItem?.state = NSControl.StateValue(rawValue: StartupHelper.applicationIsInStartUpItems() ? 1 : 0)
    }
    
    @objc fileprivate func switchLocationMenuItemState(_ menuItem:NSMenuItem) {
        
        locationMenuItem?.submenu?.items.forEach({ (menuItem) in
            menuItem.state = NSControl.StateValue(rawValue: 0);
        })
        menuItem.state = NSControl.StateValue(rawValue: 1);
        WallPaperSevice.sharedInstance.currentBingLocationSwitchState = menuItem.title;
        
    }
    fileprivate func updateLocationMenuItemState() {
        locationMenuItem?.submenu?.items.forEach({ (menuItem) in
            if(WallPaperSevice.LocationMap[menuItem.title] == WallPaperSevice.sharedInstance.currentBingLocationSwitchState){
                menuItem.state = NSControl.StateValue(rawValue: 1);
                return
            }
            
        })
    }
}

