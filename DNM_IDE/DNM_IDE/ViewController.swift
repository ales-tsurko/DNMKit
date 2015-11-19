//
//  ViewController.swift
//  DNMIDE
//
//  Created by James Bean on 11/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa
import DNMModel

struct Line {
    let string: String
    let startIndex: Int
    let stopIndex: Int
    var length: Int { return (stopIndex - startIndex) + 1 }
    var range: NSRange { return NSMakeRange(startIndex, length) }
}

class ViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {

    var textView: NSTextView!
    var fileTokenizer = Tokenizer()
    var currentLine: Line?
    
    let defaultFont: NSFont = NSFont(name: "Menlo", size: 12)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenHeight = 800
        view.frame = CGRect(x: 0, y: 0, width: 400, height: screenHeight)
        textView = NSTextView(frame: view.frame)
        
        textView.delegate = self
        textView.richText = true
        textView.textStorage!.delegate = self
        textView.font = defaultFont
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
    
    func textDidChange(notification: NSNotification) {

        setCurrentLineWithCurrentSelection()
        setDefaultStyleForCurrentLine()
        highlightCurrentLine()
    }
    
    func setDefaultStyleForCurrentLine() {
        guard let currentLine = currentLine else { return }
        textView.setFont(defaultFont, range: currentLine.range)
        // deal with fgcolor, bgcolor, bold, italic,
    }
    
    func highlightCurrentLine() {
        guard let currentLine = currentLine else { return }
        let tokenizer = Tokenizer()
        let tokenContainer = tokenizer.tokenizeString(currentLine.string)
        print("highlight line --------------------------------------------------------")
        traverseToColorRangeWithToken(tokenContainer, andIdentifierString: "")
    }
    
    func setCurrentLineWithCurrentSelection() {
        let i = textView.selectedRange().location
        if let (lineCount, lineStartIndex) = lineCountAndLineStartIndexOfLineContainingIndex(i),
            lineStopIndex = lineStopIndexOfLineContainingIndex(i),
            textStorage = textView.textStorage where textStorage.string.characters.count > 0
        {
            let string = textView.textStorage!.string[lineStartIndex...lineStopIndex]
            currentLine = Line(
                string: string, startIndex: lineStartIndex, stopIndex: lineStopIndex
            )
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
        guard let currentLine = currentLine else { return }
        
        let identifierString: String
        switch inheritedIdentifierString {
        case ".root": identifierString = token.identifier
        default: identifierString = inheritedIdentifierString + ".\(token.identifier)"
        }
        
        print("identifierString: \(identifierString)")
        
        let styleSheet = SyntaxHighlighter.StyleSheet.sharedInstance
        if let container = token as? TokenContainer {
            
            
            
            let start = token.startIndex + currentLine.startIndex
            let stop = token.stopIndex + currentLine.startIndex
            let length = stop - start + 1
            
            print("token start: \(start); stop: \(stop)")
            
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
            
            let start = token.startIndex + currentLine.startIndex
            let stop = token.stopIndex + currentLine.startIndex
            let length = stop - start + 1
            
            print("token start: \(start); stop: \(stop)")
            
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

