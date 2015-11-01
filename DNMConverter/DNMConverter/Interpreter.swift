//
//  Interpreter.swift
//  denm_parser
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//


import Foundation
import DNMUtility
import DNMModel

internal class Interpreter {
    
    internal var actions: [Action]
    
    private var durationAccumulationMode: DurationAccumulationMode = .Increment
    
    private var durationNodeStack: [DurationNode] = []
    private var curDurationNodeLeaf: DurationNode?
    
    // SHOULD JUST USE THESE
    private var accumDurInCurMeasure: Duration = DurationZero
    private var accumTotalDur: Duration = DurationZero
    private var accumMeasureTotalDur: Duration = DurationZero
    
    private var curMeasureOffset: Duration = DurationZero
    private var curDurationNodeOffset: Duration = DurationZero
    
    // tuplet shit
    private var curDepth: Int = 0

    // THIS SHOULDN'T BE NECEESSARY -- DEPRECATE
    private var accumDurInCurMeasureByID: [String : Duration] = [:]
    private var accumTotalDurByID: [String : Duration] = [:]
    
    // DEPRECATE
    private var curID: String?
    
    private var iIDsByPID: [String : [String]] = [:]
    private var iIDsAndInstrumentTypesByPID: [ [ String : [(String, InstrumentType)] ] ] = []
    
    internal init(actions: [Action]) {
        self.actions = actions
    }
    
    internal func makeScoreInfo() -> ScoreInfo {
        var pID: String = ""
        var iID: String = ""
        var measures: [Measure] = []
        var durationNodes: [DurationNode] = []
        var tempoMarkings: [TempoMarking] = []
        var rehearsalMarkings: [RehearsalMarking] = []
        
        for action in actions {
            var component: Component?
            switch action {
            case .IIDsAndInstrumentTypesByPID(let iIDsAndInstrumentTypesByPID):
                
                // Convert String representation of InstrumentType to InstrumentType proper
                for iIDAndInstrumentType in iIDsAndInstrumentTypesByPID {
                    for (pID, arrayOfIIDsAndInstrumentTypes) in iIDAndInstrumentType {
                        var dictToAdd: [ String: [(String, InstrumentType)] ] = [ pID : [] ]
                        for iIDAndInstrumentType in arrayOfIIDsAndInstrumentTypes {
                            let iID = iIDAndInstrumentType.0
                            let value = iIDAndInstrumentType.1
                            if let instrumentType = InstrumentType(rawValue: value) {
                                dictToAdd[pID]!.append((iID, instrumentType))
                                
                                // add to iIDsByPID
                                if iIDsByPID[pID] == nil { iIDsByPID[pID] = [iID] }
                                else { iIDsByPID[pID]!.append(iID) }
                            }
                            else { fatalError("Invalid Instrument Type: \(value)") }
                        }
                        self.iIDsAndInstrumentTypesByPID.append(dictToAdd)
                    }
                }
            case .PID(let string):                
                if iIDsByPID[string] == nil { fatalError("Undeclared Performer ID") }
                pID = string
            case .IID(let string):
                if iIDsByPID[pID] == nil { fatalError("Undeclared Performer ID") }
                else if !iIDsByPID[pID]!.contains(string) { fatalError("Undeclared Instrument ID") }
                iID = string
            case .DurationAccumulationMode(let mode):
                switch mode {
                case "+": durationAccumulationMode = .Increment
                case "-": durationAccumulationMode = .Decrement
                case "|":
                    durationAccumulationMode = .Measure
                    accumDurInCurMeasure = DurationZero
                default:
                    assertionFailure("UNDOCUMENTED DURATION ACCUMULATION MODE")
                }
            case .Measure:
                setDurationOfLastMeasureOfMeasures(&measures)
                // encapsulate properly
                let measure = Measure(offsetDuration: curMeasureOffset)
                measures.append(measure)
                accumDurInCurMeasure = DurationZero
            case .HideTimeSignature:
                if var lastMeasure = measures.last {
                    lastMeasure.setHasTimeSignature(false)
                    measures.removeLast()
                    measures.append(lastMeasure)
                }
            case .RehearsalMarking(let type):
                let rehearsalMarking = RehearsalMarking(
                    index: 0, type: type, offsetDuration: curMeasureOffset
                )
                rehearsalMarkings.append(rehearsalMarking)
            case .DurationNodeRoot(let duration):
                
                // CREATE DURATION NODE
                // encapsulate ----------------------------------------------------------------
                let (beats, subdivision) = duration
                let durationNodeRoot = DurationNode(duration: Duration(beats, subdivision))
                // ----------------------------------------------------------------------------
                
                // SET OFFSET DURATION OF DURATION NODE
                // encapsulate ----------------------------------------------------------------
                let offsetDuration: Duration
                switch durationAccumulationMode {
                case .Measure:
                    offsetDuration = curMeasureOffset
                    accumTotalDur = curMeasureOffset // reset master counter to measure offset
                    accumDurInCurMeasure = durationNodeRoot.duration
                case .Increment:
                    offsetDuration = accumTotalDur
                    accumDurInCurMeasure += durationNodeRoot.duration
                case .Decrement:
                    if let lastDurationNode = durationNodeStack.last {
                        offsetDuration = lastDurationNode.offsetDuration
                        accumTotalDur = offsetDuration
                        accumDurInCurMeasure -= lastDurationNode.duration
                    }
                    else { offsetDuration = DurationZero }
                }
                durationNodeRoot.offsetDuration = offsetDuration
                // ----------------------------------------------------------------------------
                
                durationNodes.append(durationNodeRoot)
                durationNodeStack = [durationNodeRoot]
                accumTotalDur += durationNodeRoot.duration
                curDepth = 0
                
            case .DurationNodeInternal(let beats, let depth):
                if depth < curDepth {
                    let amount = curDepth - depth
                    durationNodeStack.removeLast(amount: amount)
                }
                durationNodeStack.last!.addChildWithBeats(beats)
                let dn = durationNodeStack.last!.children.last! as! DurationNode
                durationNodeStack.append(dn)
                curDepth = depth
            case .DurationNodeLeaf(let beats, let depth):
                if depth < curDepth {
                    let amount = curDepth - depth
                    durationNodeStack.removeLast(amount: amount)
                }
                durationNodeStack.last!.addChildWithBeats(beats)
                let dn = durationNodeStack.last!.children.last! as! DurationNode
                curDurationNodeLeaf = dn
                curDepth = depth
            case .Rest:
                component = ComponentRest(pID: pID, iID: iID)
            case .ExtensionStart:
                component = ComponentExtensionStart(pID: pID, iID: iID)
            case .ExtensionStop:
                component = ComponentExtensionStop(pID: pID, iID: iID)
            case .Pitch(let pitches):
                component = ComponentPitch(pID: pID, iID: iID, pitches: pitches)
            case .Dynamic(let marking):
                component = ComponentDynamic(id: pID, pID: pID, iID: iID, marking: marking)
            case .DMLigatureStart:
                component = ComponentDMLigatureStart(id: pID, pID: pID, iID: iID, type: 1) // temp
            case .DMLigatureStop:
                component = ComponentDMLigatureStop(id: pID, pID: pID, iID: iID)
            case .Articulation(let markings):
                component = ComponentArticulation(pID: pID, iID: iID, markings: markings)
            case .SlurStart:
                // to-do: make id an optional thing, should be set in Parser
                component = ComponentSlurStart(id: pID, pID: pID, iID: iID)
            case .SlurStop:
                // see above
                component = ComponentSlurStop(id: pID, pID: pID, iID: iID)
            case .NonMetrical:
                durationNodeStack.last?.isMetrical = false
            case .NonNumerical:
                durationNodeStack.last?.isNumerical = false
            case .Node(let value):
                component = ComponentNode(pID: pID, iID: iID, value: value)
            case .EdgeStart(let hasDashes):
                component = ComponentEdgeStart(pID: pID, iID: iID, hasDashes: hasDashes)
            case .EdgeStop:
                component = ComponentEdgeStop(pID: pID, iID: iID)
            case .Wave:
                component = ComponentWave(pID: pID, iID: iID)
            case .Tempo(let value, let subdivisionValue):
                
                let oD: Duration
                if let lastDurationNode = durationNodeStack.last {
                    oD = lastDurationNode.offsetDuration + lastDurationNode.duration
                }
                else { oD = curMeasureOffset }
                
                let tempoMarking = TempoMarking(
                    value: value, subdivisionLevel: subdivisionValue, offsetDuration: oD
                )
                tempoMarkings.append(tempoMarking)
            case .Label(let value):
                component = ComponentLabel(pID: pID, iID: iID, value: value)
            case .StringArtificialHarmonic(let pitch):
                component = ComponentStringArtificialHarmonic(pID: pID, iID: iID, pitch: pitch)
            case .StringBowDirection(let value):
                component = ComponentStringBowDirection(pID: pID, iID: iID, bowDirection: value)
            case .StringNumber(let value):
                component = ComponentStringNumber(pID: pID, iID: iID, romanNumeral: value)
            case .GlissandoStart:
                component = ComponentGlissandoStart(pID: pID, iID: iID)
            case .GlissandoStop:
                component = ComponentGlissandoStop(pID: pID, iID: iID)
            default:
                break
            }
            if let component = component { curDurationNodeLeaf?.addComponent(component) }
        }
        
        setDurationOfLastMeasureOfMeasures(&measures)
        cleanUpDurationNodes(durationNodes)
        
        
        // this will probably continue being in flux
        let scoreInfo = ScoreInfo(
            iIDsAndInstrumentTypesByPID: iIDsAndInstrumentTypesByPID,
            measures: measures,
            tempoMarkings: tempoMarkings,
            durationNodes: durationNodes,
            rehearsalMarkings: rehearsalMarkings
        )
        return scoreInfo
    }
    
    private func cleanUpDurationNodes(durationNodes: [DurationNode]) {
        for durationNode in durationNodes {
            (durationNode.root as! DurationNode).matchDurationsOfTree()
            (durationNode.root as! DurationNode).scaleDurationsOfChildren()
            (durationNode.root as! DurationNode).setOffsetDurationOfChildren()
        }
    }
    
    private func setaccumDurInCurMeasureForID(id: String) {
        // something: refactor above
    }
    
    private func setDurationOfLastMeasureOfMeasures(inout measures: [Measure]) {
        
        if var lastMeasure = measures.last {
            lastMeasure.duration = accumDurInCurMeasure
            measures.removeLast()
            measures.append(lastMeasure)
            curMeasureOffset += lastMeasure.duration
        }
        
        /*
        if measures.count > 0 {
            /*
            /*
            // get max measure dur
            var maxMeasureDur: Duration = DurationZero
            for (_, accumDurInCurMeasure) in accumDurInCurMeasureByID {
                if accumDurInCurMeasure > maxMeasureDur { maxMeasureDur = accumDurInCurMeasure }
            }
            */
            
            // set measure size to max measure dur, probably throw error if not all ==
            //measures.last!.setDuration(maxMeasureDur)
            //measures.last!.duration = maxMeasureDur
            measures.last!.duration = maxMeasureDur
            curMeasureOffset += measures.last!.duration
            */
         
            measures.last!.duration = accumDurInCurMeasure
        }
        */
        
        for (id, _) in accumDurInCurMeasureByID { accumDurInCurMeasureByID[id]! = DurationZero }
    }
}

internal enum DurationAccumulationMode {
    case Measure
    case Increment
    case Decrement
}

