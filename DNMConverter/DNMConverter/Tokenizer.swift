//
//  Tokenizer.swift
//  Tokenizer3
//
//  Created by James Bean on 11/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMUtility
import DNMModel

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
        mainScanner.charactersToBeSkipped = newLineCharacterSet
        
        let rootTokenContainer = TokenContainer(identifier: "root", startIndex: 0)
        
        // read a single line
        while mainScanner.scanUpToCharactersFromSet(newLineCharacterSet, intoString: &lineString) {
            
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

            lineStartIndex += lineScanner.string.characters.count
            lineCount++
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

        // wrap this in func: scanTopLevelCommands()
        scanPitchCommandWithScanner(scanner, andContainer: container)
        scanDynamicCommandWithScanner(scanner, andContainer: container)
        scanArticulationCommandWithScanner(scanner, andContainer: container)
        
        scanSlurStartWithScanner(scanner, andContainer: container)
        scanSlurStopWithScanner(scanner, andContainer: container)

        scanPerformerIDAndInstrumentIDWithScanner(scanner, andContainer: container)
    }
    
    private func scanTopLevelCommandsWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        
    }
    
    private func scanHeaderWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    ) -> [String : String]
    {
        var beginLocation = scanner.scanLocation

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
            scanner.scanLocation = beginLocation
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
        
        let beginLocation = scanner.scanLocation
        
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
                    startIndex: beginLocation + lineStartIndex
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
                    
                    let beginLocation = scanner.scanLocation
                    
                    if scanner.scanCharactersFromSet(letterCharacterSet, intoString: &string) {
                        
                        switch instrumentIDOrType {
                        case .ID:
                            instrumentID = string as! String
                            
                            // Create Token for InstrumentID
                            let instrumentIDToken = TokenString(
                                identifier: "InstrumentID",
                                value: instrumentID,
                                startIndex: beginLocation + lineStartIndex
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
                                startIndex: beginLocation + lineStartIndex
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
        var beginLocation = scanner.scanLocation
        var string: NSString?
        
        if scanner.scanString("(", intoString: &string) {
            
            let slurStartTokenContainer = TokenContainer(
                identifier: "SlurStart",
                openingValue: "(",
                startIndex: beginLocation + lineStartIndex
            )
            
            container.addToken(slurStartTokenContainer)
        }
    }
    
    private func scanSlurStopWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        var string: NSString?
        
        if scanner.scanString(")", intoString: &string) {
    
            let slurStopTokenContainer = TokenContainer(
                identifier: "SlurStop",
                openingValue: ")",
                startIndex: beginLocation + lineStartIndex
            )
            container.addToken(slurStopTokenContainer)
        }
    }
    
    private func scanArticulationCommandWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        
        var string: NSString?
        
        var articulationMarkings: [String] = []
        if scanner.scanString("a", intoString: &string) {
            
            let articulationTokenContainer = TokenContainer(
                identifier: "Articulation",
                openingValue: "a",
                startIndex: beginLocation + lineStartIndex
            )

            var beginLocation = scanner.scanLocation
            let set = NSMutableCharacterSet(charactersInString: ".->")
            while scanner.scanCharactersFromSet(set, intoString: &string) {
                
                let token = TokenString(
                    identifier: "ArticulationArgument",
                    value: string as! String,
                    startIndex: beginLocation + lineStartIndex
                )
                beginLocation = scanner.scanLocation
                articulationTokenContainer.addToken(token)
            }
            container.addToken(articulationTokenContainer)
        }
        
        // Unwind scanner if no articulation markings found
        if articulationMarkings.count == 0 {
            scanner.scanLocation = beginLocation
            return
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
            
            var beginLocation = scanner.scanLocation
            
            // add tokenContainer to container
            var pitchTokenContainer = TokenContainer(
                identifier: "Pitch",
                startIndex: beginLocation + lineStartIndex
            )
            
            var floatValue: Float = 0.0
            while scanner.scanFloat(&floatValue) {
                let stopIndex = scanner.scanLocation
                
                let token = TokenFloat(
                    identifier: "MIDIValue",
                    value: floatValue,
                    startIndex: beginLocation + lineStartIndex,
                    stopIndex: scanner.scanLocation + lineStartIndex
                )

                pitchTokenContainer.addToken(token)
                beginLocation = scanner.scanLocation
            }
            
            container.addToken(pitchTokenContainer)

            scanSpannerWithScanner(scanner, andContainer: pitchTokenContainer)
        }
    }
    
    private func scanDynamicCommandWithScanner(scanner: NSScanner, andContainer container: TokenContainer) {
        let beginLocation: Int = scanner.scanLocation
        var string: NSString?
        
        if scanner.scanString("d", intoString: &string) {
            
            let dynamicMarkingContainer = TokenContainer(
                identifier: "DynamicMarking",
                openingValue: "d",
                startIndex: beginLocation
            )
            
            var dynamicMarking: String?
            let set = NSMutableCharacterSet(charactersInString: "opmf")
            while scanner.scanCharactersFromSet(set, intoString: &string) {
                let beginLocation = scanner.scanLocation
                let token = TokenString(
                    identifier: "DynamicMarkingArgument",
                    value: string as! String,
                    startIndex: beginLocation + lineStartIndex
                )
                dynamicMarkingContainer.addToken(token)
                dynamicMarking = string as? String
                break
            }
            
            // Unwind scanner if invalid
            if dynamicMarking == nil {
                scanner.scanLocation = beginLocation
                return
            }
            
            // TODO: pass new container
            scanSpannerWithScanner(scanner, andContainer: dynamicMarkingContainer)
            container.addToken(dynamicMarkingContainer)
        }
    }
    
    /*
    private func scanPerformerIDWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        var performerID: String?
        var string: NSString?
        let set = NSCharacterSet.letterCharacterSet()
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            performerID = string as? String
            
            let token = TokenString(
                identifier: "PerformerID",
                value: performerID!,
                startIndex: beginLocation + lineStartIndex
            )
            container.addToken(token)
        }
        
        if performerID == nil || performerID!.characters.count != 2 {
            scanner.scanLocation = beginLocation
            return
        }
    }
    */
    
        /*
    private func scanInstrumentIDWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        var instrumentID: String?
        var string: NSString?
        let set = NSCharacterSet.letterCharacterSet()
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            instrumentID = string as? String
            
            let token = TokenString(
                identifier: "InstrumentID",
                value: instrumentID!,
                startIndex: beginLocation + lineStartIndex
            )
            container.addToken(token)
        }
        
        if instrumentID == nil || instrumentID!.characters.count != 2 {
            scanner.scanLocation = beginLocation
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
        
        let beginLocation = scanner.scanLocation
        
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
                startIndex: beginLocation + lineStartIndex
            )
            container.addToken(token)
            if isComplete { break }
        }
    }
    

    
    // Find best way to generalize this process!
    private func scanSpannerWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
    
        let beginLocation = scanner.scanLocation

        var string: NSString?
        
        // order of commands is enforced
        if scanner.scanString("[", intoString: &string) {
            
            var spannerTokenContainer = TokenContainer(
                identifier: "SpannerStart",
                openingValue: "[",
                startIndex: beginLocation + lineStartIndex
            )
            
            // scanExponent
            while scanner.scanString("^", intoString: &string) {
                
                // dangerous!
                let beginLocation = scanner.scanLocation
                var floatValue: Float = 0.0
                if scanner.scanFloat(&floatValue) {
                    
                    // dangerous!
                    let beginLocation = scanner.scanLocation
                    
                    // create tokenContainer for spanner exponent
                    let exponentTokenContainer = TokenContainer(
                        identifier: "SpannerExponent",
                        openingValue: "^",
                        startIndex: beginLocation
                    )
                    
                    // create single token for argument
                    let token = TokenFloat(
                        identifier: "SpannerExponentArgument",
                        value: floatValue,
                        startIndex: beginLocation + lineStartIndex,
                        stopIndex: scanner.scanLocation + lineStartIndex
                    )
                    
                    exponentTokenContainer.addToken(token)
                    spannerTokenContainer.addToken(exponentTokenContainer)
                }
            }
            
            // scanWidth
            while scanner.scanString("-w", intoString: &string) {
                var beginLocation = scanner.scanLocation
                
                let widthTokenContainer = TokenContainer(
                    identifier: "SpannerWidth",
                    openingValue: "-w",
                    startIndex: beginLocation + lineStartIndex
                )
                
                var widthArguments: [Float] = []
                var floatValue: Float = 0.0
                
                while scanner.scanFloat(&floatValue) {
                    let token = TokenFloat(
                        identifier: "SpannerWidthArgument",
                        value: floatValue,
                        startIndex: beginLocation + lineStartIndex,
                        stopIndex: scanner.scanLocation + lineStartIndex - 1
                    )
                    widthTokenContainer.addToken(token)
                    beginLocation = scanner.scanLocation
                }
                spannerTokenContainer.addToken(widthTokenContainer)
            }
            
            // scanDashes
            while scanner.scanString("-d", intoString: &string) {
                var beginLocation = scanner.scanLocation
                
                let dashesTokenContainer = TokenContainer(
                    identifier: "SpannerDashes",
                    openingValue: "-d",
                    startIndex: beginLocation + lineStartIndex
                )
                
                var floatValue: Float = 0.0
                while scanner.scanFloat(&floatValue) {
                    
                    let token = TokenFloat(
                        identifier: "SpannerDashesArgument",
                        value: floatValue,
                        startIndex: beginLocation + lineStartIndex,
                        stopIndex: scanner.scanLocation + lineStartIndex - 1
                    )
                    dashesTokenContainer.addToken(token)
                    beginLocation = scanner.scanLocation
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
    
    private func scanNonRootDurationNodeWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        var beats: Int?
        var floatValue: Float = 0.0
        if scanner.scanFloat(&floatValue) { beats = Int(floatValue) }
        
        if beats == nil {
            scanner.scanLocation = beginLocation
            return
        }
        
        // Create Token for RootDurationNode Duration
        let token = TokenInt(
            identifier: "RootDuration",
            value: beats!,
            startIndex: beginLocation + lineStartIndex,
            stopIndex: scanner.scanLocation + lineStartIndex - 1,
            indentationLevel: currentIndentationLevel
        )
        container.addToken(token)
    }
    
    private func scanLeafDurationWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        var beats: Int?
        var floatValue: Float = 0.0
        if scanner.scanFloat(&floatValue) { beats = Int(floatValue) }
        
        if beats == nil {
            scanner.scanLocation = beginLocation
            return
        }

        var identifier: String
        var string: NSString?
        if scanner.scanString("--", intoString: &string) { identifier = "InternalNodeDuration" }
        else { identifier = "LeafNodeDuration" }
        
        print("identifier: \(identifier)")

        // This should be a container,
        let token = TokenInt(
            identifier: identifier,
            value: beats!,
            startIndex: beginLocation + lineStartIndex,
            stopIndex: scanner.scanLocation + lineStartIndex - 1, // dirty
            indentationLevel: currentIndentationLevel
        )
        container.addToken(token)
    }

    private func scanDurationWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    ) {

        // in case of failure, unwind to previous location
        let beginLocation = scanner.scanLocation
        
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
            scanner.scanLocation = beginLocation
            return
        }
        
        // startIndex and stopIndex not correct
        let token = TokenDuration(
            identifier: "RootDuration",
            value: (beats!, subdivisionValue!),
            startIndex: beginLocation + lineStartIndex,
            stopIndex: scanner.scanLocation + lineStartIndex - 1 // dirty
        )
        
        container.addToken(token)
    }
    
    private func scanDurationNodeStackModeWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        var stackMode: String?
        var string: NSString?
        let set = NSCharacterSet(charactersInString: "|+-")
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            stackMode = string as? String
        }
        
        if stackMode == nil {
            scanner.scanLocation = beginLocation
            return
        }
        
        let token = TokenString(
            identifier: "DurationNodeStackMode",
            value: string as! String,
            startIndex: beginLocation + lineStartIndex
        )
        container.addToken(token)
    }
    
    private func scanMeasureWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        let beginLocation = scanner.scanLocation
        var string: NSString?
        while scanner.scanString("#", intoString: &string) {
            
            // perhaps stop index is not necessary? for strings? just create range with
            // -- startIndex + string.characters.count
            
            let token = TokenString(
                identifier: "Measure",
                value: "#",
                startIndex: beginLocation + lineStartIndex
            )
            container.addToken(token)
        }
    }
    
    private func scanCommentsWithScanner(scanner: NSScanner) {
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