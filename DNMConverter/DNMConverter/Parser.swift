//
//  Parser.swift
//  denm_parser
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

internal class Parser {
    
    // d r y
    private let commands: [String] = [
        "[R]", "#","!n", "!m", "tempo", "!t",
        "p","d","a",
        "->","<-","(",")","r", "+", "-", "|",
        "node", "node_stop", "edge_start", "edge_stop",
        "wave", "label",
        "a_harm", "n_harm", "sa_#", "sa_bpl", "sa_bpos", "sa_bdir"
    ]
    
    // continue implementing later
    private var patternsByCommand: [String : [String]] = [
        "tempo": ["_numeric_", "[","]"],
        "#": [],
        "|": [],
        "+": [],
        "-": [],
        "->": [],
        "<-": [],
        "!n": [],
        "!m:": [],
        "p": ["_numeric_", "[","]"],
        "a": [".","-", ">", "trem"],
        "d": ["_alpha_"],
        "node": ["[","]"],
        "wave": ["[","]"],
        "a_harm": ["_numeric_", "[", "]"]
    ]
    
    internal var tokens: [Token]
    
    internal init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    internal func getActions() -> [Action] {
        var actions: [Action] = []
        var index: Int = 0
        
        while index < tokens.count {
            
            if index == 0 { actions.appendContentsOf(getActionsFromHeaderAtIndex(&index)) }
            
            switch tokens[index] {
            case .Number(let value, let indentationLevel, _):
                if indentationLevel == 0 {
                    // ROOT NODE
                    let duration: (Int, Int) = getDurationBegunAtIndex(&index)
                    let action: Action = .DurationNodeRoot(duration: duration)
                    actions.append(action)
                    
                    // GET PID
                    index++
                    switch tokens[index] {
                    case .Symbol(let value, _, _):
                        actions.append(Action.PID(string: value))
                    default:
                        index-- // step back
                    }
                    
                    // GET IID
                    index++
                    switch tokens[index] {
                    case .Symbol(let value, _, _):
                        actions.append(Action.IID(string: value))
                    default:
                        index-- // step back
                    }
                }
                else if index < tokens.count - 1 {
                    // CONTAINER OR LEAF
                    let beats: Int = (value as NSString).integerValue
                    let nextToken = tokens[index + 1]
                    switch nextToken {
                    case .Symbol(let value, _, _):
                        switch value {
                        case _ where commands.contains(value):
                            let action: Action = .DurationNodeLeaf(
                                beats: beats, depth: indentationLevel - 1
                            )
                            actions.append(action)
                        default:
                            let action: Action = .DurationNodeInternal(
                                beats: beats, depth: indentationLevel - 1
                            )
                            actions.append(action)
                        }
                    default:
                        break
                    }
                }
            case .Symbol(let value, _, _):
                switch value {
                    
                case let command where commands.contains(value):
                    switch command {
                    case "#":
                        actions.append(.Measure)
                    case "[R]":
                        let action = Action.RehearsalMarking(type: "Alphabetical")
                        actions.append(action)
                    case "!t":
                        let action = Action.HideTimeSignature(id: "temp")
                        actions.append(action)
                    case "->":
                        actions.append(.ExtensionStart(id: "temp"))
                    case "<-":
                        actions.append(.ExtensionStop(id: "temp"))
                    case "+":
                        actions.append(.DurationAccumulationMode(mode: command))
                    case "-":
                        actions.append(.DurationAccumulationMode(mode: command))
                    case "|":
                        actions.append(.DurationAccumulationMode(mode: command))
                    case "(":
                        actions.append(Action.SlurStart(id: "temp"))
                    case ")":
                        actions.append(Action.SlurStop(id: "temp"))
                    case "p":
                        let pitchActions = getActionsForPitchBegunAtIndex(&index)
                        actions += pitchActions
                    case "d":
                        let actionsForDM = getActionsFromDynamicBegunAtIndex(&index)
                        actions += actionsForDM
                    case "a":
                        let arguments: [String] = getArticulationArgumentsBegunAtIndex(&index)
                        let action = Action.Articulation(markings: arguments)
                        actions.append(action)
                    case "r":
                        actions.append(.Rest)
                    case "!n":
                        let action = Action.NonNumerical(id: "temp")
                        actions.append(action)
                    case "!m":
                        let action = Action.NonMetrical(id: "temp")
                        actions.append(action)
                    case "node":
                        actions += getActionsForNodeBegunAtIndex(&index)
                        // getActionsForNodeBegunAtIndex()
                        /*
                        index++
                        switch tokens[index] {
                        case .Number(let value, _, _):
                            let action = Action.Node(value: (value as NSString).floatValue)
                            actions.append(action)
                        default: break
                        }
                        */
                    case "wave":
                        let action = Action.Wave(id: "temp")
                        actions.append(action)
                    case "label":
                        index++
                        switch tokens[index] {
                        case .Symbol(let value, _, _):
                            let action = Action.Label(value: value)
                            actions.append(action)
                        default: break
                        }
                    case "a_harm":
                        index++
                        switch tokens[index] {
                        case .Number(let value, _, _):
                            let action = Action.StringArtificialHarmonic(
                                pitch: (value as NSString).floatValue
                            )
                            actions.append(action)
                        default: break
                        }
                        break
                    case "tempo":
                        var tempo_value: Int?
                        var subdivisionLevel: Int?
                        
                        index++
                        switch tokens[index] {
                        case .Number(let value, _, _):
                            tempo_value = (value as NSString).integerValue
                        default: index-- // just kidding
                        }
                        index++
                        switch tokens[index] {
                        case .Number(let value, _, _):
                            subdivisionLevel = (value as NSString).integerValue
                        default: index-- // just kidding
                        }
                        if let tempo_value = tempo_value, subdivisionLevel = subdivisionLevel {
                            let action = Action.Tempo(
                                value: tempo_value, subdivisionLevel: subdivisionLevel
                            )
                            actions.append(action)
                        }
                    case "sa_#":
                        print("STRING NUMBER")
                        index++
                        switch tokens[index] {
                        case .Symbol(let value, _, _):
                            let action = Action.StringNumber(value: value)
                            actions.append(action)
                        default: break
                        }
                    case "sa_bdir":
                        print("parser BOW DIRECTION")
                        index++
                        switch tokens[index] {
                        case .Symbol(let value, _, _):
                            let action = Action.StringBowDirection(value: value)
                            actions.append(action)
                        default: break
                        }
                    default:
                        break
                    }
            
                default:
                    // this is a hack; make to ensure alphanumeric components only
                    // -- make helper function String.isAlphaNumeric() -> Bool
                    if Array(value.characters).first! != "-" {
                        
                        
                        actions.append(.ID(string: value))
                    
                    }
                }
            }
            index++
        }
        return actions
    }
    
    private func getActionsForNodeBegunAtIndex(inout index: Int) -> [Action] {
        let initialLineCount = getLineCountAtIndex(index)

        var actions: [Action] = []
        index++
        while index < tokens.count {
            
            // check line count
            let currentLineCount = getLineCountAtIndex(index)
            if currentLineCount > initialLineCount {
                index--
                return actions
            }
            
            // if good, continue
            switch tokens[index] {
            case .Number(let value, _, _):
                let action = Action.Node(value: (value as NSString).floatValue)
                actions.append(action)
            case .Symbol(let value, _, _):
                switch value {
                case "[":
                    let action = Action.EdgeStart(hasDashes: true)
                    actions.append(action)
                case "]":
                    let action = Action.EdgeStop(id: "temp")
                    actions.append(action)
                default:
                    index--
                    return actions
                }
            }
            index++
        }
        return actions
    }
    
    private func getActionsFromDynamicBegunAtIndex(inout index: Int) -> [Action] {
        var actions: [Action] = []
        
        // get marking
        index++
        switch tokens[index] {
        case .Symbol(let value, _, _):
            let action = Action.Dynamic(marking: value)
            actions.append(action)
        default:
            index--
            return actions
        }
        
        index++
        while index < tokens.count {
            switch tokens[index] {
            case .Symbol(let value, _, _):
                switch value {
                case "]":
                    let action = Action.DMLigatureStop(id: "temp")
                    actions.append(action)
                case "[":
                    let action = Action.DMLigatureStart(id: "temp")
                    actions.append(action)
                default:
                    index--
                    return actions
                }
            default:
                index--
                return actions
            }
            index++
        }
        return actions
    }
    
    private func getActionsFromHeaderAtIndex(inout index: Int) -> [Action] {
        
        var actions: [Action] = []
        var pIDs: [String] = []
        var iIDs: [String] = []
        var instrumentTypes: [String] = []
        
        var instrumentTypeByIIDsByPID: [String : [String : String]] = [:]
        
        // [[String : [(String, String)]], [String : (String, String)]]
        var instrumentTypeAndIIDByPID: [ [ String : [ (String, String) ] ] ] = []
        
        // just make sure first value is P
        switch tokens[index] {
        case .Symbol(let value, _, _):
            assert(value == "P:", "header must start with a Performer Declaration, for now")
        default: break
        }
        
        var curPID: String?
        var curIID: String?
        var id_count: Int = 0
        while index < tokens.count {
            switch tokens[index] {
            case .Symbol(let value, _, _):
                
                switch value {
                case "P:":
                    index++
                    id_count = 1 // go to IID stage
                case "#":    
                    let action = Action.IIDsAndInstrumentTypesByPID(
                        instrumentTypeAndIIDByPID: instrumentTypeAndIIDByPID
                    )
                    actions = [action]
                    return actions
                default:
                    switch id_count {
                    case 1:
                        // PID
                        pIDs.append(value)
                        curPID = value
                        instrumentTypeAndIIDByPID.append([value : []]) // initialize array
                        instrumentTypeByIIDsByPID[value] = [:]
                        id_count++
                    case 2:
                        // IID
                        iIDs.append(value)
                        curIID = value
                        id_count++
                    case 3:
                        // InstrumentType
                        instrumentTypes.append(value)
                        
                        if let curPID = curPID, curIID = curIID {
                            instrumentTypeByIIDsByPID[curPID]![curIID] = value
                            
                            if var arrayForCurPID = instrumentTypeAndIIDByPID.last?[curPID] {
                                print("array for curPID: \(curPID): \(arrayForCurPID)")
                                arrayForCurPID.append( (curIID, value) )
                                instrumentTypeAndIIDByPID.removeLast()
                                instrumentTypeAndIIDByPID.append([curPID : arrayForCurPID])
                            }
                        }
                        id_count = 2
                    default: break
                    }
                    index++
                }
                break
            default: break
            }
        }
        
        return actions
    }
    
    private func getDurationBegunAtIndex(inout index: Int) -> (Int, Int) {
        var beats: Int
        var subdivision: Int
        
        let beatsNumber = tokens[index]
        switch beatsNumber {
        case .Number(let value,  _,  _):
            beats = (value as NSString).integerValue
        default:
            beats = 0
            assertionFailure("duration must have two number tokens")
        }
        // move to next number
        index++
        let subdivisionNumber = tokens[index]
        switch subdivisionNumber {
        case .Number(let value, _,  _):
            subdivision = (value as NSString).integerValue
        default:
            subdivision = 1
            assertionFailure("duration must have two number tokens")
        }
        return (beats, subdivision)
    }
    
    private func getArticulationArgumentsBegunAtIndex(inout index: Int) -> [String] {
        
        var initialLineCount: Int
        switch tokens[index] {
        case .Symbol(_, _, let lineCount):
            initialLineCount = lineCount
        default:
            initialLineCount = 0
            assertionFailure("articulation argument command must be a symbol")
        }
        index++
        
        var arguments: [String] = []
        while index < tokens.count {
            switch tokens[index] {
            case .Symbol(let value, _, let lineCount):
                if lineCount != initialLineCount || value == ")" || value == "(" {
                    index--
                    return arguments
                }
                else {
                    arguments.append(value)
                    index++
                }
            default:
                index--
                return arguments
            }
        }
        index--
        return arguments
    }
    
    private func getActionsForWaveformBegunAtIndex(inout index: Int) -> [Action] {
        
        return []
    }
    
    private func getActionsForPitchBegunAtIndex(inout index: Int) -> [Action] {
        
        // set initial line count, in case we cross lines
        let initialLineCount: Int
        switch tokens[index] {
        case .Number(_, _, let lineCount): initialLineCount =  lineCount
        case .Symbol(_, _, let lineCount): initialLineCount =  lineCount
        }
        
        var actions: [Action] = []
        var pitchValues: [Float] = []
        index++
        while index < tokens.count {
            switch tokens[index] {
            case .Number(let value, _, let lineCount):
                if lineCount > initialLineCount {
                    let pitchAction = Action.Pitch(pitchValues)
                    actions.append(pitchAction)
                    index--
                    return actions
                }
                pitchValues.append((value as NSString).floatValue)
            case .Symbol(let value, _, let lineCount):
                if lineCount > initialLineCount {
                    let pitchAction = Action.Pitch(pitchValues)
                    actions.append(pitchAction)
                    index--
                    return actions
                }
                switch value {
                case "]":
                    let action = Action.GlissandoStop(id: "temp")
                    actions.append(action)
                case "[":
                    let action = Action.GlissandoStart(id: "temp")
                    actions.append(action)
                default:
                    let pitchAction = Action.Pitch(pitchValues)
                    actions.append(pitchAction)
                    index--
                    return actions
                }
            }
            index++
        }
        return actions
    }
    
    private func getPitchArgumentsBegunAtIndex(inout index: Int) -> [Float] {
        var initialLineCount: Int
        switch tokens[index] {
        case .Symbol(_, _, let lineCount):
            initialLineCount = lineCount
        default:
            initialLineCount = 0
            assertionFailure("pitch argument command must be a symbol")
        }
        index++
        
        var arguments: [Float] = []
        while index < tokens.count {
            switch tokens[index] {
            case .Number(let value, _, let lineCount):
                if lineCount != initialLineCount {
                    index--
                    return arguments
                }
                else {
                    let floatValue = (value as NSString).floatValue
                    arguments.append(floatValue)
                    index++
                }
            default:
                index--
                return arguments
            }
        }
        index--
        return arguments
    }
    
    private func getValueAtIndex(index: Int) -> String? {
        if index >= 0 && index < tokens.count {
            switch tokens[index] {
            case .Symbol(let value, _, _): return value
            case .Number(let value, _, _): return value
            }
        }
        return nil
    }
    
    private func getLineCountAtIndex(index: Int) -> Int? {
        if index >= 0 && index < tokens.count {
            switch tokens[index] {
            case .Symbol(_, _, let lineCount): return lineCount
            case .Number(_, _, let lineCount): return lineCount
            }
        }
        return nil
    }
    
    private func getIndentationLevelAtIndex(index: Int) -> Int? {
        if index >= 0 && index < tokens.count {
            switch tokens[index] {
            case .Symbol(_, let indentationLevel, _): return indentationLevel
            case .Number(_, let indentationLevel, _): return indentationLevel
            }
        }
        return nil
    }
}

// think about how this is integrated
internal enum Command: String {
    case Octothorpe = "#"
    case P = "p"
    case D = "d"
    case A = "a"
    case RightArrow = "->"
    case ParenLeft = "("
    case ParenRight = ")"
    case Star = "*"
    case Minus = "-" // eek
    case Plus = "+"
    case VerticalLine = "|"

    //["#","p","d","a","->","(",")","*", "+", "-", "|"]
}