//
//  AppDelegate.swift
//  DNMIDE
//
//  Created by James Bean on 11/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let newWindow = NSWindow(contentRect:
        NSRect(x: 0, y: 0, width: 400, height: NSScreen.mainScreen()?.frame.height ?? 800),
        styleMask: NSTitledWindowMask | NSResizableWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask,
        backing: NSBackingStoreType.Buffered, `defer`: false
    )
    
    func createNewWindow() {
        let screenHeight = NSScreen.mainScreen()?.frame.height ?? 800
        newWindow.title = "dnm"
        newWindow.opaque = false
        newWindow.movableByWindowBackground = true
        newWindow.backgroundColor = NSColor(calibratedHue: 0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        newWindow.makeKeyAndOrderFront(nil)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        createNewWindow()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

