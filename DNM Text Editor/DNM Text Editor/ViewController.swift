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

    @IBOutlet var textView: NSTextView!
    
    var fileTokenizer = Tokenizer()
    var currentLine: Line?
    
    let defaultFont: NSFont = NSFont(name: "Menlo", size: 12)!
    let defaultTextColor = NSColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextView()
    }
    
    private func setUpTextView() {
        textView.delegate = self
        textView.richText = true
        textView.textStorage!.delegate = self
        textView.font = defaultFont
        textView.automaticDashSubstitutionEnabled = false
        textView.automaticSpellingCorrectionEnabled = false
        textView.backgroundColor = NSColor(hue: 0, saturation: 0, brightness: 0.03, alpha: 1)
        textView.insertionPointColor = NSColor.whiteColor()
    }

    // move all of this else where
    func textDidChange(notification: NSNotification) {
        setCurrentLineWithCurrentSelection()
        setDefaultStyleForCurrentLine()
        highlightCurrentLine()
    }
    
    func setDefaultStyleForCurrentLine() {
        guard let currentLine = currentLine else { return }
        textView.setFont(defaultFont, range: currentLine.range)
        textView.setTextColor(defaultTextColor, range: currentLine.range)
        
        // USE idiom to manage background color (and maybe all of the attributes?)
        /*
        guard let textStorage = textView.textStorage else { return }
        
        let lightColor = NSColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
        textStorage.addAttribute(
            NSBackgroundColorAttributeName, value: lightColor, range: currentLine.range
        )
        */
        
        // deal with fgcolor, bgcolor, bold, italic,
    }
    
    func highlightCurrentLine() {
        guard let currentLine = currentLine else { return }
        let tokenizer = Tokenizer()
        let tokenContainer = tokenizer.tokenizeString(currentLine.string)
        traverseToColorRangeWithToken(tokenContainer, andIdentifierString: "")
    }
    
    func setCurrentLineWithCurrentSelection() {
        let i = textView.selectedRange().location
        if let (_, lineStartIndex) = lineCountAndLineStartIndexOfLineContainingIndex(i),
            lineStopIndex = lineStopIndexOfLineContainingIndex(i),
            textStorage = textView.textStorage where textStorage.string.characters.count > 0
        {
            // prevent crash
            if lineStopIndex > textStorage.string.characters.count - 1 { return }
            let string = textStorage.string[lineStartIndex...lineStopIndex]
            currentLine = Line(
                string: string, startIndex: lineStartIndex, stopIndex: lineStopIndex
            )
        }
    }
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
        guard textView.textStorage != nil && textView.textStorage!.characters.count > 0 else {
            return nil
        }
        
        // hmmm...
        if let (_, _) = lineCountAndLineStartIndexOfLineContainingIndex(index) {
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
        
        print("\(identifierString): \(token)")

        let styleSheet = SyntaxHighlighter.StyleSheet.sharedInstance
        if let container = token as? TokenContainer {
            
            // create range
            let start = token.startIndex + currentLine.startIndex
            let stop = token.stopIndex + currentLine.startIndex
            let length = stop - start + 1
            let range = NSMakeRange(start, length)
            
            // encapsulate this: set style for range // get isBold
            if let foregroundColor = styleSheet[identifierString]["foregroundColor"].array {
                
                let hue = CGFloat(foregroundColor[0].floatValue)
                let saturation = CGFloat(foregroundColor[1].floatValue)
                let brightness = CGFloat(foregroundColor[2].floatValue)
                let color = NSColor(
                    calibratedHue: hue,
                    saturation: saturation,
                    brightness: brightness,
                    alpha: 1
                )
                textView.setTextColor(color, range: range)
            }
            
            for token in container.tokens {
                traverseToColorRangeWithToken(token, andIdentifierString: identifierString)
            }
        }
        else {
            
            /*
            // set style defaults up here
            var isBold: Bool = false
            var foregroundColor: NSColor = NSColor.blackColor()
            */
            
            // make range
            let start = token.startIndex + currentLine.startIndex
            let stop = token.stopIndex + currentLine.startIndex
            let length = stop - start + 1
            let range = NSMakeRange(start, length)
            
            if let foregroundColor = styleSheet[identifierString]["foregroundColor"].array {
                let hue = CGFloat(foregroundColor[0].floatValue)
                let saturation = CGFloat(foregroundColor[1].floatValue)
                let brightness = CGFloat(foregroundColor[2].floatValue)
                let color = NSColor(
                    hue: hue, saturation: saturation, brightness: brightness, alpha: 1
                )
                textView.setTextColor(color, range: range)
            }
            
            
            let fontManager = NSFontManager.sharedFontManager()
            if let isBold = styleSheet[identifierString]["isBold"].bool where isBold {
                let boldFont = fontManager.fontWithFamily("Menlo", traits: NSFontTraitMask.BoldFontMask, weight: 0, size: 12)!
                textView.setFont(boldFont, range: range)
            }
            else {
                let font = fontManager.fontWithFamily("Menlo",
                    traits: NSFontTraitMask.UnboldFontMask, weight: 0, size: 12
                )!
                textView.setFont(font, range: range)
            }
        }
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

