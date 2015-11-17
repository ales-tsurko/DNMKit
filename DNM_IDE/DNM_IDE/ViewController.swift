//
//  ViewController.swift
//  DNMIDE
//
//  Created by James Bean on 11/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa
import DNMModel

class ViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {

    var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenHeight = 800
        
        
        view.frame = CGRect(x: 0, y: 0, width: 400, height: screenHeight)
        textView = NSTextView(frame: view.frame)
        
        print("textview.frame: \(textView.frame)")

        /*
        let hConstraint = NSLayoutConstraint(
            item: textView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: 0
        )
        */
        
        //view.addConstraint(hConstraint)

        //NSLayoutConstraint.activateConstraints([hConstraint])
        
        textView.delegate = self
        textView.richText = true
        textView.textStorage!.delegate = self
        textView.font = NSFont(name: "Menlo", size: 12)
        textView.automaticDashSubstitutionEnabled = false
        view.addSubview(textView)
        
        let styleSheet = SyntaxHighlighter.StyleSheet.sharedInstance
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // func getLineAtIndex(index: Int) -> Int { // get index from selectionRange }
    
    // do on background thread, do tokenization of everything
    // but main thread to just the line
    // or find the correct insertion point
    // and insert the next tokens where necessary

    func textDidChange(notification: NSNotification) {
        
        
        let selectionRange = textView.selectedRange()
        //print("selectionRange: \(selectionRange)")
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            
            if let string = self.textView.textStorage?.string {
                let tokenizer = Tokenizer()
                let tokenContainer = tokenizer.tokenizeString(string)
        
                print(tokenContainer)
                
                dispatch_async(dispatch_get_main_queue()) {
                    for token in tokenContainer.tokens {
                        self.traverseToColorRangeWithToken(tokenContainer, andIdentifierString: "")
                    }
                }
            }
        }
    }
    
    func traverseToColorRangeWithToken(token: Token,
        andIdentifierString inheritedIdentifierString: String
    )
    {
        
        
        let identifierString: String
        switch inheritedIdentifierString {
        case ".root": identifierString = token.identifier
        default: identifierString = inheritedIdentifierString + ".\(token.identifier)"
        }
        
        let styleSheet = SyntaxHighlighter.StyleSheet.sharedInstance
        if let container = token as? TokenContainer {

            let start = token.startIndex
            let length = token.stopIndex - token.startIndex + 1
            let range = NSMakeRange(start, length)
            
            if let foregroundColor = styleSheet[identifierString]["foregroundColor"].array {
                
                let hue = CGFloat(foregroundColor[0].floatValue)
                let saturation = CGFloat(foregroundColor[1].floatValue)
                let brightness = CGFloat(foregroundColor[2].floatValue)
                
                let color = NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
                textView.setTextColor(color, range: range)
            }
            
            for token in container.tokens {
                traverseToColorRangeWithToken(token, andIdentifierString: identifierString)
            }
        }
        else {


            // set style defaults up here
            var isBold: Bool = false
            var foregroundColor: NSColor = NSColor.blackColor()
            
            let start = token.startIndex
            let length = token.stopIndex - token.startIndex + 1
            let range = NSMakeRange(start, length)

            
            if let foregroundColor = styleSheet[identifierString]["foregroundColor"].array {
                
                let hue = CGFloat(foregroundColor[0].floatValue)
                let saturation = CGFloat(foregroundColor[1].floatValue)
                let brightness = CGFloat(foregroundColor[2].floatValue)
                
                let color = NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)

                
                textView.setTextColor(color, range: range)

                
                //print("foregroundColor: \(foregroundColor)")
            }
            
            let fontManager = NSFontManager.sharedFontManager()
            if let isBold = styleSheet[identifierString]["isBold"].bool where isBold {
                
                //print("SHOULD BE BOLD!")
                let boldFont = fontManager.fontWithFamily("Menlo", traits: NSFontTraitMask.BoldFontMask, weight: 0, size: 12)!
                textView.setFont(boldFont, range: range)
            }
            else {
                
                //print("NOT BOLD")
                let font = fontManager.fontWithFamily("Menlo", traits: NSFontTraitMask.UnboldFontMask, weight: 0, size: 12)!
                textView.setFont(font, range: range)
            }
            

            
            /*
            let start = token.startIndex
            let length = token.stopIndex - token.startIndex + 1
            
            if length >= 0 {
                let range = NSMakeRange(start, length)
                let colorByIdentifier: [String : NSColor] = [
                    "Measure": NSColor.grayColor(),
                    "DurationNodeStackMode": NSColor.grayColor(),
                    "Articulation": NSColor.blueColor(),
                    "RootDuration": NSColor.purpleColor(),
                    "LeafNodeDuration": NSColor.purpleColor(),
                    "InternalNodeDuration": NSColor.purpleColor(),
                    "PerformerID": NSColor.orangeColor(),
                    "InstrumentID": NSColor.orangeColor(),
                    "PerformerDeclaration": NSColor.yellowColor(),
                    
                ]
                let color = colorByIdentifier[token.identifier] ?? NSColor.blackColor()
                textView.setTextColor(color, range: range)
            }
            */
        }
    }
    
    /*
    func colorRangeWithToken(token: Token) {

        //print("color range with token: \(token)")
        
        if let container = token as? TokenContainer {
            
            print("container: \(token)")
            let start = token.startIndex
            let length = token.stopIndex - token.startIndex + 1
            
            if length >= 0 {
                let range = NSMakeRange(start, length)
                let colorByIdentifier: [String : NSColor] = [
                    "Pitch": NSColor.redColor(),
                    "MIDIValue": NSColor.orangeColor(),
                    "SlurStart": NSColor.yellowColor(),
                    "SlurStop": NSColor.yellowColor(),
                    "Articulation": NSColor.redColor(),
                    "ArticulationMarking": NSColor.redColor()
                ]
                let color = colorByIdentifier[token.identifier] ?? NSColor.blackColor()
                textView.setTextColor(color, range: range)
            }
        }
        else {
            let start = token.startIndex
            let length = token.stopIndex - token.startIndex + 1
            
            if length >= 0 {
                let range = NSMakeRange(start, length)
                let colorByIdentifier: [String : NSColor] = [
                    "Measure": NSColor.grayColor(),
                    "DurationNodeStackMode": NSColor.grayColor(),
                    "Articulation": NSColor.blueColor(),
                    "RootDuration": NSColor.purpleColor(),
                    "LeafNodeDuration": NSColor.purpleColor(),
                    "InternalNodeDuration": NSColor.purpleColor(),
                    "PerformerID": NSColor.orangeColor(),
                    "InstrumentID": NSColor.orangeColor(),
                    "PerformerDeclaration": NSColor.yellowColor(),

                ]
                let color = colorByIdentifier[token.identifier] ?? NSColor.blackColor()
                textView.setTextColor(color, range: range)
            }
        }
    }
    */
}

