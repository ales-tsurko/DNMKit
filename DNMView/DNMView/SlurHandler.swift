//
//  SlurHandler.swift
//  denm_view
//
//  Created by James Bean on 9/29/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class SlurHandler {
    
    public var id: String = ""
    public var graphEvent0: GraphEvent?
    public var graphEvent1: GraphEvent?
    public var slur: Slur?
    public var system: System?
    public var g: CGFloat = 10
    
    public var connectionPoint0: CGPoint { get { return getConnectionPoint0() } }
    public var connectionPoint1: CGPoint { get { return getConnectionPoint1() } }
    
    public init(
        id: String,
        g: CGFloat = 10,
        graphEvent0: GraphEvent? = nil,
        graphEvent1: GraphEvent? = nil
    )
    {
        self.id = id
        self.g = g
        self.graphEvent0 = graphEvent0
        self.graphEvent1 = graphEvent1
    }
    
    // size? g?
    public func makeSlurInContext(context: CALayer) -> Slur? {
        if let graphEvent0 = graphEvent0, graphEvent1 = graphEvent1 {
            let point0 = getConnectionPoint0InContext(context)
            let point1 = getConnectionPoint1InContext(context)
            let stemDirection = graphEvent0.stemDirection // for now
            let slur = Slur(point1: point0, point2: point1, stemDirection: stemDirection, g: g)
            self.slur = slur
            return slur
        }
        else if let graphEvent0 = graphEvent0 where graphEvent1 == nil {
            let point0 = getConnectionPoint0InContext(context)
            let point1 = CGPointMake(context.frame.width + 20, point0.y) // hack x val
            let stemDirection = graphEvent0.stemDirection
            let slur = Slur(point1: point0, point2: point1, stemDirection: stemDirection, g: g)
            self.slur = slur
            return slur
        }
        else if let graphEvent1 = graphEvent1 where graphEvent0 == nil {
            let point1 = getConnectionPoint1InContext(context)
            let point0 = CGPointMake(-10, point1.y) // hack x val
            let stemDirection = graphEvent1.stemDirection
            let slur = Slur(point1: point0, point2: point1, stemDirection: stemDirection, g: g)
            self.slur = slur
            return slur
        }
        return nil
    }
    
    public func repositionInContext(context: CALayer) {

        if let slur = slur {
            
            /*
            if slur.superlayer == nil {
                if let graphEvent0 = graphEvent0, graphEvent1 = graphEvent1 {
                    if graphEvent0.graph!.instrument!.performer!.superlayer != nil &&
                        graphEvent1.graph!.instrument!.performer!.superlayer != nil
                    {
                        context.addSublayer(slur)
                    }
                }
            }
            else {
                if let graphEvent0 = graphEvent0, graphEvent1 = graphEvent1 {
                    if graphEvent0.graph!.instrument!.performer!.superlayer == nil ||
                        graphEvent1.graph!.instrument!.performer!.superlayer == nil
                    {
                        slur.removeFromSuperlayer()
                    }
                }
            }
            */
            
            // both ends within same system
            if let graphEvent0 = graphEvent0, graphEvent1 = graphEvent1 {
                
                let point0 = getConnectionPoint0InContext(context)
                let point1 = getConnectionPoint1InContext(context)
                slur.setPoint1(point0, andPoint2: point1) // why why why point1 and point2 wtf
                
                if let index0 = graphEvent0.graph!.events.indexOfObject(graphEvent0),
                    index1 = graphEvent1.graph!.events.indexOfObject(graphEvent1)
                {
                    print("reposition slur: index0: \(index0); index1: \(index1)")
                    
                    
                    switch graphEvent0.stemDirection {
                    case .Down:
                        var eventWithMaxY: GraphEvent?
                        if index1 > index0 + 1 {
                            for e in (index0 + 1)..<index1 {
                                let event = graphEvent0.graph!.events[e]
                                if eventWithMaxY == nil { eventWithMaxY = event }
                                else if event.maxY > eventWithMaxY!.maxY { eventWithMaxY = event }
                            }
                        }
                        
                        let x = eventWithMaxY!.x
                        let y = eventWithMaxY!.maxY + 0.5 * g // pad
                        
                        let point_local = CGPoint(x: x, y: y)
                        
                        let convertedPoint = context.convertPoint(point_local,
                            fromLayer: graphEvent0.graph!.eventsLayer
                        )
                        
                        print("slur.adjustToAvoidPoint: x: \(x); y: \(y)")
                        slur.adjustToAvoidPoint(convertedPoint)
                        slur.build()
                    case .Up:
                        // finish
                        
                        // then go on
                        
                        break
                    }
                    
                    
                   
                }
                

            }
            // frayed at end
            else if let graphEvent0 = graphEvent0 where graphEvent1 == nil {
                let point0 = getConnectionPoint0InContext(context)
                let point1 = CGPointMake(context.frame.width + 20, point0.y) // hack x val
                slur.setPoint1(point0, andPoint2: point1)
            }
            // frayed at beginning
            else if let graphEvent1 = graphEvent1 where graphEvent0 == nil {
                let point1 = getConnectionPoint1InContext(context)
                let point0 = CGPointMake(-10, point1.y) // hack x val
                slur.setPoint1(point0, andPoint2: point1)
            }
        }
    }
    
    private func getConnectionPoint0InContext(context: CALayer) -> CGPoint {
        if let graphEvent0 = graphEvent0 {
            if let graph0 = graphEvent0.graph {
                let point_inContext = context.convertPoint(getConnectionPoint0(),
                    fromLayer: graph0.eventsLayer
                )
                return point_inContext
            }
        }
        return CGPointZero
    }
    
    private func getConnectionPoint1InContext(context: CALayer) -> CGPoint {
        if let graphEvent1 = graphEvent1 {
            if let graph1 = graphEvent1.graph {
                let point_inContext = context.convertPoint(getConnectionPoint1(),
                    fromLayer: graph1.eventsLayer
                )
                return point_inContext
            }
        }
        return CGPointZero
    }
    
    private func getConnectionPoint0() -> CGPoint {
        if let graphEvent0 = graphEvent0 {
            let x_local = graphEvent0.x
            let y_local = graphEvent0.slurConnectionY!
            let point_local = CGPoint(x: x_local, y: y_local)
            return point_local
        }
        return CGPointZero
    }
    
    private func getConnectionPoint1() -> CGPoint {
        if let graphEvent1 = graphEvent1 {
            let x_local = graphEvent1.x
            let y_local = graphEvent1.slurConnectionY!
            let point_local = CGPoint(x: x_local, y: y_local)
            return point_local
        }
        return CGPointZero
    }
}