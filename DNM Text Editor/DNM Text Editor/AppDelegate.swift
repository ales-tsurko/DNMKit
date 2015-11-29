//
//  AppDelegate.swift
//  DNM_IDE
//
//  Created by James Bean on 11/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa
import DNMModel
import Parse
import Bolts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // make the transient nature of these things more apparent
    var fileName: String?
    var fileURL: NSURL?
    var string: String = ""
    
    @IBAction func openMenuItemSelected(sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.beginWithCompletionHandler { (result: Int) -> () in
            
        }
    }
    
    
    @IBAction func saveAsMenuItemSelected(sender: NSMenuItem) {
     
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
        
        // don't think this is the best way to do this...
        if let vc = NSApplication
            .sharedApplication()
            .keyWindow?
            .contentViewController as? ViewController
        {
            if let string = vc.textView.textStorage?.string {
                saveFileToLocalDirectoryWithString(string)
                saveFileToParseWithString(string)
            }
        }
    }
    
    func saveFileToParseWithString(string: String) {

        // temp
        let scoreModel = Parser().parseTokenContainer(Tokenizer().tokenizeString(string))
        let title = scoreModel.metadata["Title"] ?? fileName
        
        let score = PFObject(className: "Score")
        score["username"] = PFUser.currentUser()?.username
        score["title"] = title
        score["text"] = string
        do {
            try score.save()
        }
        catch {
            print("couldnt save: \(error)")
        }
        
        // create scoreFile (PFFile) with NSData
        // current issue: must save PFFile
        // -- before saving the PFObject it is associated with
        // haven't gotten that working yet
        // if let _ = string.dataUsingEncoding(NSUTF8StringEncoding) { }
        
    }
    
    func saveFileToLocalDirectoryWithString(string: String) {
        if let fileURL = fileURL {
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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

