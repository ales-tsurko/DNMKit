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
    private var instrumentIDAndInstrumentTypeByPerformerID = OrderedDictionary<
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
                case "LeafDuration": manageLeafDurationToken(token)
                default: break
                }
            }
        }
        
        // return something real
        return DNMScoreModel()
    }
    
    private func manageMeasureToken() {
        setDurationOfLastMeasure()
        let measure = Measure(offsetDuration: currentMeasureDurationOffset)
        measures.append(measure)
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
        }
    }
    
    // needs to be TokenContainer
    private func manageLeafDurationToken(token: Token) {
        if let tokenInt = token as? TokenInt {
            print(tokenInt)
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
    
    private func setDurationOfLastMeasure() {
        if measures.count == 0 { return }
        var lastMeasure = measures[measures.count - 1]
        lastMeasure.duration = accumDurationInMeasure
        currentMeasureDurationOffset += lastMeasure.duration
    }
    
    private func finalizedDurationNodes(durationNodes: [DurationNode]) {
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

private enum TokenizerError: ErrorType {
    case InvalidInstrumentType
    case UndeclaredPerformerID
    case UndeclaredInstrumentID
    
}