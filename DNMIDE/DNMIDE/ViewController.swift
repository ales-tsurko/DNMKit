//
//  ViewController.swift
//  DNMIDE
//
//  Created by James Bean on 11/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {

    var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView = NSTextView(frame: view.frame)
        textView.delegate = self
        textView.richText = true
        textView.textStorage!.delegate = self
        textView.font = NSFont(name: "Menlo", size: 12)
        view.addSubview(textView)
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func textDidChange(notification: NSNotification) {
    
        print(notification)
        
        if let string = textView.textStorage?.string {
            let tokenizer = Tokenizer()
            let container = tokenizer.tokenizeString(string)
            print(container)
            
            for token in container.tokens {
                colorRangeWithToken(token)
            }
            
            /*
            for token in container.tokens {
                switch token.identifier {
                case "Measure":
                    let length = token.stopIndex - token.startIndex + 1
                    let range = NSMakeRange(token.startIndex, length)
                    let color = NSColor.redColor()
                    textView.textStorage!.removeAttribute(NSForegroundColorAttributeName, range: range)
                    textView.setTextColor(color, range: range)
                case "Articulation":
                    print(token)
                    let start = token.startIndex
                    let length = 1
                    let range = NSMakeRange(start, length)
                    let color = NSColor.greenColor()
                    textView.setTextColor(color, range: range)
                case "ArticulationArgument":
                    let start = token.startIndex
                    let length = 1
                    let range = NSMakeRange(start, length)
                    let color = NSColor.blueColor()
                    textView.setTextColor(color, range: range)
                default: break
                }
            }
            */
        }
    }
    
    func colorRangeWithToken(token: Token) {

        print("color range with token: \(token)")
        
        let start = token.startIndex
        let length = token.stopIndex - token.startIndex + 1
        
        if length >= 0 {
            let range = NSMakeRange(start, length)
            
            let colorByIdentifier: [String : NSColor] = [
                "Measure": NSColor.grayColor(),
                "DurationNodeStackMode": NSColor.grayColor(),
                "Pitch": NSColor.redColor(),
                "Articulation": NSColor.blueColor(),
                "RootDuration": NSColor.purpleColor(),
                "LeafNodeDuration": NSColor.purpleColor(),
                "InternalNodeDuration": NSColor.purpleColor(),
                "PerformerID": NSColor.orangeColor(),
                "InstrumentID": NSColor.orangeColor(),
                "PerformerDeclaration": NSColor.yellowColor(),
                "SlurStart": NSColor.yellowColor(),
                "SlurStop": NSColor.yellowColor()
            ]
            
            let color = colorByIdentifier[token.identifier] ?? NSColor.blackColor()

            textView.setTextColor(color, range: range)
        }
    }
}




































