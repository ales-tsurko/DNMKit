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
        
        print("save file")
        
        if let vc = NSApplication
            .sharedApplication()
            .keyWindow?
            .contentViewController as? ViewController
        {
            
            // make method: saveToLocalDirectory()
            // user chosen directory
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
            
            // make method:
            // parse datastore
            if let string = vc.textView.textStorage?.string {
                

                // temp
                let scoreModel = Parser().parseTokenContainer(Tokenizer().tokenizeString(string))
                
                print("scoremodel: \(scoreModel)")
                
                let title = scoreModel.metadata["Title"] ?? fileName
                
                if let _ = string.dataUsingEncoding(NSUTF8StringEncoding) {
                    //print("scoreData: \(scoreData)")
                    //let scoreFile = PFFile(data: scoreData)
                    let score = PFObject(className: "Score")
                    score["username"] = PFUser.currentUser()?.username
                    score["title"] = title
                    score["text"] = string
                    //score["score"] = scoreFile
                    do {
                        try score.save()
                    }
                    catch {
                        print("couldnt save: \(error)")
                    }
                }
            }
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

