//
//  AppDelegate.swift
//  DNM_IDE
//
//  Created by James Bean on 11/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa
import Parse
import Bolts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var fileName: String?
    var fileURL: NSURL?
    var string: String = ""
    
    @IBAction func openMenuItemSelected(sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.beginWithCompletionHandler { (result: Int) -> () in
            
        }
    }
    
    @IBAction func saveMenuItemSelected(sender: NSMenuItem) {
        
        if fileName != nil { self.saveFile() }
        else {
            // open the save panel
            let savePanel = NSSavePanel()
            savePanel.beginWithCompletionHandler { (result: Int) -> () in
                if result == NSFileHandlingPanelOKButton {
                    self.fileName = savePanel.nameFieldStringValue
                    self.fileURL = savePanel.URL
                    self.saveFile()
                }
                else {
                    // cancel
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
                    print(error)
                }
            }
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Parse.enableLocalDatastore()
        
        // connect to DNM app on Parse
        Parse.setApplicationId("C0t9tBbniTyxCSkyhkG06uJM7lUQ8Cbhl8qMQz7L",
            clientKey: "wHC4msb5rU8MhUF0E3GW0sJbTgLU5yA3x5WUAGlS"
        )
        
        // should i do this? seems weird, and not helpful ... yet?
        //PFAnalytics.trackAppOpenedWithLaunchOptions(nil)


    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func application(sender: NSApplication, openFile filename: String) -> Bool {
        print("application open file")
        return false
    }
    
}

