//
//  Parser.swift
//  DNMConverter
//
//  Created by James Bean on 11/9/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class Parser {
    
    /** 
    Manner in which the current DurationNode is placed in time
    - Measure: place DurationNode at beginning of current Measure
    - Increment: place DurationNode immediately after last DurationNode
    - Decrement: place DurationNode at beginning of last DurationNode
    */
    private var durationNodeStackMode: DurationNodeStackMode = .Measure
    
    /// Stack of DurationNodes, used to embed DurationNodes into other ones
    //private var durationNodeContainerStack = Stack<DurationNode>()
    
    // use instead of above
    private var durationNodeContainerStack = Stack<DurationNode>()
    
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
    
    private var currentPerformerID: String?
    private var currentInstrumentID: String?
    
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
                
                case "SlurStart": manageSlurStartToken()
                case "SlurStop": manageSlurStopToken()
                
                case "Measure": manageMeasureToken()
                    
                case "ExtensionStart": manageExtensionStartToken()
                case "ExtensionStop": manageExtensionStopToken()

                case "DurationNodeStackModeMeasure": manageDurationNodeStackModeMeasure()
                case "DurationNodeStackModeIncrement": manageDurationNodeStackModeIncrement()
                case "DurationNodeStackModeDecrement": manageDurationNodeStackModeDecrement()

                default: break
                }
            }
            else {
                switch token.identifier {

                case "RootNodeDuration": manageRootDurationToken(token)
                case "InternalNodeDuration": manageInternalDurationToken(token)
                case "LeafNodeDuration": manageLeafNodeDurationToken(token)
                case "PerformerID": managePerformerIDWithToken(token)
                case "InstrumentID": manageInstrumentIDWithToken(token)
                default: break
                }
            }
        }
        
        setDurationOfLastMeasure()
        finalizeDurationNodes()

        let scoreModel = makeScoreModel()
        
        // return something real
        return scoreModel
    }
    
    private func manageDurationNodeStackModeMeasure() {
        durationNodeStackMode = .Measure
        accumDurationInMeasure = DurationZero
    }
    
    private func manageDurationNodeStackModeIncrement() {
        durationNodeStackMode = .Increment
    }
    
    private func manageDurationNodeStackModeDecrement() {
        
    }
    
    
    /*
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
    */
    
    private func manageExtensionStartToken() {
        print("manage extension start")
        guard let pID = currentPerformerID, iID = currentInstrumentID else { return }
        let component = ComponentExtensionStart(performerID: pID, instrumentID: iID)
        addComponent(component)
    }
    
    private func manageExtensionStopToken() {
        print("manage extension stop")
        guard let pID = currentPerformerID, iID = currentInstrumentID else { return }
        let component = ComponentExtensionStop(performerID: pID, instrumentID: iID)
        addComponent(component)
    }
    
    private func managePerformerIDWithToken(token: Token) {
        currentPerformerID = (token as? TokenString)?.value
    }
    
    private func manageInstrumentIDWithToken(token: Token) {
        currentInstrumentID = (token as? TokenString)?.value
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
        
        print("manage perf decl: token \(container)")
        
        var performerID: String {
            for token in container.tokens {
                switch token.identifier {
                case "PerformerID":
                    return (token as! TokenString).value
                default: break
                }
            }
            return ""
        }
        
        // Create the ordered dictionary that will contain the order dictionary for this PID
        var instrumentIDsAndInstrumentTypesByPerformerID = OrderedDictionary<
            String, OrderedDictionary<String, InstrumentType>
        >()
        
        // Initialize the ordered dictionary for this PID
        instrumentIDsAndInstrumentTypesByPerformerID[performerID] = OrderedDictionary<
            String, InstrumentType
        >()
        
        // Same as above but short name
        var dictForPID = instrumentIDsAndInstrumentTypesByPerformerID[performerID]!
        
        // Keep adding pairs of InstrumentIDs and InstrumentTypes as they come
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
        self.instrumentIDAndInstrumentTypesByPerformerID[performerID] = dictForPID
    }
    
    private func manageMeasureToken() {
        
        print("manage measure token")
        
        setDurationOfLastMeasure()
        let measure = Measure(offsetDuration: currentMeasureDurationOffset)
        measures.append(measure)
        
        
        accumDurationInMeasure = DurationZero
        
        print("measures: \(measures)")
        
        // set default duration node stacking behavior
        durationNodeStackMode = .Measure
    }
    
    private func setDurationOfLastMeasure() {
        if measures.count == 0 { return }
        
        // pop last measure to modify
        var lastMeasure = measures.removeLast()
        lastMeasure.duration = accumDurationInMeasure
        
        // push last measure back on stack
        measures.append(lastMeasure)
        
        // set location of next measure to be created
        currentMeasureDurationOffset += lastMeasure.duration
    }
    
    
    
    private func manageRootDurationToken(token: Token) {
        if let tokenDuration = token as? TokenDuration {
            let rootDurationNode = DurationNode(duration: Duration(tokenDuration.value))
            setOffsetDurationForNewRootDurationNode(rootDurationNode)
            addRootDurationNode(rootDurationNode)
            accumTotalDuration += rootDurationNode.duration
            accumDurationInMeasure += rootDurationNode.duration
            currentDurationNodeDepth = 0
        }
    }

    private func manageInternalDurationToken(token: Token) {
        if let tokenInt = token as? TokenInt, indentationLevel = tokenInt.indentationLevel {

            // Pop the necessary amount of DurationNodeContainers from the stack
            let depth = indentationLevel - 1
            if depth < currentDurationNodeDepth {
                let amount = currentDurationNodeDepth - depth
                durationNodeContainerStack.pop(amount: amount)
            }
            
            // Add new Internal DurationNode with Beats
            let beats = tokenInt.value
            if let lastDurationNode = durationNodeContainerStack.top {
                let lastDurationNodeContainer = lastDurationNode.addChildWithBeats(beats)
                durationNodeContainerStack.push(lastDurationNodeContainer)
                currentDurationNodeDepth = depth
            }
        }
    }
    
    private func manageLeafNodeDurationToken(token: Token) {
        if let tokenInt = token as? TokenInt, indentationLevel = tokenInt.indentationLevel {

            // Pop the necessary amount of DurationNodeContainers from the stack
            let depth = indentationLevel - 1
            if depth < currentDurationNodeDepth {
                let amount = currentDurationNodeDepth - depth
                durationNodeContainerStack.pop(amount: amount)
            }
            
            // Add new Leaf DurationNode
            let beats = tokenInt.value
            if let lastDurationNode = durationNodeContainerStack.top {
                let lastDurationNodeChild = lastDurationNode.addChildWithBeats(beats)
                currentDurationNodeLeaf = lastDurationNodeChild
                currentDurationNodeDepth = depth
            }
        }
    }
    
    private func manageSlurStartToken() {
        guard let pID = currentPerformerID, iID = currentInstrumentID else { return }
        let component = ComponentSlurStart(performerID: pID, instrumentID: iID)
        addComponent(component)
    }
    
    private func manageSlurStopToken() {
        guard let pID = currentPerformerID, iID = currentInstrumentID else { return }
        let component = ComponentSlurStop(performerID: pID, instrumentID: iID)
        addComponent(component)
    }
    
    private func managePitchTokenContainer(container: TokenContainer) {
        var pitches: [Float] = []
        for token in container.tokens {
            if let spannerStart = token as? TokenContainer
                where spannerStart.identifier == "SpannerStart"
            {
                // manage glissando
                // add glissando component
            }
            else if let tokenFloat = token as? TokenFloat {
                pitches.append(tokenFloat.value)
            }
        }
        guard let pID = currentPerformerID, iID = currentInstrumentID else { return }
        let component = ComponentPitch(performerID: pID, instrumentID: iID, values: pitches)
        addComponent(component)
    }
    
    private func manageDynamicMarkingTokenContainer(container: TokenContainer) {
        guard let pID = currentPerformerID, iID = currentInstrumentID else { return }
        for token in container.tokens {
            switch token.identifier {
            case "Value":
                let value = (token as! TokenString).value
                addDynamicMarkingComponentWithValue(value, performerID: pID, instrumentID: iID)
            case "SpannerStart":
                let component = ComponentDynamicMarkingSpannerStart(
                    performerID: pID, instrumentID: iID)
                addComponent(component)
                
            case "SpannerStop":
                let component = ComponentDynamicMarkingSpannerStop(
                    performerID: pID, instrumentID: iID)
                addComponent(component)
            default: break
            }
        }
    }
    
    private func addDynamicMarkingComponentWithValue(value: String,
        performerID: String, instrumentID: String
    )
    {
        let component = ComponentDynamicMarking(
            performerID: performerID,
            instrumentID: instrumentID,
            value: value
        )
        addComponent(component)
    }
    
    private func manageArticulationTokenContainer(container: TokenContainer) {
        var markings: [String] = []
        for token in container.tokens {
            if let tokenString = token as? TokenString { markings.append(tokenString.value) }
        }
        guard let pID = currentPerformerID, iID = currentInstrumentID else { return }
        let component = ComponentArticulation(performerID: pID, instrumentID: iID, values: markings)
        addComponent(component)
    }
    
    private func manageSpannerStartTokenContainer(container: TokenContainer) {

    }

    private func setOffsetDurationForNewRootDurationNode(rootDurationNode: DurationNode) {
        let offsetDuration: Duration
        switch durationNodeStackMode {
        case .Measure:
            offsetDuration = currentMeasureDurationOffset
            accumTotalDuration = currentMeasureDurationOffset
            //accumDurationInMeasure = rootDurationNode.duration
        case .Increment:
            offsetDuration = accumTotalDuration
        case .Decrement:
            if let lastDurationNode = durationNodeContainerStack.top {
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
        print("add root durationNode: \(rootDurationNode)")
        durationNodes.append(rootDurationNode)
        durationNodeContainerStack = Stack(items: [rootDurationNode])
    }
    
    private func finalizeDurationNodes() {
        for durationNode in durationNodes {
            (durationNode.root as! DurationNode).matchDurationsOfTree()
            (durationNode.root as! DurationNode).scaleDurationsOfChildren()
            (durationNode.root as! DurationNode).setOffsetDurationOfChildren()
        }
    }
    
    private func addComponent(component: Component) {
        currentDurationNodeLeaf?.addComponent(component)
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