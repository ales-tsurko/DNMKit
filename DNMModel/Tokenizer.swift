//
//  Tokenizer.swift
//  Tokenizer3
//
//  Created by James Bean on 11/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

// At some point, find way to inject new commands and argument types in here dynamically
public class Tokenizer {
    
    private let newLineCharacterSet = NSCharacterSet.newlineCharacterSet()
    private let letterCharacterSet = NSCharacterSet.letterCharacterSet()
    
    private var lineCount: Int = 0
    private var lineStartIndex: Int = 0
    private var index: Int = 0
    private var isInBlockComment: Bool = false
    
    private var indentationLevelByLine: [Int] = []
    
    private var currentIndentationLevel: Int { return indentationLevelByLine[lineCount] }
    
    public init() { }
    
    public func tokenizeString(string: String) -> TokenContainer {
        
        // the string for the current line
        var lineString: NSString? // probably rename this to lineString
        
        // main scanner that reads one line at a time
        let mainScanner = NSScanner(string: string)
        mainScanner.charactersToBeSkipped = nil
        
        let rootTokenContainer = TokenContainer(identifier: "root", startIndex: 0)
        
        // CLEAN UP
        while !mainScanner.atEnd {
            
            if mainScanner.scanCharactersFromSet(newLineCharacterSet, intoString: &lineString) {
                lineCount++
                let lineLength = lineString!.length
                lineStartIndex += lineLength
                indentationLevelByLine.append(0)
            }
            else {
                while mainScanner.scanUpToCharactersFromSet(newLineCharacterSet,
                    intoString: &lineString)
                {
                    
                    let lineLength = lineString!.length
                    
                    // Set indentation level by line
                    let indentationLevel = indentationLevelWithLine(lineString as! String)
                    indentationLevelByLine.append(indentationLevel)
                    
                    // this is the scanner for the current line
                    let lineScanner = NSScanner(string: lineString as! String)
                    
                    lineScanner.charactersToBeSkipped = NSMutableCharacterSet.whitespaceCharacterSet()
                    lineScanner.caseSensitive = true
                    
                    scanCommentsWithScanner(lineScanner)
                    if isInBlockComment {
                        lineStartIndex += lineScanner.string.characters.count
                        continue
                    }
                    
                    // scan for performer declarations
                    scanPerformerDeclaractionWithScanner(lineScanner, andContainer: rootTokenContainer)
                    
                    // scan line for musical events
                    scanLineWithScanner(lineScanner, andContainer: rootTokenContainer)
                    
                    lineStartIndex += lineLength
                    lineCount++
                }
            }
        }
        return rootTokenContainer
    }
    
    private func indentationLevelWithLine(line: String) -> Int {
        let whitespaceScanner = NSScanner(string: line)
        whitespaceScanner.charactersToBeSkipped = nil

        var tabCount: Int = 0
        var spaceCount: Int = 0
        
        var string: NSString?
        while whitespaceScanner.scanString(" ", intoString: &string) {
            spaceCount++
        }

        while whitespaceScanner.scanString("\t", intoString: &string) {
            tabCount++
        }
        
        let indentationLevel = tabCount + (spaceCount / 4)
        return indentationLevel
    }
    
    private func scanLineWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        scanHeaderWithScanner(scanner, andContainer: container)
        scanMeasureWithScanner(scanner, andContainer: container)
        
        scanDurationNodeStackModeWithScanner(scanner, andContainer: container)
        scanDurationWithScanner(scanner, andContainer: container)
        scanLeafDurationWithScanner(scanner, andContainer: container)

        scanPitchCommandWithScanner(scanner, andContainer: container)
        scanArticulationCommandWithScanner(scanner, andContainer: container)
        scanDynamicCommandWithScanner(scanner, andContainer: container)
        scanSlurStartWithScanner(scanner, andContainer: container)
        scanSlurStopWithScanner(scanner, andContainer: container)
        
        scanExtensionStartWithScanner(scanner, andContainer: container)
        scanExtensionStopWithScanner(scanner, andContainer: container)

        scanPerformerIDAndInstrumentIDWithScanner(scanner, andContainer: container)
    }
    
    private func scanTopLevelCommandsWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        
    }
    
    private func scanExtensionStartWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var startIndex = scanner.scanLocation
        var string: NSString?
        if scanner.scanString("->", intoString: &string) {
            let token = TokenString(
                identifier: "ExtensionStart",
                value: "->",
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
        }
    }
    
    private func scanExtensionStopWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var startIndex = scanner.scanLocation
        var string: NSString?
        if scanner.scanString("<-", intoString: &string) {
            let token = TokenString(
                identifier: "ExtensionStop",
                value: "<-",
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
        }
    }
    
    
    
    private func scanHeaderWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    ) -> [String : String]
    {
        var startIndex = scanner.scanLocation

        var string: NSString?
        
        var dictionary: [String : String] = [:]
        
        if scanner.string.characters.contains(Character(":")) {
            
            // get key
            if scanner.scanUpToString(":", intoString: &string) {
                
                let key = string as! String
                
                // brush past the ":"
                scanner.scanLocation++
                
                let set = NSCharacterSet.newlineCharacterSet()
                scanner.scanUpToCharactersFromSet(set, intoString: &string)
                if let string = string {
                    let value = string as String
                    dictionary[key] = value
                }
            }
        }
        
        if dictionary.count == 0 {
            scanner.scanLocation = startIndex
            return [:]
        } else {
            return dictionary
        }
    }
    
    private func scanPerformerDeclaractionWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    ) -> OrderedDictionary<String, OrderedDictionary<String, String>>?
    {
        
        // Enum used to switch between InstrumentID and InstrumentType as they are declared
        enum InstrumentIDOrType {
            case ID
            case Type
            
            mutating func switchState() {
                switch self {
                case .ID: self = .Type
                case .Type: self = .ID
                }
            }
        }
        
        let startIndex = scanner.scanLocation
        
        var string: NSString?
        if scanner.scanString("P:", intoString: &string) {
        
            var performerID: String

            // DO ALL OF THE ORDERED DICT STUFF IN PARSER!
            var instrumentIDsAndInstrumentTypeByPerformerID = OrderedDictionary<
                String, OrderedDictionary<String, String>
            >()
            
            let letterCharacterSet = NSMutableCharacterSet.letterCharacterSet()
            
            // Match PerformerID declaration
            if scanner.scanCharactersFromSet(letterCharacterSet, intoString: &string) {
                
                // This is the PerformerID
                performerID = string as! String
                
                let performerDeclarationTokenContainer = TokenContainer(
                    identifier: "PerformerDeclaration",
                    openingValue: performerID,
                    startIndex: startIndex + lineStartIndex
                )
                
                instrumentIDsAndInstrumentTypeByPerformerID[performerID] = (
                    OrderedDictionary<String,String>()
                )
                
                var dictForPID = instrumentIDsAndInstrumentTypeByPerformerID[performerID]!
                
                var instrumentID: String!
                var instrumentType: String!
                
                // This enum alternates with each symbol found
                var instrumentIDOrType = InstrumentIDOrType.ID
                
                while true {
                    
                    let startIndex = scanner.scanLocation
                    
                    if scanner.scanCharactersFromSet(letterCharacterSet, intoString: &string) {
                        
                        switch instrumentIDOrType {
                        case .ID:
                            instrumentID = string as! String
                            
                            // Create Token for InstrumentID
                            let instrumentIDToken = TokenString(
                                identifier: "InstrumentID",
                                value: instrumentID,
                                startIndex: startIndex + lineStartIndex
                            )
                            
                            // Commit InstrumentID Token
                            performerDeclarationTokenContainer.addToken(instrumentIDToken)
                            
                            // Switch enum to .Type
                            instrumentIDOrType.switchState()
                        case .Type:
                            instrumentType = string as! String
                            
                            // Create Token for InstrumentType
                            let instrumentTypeToken = TokenString(
                                identifier: "InstrumentType",
                                value: instrumentType,
                                startIndex: startIndex + lineStartIndex
                            )
                            
                            // Commit InstrumentType Token
                            performerDeclarationTokenContainer.addToken(instrumentTypeToken)
                            
                            dictForPID[instrumentID] = instrumentType
                            
                            // Clear everything
                            instrumentID = nil
                            instrumentType = nil
                            
                            // Switch enum to .ID
                            instrumentIDOrType.switchState()
                        }
                    }
                    else {

                        // Commit PerformerDeclaration TokenContainer to root TokenContainer
                        container.addToken(performerDeclarationTokenContainer)
                        return instrumentIDsAndInstrumentTypeByPerformerID
                    }
                }
            }
        }
        return nil
    }
    
    private func scanSlurStartWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var startIndex = scanner.scanLocation
        var string: NSString?
        
        if scanner.scanString("(", intoString: &string) {
            let slurStartTokenContainer = TokenContainer(
                identifier: "SlurStart",
                openingValue: "(",
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(slurStartTokenContainer)
        }
    }
    
    private func scanSlurStopWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var string: NSString?
        
        if scanner.scanString(")", intoString: &string) {
            let slurStopTokenContainer = TokenContainer(
                identifier: "SlurStop",
                openingValue: ")",
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(slurStopTokenContainer)
        }
    }
    
    private func scanArticulationCommandWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var string: NSString?
        
        var articulationMarkings: [String] = []
        if scanner.scanString("a", intoString: &string) {
            let articulationTokenContainer = TokenContainer(
                identifier: "Articulation",
                openingValue: "a",
                startIndex: startIndex + lineStartIndex
            )
            var startIndex = scanner.scanLocation + 1
            let set = NSMutableCharacterSet(charactersInString: ".->")
            while scanner.scanCharactersFromSet(set, intoString: &string) {
                
                let token = TokenString(
                    identifier: "Value",
                    value: string as! String,
                    startIndex: startIndex + lineStartIndex
                )
                startIndex = scanner.scanLocation
                articulationTokenContainer.addToken(token)
            }
            container.addToken(articulationTokenContainer)
        }
    }
    
    // TODO: have these funcs return Bool
    private func scanPitchCommandWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var string: NSString?
        
        // TODO: add compatibility with note name convention -- convert to MIDI later
        if scanner.scanString("p", intoString: &string) {
            
            var startIndex = scanner.scanLocation
            
            // add tokenContainer to container
            var pitchTokenContainer = TokenContainer(
                identifier: "Pitch",
                startIndex: startIndex + lineStartIndex - 1
            )
            
            var floatValue: Float = 0.0
            while scanner.scanFloat(&floatValue) {
                let stopIndex = scanner.scanLocation
                
                let token = TokenFloat(
                    identifier: "Value",
                    value: floatValue,
                    startIndex: startIndex + lineStartIndex,
                    stopIndex: scanner.scanLocation + lineStartIndex - 1
                )
                pitchTokenContainer.addToken(token)
                startIndex = scanner.scanLocation
            }
            scanSpannerStartWithScanner(scanner, andContainer: pitchTokenContainer)
            scanSpannerStopWithScanner(scanner, andContainer: pitchTokenContainer)
            container.addToken(pitchTokenContainer)
        }
    }
    
    private func scanDynamicCommandWithScanner(scanner: NSScanner, andContainer container: TokenContainer) {

        var string: NSString?
        let startIndex: Int = scanner.scanLocation
        while scanner.scanString("d", intoString: &string) {
            let dynamicMarkingContainer = TokenContainer(
                identifier: "DynamicMarking",
                openingValue: "d",
                startIndex: startIndex + lineStartIndex
            )
            var dynamicMarking: String?
            let set = NSMutableCharacterSet(charactersInString: "opmf")
            let startIndex = scanner.scanLocation
            while scanner.scanCharactersFromSet(set, intoString: &string) {
                let token = TokenString(
                    identifier: "Value",
                    value: string as! String,
                    startIndex: startIndex + lineStartIndex + 1
                )
                dynamicMarkingContainer.addToken(token)
                dynamicMarking = string as? String
            }
            scanSpannerStopWithScanner(scanner, andContainer: dynamicMarkingContainer)
            scanSpannerStartWithScanner(scanner, andContainer: dynamicMarkingContainer)
            container.addToken(dynamicMarkingContainer)
        }
    }
    
    /*
    private func scanPerformerIDWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var performerID: String?
        var string: NSString?
        let set = NSCharacterSet.letterCharacterSet()
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            performerID = string as? String
            
            let token = TokenString(
                identifier: "PerformerID",
                value: performerID!,
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
        }
        
        if performerID == nil || performerID!.characters.count != 2 {
            scanner.scanLocation = startIndex
            return
        }
    }
    */
    
        /*
    private func scanInstrumentIDWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var instrumentID: String?
        var string: NSString?
        let set = NSCharacterSet.letterCharacterSet()
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            instrumentID = string as? String
            
            let token = TokenString(
                identifier: "InstrumentID",
                value: instrumentID!,
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
        }
        
        if instrumentID == nil || instrumentID!.characters.count != 2 {
            scanner.scanLocation = startIndex
            return
        }
    }
    */
    
    private func scanPerformerIDAndInstrumentIDWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        
        // Enum used to switch between PerformerID and InstrumentID
        enum PIDOrIID {
            case PID
            case IID
            
            mutating func switchState() {
                switch self {
                case .PID: self = .IID
                case .IID: self = .PID
                }
            }
        }
        
        var startIndex = scanner.scanLocation + 1
        
        var identifier: String
        var id: String?
        var pIDOrIID = PIDOrIID.PID
        var isComplete: Bool = false
        var string: NSString?
        while scanner.scanCharactersFromSet(letterCharacterSet, intoString: &string) {
            
            
            
            switch pIDOrIID {
            case .PID:
                identifier = "PerformerID"
                id = string as? String
                pIDOrIID.switchState()
                
            case .IID:
                identifier = "InstrumentID"
                id = string as? String

                // Once a pair of PID and IID is found, break out of loop
                isComplete = true
            }
            
            let token = TokenString(
                identifier: identifier,
                value: id!,
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
            
            startIndex = scanner.scanLocation + 1
            if isComplete { break }
        }
    }
    
    
    
    // Find best way to generalize this process!
    private func scanSpannerStartWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {

        let startIndex = scanner.scanLocation

        var string: NSString?
        
        // order of commands is enforced
        if scanner.scanString("[", intoString: &string) {
            
            var spannerTokenContainer = TokenContainer(
                identifier: "SpannerStart",
                openingValue: "[",
                startIndex: startIndex + lineStartIndex
            )
            
            // scanExponent
            while scanner.scanString("^", intoString: &string) {
                
                // dangerous!
                let startIndex = scanner.scanLocation
                var floatValue: Float = 0.0
                if scanner.scanFloat(&floatValue) {
                    
                    // dangerous!
                    let startIndex = scanner.scanLocation
                    
                    // create tokenContainer for spanner exponent
                    let exponentTokenContainer = TokenContainer(
                        identifier: "SpannerExponent",
                        openingValue: "^",
                        startIndex: startIndex
                    )
                    
                    // create single token for argument
                    let token = TokenFloat(
                        identifier: "Value",
                        value: floatValue,
                        startIndex: startIndex + lineStartIndex,
                        stopIndex: scanner.scanLocation + lineStartIndex
                    )
                    
                    exponentTokenContainer.addToken(token)
                    spannerTokenContainer.addToken(exponentTokenContainer)
                }
            }
            
            // scanWidth
            while scanner.scanString("-w", intoString: &string) {
                var startIndex = scanner.scanLocation
                
                let widthTokenContainer = TokenContainer(
                    identifier: "SpannerWidth",
                    openingValue: "-w",
                    startIndex: startIndex + lineStartIndex
                )
                
                var widthArguments: [Float] = []
                var floatValue: Float = 0.0
                
                while scanner.scanFloat(&floatValue) {
                    let token = TokenFloat(
                        identifier: "Value",
                        value: floatValue,
                        startIndex: startIndex + lineStartIndex,
                        stopIndex: scanner.scanLocation + lineStartIndex - 1
                    )
                    widthTokenContainer.addToken(token)
                    startIndex = scanner.scanLocation
                }
                spannerTokenContainer.addToken(widthTokenContainer)
            }
            
            // scanDashes
            while scanner.scanString("-d", intoString: &string) {
                var startIndex = scanner.scanLocation
                
                let dashesTokenContainer = TokenContainer(
                    identifier: "SpannerDashes",
                    openingValue: "-d",
                    startIndex: startIndex + lineStartIndex
                )
                
                var floatValue: Float = 0.0
                while scanner.scanFloat(&floatValue) {
                    
                    let token = TokenFloat(
                        identifier: "Value",
                        value: floatValue,
                        startIndex: startIndex + lineStartIndex,
                        stopIndex: scanner.scanLocation + lineStartIndex - 1
                    )
                    dashesTokenContainer.addToken(token)
                    startIndex = scanner.scanLocation
                }
                spannerTokenContainer.addToken(dashesTokenContainer)
            }
            
            container.addToken(spannerTokenContainer)
            
            /*
            // scanColor
            while scanner.scanString("c", intoString: &string) {
            
            }
            */
            
            /*
            // scanControlPoints
            while scanner.scanString("cp", intoString: &string) {
                
            }
            */
        }
    }
    
    private func scanSpannerStopWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var string: NSString?
        
        // order of commands is enforced
        while scanner.scanString("]", intoString: &string) {
            
            let token = TokenString(
                identifier: "SpannerStop",
                value: "]",
                startIndex: startIndex + lineStartIndex + 1
            )
            container.addToken(token)
        }
    }
    
    /*
    private func scanNonRootDurationNodeWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        
        let startIndex = scanner.scanLocation + 1
        var beats: Int?
        var floatValue: Float = 0.0
        if scanner.scanFloat(&floatValue) { beats = Int(floatValue) }
        
        /*
        if beats == nil {
            scanner.scanLocation = startIndex
            return
        }
        */
        
        var subdivision: Int?
        floatValue = 0.0
        if scanner.scanFloat(&floatValue) { subdivision = Int(floatValue) }
        
        scanner.scanLocation += 1
        //if subdivision == nil
        
        // Create Token for RootDurationNode Duration
        let token = TokenDuration(
            identifier: "RootNodeDuration",
            value: (beats!, subdivision!),
            startIndex: startIndex + lineStartIndex,
            stopIndex: scanner.scanLocation + lineStartIndex,
            indentationLevel: currentIndentationLevel
        )
        container.addToken(token)
    }
    */
    
    private func scanLeafDurationWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var beats: Int?
        var floatValue: Float = 0.0
        if scanner.scanFloat(&floatValue) { beats = Int(floatValue) }
        
        if beats == nil {
            scanner.scanLocation = startIndex
            return
        }

        var identifier: String
        var string: NSString?
        if scanner.scanString("--", intoString: &string) { identifier = "InternalNodeDuration" }
        else { identifier = "LeafNodeDuration" }
        
        

        // This should be a container,
        let token = TokenInt(
            identifier: identifier,
            value: beats!,
            startIndex: startIndex + lineStartIndex,
            stopIndex: scanner.scanLocation + lineStartIndex - 1, // dirty
            indentationLevel: currentIndentationLevel
        )
        container.addToken(token)
    }

    private func scanDurationWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    ) {

        // in case of failure, unwind to previous location
        let startIndex = scanner.scanLocation
        
        // float val to be written to be scanner
        var floatValue: Float = 0.0
        
        var beats: Int?
        var subdivisionValue: Int?
        
        while scanner.scanFloat(&floatValue) {
        
            if beats == nil { beats = Int(floatValue) }
            else if subdivisionValue == nil { subdivisionValue = Int(floatValue) }
            else { break }
        }
        
        if beats == nil || subdivisionValue == nil {
            scanner.scanLocation = startIndex
            return
        }
        
        // startIndex and stopIndex not correct
        let token = TokenDuration(
            identifier: "RootNodeDuration",
            value: (beats!, subdivisionValue!),
            startIndex: startIndex + lineStartIndex,
            stopIndex: scanner.scanLocation + lineStartIndex - 1 // dirty
        )
        
        container.addToken(token)
    }
    
    private func scanDurationNodeStackModeWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var stackMode: String?
        var string: NSString?
        let set = NSCharacterSet(charactersInString: "|+-")
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            stackMode = string as? String
        }
        
        if stackMode == nil {
            scanner.scanLocation = startIndex
            return
        }
        
        let token = TokenString(
            identifier: "DurationNodeStackMode",
            value: string as! String,
            startIndex: startIndex + lineStartIndex
        )
        container.addToken(token)
    }
    
    private func scanMeasureWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let startIndex = scanner.scanLocation
        var string: NSString?
        if scanner.scanString("#", intoString: &string) {
            
            let token = TokenString(
                identifier: "Measure",
                value: "#",
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
        }
    }
    
    private func scanCommentsWithScanner(scanner: NSScanner) {
        // do actually create tokens for comments!!!
        // cuz we still have to do highlighting for those
        scanLineCommentWithScanner(scanner)
        scanBlockCommentStartWithScanner(scanner)
        scanBlockCommentStopWithScanner(scanner)
    }
    
    private func scanBlockCommentStartWithScanner(scanner: NSScanner) {
        var string: NSString?
        if scanner.scanString("/*", intoString: &string) { isInBlockComment = true }
    }
    
    private func scanBlockCommentStopWithScanner(scanner: NSScanner) {
        var string: NSString?
        if scanner.scanString("*/", intoString: &string) { isInBlockComment = false }
    }
    
    private func scanLineCommentWithScanner(scanner: NSScanner) {
        var string: NSString?
        if scanner.scanString("//", intoString: &string) {
            scanner.scanUpToCharactersFromSet(newLineCharacterSet, intoString: &string)
        }
    }
  
    // perhaps get indentationLevelByLine first ?
    /*
    // this is not working correcttly
    private func indentationLevelWithScanner(scanner: NSScanner) -> Int {
        //print("get indentation level!")
        var spaceCount: Int = 0
        var tabCount: Int = 0
        var string: NSString?
        var set = NSMutableCharacterSet.whitespaceCharacterSet()
        //print("scanner.string: \(scanner.string)")
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            //print("whitespace: \(string)")
        }
        
        return 0
    }
    */
    // func for specific usages: tokenizeSpannerStartWithScanner(scanner: NSScanner)
}