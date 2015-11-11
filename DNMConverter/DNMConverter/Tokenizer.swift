//
//  Tokenizer.swift
//  Tokenizer3
//
//  Created by James Bean on 11/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMUtility

// At some point, find way to inject new commands and argument types in here dynamically
public class Tokenizer {
    
    private let newLineSet = NSCharacterSet.newlineCharacterSet()
    private let letterSet = NSCharacterSet.letterCharacterSet()
    
    private var lineCount: Int = 0
    private var lineStartIndex: Int = 0
    private var index: Int = 0
    private var isInBlockComment: Bool = false
    
    public init() { }
    
    public func tokenizeString(string: String) -> TokenContainer {
        
        // the string for the current line
        var lineString: NSString? // probably rename this to lineString
        
        // main scanner that reads one line at a time
        let mainScanner = NSScanner(string: string)
        
        // inject the header info here
        
        var metaData: [String : String] = [:]

        // deal with ordering later
        //var iIDsAndInstrumentTypesByPID: [String : [(String, String)]] = [:]
        
        var iIDsAndInstrumentTypesByPID = OrderedDictionary<
            String, OrderedDictionary<String, String>
        >()
        
        let rootTokenContainer = TokenContainer(identifier: "root", startIndex: 0)
        
        // read a single line
        while mainScanner.scanUpToCharactersFromSet(newLineSet, intoString: &lineString) {

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
            if let performerDeclaration = scanPerformerDeclaractionWithScanner(lineScanner,
                andContainer: rootTokenContainer
            )
            {
                for (pID, iTypeByIID) in performerDeclaration {
                    print("pID: \(pID): \(iTypeByIID)")
                    for (iID, iType) in iTypeByIID {
                        print("iID: \(iID): \(iType)")
                    }
                }
                print(performerDeclaration)
                
                iIDsAndInstrumentTypesByPID.appendContentsOfOrderedDictionary(performerDeclaration)
            }
            
            print("ALL OF THEM: \(iIDsAndInstrumentTypesByPID)")
            
            
            
            // scan for line meta data
            let lineMetaData = scanHeaderWithScanner(lineScanner,
                andContainer: rootTokenContainer
            )
            
            // extend all metadata with lineMetaData (make a clean method for this!)
            for (k,v) in lineMetaData { metaData[k] = v }
            //for (k,v) in performerDeclaration { iIDsAndInstrumentTypesByPID[k] = v }
            
            scanLineWithScanner(lineScanner, andContainer: rootTokenContainer)
            

            
            lineStartIndex += lineScanner.string.characters.count
            lineCount++
        }
        return rootTokenContainer
    }
    
    private func scanLineWithScanner(scanner: NSScanner,
        andContainer container: TokenContainer
    )
    {
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

        scanPIDWithScanner(scanner, andContainer: container)
        scanIIDWithScanner(scanner, andContainer: container)
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
        
        // This is used to switch between InstrumentID and InstrumentType as they are declared
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
            
            // deprecate
            var _iIDsByPID: [(String, String)] = []
            
            //var instrumentIDsByPerformerID = OrderedDictionary<String, String>()
            
            var instrumentIDsAndInstrumentTypeByPerformerID = OrderedDictionary<
                String, OrderedDictionary<String, String>
            >()
            
            // adjust this so that there is a count (0,1) that switches, but this works for now
            
            let set = NSMutableCharacterSet.letterCharacterSet()
            
            // Match PerformerID declaration
            if scanner.scanCharactersFromSet(set, intoString: &string) {
                
                // This is the PerformerID
                performerID = string as! String
                
                // This enum will switch every time there is a match
                var instrumentIDOrType = InstrumentIDOrType.ID
                
                var instrumentID: String?
                var instrumentType: String?
                
                while true {
                    
                    if scanner.scanCharactersFromSet(set, intoString: &string) {
                    
                        switch instrumentIDOrType {
                        case .ID:
                            instrumentID = string as? String
                            instrumentIDOrType.switchState()
                        case .Type:
                            instrumentType = string as? String
                            let tuple = (instrumentID!, instrumentType!)
                            
                            // ensure ...
                            if instrumentIDsAndInstrumentTypeByPerformerID[performerID] == nil {
                                instrumentIDsAndInstrumentTypeByPerformerID[performerID] = (
                                    OrderedDictionary<String,String>()
                                )
                            }
                            
                            instrumentIDsAndInstrumentTypeByPerformerID[performerID]![instrumentID!] = instrumentType
                            instrumentID = nil
                            instrumentType = nil
                            instrumentIDOrType.switchState()
                        }
                    }
                    else {
                        return instrumentIDsAndInstrumentTypeByPerformerID
                    }
                }
            }
            
            /*
            if iIDsByPID.count == 0 {
                print("Error: Performer Declared improperly")
                scanner.scanLocation = beginLocation
                return nil
            } else {
                
                print("perf decl : \([pID!: iIDsByPID])")
                
                
                return [pID!: iIDsByPID]
            }
            */
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
    
    private func scanPIDWithScanner(scanner: NSScanner, andContainer container: TokenContainer) {
        let beginLocation = scanner.scanLocation
        var pID: String?
        var string: NSString?
        let set = NSCharacterSet.letterCharacterSet()
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            pID = string as? String
            break
        }
        
        if pID == nil || pID!.characters.count != 2 {
            scanner.scanLocation = beginLocation
            return
        }
    }
    
    private func scanIIDWithScanner(scanner: NSScanner, andContainer container: TokenContainer) {
        let beginLocation = scanner.scanLocation
        var iID: String?
        var string: NSString?
        let set = NSCharacterSet.letterCharacterSet()
        while scanner.scanCharactersFromSet(set, intoString: &string) {
            iID = string as? String
            break
        }
        
        if iID == nil || iID!.characters.count != 2 {
            scanner.scanLocation = beginLocation
            return
        }
    }
    
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
        
        // This should be a container,
        // with (value) and (depth) tokens!
        let token = TokenInt(
            identifier: "LeafDuration",
            value: beats!,
            startIndex: beginLocation + lineStartIndex,
            stopIndex: scanner.scanLocation + lineStartIndex - 1 // dirty
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
            scanner.scanUpToCharactersFromSet(newLineSet, intoString: &string)
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