//
//  Parser.swift
//  DNMConverter
//
//  Created by James Bean on 11/9/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMUtility
import DNMModel

public class Parser {
    
    /** 
    Manner in which the current DurationNode is placed in time
    - Measure: place DurationNode at beginning of current Measure
    - Increment: place DurationNode immediately after last DurationNode
    - Decrement: place DurationNode at beginning of last DurationNode
    */
    private var durationNodeStackMode: DurationNodeStackMode = .Measure
    
    /// Stack of DurationNodes, used to embed DurationNodes into other ones
    private var durationNodeStack = Stack<DurationNode>()
    
    /// Current DurationNodeLeaf which shall be decorated with Components
    private var currentDurationNodeLeaf: DurationNode?
    
    /// Offset of start of current measure from the beginning of the piece
    private var currentMeasureDurationOffset: Duration = DurationZero
    
    /// Offset of current location from beginning of current measure
    private var accumDurationInMeasure: Duration = DurationZero
    
    /// Offset of current DurationNode from beginning of the piece
    private var currentDurationNodeOffset: Duration = DurationZero
    
    /// Offset of current location from the beginning of the piece
    private var accumTotalDuration: Duration = DurationZero
    
    /// Depth of current DurationNode (in the case of embedded tuplets)
    private var currentDurationNodeDepth: Int = 0
    
    /**
    Collection of InstrumentIDsWithInstrumentType, organized by PerformerID.
    These values ensure Performer order and Instrument order, 
    while making it still possible to call for this information by key identifiers.
    */
    private var instrumentIDAndInstrumentTypesByPerformerID = OrderedDictionary<
        String, OrderedDictionary<String, InstrumentType>
    >()
    
    
    // MARK: DNMScoreModel values
    
    private var title: String = ""
    private var durationNodes: [DurationNode] = []
    private var measures: [Measure] = []
    private var tempoMarkings: [TempoMarking] = []
    private var rehearsalMarkings: [RehearsalMarking] = []
    
    public init() { }
    
    public func parseTokenContainer(tokenContainer: TokenContainer) -> DNMScoreModel {
        
        for token in tokenContainer.tokens {
    
            if let container = token as? TokenContainer {
                switch container.identifier {
                case "PerformerDeclaration":
                    do { try managePerformerDeclarationTokenContainer(container) }
                    catch ParserError.InvalidInstrumentType(let string) {
                        print("INVALID InstrumentType: \(string)")
                    } catch _ { print("...?") }
                    
                case "Pitch": managePitchTokenContainer(container)
                case "DynamicMarking": manageDynamicMarkingTokenContainer(container)
                case "Articulation": manageArticulationTokenContainer(container)
                case "SlurStart": manageSlurStartTokenContainer(container)
                case "SlurStop": manageSlurStopTokenContainer(container)
                    
                // shouldn't happen at top-level: only embedded
                //case "SpannerStart": manageSpannerStartTokenContainer(container)
                default: break
                }
            }
            else {
                switch token.identifier {
                case "DurationNodeStackMode": manageDurationNodeStackModeToken(token)
                case "Measure": manageMeasureToken()
                case "RootDuration": manageRootDurationToken(token)
                case "InternalNodeDuration": manageInternalDurationToken(token)
                case "LeafNodeDuration": manageLeafNodeDurationToken(token)
                default: break
                }
            }
        }
        
        finalizeDurationNodes()
        
        let scoreModel = makeScoreModel()
        for dn in durationNodes {
            print(dn)
        }
        
        // return something real
        return scoreModel
    }
    
    private func makeScoreModel() -> DNMScoreModel {
        var scoreModel = DNMScoreModel()
        scoreModel.title = title
        scoreModel.measures = measures
        scoreModel.durationNodes = durationNodes
        scoreModel.tempoMarkings = tempoMarkings
        scoreModel.rehearsalMarkings = rehearsalMarkings
        scoreModel.instrumentIDsAndInstrumentTypesByPerformerID = instrumentIDAndInstrumentTypesByPerformerID
        return scoreModel
    }
    
    private func managePerformerDeclarationTokenContainer(container: TokenContainer) throws {
        let performerID = container.openingValue
        
        var instrumentIDsAndInstrumentTypesByPerformerID = OrderedDictionary<
            String, OrderedDictionary<String, InstrumentType>
        >()
        
        instrumentIDsAndInstrumentTypesByPerformerID[performerID] = OrderedDictionary<
            String, InstrumentType
        >()
        
        var dictForPID = instrumentIDsAndInstrumentTypesByPerformerID[performerID]!
        var lastInstrumentID: String?
        for token in container.tokens {
            switch token.identifier {
            case "InstrumentID":
                let instrumentID = (token as! TokenString).value
                lastInstrumentID = instrumentID
            case "InstrumentType":

                let instrumentTypeString = (token as! TokenString).value
                
                guard let instrumentType = InstrumentType(rawValue: instrumentTypeString) else {
                    throw ParserError.InvalidInstrumentType(string: instrumentTypeString)
                }
                
                if let lastInstrumentID = lastInstrumentID {
                    dictForPID[lastInstrumentID] = instrumentType
                }
            default: break
            }
        }
        
        self.instrumentIDAndInstrumentTypesByPerformerID.appendContentsOfOrderedDictionary(
            instrumentIDAndInstrumentTypesByPerformerID
        )
    }
    
    private func manageMeasureToken() {
        setDurationOfLastMeasure()
        let measure = Measure(offsetDuration: currentMeasureDurationOffset)
        measures.append(measure)
    }
    
    private func setDurationOfLastMeasure() {
        if measures.count == 0 { return }
        var lastMeasure = measures[measures.count - 1]
        lastMeasure.duration = accumDurationInMeasure
        currentMeasureDurationOffset += lastMeasure.duration
    }
    
    private func manageDurationNodeStackModeToken(token: Token) {
        if let tokenString = token as? TokenString {
            if let stackMode = DurationNodeStackMode(rawValue: tokenString.value) {
                durationNodeStackMode = stackMode
            }
        }
        
        switch durationNodeStackMode {
        case .Measure: accumDurationInMeasure = DurationZero
        case .Increment: break
        case .Decrement: break // currently, not supported?
        }
    }
    
    private func manageRootDurationToken(token: Token) {
        if let tokenDuration = token as? TokenDuration {
            print(tokenDuration)
            
            let rootDurationNode = DurationNode(duration: Duration(tokenDuration.value))
            setOffsetDurationForNewRootDurationNode(rootDurationNode)
            addRootDurationNode(rootDurationNode)
            accumTotalDuration += rootDurationNode.duration
            currentDurationNodeDepth = 0
        }
    }
    
    private func manageLeafNodeDurationToken(token: Token) {
        if let tokenInt = token as? TokenInt, indentationLevel = tokenInt.indentationLevel {
            print("manage leaf with beats: \(tokenInt.value); indentation: \(indentationLevel)")
        }
    }
    
    // FIXME: investigate this
    private func manageInternalDurationToken(token: Token) {
        if let tokenInt = token as? TokenInt, indentationLevel = tokenInt.indentationLevel {
            
            let beats = tokenInt.value
            let depth = indentationLevel - 1
            if depth < currentDurationNodeDepth {
                let amount = currentDurationNodeDepth - depth
                durationNodeStack.pop(amount: amount)
            }
            if let lastDurationNode = durationNodeStack.top {
                let lastDurationNodeChild = lastDurationNode.addChildWithBeats(beats)
                durationNodeStack.push(lastDurationNodeChild)
                currentDurationNodeLeaf = lastDurationNodeChild
                currentDurationNodeDepth = depth
            }
        }
    }
    
    private func manageSlurStartTokenContainer(container: TokenContainer) {
        // add slur start
    }
    
    private func manageSlurStopTokenContainer(container: TokenContainer) {
        // add slur stop
    }
    
    private func managePitchTokenContainer(container: TokenContainer) {
        var pitches: [Float] = []
        for token in container.tokens {
            if let spannerStart = token as? TokenContainer
                where spannerStart.identifier == "SpannerStart"
            {
                // manage glissando
            }
            else if let tokenFloat = token as? TokenFloat {
                pitches.append(tokenFloat.value)
            }
        }
    }
    
    private func manageDynamicMarkingTokenContainer(container: TokenContainer) {
        
    }
    
    private func manageArticulationTokenContainer(container: TokenContainer) {
        
    }
    
    private func manageSpannerStartTokenContainer(container: TokenContainer) {
        
    }
    

    
    private func setOffsetDurationForNewRootDurationNode(rootDurationNode: DurationNode) {
        let offsetDuration: Duration
        switch durationNodeStackMode {
        case .Measure:
            offsetDuration = currentMeasureDurationOffset
            accumTotalDuration = currentMeasureDurationOffset
            accumDurationInMeasure = rootDurationNode.duration
        case .Increment:
            offsetDuration = accumTotalDuration
        case .Decrement:
            if let lastDurationNode = durationNodeStack.top {
                offsetDuration = lastDurationNode.offsetDuration
                accumTotalDuration = offsetDuration
                accumDurationInMeasure -= lastDurationNode.duration
            } else {
                offsetDuration = DurationZero
            }
        }
        rootDurationNode.offsetDuration = offsetDuration
    }
    
    private func addRootDurationNode(rootDurationNode: DurationNode) {
        durationNodes.append(rootDurationNode)
        durationNodeStack = Stack(items: [rootDurationNode])
    }
    
    private func finalizeDurationNodes() {
        for durationNode in durationNodes {
            (durationNode.root as! DurationNode).matchDurationsOfTree()
            (durationNode.root as! DurationNode).scaleDurationsOfChildren()
            (durationNode.root as! DurationNode).setOffsetDurationOfChildren()
        }
    }
}

private enum DurationNodeStackMode: String {
    case Measure = "|"
    case Increment = "+"
    case Decrement = "-"
}

private enum ParserError: ErrorType {
    case InvalidInstrumentType(string: String)
    case UndeclaredPerformerID
    case UndeclaredInstrumentID
    
}