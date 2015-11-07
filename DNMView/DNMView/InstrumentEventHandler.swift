//
//  InstrumentEventHandler.swift
//  denm_view
//
//  Created by James Bean on 10/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

// when where how to add graphEvents to instrumentEvent?

public class InstrumentEventHandler {
    
    public var bgEvent: BGEvent?
    public var instrumentEvent: InstrumentEvent?
    public var stem: Stem?
    public var system: System?
    
    private var stemDirection: StemDirection { get { return getStemDirection() } }
    
    public init(bgEvent: BGEvent?, instrumentEvent: InstrumentEvent? = nil, system: System? = nil) {
        self.bgEvent = bgEvent
        self.instrumentEvent = instrumentEvent
        self.system = system
    }
    
    public func decorateInstrumentEvent() {
        if bgEvent == nil { return }
        if instrumentEvent == nil { return }
        let x = bgEvent!.x_objective!
        for component in bgEvent!.durationNode.components {
            switch component.property {
            case .Rest:
                for graphEvent in instrumentEvent!.graphEvents {
                    graphEvent.isRest = true
                    graphEvent.graph?.stopLinesAtX(graphEvent.x)
                }
            case .StringArtificialHarmonic(let pitch):
                for graphEvent in instrumentEvent!.graphEvents {
                    if graphEvent.graph! is Staff && graphEvent.graph!.id == "fingeredPitch" {
                        let fingeredPitch = Pitch(midi: MIDI(pitch))
                        let harmonicPressurePitch = Pitch(midi: MIDI(pitch + 5))
                        (graphEvent as? StaffEvent)?.addPitch(fingeredPitch, withNoteheadType: .Ord)
                        (graphEvent as? StaffEvent)?.addPitch(harmonicPressurePitch, withNoteheadType: .DiamondEmpty)
                    }
                    else if graphEvent.graph! is Staff && graphEvent.graph!.id == "soundingPitch" {
                        let soundingPitch = Pitch(midi: MIDI(pitch + 24)) // hack for touch_4 harm
                        (graphEvent as? StaffEvent)?.addPitch(soundingPitch,
                            withNoteheadType: .CircleEmpty
                        )
                    }
                }
            case .Pitch(let pitches):
                for graphEvent in instrumentEvent!.graphEvents {
                    if let _ = graphEvent.graph as? Staff {
                        for p in pitches {
                            let pitch = Pitch(midi: MIDI(p))
                            (graphEvent as? StaffEvent)?.addPitch(pitch)
                        }
                    }
                }
            case .StringBowDirection(let bowDirection):
                for graphEvent in instrumentEvent!.graphEvents {
                    system?.addComponentType("articulations", withID: component.pID)
                    if let directionType = BowDirection(rawValue: bowDirection) {
                        if let articulation = ArticulationStringBowDirection.withType(directionType) {
                            articulation.build()
                            graphEvent.addArticulation(articulation)
                        }
                    }
                }
            case .StringNumber(let romanNumeral):
                for graphEvent in instrumentEvent!.graphEvents {
                    let articulation = ArticulationStringNumber(romanNumeralString: romanNumeral)
                    articulation.build()
                    graphEvent.addArticulation(articulation)
                }
            case .Node(_):
                // currently decorated automatically when intiialized, will be extended later
                break
            case .EdgeStart(let spannerArguments):

                for graphEvent in instrumentEvent!.graphEvents {
                    if let ccGraph = graphEvent.graph as? GraphContinuousController {
                        ccGraph.startEdgeAtX(x, spannerArguments: spannerArguments)
                    }
                }
            case .EdgeStop:
                break
            case .StringNumber(_):
                break
            case .StringBowDirection(_):
                break
            case .Articulation(let markings):
                for graphEvent in instrumentEvent!.graphEvents {
                    // perhaps place this somewhere else...
                    system?.addComponentType("articulations", withID: component.pID)
                    for marking in markings {
                        if let type = ArticulationTypeWithMarking(marking) {
                            // switch GraphEventArticulation vs StemArticulation
                            switch type {
                            case .Tremolo: bgEvent!.addStemArticulationType(type)
                            default: graphEvent.addArticulationWithType(type)
                            }
                        }
                    }
                }
            case .Label(let value):
                
                for graphEvent in instrumentEvent!.graphEvents {
                    let label = Label(x: 0, top: 0, height: 20, text: value)
                    graphEvent.addLabel(label)
                }
            default: break
            }
        }
    }
    

    
    public func repositionStemInContext(context: CALayer) {
        if let stem = stem {
            if let bgStratum = bgEvent?.bgStratum {
                if instrumentEvent == nil && stem.superlayer == nil {
                    context.insertSublayer(stem, atIndex: 1) // after barlinesLayer?
                }
                else {
                    
                    // if bg stratum is invisible, remove stem
                    if bgStratum.superlayer == nil { stem.removeFromSuperlayer() }
                    else {
                        
                        // NEED TO CHECK THIS, different context than graph
                        
                        
                        if let _ = instrumentEvent?.instrument {
                            if stem.superlayer == nil {
                                context.insertSublayer(stem, atIndex: 1) // after barlinesLayer ?
                            }
                        }
                        /*
                        else if stem.superlayer != nil {
                            stem.removeFromSuperlayer()
                        }
                        */
                    }
                }
            }
            
            if stem.superlayer != nil {
                let beamEndY = getBeamEndYInContext(context)
                let infoEndY = getInfoEndYInContext(context)
                stem.setBeamEndY(beamEndY, andInfoEndY: infoEndY)
            }
        }
    }
    
    public func makeStemInContext(context: CALayer) -> Stem {
        let infoEndY = getInfoEndYInContext(context)
        let beamEndY = getBeamEndYInContext(context)
        if let stem_x = bgEvent?.x_objective {
            let stem = Stem(x: stem_x, beamEndY: beamEndY, infoEndY: infoEndY)
            stem.bgEvent = bgEvent
            stem.instrumentEvent = instrumentEvent
            bgEvent?.stem = stem
            instrumentEvent?.stem = stem
            self.stem = stem
            return stem
        }
        else { fatalError("could not create stem") }
    }
    
    private func getInfoEndYInContext(context: CALayer) -> CGFloat {
        if bgEvent == nil { return 0 }
        
        if let instrumentEvent = instrumentEvent {
            return context.convertY(instrumentEvent.stemEndY,
                fromLayer: instrumentEvent.instrument!
            )
        }
        else {
            if let bgStratum = bgEvent?.bgStratum {
                switch bgStratum.stemDirection {
                case .Down:
                    if let deNode = bgStratum.deNode {
                        return context.convertY(deNode.frame.maxY, fromLayer: bgStratum)
                    }
                    else {
                        return context.convertY(bgStratum.frame.height, fromLayer: bgStratum)
                    }
                case .Up:
                    if let deNode = bgStratum.deNode {
                        return context.convertY(deNode.frame.minY, fromLayer: bgStratum)
                    }
                    else { return context.convertY(0, fromLayer: bgStratum) }
                }
            }
        }
        return 0
    }
    
    private func getBeamEndYInContext(context: CALayer) -> CGFloat {
        if let bgStratum = bgEvent?.bgStratum {
            return context.convertY(bgStratum.beamEndY, fromLayer: bgStratum.beamsLayerGroup!)
        }
        else { return 0 }
    }

    // NOT CURRENTLY USED
    private func getStemDirection() -> StemDirection {
        return .Down
    }
    
    // deprecate, but first, pull necessary bits
    public func _decorateInstrumentEvent() {
        if bgEvent == nil { return }
        if instrumentEvent == nil { return }
        
        for graphEvent in instrumentEvent!.graphEvents {
            for component in bgEvent!.durationNode.components {
                switch component.property {
                case .Rest:
                    graphEvent.isRest = true
                    graphEvent.graph?.stopLinesAtX(graphEvent.x)
                case .Articulation(let markings):
                    system?.addComponentType("articulations", withID: component.pID)
                    for marking in markings {
                        if let type = ArticulationTypeWithMarking(marking) {
                            // switch GraphEventArticulation vs StemArticulation
                            switch type {
                            case .Tremolo:
                                bgEvent!.addStemArticulationType(type)
                            default:
                                graphEvent.addArticulationWithType(type)
                            }
                        }
                    }
                case .StringBowDirection(let bowDirection):
                    system?.addComponentType("articulations", withID: component.pID)
                    if let directionType = BowDirection(rawValue: bowDirection) {
                        if let articulation = ArticulationStringBowDirection.withType(directionType) {
                            articulation.build()
                            graphEvent.addArticulation(articulation)
                        }
                    }
                case .StringNumber(let romanNumeral):
                    let articulation = ArticulationStringNumber(romanNumeralString: romanNumeral)
                    articulation.build()
                    graphEvent.addArticulation(articulation)
                    
                case .Pitch, .StringArtificialHarmonic:
                    system?.addComponentType("pitches", withID: component.pID)
                    graphEvent.graph!.startLinesAtX(graphEvent.x)
                    
                case .GlissandoStart:
                    // SOMETHING
                    break
                case .GlissandoStop:
                    // testing hack
                    graphEvent.graph!.addGlissandoFromGraphEventAtIndex(0, toIndex: 1)
                case .Node(_):
                    // happens automatically when eventHandler is created within System
                    break
                case .Label(let value):
                    let label = Label(x: 0, top: 0, height: 20, text: value)
                    graphEvent.addLabel(label)
                default: break
                }
                
                // SWITCH HERE FOR SPECIFIC GRAPH TYPES
                
                // Do Staff things
                if let staffEvent = graphEvent as? StaffEvent {
                    switch component.property {
                    case .Pitch(let pitches):
                        for pitch in pitches {
                            staffEvent.addPitch(Pitch(midi: MIDI(pitch)))
                        }
                    case .StringArtificialHarmonic(let pitch):
                        
                        // do this within InstrumentEvent
                        let fingeredPitch = Pitch(midi: MIDI(pitch))
                        let harmonicPressurePitch = Pitch(midi: MIDI(pitch + 5))
                        staffEvent.addPitch(fingeredPitch, withNoteheadType: .Ord)
                        staffEvent.addPitch(harmonicPressurePitch, withNoteheadType: .DiamondEmpty)
                    default: break
                    }
                }
            }
        }
    }
}
