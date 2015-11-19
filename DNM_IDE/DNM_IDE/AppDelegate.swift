//
//  AppDelegate.swift
//  DNM_IDE
//
//  Created by James Bean on 11/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var fileName: String?
    
    //var window: NSWindow!
    
    @IBAction func menuSelected(sender: NSMenuItem) {
        print("\(sender.title) was selected")

        
        if let fileName = fileName {
            // don't open save panel
        }
        else {
            // open it
            let savePanel = NSSavePanel()
            savePanel.beginWithCompletionHandler { (result: Int) -> () in
                if result == NSFileHandlingPanelOKButton {
                    print("ok: \(savePanel.nameFieldStringValue)")
                    
                }
                else {
                    print("cancel")
                }
            }
        }
        
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /*
        let height = NSScreen.mainScreen()?.frame.height ?? 800
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: height),
            styleMask: NSTitledWindowMask
                | NSClosableWindowMask
                | NSMiniaturizableWindowMask
                | NSResizableWindowMask,
            backing: NSBackingStoreType.Buffered,
            `defer`: true
        )
        
        let textView = NSTextView(frame: window.frame)
        textView.string = "hello"
        window.contentView!.addSubview(textView)
        
        window.contentView!.autoresizesSubviews = true
        textView.autoresizingMask = [
            NSAutoresizingMaskOptions.ViewHeightSizable,
            NSAutoresizingMaskOptions.ViewWidthSizable
        ]
        
        let controller = NSWindowController(window: window)
        window.makeKeyAndOrderFront(window)
        */
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    
}

