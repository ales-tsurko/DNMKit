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
    var fileTokenizer = Tokenizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenHeight = 800
        view.frame = CGRect(x: 0, y: 0, width: 400, height: screenHeight)
        textView = NSTextView(frame: view.frame)
        
        textView.delegate = self
        textView.richText = true
        textView.textStorage!.delegate = self
        textView.font = NSFont(name: "Menlo", size: 12)
        textView.automaticDashSubstitutionEnabled = false
        view.addSubview(textView)
        
        // make a static var : SyntaxHighlighter
        //let styleSheet = SyntaxHighlighter.StyleSheet.sharedInstance
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
        
        let range = NSMakeRange(0, textView.textStorage!.characters.count)
        textView.setTextColor(NSColor.blackColor(), range: range)
        
        let i = textView.selectedRange().location
        if let (lineCount, lineStartIndex) = lineCountAndLineStartIndexOfLineContainingIndex(i) {
            
            if let lineStopIndex = lineStopIndexOfLineContainingIndex(i) {
                
                print("lineCount: \(lineCount), lineStartIndex: \(lineStartIndex); lineStopIndex: \(lineStopIndex)")
                
                let len = (lineStopIndex - lineStartIndex) + 1
                let lineRange = NSMakeRange(lineStartIndex, len)
                print(lineRange)
                
                self.textView.setTextColor(NSColor.redColor(), range: lineRange)
            }
        }
        
        
        
        
        /*
        // do this with NSScanner?

        // make func: rangeOfCurrentlySelectedLine() -> (Int, Int)
        // two internal funcs:  (lineCount,lineStartIndex), and lineStopIndex
        
        var lc = 0 // rename as lineCount in context
        var lsi = 0 // rename as lineStartIndex in context
        
        guard let textStorage = textView.textStorage where textStorage.characters.count > 0
            else { return }
        
        let newLineScanner = NSScanner(string: textStorage.string)
        print("string: \(newLineScanner.string)")
        newLineScanner.charactersToBeSkipped = nil
        
        // get count of current line, and start index of current line
        
        var str: NSString?
        while newLineScanner.scanLocation < selectionRange.location {
            if newLineScanner.scanString("\n", intoString: &str) {
                lc++
                lsi = newLineScanner.scanLocation - 1
            } else {
                newLineScanner.scanLocation++
            }
        }
        
        // get stop index of current line
        // get stopIndexOfLine
        newLineScanner.scanLocation == selectionRange.location
        newLineScanner.scanUpToString("\n", intoString: &str)
        let lstopi = newLineScanner.scanLocation - 1

        var lineCount = 0
        var lineStartIndex: Int = 0
        for i in 0..<selectionRange.location {
            if textView.textStorage?.string[i] == "\n" {
                lineCount++
                lineStartIndex = i
            }
        }
        
        var lineStopIndex: Int = -1
        for i in selectionRange.location..<textView.textStorage!.characters.count {
            if textView.textStorage?.string[i] == "\n" {
                lineStopIndex = i - 1
                break
            }
        }
        if lineStopIndex == -1 {
            lineStopIndex = textView.textStorage!.characters.count - 1
        }
        */
        
        /*
        print("lineCount: \(lineCount); lc: \(lc); lineStartIndex: \(lineStartIndex);  lsi: \(lineStartIndex); lineStopIndex: \(lineStopIndex); lstopi: \(lstopi)")
        

        
        let tokenizer = Tokenizer()
        
        // sloppy
        guard textView.textStorage != nil && textView.textStorage!.characters.count > 0 else { return
        }
        let string = textView.textStorage!.string[lineStartIndex...lineStopIndex]
        
        let tokenContainer = tokenizer.scanLine(string, startingAtIndex: lineStartIndex)
        print(tokenContainer)
        */
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            
            /*
            if let string = self.textView.textStorage?.string {
                let tokenizer = Tokenizer()
                let tokenContainer = tokenizer.tokenizeString(string)
        
                dispatch_async(dispatch_get_main_queue()) {
                    for token in tokenContainer.tokens {
                        self.traverseToColorRangeWithToken(tokenContainer, andIdentifierString: "")
                    }
                }
            }
            */
        }
    }
    
    // really, we should build up lines
    
    func lineCountAndLineStartIndexOfLineContainingIndex(index: Int) -> (Int, Int)? {
        
        if let textStorage = textView.textStorage where textStorage.characters.count > 0 {

            // create scanner that looks for newline strings
            let scanner = NSScanner(string: textStorage.string)
            scanner.charactersToBeSkipped = nil
            
            var lineCount = 0
            var lineStartIndex = 0
            
            var str: NSString?
            while scanner.scanLocation < index {
                if scanner.scanString("\n", intoString: &str) {
                    lineCount++
                    lineStartIndex = scanner.scanLocation - 1
                } else {
                    scanner.scanLocation++
                }
            }
            return (lineCount, lineStartIndex)
        }
        return nil
    }
    
    func lineStopIndexOfLineContainingIndex(index: Int) -> Int? {
        // get line start index
        guard textView.textStorage != nil && textView.textStorage!.characters.count > 0 else {
            return nil
        }
        
        if let (_, lineStartIndex) = lineCountAndLineStartIndexOfLineContainingIndex(index) {
            let textStorage = textView.textStorage!
            let scanner = NSScanner(string: textStorage.string)
            scanner.charactersToBeSkipped = nil
            scanner.scanLocation = index
            
            var str: NSString?
            scanner.scanUpToString("\n", intoString: &str)
            return scanner.scanLocation - 1
        }
        return nil
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

