//
//  InstrumentString.swift
//  denm_view
//
//  Created by James Bean on 10/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public class InstrumentString: Instrument {
    
    // sounding pitch graph
    // fingered pitch graph
    
    public var staff_soundingPitch: Graph?
    public var staff_fingeredPitch: Graph?
    public var tablature: GraphContinuousController?
    
    public override init() { super.init() }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public override func createGraphsWithComponent(component: Component, andG g: CGFloat) {
        if !component.isGraphBearing { return }
        
        switch component {
        case let pitch as ComponentPitch: break
        case let stringArtificialHarmonic as ComponentStringArtificialHarmonic: break
        case let graphNode as ComponentGraphNode: break
        case let waveform as ComponentWaveform: break
        default: break
        }
        
        // TODO: flesh out -- reimplement
        
        /*
        switch component.property {
        case .Pitch, .StringArtificialHarmonic:
            
            if graphByID["soundingPitch"] == nil {
                let soundingPitch = Staff(id: "soundingPitch", g: g)
                if let (clefType, transposition, _) = instrumentType?
                    .preferredClefsAndTransposition.first
                {
                    soundingPitch.id = "soundingPitch"
                    soundingPitch.pad_bottom = g
                    soundingPitch.pad_top = g
                    soundingPitch.addClefWithType(clefType, withTransposition: transposition, atX: 15)
                    addGraph(soundingPitch, isPrimary: false)
                    staff_soundingPitch = soundingPitch
                }
                else { fatalError("Can't find a proper clef and transposition") }
            }
            
            if graphByID["fingeredPitch"] == nil {
                let fingeredPitch = Staff(id: "fingeredPitch", g: g)
                if let (clefType, transposition, _) = instrumentType?
                    .preferredClefsAndTransposition.first
                {
                    fingeredPitch.id = "fingeredPitch"
                    fingeredPitch.pad_bottom = g
                    fingeredPitch.pad_top = g
                    fingeredPitch.addClefWithType(clefType,
                        withTransposition: transposition, atX: 15
                    ) // HACK
                    addGraph(fingeredPitch)
                    staff_fingeredPitch = fingeredPitch
                }
                else { fatalError("Can't find a proper clef and transposition") }
            }
            
        /*
        case .Pitch:
            
            // CREATE GRAPH IF NECESSARY
            if graphByID["staff"] == nil {
                let staff = Staff(id: "staff", g: g)
                if let (clefType, transposition, _) = instrumentType?
                    .preferredClefsAndTransposition.first
                {
                    staff.id = "staff" // hack
                    staff.pad_bottom = g
                    staff.pad_top = g
                    staff.addClefWithType(clefType, withTransposition: transposition, atX: 15) // HACK
                    addGraph(staff)
                }
                else { fatalError("Can't find a proper clef and transposition") }
            }
        */
        case .Node:
            if graphByID["node"] == nil {
                let graph = GraphContinuousController(id: "node")
                graph.height = 25 // hack
                graph.pad_bottom = 5 // hack
                graph.pad_top = 5 // hack
                graph.addClefAtX(15) // hack
                addGraph(graph)
            }
        case .Wave:
            if graphByID["wave"] == nil {
                let graph = GraphWaveform(id: "wave", height: 60, width: frame.width) // hack
                graph.addClefAtX(15) // hack
                addGraph(graph)
            }
        default: break
        }
        // ------------------------------------------------------------------------------------
        */
    }
    
    public override func createInstrumentEventWithComponent(component: Component,
        atX x: CGFloat, withStemDirection stemDirection: StemDirection
    ) -> InstrumentEvent?
    {
        
        switch component {
        case let pitch as ComponentPitch: break
        case let stringArtificialHarmonic as ComponentStringArtificialHarmonic: break
        case let graphNode as ComponentGraphNode: break
        case let waveform as ComponentWaveform: break
        default: break
        }
        
        /*
        //let pID = component.pID, iID = component.iID
        switch component.property {
        case .Pitch, .StringArtificialHarmonic:
            
            let instrumentEvent = InstrumentEvent(x: x, stemDirection: stemDirection)
            if let fingeredPitch = graphByID["fingeredPitch"] {
                let graphEvent = fingeredPitch.startEventAtX(x, withStemDirection: stemDirection)
                instrumentEvent.addGraphEvent(graphEvent)
            }
            if let soundingPitch = graphByID["soundingPitch"] {
                let graphEvent = soundingPitch.startEventAtX(x, withStemDirection: stemDirection)
                graphEvent.isConnectedToStem = false
                graphEvent.s = 0.75
                instrumentEvent.addGraphEvent(graphEvent)
                
            }
            instrumentEvent.instrument = self
            return instrumentEvent
            
            /*
            if let staff = graphByID["staff"] {
                let graphEvent = staff.startEventAtX(x, withStemDirection: stemDirection)
                
                let instrumentEvent = InstrumentEvent(x: x, stemDirection: stemDirection)
                instrumentEvent.instrument = self
                // for now, just add the single graph event
                instrumentEvent.addGraphEvent(graphEvent)
                print("instrumentEvent: \(instrumentEvent)")

                return instrumentEvent
            }
            */
            
        case .Node(let value):
            assert(graphByID["node"] != nil, "can't find node graph")
            if let graph = graphByID["node"] {
                let graphEvent = (graph as? GraphContinuousController)!.addNodeEventAtX(x,
                    withValue: value, andStemDirection: stemDirection
                )
                
                let instrumentEvent = InstrumentEvent(x: x, stemDirection: stemDirection)
                instrumentEvent.instrument = self
                // for now, just add the single graph event
                instrumentEvent.addGraphEvent(graphEvent)
                return instrumentEvent
            }
            /*
            case .Wave:
            assert(graphByID["wave"] != nil, "can't find wave graph")
            if let graph = graphByID["wave"] {
            let graphEvent = (graph as? GraphWaveform)?.addSampleWaveformAtX(x,
            withDuration: Duration(2,8), andBeatWidth: 120
            ) // HACK
            return graphEvent
            }
            */
        default:
            break
        }
        */
        return nil
    }
}
