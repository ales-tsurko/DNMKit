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
    var fileURL: NSURL?
    var string: String = ""
    
    @IBAction func openMenuItemSelected(sender: NSMenuItem) {
        print("open")
        let openPanel = NSOpenPanel()
        openPanel.beginWithCompletionHandler { (result: Int) -> () in
            
        }
    }
    
    @IBAction func saveMenuItemSelected(sender: NSMenuItem) {
        
        if let fileName = fileName {
            self.saveFile()
        }
        else {
            // open it
            let savePanel = NSSavePanel()
            savePanel.beginWithCompletionHandler { (result: Int) -> () in
                if result == NSFileHandlingPanelOKButton {
                    self.fileName = savePanel.nameFieldStringValue
                    self.fileURL = savePanel.URL

                    print("ok: fileURL: \(self.fileURL)")
                    self.saveFile()
                }
                else {
                    print("cancel")
                }
            }
        }
    }
    
    func saveFile() {

        if let vc = NSApplication
            .sharedApplication()
            .keyWindow?
            .contentViewController as? ViewController
        {
            if let string = vc.textView.textStorage?.string, fileURL = fileURL {
                do {
                    try string.writeToURL(fileURL,
                        atomically: false,
                        encoding: NSUTF8StringEncoding
                    )
                }
                catch let error {
                    print("couldn't save: \(error)")
                }
            }
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func application(sender: NSApplication, openFile filename: String) -> Bool {
        print("application open file")
        return false
    }
    
}
