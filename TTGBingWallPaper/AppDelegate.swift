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
        menu.addItem(withTitle: NSLocalizedString("NEWEST",comment:""), action: #selector(menuItemNewestWallPaperClick), keyEquivalent: "n")
        // Refresh random wall paper
        menu.addItem(withTitle: NSLocalizedString("RANDOM",comment:""), action: #selector(menuItemRandomWallPaperClick), keyEquivalent: "r")
        // Copyright
        menu.addItem(withTitle: NSLocalizedString("PHOTOINFO",comment:""), action: #selector(menuItemCopyrightClick), keyEquivalent: "i")
        
        
        // Sub menu
        let subMenu = NSMenu()
        
        WallPaperSevice.LocationMap.sorted(by: <) .forEach { (_ key:String,_ value:String) in
            let locationMenuItem = NSMenuItem(title: NSLocalizedString(key,comment:""), action: #selector(switchLocationMenuItemState), keyEquivalent: "")
            locationMenuItem.representedObject = key
            subMenu.addItem(locationMenuItem)
        }
        
        locationMenuItem = NSMenuItem()
        locationMenuItem?.title = NSLocalizedString("LOCAL",comment:"")
        locationMenuItem?.submenu = subMenu
        locationMenuItem?.keyEquivalent = "g"
        menu.addItem(locationMenuItem!)
        updateLocationMenuItemState()
        
        // Auto update
        autoUpdateMenuItem = NSMenuItem(title: NSLocalizedString("AUTOUPDATE",comment:""), action: #selector(menuItemAutoUpdateClick), keyEquivalent: "e")
        autoUpdateMenuItem?.toolTip = NSLocalizedString("AUTOUPDATE.TIP",comment:"")
        autoUpdateMenuItem?.onStateImage = NSImage(named: "checked")
        autoUpdateMenuItem?.offStateImage = nil
        updateAutoUpdateMenuItemState()
        menu.addItem(autoUpdateMenuItem!)
        
        // Launch at startup
        launchAtStartupMenuItem = NSMenuItem(title: NSLocalizedString("LAUNCH",comment:""), action: #selector(menuItemLaunchAtStartupClick), keyEquivalent: "")
        launchAtStartupMenuItem?.toolTip = NSLocalizedString("LAUNCH.TIP",comment:"")
        launchAtStartupMenuItem?.onStateImage = NSImage(named: "checked")
        launchAtStartupMenuItem?.offStateImage = nil
        updateLaunchAtStartupMenuItemState()
        menu.addItem(launchAtStartupMenuItem!)
        
        // Open WallPaper folder
        menu.addItem(withTitle: NSLocalizedString("HISTORY",comment:""), action: #selector(menuItemOpenWallPapersFolderClick), keyEquivalent: "f")
        
        // Github
        //subMenu.addItem(withTitle: "Github", action: #selector(menuItemGithubClick), keyEquivalent: "");
        
        // About
        menu.addItem(withTitle: NSLocalizedString("ABOUT",comment:""), action: #selector(menuItemAboutClick), keyEquivalent: "a")
        
        // Quit
        menu.addItem(withTitle: NSLocalizedString("QUIT",comment:""), action: #selector(menuItemQuitClick), keyEquivalent: "q")
        
        statusItem.menu = menu
    }
    
    // MARK: Actions
    
    @objc func menuItemLaunchAtStartupClick() {
        StartupHelper.toggleLaunchAtStartup()
        updateLaunchAtStartupMenuItemState()
        
        let subTitle:String = NSLocalizedString("MESSATE.SUBTITLE.AUTOUPDATE",comment:"")
        let open:String = StartupHelper.applicationIsInStartUpItems() ? NSLocalizedString("MESSATE.ON",comment:"") : NSLocalizedString("MESSATE.OFF",comment:"")
        
        UserNotificationHelper.show(NSLocalizedString("MESSATE.TITLE",comment:""), subTitle: String(format: "%s%s", subTitle,open), content: "")
    }
    
    @objc func menuItemAutoUpdateClick(local:String) {
        let state = WallPaperSevice.sharedInstance.currentAutoUpadteSwitchState
        
        let subTitle:String = NSLocalizedString("MESSATE.SUBTITLE.AUTOUPDATE",comment:"")
        let open:String = state ? NSLocalizedString("MESSATE.ON",comment:"") : NSLocalizedString("MESSATE.OFF",comment:"")
        
        UserNotificationHelper.show(NSLocalizedString("MESSATE.TITLE",comment:""), subTitle: String(format: "%s%s", subTitle,open), content: "")
        
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
        let local = menuItem.representedObject as! String
        WallPaperSevice.sharedInstance.currentBingLocationSwitchState = local;
        
    }
    fileprivate func updateLocationMenuItemState() {
        locationMenuItem?.submenu?.items.forEach({ (menuItem) in
            let local = menuItem.representedObject as! String
            if(WallPaperSevice.LocationMap[local] == WallPaperSevice.sharedInstance.currentBingLocationSwitchState){
                menuItem.state = NSControl.StateValue(rawValue: 1);
                return
            }
            
        })
    }
}

