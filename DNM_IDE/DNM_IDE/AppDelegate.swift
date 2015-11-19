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
    
    @IBAction func menuSelected(sender: NSMenuItem) {
        print("\(sender.title) was selected")

        
        
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
        
        print("URL: \(fileURL)")
        // get text file
        if let vc = NSApplication
            .sharedApplication()
            .keyWindow?
            .contentViewController as? ViewController
        {
            print("view controller? : \(vc)")
            if let string = vc.textView.textStorage?.string {
                print(string)
                
                if let fileURL = fileURL {
                    let filePath = fileURL.absoluteString
                    do {
                        print("saving path: \(string) at path: \(filePath)")
                        try string.writeToURL(fileURL, atomically: false, encoding: NSUTF8StringEncoding)
                        //try string.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
                    }
                    catch let error {
                        print("couldn't save: \(error)")
                    }
                }
                
                /*
                if let dir : NSString = NSSearchPathForDirectoriesInDomains(
                    NSSearchPathDirectory.DocumentDirectory,
                    NSSearchPathDomainMask.AllDomainsMask,
                    true
                ).first
                {
                    let path = dir.stringByAppendingPathComponent(fileName!);

                    do {
                        try string.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                    }
                    catch {
                        print("couldn't save")
                    }
                    
                    /*
                    //reading
                    do {
                        let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                    }
                    catch {/* error handling here */}
                    */
                }
                */
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

