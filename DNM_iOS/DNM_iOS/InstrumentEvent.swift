//
//  InstrumentEvent.swift
//  denm_view
//
//  Created by James Bean on 10/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

// consider protocol for Event
public class InstrumentEvent: CALayer {

    public var x: CGFloat = 0
    
    public var instrument: Instrument?
    public var graphEvents: [GraphEvent] = []
    public var stem: Stem?
    public var stemDirection: StemDirection = .Down
    
    public var minInfoY: CGFloat { return getMinInfoY() }
    public var maxInfoY: CGFloat { return getMaxInfoY() }
    
    public var stemEndY: CGFloat { return getStemEndY() } // make getter
    
    public var hasOnlyRestEvents: Bool {
        for graphEvent in graphEvents { if !(graphEvent is GraphEventRest) { return false } }
        return true
    }
    
    public init(x: CGFloat, stemDirection: StemDirection, stem: Stem? = nil) {
        super.init()
        self.x = x
        self.stemDirection = stemDirection
        self.stem = stem
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addGraphEvent(graphEvent: GraphEvent) {
        graphEvents.append(graphEvent)
    }
    
    public func addArticulationWithType(type: ArticulationType) {
        for graphEvent in graphEvents { graphEvent.addArticulationWithType(type) }
    }
    
    private func getMinInfoY() -> CGFloat {
        if graphEvents.count == 0 { return 0 }
        if let instrument = instrument {
            var minInfoY: CGFloat?
            for graphEvent in graphEvents {
                let minInfoY_local = graphEvent.minInfoY
                var inInstrContext: CGFloat = 0
                if let graph = graphEvent.graph where graph is Staff {
                    inInstrContext = instrument.convertY(minInfoY_local, fromLayer: graph.eventsLayer)
                }
                else if let graph = graphEvent.graph {
                    inInstrContext = instrument.convertY(minInfoY_local, fromLayer: graph)
                }
                if minInfoY == nil { minInfoY = inInstrContext }
                else if inInstrContext > maxInfoY { minInfoY = inInstrContext }
            }
            return minInfoY!
        }
        return 0
        
        //return graphEvents.sort { $0.minInfoY < $1.minInfoY }.first!.minInfoY
        // must convert to instrument
    }
    
    private func getMaxInfoY() -> CGFloat {
        if graphEvents.count == 0 { return 0 }
        if let instrument = instrument {
            var maxInfoY: CGFloat?
            for graphEvent in graphEvents {
                
                // if this graph event is not connected to a stem, pass (e.g.: sounding pitch)
                if !graphEvent.isConnectedToStem { continue }
                
                let maxInfoY_local = graphEvent.maxInfoY
                var inInstrContext: CGFloat = 0
                if let graph = graphEvent.graph where graph is Staff {
                    inInstrContext = instrument.convertY(maxInfoY_local, fromLayer: graph.eventsLayer)
                }
                else if let graph = graphEvent.graph {
                    inInstrContext = instrument.convertY(maxInfoY_local, fromLayer: graph)
                }
                if maxInfoY == nil { maxInfoY = inInstrContext }
                else if inInstrContext > maxInfoY { maxInfoY = inInstrContext }
            }
            return maxInfoY!
        }
        return 0
    }
    
    private func getStemEndY() -> CGFloat {
        switch stemDirection {
        case .Up: return minInfoY
        case .Down: return maxInfoY
        }
    }
}