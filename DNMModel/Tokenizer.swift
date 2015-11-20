//
//  Tokenizer.swift
//  Tokenizer3
//
//  Created by James Bean on 11/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation


public class Tokenizer {

    public enum ArgumentType: String {
        case String
        case Int
        case Float
        case Duration
        case DynamicMarking
        case Articulation
        case Spanner
    }
    
    public struct TopLevelCommand {
        
        var identifier: String
        var openingValue: String
        var allowableTypes: [ArgumentType]
        
        public init(identifier: String, openingValue: String, allowableTypes: [ArgumentType]) {
            self.identifier = identifier
            self.openingValue = openingValue
            self.allowableTypes = allowableTypes
        }
    }
    
    // currently public for the sake of testing, but should be private, ultimately
    public struct Line: CustomStringConvertible {
        
        public var description: String { return getDescription() }
        
        let string: String
        let startIndex: Int
        let stopIndex: Int
        var indentationLevel: Int { return getIndentationLevel() }
        
        init(string: String, startingAtIndex startIndex: Int) {
            self.string = string
            self.startIndex = startIndex
            self.stopIndex = startIndex + string.characters.count
        }
        
        private func getIndentationLevel() -> Int {
            
            // create scanner to isolate just the initial whitespace characters
            let scanner = NSScanner(string: string)
            scanner.charactersToBeSkipped = nil
            
            // create non-whitespace character set
            let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
            characterSet.formUnionWithCharacterSet(
                NSMutableCharacterSet.punctuationCharacterSet()
            )
            
            // create a string of just the leading whitespace for this line
            var ws: NSString?
            scanner.scanUpToCharactersFromSet(characterSet, intoString: &ws)
            
            if ws != nil {
                // scan through each character in the leading whitespace of this line
                let whiteSpaceScanner = NSScanner(string: ws as! String)
                whiteSpaceScanner.charactersToBeSkipped = nil
                
                // get the amount of spaces and tabs in the leading whitespace of this line
                var spaceCount: Int = 0
                var tabCount: Int = 0
                while !whiteSpaceScanner.atEnd {
                    if whiteSpaceScanner.scanString("\t", intoString: &ws) { tabCount++ }
                    else if whiteSpaceScanner.scanString(" ", intoString: &ws) { spaceCount++ }
                    else { whiteSpaceScanner.scanLocation++ }
                }
                let indentationLevel = Int(floor(Float(spaceCount) / 4)) + tabCount
                return indentationLevel
            }
            return 0
        }
        
        private func getDescription() -> String {
            var description: String = "Line: "
            description += "'\(string)': from \(startIndex) to \(stopIndex)"
            description += " indent: \(indentationLevel)"
            return description
        }
    }
    
    // currently public for the sake of testing, though should be private ultimately
    public struct LineCollection: CustomStringConvertible {
        
        public var description: String { return getDescription() }

        var lines: [Line]
        
        init() {
            self.lines = []
        }
        
        mutating func addLineWithString(string: String, startingAtIndex startIndex: Int) {
            // indentation temp
            let line = Line(string: string, startingAtIndex: startIndex)
            addLine(line)
        }
        
        mutating func addLine(line: Line) {
            lines.append(line)
            lines.sortInPlace { $0.startIndex < $1.startIndex }
        }
        
        func lineStartingAtIndex(index: Int) -> Line? {
            if lines.count == 0 { return nil }
            for line in lines { if line.startIndex == index { return line } }
            return nil
        }
        
        func lineIncludingIndex(index: Int) -> Line? {
            if lines.count == 0 { return nil }
            for line in lines {
                if line.startIndex <= index && line.stopIndex >= index { return line }
            }
            return nil
        }
        
        private func getDescription() -> String {
            var description: String = ""
            for line in lines { description += "\n\(line)" }
            return description
        }
    }
    
    public class TopLevelCommands {
        class var sharedInstance: JSON {
            struct Static {
                static let instance: JSON = Static.getInstance()
                static func getInstance() -> JSON {
                    let bundle = NSBundle(forClass: TopLevelCommands.self)
                    let filePath = bundle.pathForResource("TopLevelCommands", ofType: "json")!
                    let jsonData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
                    let jsonObj = JSON(data: jsonData)
                    return jsonObj
                }
            }
            return Static.instance
        }
    }
    
    private let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
    private let newLineCharacterSet = NSCharacterSet.newlineCharacterSet()
    private let letterCharacterSet = NSCharacterSet.letterCharacterSet()
    private let alphanumericCharacterSet = NSCharacterSet.alphanumericCharacterSet()
    private let dynamicMarkingsString = "ompf"
    private let articulationMarkingsString = "-.>"
    private var instrumentTypeCharacterSet: NSCharacterSet {
        return makeInstrumentTypeCharacterSet()
    }
    
    
    private var lineCount: Int = 0
    private var lineStartIndex: Int = 0
    private var index: Int = 0
    private var isInBlockComment: Bool = false
    
    private var indentationLevelByLine: [Int] = []
    
    private var currentIndentationLevel: Int { return indentationLevelByLine[lineCount] }
    
    public var topLevelCommands: [TopLevelCommand] = []
    
    private var lines: LineCollection = LineCollection()
    
    public init() {
        setDefaultTopLevelCommands()
    }

    private func addLineWithString(string: String, startingAtIndex startIndex: Int) {
        lines.addLineWithString(string, startingAtIndex: startIndex)
    }
    
    private func setDefaultTopLevelCommands() {
        let tlcs = TopLevelCommands.sharedInstance
        for tlc in tlcs.arrayValue {
            
            // identifier of top level command: for token creation / syntax highlighting
            let identifier = tlc["identifier"].stringValue
            
            // the string value that opens the command (e.g. "p" or "d")
            let openingValue = tlc["openingValue"].stringValue
            
            // allowable types for this command -- may have 0 values
            var allowableTypes: [ArgumentType] = []
            if let allowables = tlc["allowableTypes"].array {
                for allowableTypeJSON in allowables {
                    let allowableTypeString = allowableTypeJSON.stringValue
                    if let argumentType = ArgumentType(rawValue: allowableTypeString) {
                        allowableTypes.append(argumentType)
                    }
                }
            }
            
            // create top level command proper
            let topLevelCommand = TopLevelCommand(
                identifier: identifier,
                openingValue: openingValue,
                allowableTypes: allowableTypes
            )
            
            // add top level command
            topLevelCommands.append(topLevelCommand)
        }
    }
    
    private func makeTokenContainerForCommand(command: TopLevelCommand,
        startingAtIndex startIndex: Int
    ) -> TokenContainer
    {
        let tokenContainer = TokenContainer(
            identifier: command.identifier,
            openingValue: command.openingValue,
            startIndex: startIndex
        )
        return tokenContainer
    }
    
    private func _scanTopLevelCommandsWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        // the index that the scanner is unwound back to
        // in the case of a match, this is set to index just after the stopIndex of the match
        var unwindIndex: Int = scanner.scanLocation
        while !scanner.atEnd {
            var matchWasFound = false
            for command in topLevelCommands {
                if scanTopLevelCommand(command, withScanner: scanner, andContainer: container) {
                    matchWasFound = true
                    unwindIndex = scanner.scanLocation
                    break
                }
            }
            if scanner.atEnd { break }
            if !matchWasFound { scanner.scanLocation++ }
        }
        scanner.scanLocation = unwindIndex
    }

    
    private func scanTopLevelCommand(command: TopLevelCommand,
        withScanner scanner: NSScanner, andContainer parentContainer: TokenContainer
    ) -> Bool
    {
        var startIndex: Int = lineStartIndex + scanner.scanLocation
        
        // ? dirty: currently, measure / durationNodeStackMode crashing as they are first chars
        if scanner.scanLocation > 0 { startIndex += 1 }

        var str: NSString?
        if scanner.scanString(command.openingValue, intoString: &str) {

            var unwindIndex: Int = scanner.scanLocation
            
            // create TokenContainer for this top level command
            let container = makeTokenContainerForCommand(command, startingAtIndex: startIndex)
            
            // add the TokenContainer to the inherited parentContainer
            parentContainer.addToken(container)
            
            while !scanner.atEnd {
                var matchWasFound = false
    
                for type in command.allowableTypes {
                    if scanArgumentType(type, withScanner: scanner, andContainer: container) {
                        unwindIndex = scanner.scanLocation
                        matchWasFound = true
                    }
                    if scanner.atEnd { break }
                }
                if !matchWasFound {
                    scanner.scanLocation++
                    break
                }
            }
            scanner.scanLocation = unwindIndex
            return true
        }
        return false
    }
    
    
    // Currently all string
    private func scanArgumentType(argumentType: ArgumentType,
        withScanner scanner: NSScanner, andContainer container: TokenContainer
    ) -> Bool
    {
        func addToken(token: Token) { container.addToken(token) }
        
        func addStringValueTokenWithString(string: String, atIndex index: Int) {
            let token = TokenString(identifier: "Value", value: string, startIndex: index)
            addToken(token)
        }
        
        func addFloatValueTokenWithFloat(float: Float,
            fromIndex startIndex: Int, toIndex stopIndex: Int
        )
        {
            let token = TokenFloat(
                identifier: "Value", value: float, startIndex: startIndex, stopIndex: stopIndex
            )
            addToken(token)
        }
        
        var startIndex: Int = lineStartIndex + scanner.scanLocation
        switch argumentType {
        case .String:
            var str: NSString?
            if scanner.scanCharactersFromSet(alphanumericCharacterSet, intoString: &str) {
                addStringValueTokenWithString(str as! String, atIndex: startIndex + 1)
                return true
            }
        case .Int:

            break
        case .Float:

            var floatValue: Float = 0.0
            if scanner.scanFloat(&floatValue) {
                let stopIndex = lineStartIndex + scanner.scanLocation - 1
                addFloatValueTokenWithFloat(floatValue,
                    fromIndex: startIndex, toIndex: stopIndex
                )
                return true
            }
        case .Duration:

            
            break
        case .DynamicMarking:
            let charSet = NSCharacterSet(charactersInString: dynamicMarkingsString)
            var str: NSString?
            if scanner.scanCharactersFromSet(charSet, intoString: &str) {
                addStringValueTokenWithString(str as! String, atIndex: startIndex + 1)
                return true
            }
        case .Articulation:

            let charSet = NSCharacterSet(charactersInString: articulationMarkingsString)
            var str: NSString?
            if scanner.scanCharactersFromSet(charSet, intoString: &str) {
                addStringValueTokenWithString(str as! String, atIndex: startIndex + 1)
                return true
            }
        case .Spanner:
            if scanSpannerStartWithScanner(scanner, andContainer: container) {
                return true
            }
        }
        return false
    }
    
    public func tokenizeString(string: String) -> TokenContainer {
        
        print("tokenize string")
        
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
                    intoString: &lineString
                )
                {
                    let lineLength = lineString!.length
                    
                    // Set indentation level by line
                    let indentationLevel = indentationLevelWithLine(lineString as! String)
                    indentationLevelByLine.append(indentationLevel)
                    
                    // this is the scanner for the current line
                    let lineScanner = NSScanner(string: lineString as! String)
                    
                    lineScanner.charactersToBeSkipped = NSMutableCharacterSet.whitespaceCharacterSet()
                    lineScanner.caseSensitive = true
                    
                    scanCommentsWithScanner(lineScanner, andContainer: rootTokenContainer)
                    if isInBlockComment {
                        lineStartIndex += lineScanner.string.characters.count
                        continue
                    }
                    
                    scanPerformerDeclaractionWithScanner(lineScanner,
                        andContainer: rootTokenContainer
                    )
                    
                    // scan line for musical events
                    scanLineWithScanner(lineScanner, andContainer: rootTokenContainer)
                    
                    lineStartIndex += lineLength
                    lineCount++
                }
            }

        }
        return rootTokenContainer
    }

    
    private func scanLineWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {

        scanHeaderWithScanner(scanner, andContainer: container)

        scanPerformerIDAndInstrumentIDWithScanner(scanner, andContainer: container)
        
        scanDurationWithScanner(scanner, andContainer: container)
        scanLeafDurationWithScanner(scanner, andContainer: container)
        
        _scanTopLevelCommandsWithScanner(scanner, andContainer: container)
        
        //scanTopLevelCommandsWithScanner(scanner, andContainer: container)
    }
    

    
    private func scanHeaderWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    ) -> [String : String]
    {
        
        var startIndex = scanner.scanLocation// + lineStartIndex
        //if scanner.scanLocation > 0 { startIndex += 1 }
        
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
        print("scan perf decl.")
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
        
            let performerDeclarationTokenContainer = TokenContainer(
                identifier: "PerformerDeclaration",
                openingValue: "P:",
                startIndex: startIndex + lineStartIndex
            )
            
            
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
                
                let performerIDToken = TokenString(
                    identifier: "PerformerID",
                    value: performerID,
                    startIndex: startIndex + lineStartIndex
                )
                
                performerDeclarationTokenContainer.addToken(performerIDToken)
                
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
                    
                    if scanner.scanCharactersFromSet(instrumentTypeCharacterSet,
                        intoString: &string
                    )
                    {
                        
                        switch instrumentIDOrType {
                        case .ID:
                            instrumentID = string as! String
                            
                            // Create Token for InstrumentID
                            let instrumentIDToken = TokenString(
                                identifier: "InstrumentID",
                                value: instrumentID,
                                startIndex: startIndex + lineStartIndex + 1
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
                                startIndex: startIndex + lineStartIndex + 1
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
        
        var startIndex = scanner.scanLocation + lineStartIndex
        
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
                startIndex: startIndex
            )
            container.addToken(token)
            
            startIndex = scanner.scanLocation + lineStartIndex //+ 1
            if isComplete { break }
        }
    }
    
    
    
    // Find best way to generalize this process!
    private func scanSpannerStartWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    ) -> Bool
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
            return true
        }
        return false
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
    
    
    private func scanCommentsWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        // do actually create tokens for comments!!!
        // cuz we still have to do highlighting for those
        scanLineCommentWithScanner(scanner, andContainer: container)
        scanBlockCommentStartWithScanner(scanner, andContainer: container)
        scanBlockCommentStopWithScanner(scanner, andContainer: container)
    }
    
    private func scanBlockCommentStartWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var string: NSString?
        let startIndex: Int = scanner.scanLocation
        if scanner.scanString("/*", intoString: &string) {
            
            let token = TokenBlockCommentStart(startIndex: startIndex)
            container.addToken(token)
            
            isInBlockComment = true
        }
    }
    
    private func scanBlockCommentStopWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var string: NSString?
        if scanner.scanString("*/", intoString: &string) { isInBlockComment = false }
    }
    
    private func scanLineCommentWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var string: NSString?
        if scanner.scanString("//", intoString: &string) {
            scanner.scanUpToCharactersFromSet(newLineCharacterSet, intoString: &string)
        }
    }

    private func makeInstrumentTypeCharacterSet() -> NSMutableCharacterSet {
        let underscoreCharSet = NSMutableCharacterSet(charactersInString: "_")
        var alphanumericCharSet = NSMutableCharacterSet.alphanumericCharacterSet()
        alphanumericCharSet.formUnionWithCharacterSet(underscoreCharSet)
        return alphanumericCharSet
    }
    
        /*
    private func scanTopLevelCommand(command: String,
        withScanner scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        switch command {
        //case "*": break // scanRest(....)
        case "p": scanPitchCommandWithScanner(scanner, andContainer: container)
        case "a": scanArticulationCommandWithScanner(scanner, andContainer: container)
        case "d": scanDynamicCommandWithScanner(scanner, andContainer: container)
        case "(": scanSlurStartWithScanner(scanner, andContainer: container)
        case ")": scanSlurStopWithScanner(scanner, andContainer: container)
        case "->": scanExtensionStartWithScanner(scanner, andContainer: container)
        case "<-": scanExtensionStopWithScanner(scanner, andContainer: container)
        case "!n": scanNonNumericalDurationNodeModeWithScanner(scanner, andContainer: container)
        case "!m": scanNonMetricalDurationNodeModeWithScanner(scanner, andContainer: container)
        default: scanner.scanLocation++
        }
    }
    */
    
    /*
    private func scanNonNumericalDurationNodeModeWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var startIndex = scanner.scanLocation
        var str: NSString?
        if scanner.scanString("!n", intoString: &str) {
            let token = TokenString(
                identifier: "NonNumericalDurationNodeMode",
                value: "!n",
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
        }
    }
    
    private func scanNonMetricalDurationNodeModeWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        var startIndex = scanner.scanLocation
        var str: NSString?
        if scanner.scanString("!m", intoString: &str) {
            let token = TokenString(
                identifier: "NonMetricalDurationNodeMode",
                value: "!m",
                startIndex: startIndex + lineStartIndex
            )
            container.addToken(token)
        }
    }
    */
    
    /*
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
    */
    
        /*
    // this is temporary method name, which will later be called token
    public func _tokenizeString(string: String) -> TokenContainer? {
        
        var lineString: NSString?
        
        // create a scanner for an entire string
        let mainScanner = NSScanner(string: string)
        mainScanner.charactersToBeSkipped = nil
        
        while !mainScanner.atEnd {
            print(mainScanner.scanLocation)
            if mainScanner.scanCharactersFromSet(newLineCharacterSet, intoString: &lineString) {
                // manage newLine
            }
            else {
                let startIndex: Int = mainScanner.scanLocation
                while mainScanner.scanUpToCharactersFromSet(newLineCharacterSet,
                    intoString: &lineString
                )
                {
                    let lineString = lineString as! String
                    addLineWithString(lineString, startingAtIndex: startIndex)
                }
            }
        }
        
        // temp
        return nil
    }
    */
  
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
    
    /*
    private func scanTopLevelCommandsWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
        print("scanTopLevelCommands")
        let topLevelCommands = [
            
            // duration node root timing states
            "!n", // non-numerical state for current root duration node
            "!m", // non-metrical state for current root duration node
            "->", // extension start
            "<-", // extension stop
            "*", // rest
            "p", // pitch
            "a", // articulation
            "d", // dynamic
            "(", // slur start
            ")", // slur stop
            "art_harm", // artificial harmonic
            "nat_harm", // natural harmonic
            "pizz" // pizzicato
        ]
        
        var unwindToIndex: Int = scanner.scanLocation
        while !scanner.atEnd {
            print("scanner.scanLocation: \(scanner.scanLocation)")
            
            var match = false
            
            // check all top level commands for match
            for command in topLevelCommands {
                print("check for match: \(command)")
                var str: NSString?
                let startIndex = scanner.scanLocation
                print("command loop: location \(scanner.scanLocation)")
                
                if scanner.scanString(command, intoString: &str) {
                    match = true
                    print("scanned command!: \(command): startIndex: \(startIndex); scanLocation: \(scanner.scanLocation)")
                    
                    // unwind scanner to just before consuming command
                    scanner.scanLocation = startIndex
                    
                    // do the appropriate thing for each command
                    scanTopLevelCommand(command, withScanner: scanner, andContainer: container)
                    unwindToIndex = scanner.scanLocation
                }
                else {
                    print("no top level commands here!")
                    if scanner.atEnd { break }
                }
            }
            print("match? \(match)")
            if !match {
                scanner.scanLocation++
            }
        }
        
        // in makes sure that we don't consume the whole string
        scanner.scanLocation = unwindToIndex
    }
    */
    
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
    
    
    /*
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
    */
    
    /*
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
    */
    
    /*
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
    */
    
    
    /*
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
                    startIndex: startIndex + lineStartIndex + 1 // why is this?
                )
                dynamicMarkingContainer.addToken(token)
                dynamicMarking = string as? String
            }
            scanSpannerStopWithScanner(scanner, andContainer: dynamicMarkingContainer)
            scanSpannerStartWithScanner(scanner, andContainer: dynamicMarkingContainer)
            container.addToken(dynamicMarkingContainer)
        }
    }
    */
    
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

       
    /*
    public func scanLine(string: String, startingAtIndex startIndex: Int) -> TokenContainer {
        
        // set the startIndex for the line currently being scanned
        lineStartIndex = startIndex
        
        // Scanner that scans the current line only
        let lineScanner = NSScanner(string: string)
        lineScanner.charactersToBeSkipped = NSCharacterSet.whitespaceCharacterSet()

        // TokenContainer which holds all tokens for the current line only
        let rootContainer = TokenContainer(identifier: "root", openingValue: "", startIndex: 0)
        scanLineWithScanner(lineScanner, andContainer: rootContainer)
        

        // return TokenContainer
        return rootContainer
    }
    */
    
    /*
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
    */
    
    /*
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
    */

}