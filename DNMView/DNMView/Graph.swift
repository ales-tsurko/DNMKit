//
//  Graph.swift
//  denm_view
//
//  Created by James Bean on 8/17/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class Graph: ViewNode, BuildPattern/*, Identifiable*/ {

    public var id: String = ""
    
    public var events: [GraphEvent] = []
    public var instrument: Instrument?
    
    public var lineActions: [LineAction] = []
    public var lastLinesX: CGFloat?
    
    public var clefs: [Clef] = []
    
    public var linesLayer: CALayer = CALayer()
    public var clefsLayer: CALayer = CALayer()
    public var eventsLayer: CALayer = CALayer()
    
    public var hasBeenBuilt: Bool = false
    
    public var height: CGFloat = 0
    
    // distance from top (frame.minY) of eventsLayer to 0 (always >= 0)
    public var graphTop: CGFloat { get { return getGraphTop() } }
    
    // primary or supplementary
    
    // distance from bottom (frame.maxY) of eventsLayer to 0 (aways >= frame.height)
    public var graphBottom: CGFloat { get { return getGraphBottom() } }
    
    // Scale of Graph
    //public var s: CGFloat = 1
    
    public class func withType(graphType: GraphType) -> Graph? {
        switch graphType {
        case .Staff: return Staff()
        case .Cue: return RhythmCueGraph()
        case .ContinuousController: return GraphContinuousController()
        case .Switch: return GraphSwitch()
        case .Waveform: return GraphWaveform()
        }
        //return nil
    }
    
    public init(id: String) {
        super.init()
        self.id = id
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addGlissandoFromGraphEventAtIndex(index0: Int, toIndex index1: Int) {

        // TESTING HACK
        
        if index0 < events.count - 1 && index1 < events.count {
            let ge0 = events[index0]
            let ge1 = events[index1]
            let glissando = CAShapeLayer()
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(ge0.x, ge0.maxInfoY)) // hack
            path.addLineToPoint(CGPointMake(ge1.x, ge1.maxInfoY)) // hack
            glissando.path = path.CGPath
            glissando.lineWidth = 2
            glissando.strokeColor = UIColor.greenColor().CGColor
            addSublayer(glissando)
        }
    }
    
    public func addClefAtX(x: CGFloat) {
        let clef = ClefCue()
        clef.g = 12 // HACK
        clef.x = x
        clef.height = height
        clef.build()
        addClef(clef)
    }
    
    public func addClef(clef: Clef) {
        clefs.append(clef)
        if let clef = clef as? CALayer { addSublayer(clef) }
        startLinesAtX(clef.x)
    }
    
    public func startEventAtX(x: CGFloat, withStemDirection stemDirection: StemDirection)
        -> GraphEvent {
        let event = GraphEvent(x: x, stemDirection: stemDirection)
        events.append(event)
        return event
    }
    
    public func startEventAtX(x: CGFloat) -> GraphEvent {
        let event = GraphEvent(x: x)
        event.graph = self
        events.append(event)
        return event
    }
    
    public func getEventAtX(x: CGFloat) -> GraphEvent? {
        // possible for multiple? that should raise its own issue...
        for event in events { if event.x == x { return event } }
        return nil
    }
    
    // add articulations
    
    public func startLinesAtX(x: CGFloat) {
        // override
        lineActions.append(LineActionStart(x: x))
    }
    
    public func stopLinesAtX(x: CGFloat) {
        //assert(lastLinesX != nil, "must have started a line to stop a line")
        lineActions.append(LineActionStop(x: x))
        // override
    }
    
    public func build() {
        // override in subclasses
        commitLines()
        setFrame()
        hasBeenBuilt = true
    }
    
    public func commitLines() {
        lineActions.sortInPlace({$0.x < $1.x})
        var lastX: CGFloat?
        for lineAction in lineActions {
            if let start = lineAction as? LineActionStart {
                lastX = start.x
            }
            else if let stop = lineAction as? LineActionStop {
                
                // refactor...
                
                if let start_x = lastX {
                    let stop_x = stop.x
                    let line = CAShapeLayer()
                    let line_path = UIBezierPath()
                    line_path.moveToPoint(CGPointMake(start_x, 0))
                    line_path.addLineToPoint(CGPointMake(stop_x, 0))
                    line_path.moveToPoint(CGPointMake(start_x, height))
                    line_path.addLineToPoint(CGPointMake(stop_x, height))
                    line.path = line_path.CGPath
                    line.lineWidth = 1
                    //line.strokeColor = UIColor.lightGrayColor().CGColor
                    line.strokeColor = JBColor.grayscaleColorWithDepthOfField(
                        .MiddleBackground
                    ).CGColor
                    addSublayer(line)
                }
            }
        }
    }
    
    internal func addLabel() {
        // hack
        let h = 20
        let label = TextLayerConstrainedByHeight(
            text: id, x: 0, top: 10, height: 20, alignment: PositionAbsolute.Right
        )
        addSublayer(label)
    }
    
    internal func getMaxY() -> CGFloat {
        if events.count == 0 { return 0 }
        var maxY: CGFloat?
        for event in events {
            if maxY == nil { maxY = event.maxY }
            else { if event.maxY > maxY { maxY = event.maxY } }
        }
        return maxY!
    }
    
    internal func getMinY() -> CGFloat {
        if events.count == 0 { return 0 }
        var minY: CGFloat?
        for event in events {
            if minY == nil { minY = event.minY }
            else { if event.minY < minY { minY = event.minY } }
        }
        return minY!
    }
    
    public func getGraphTop() -> CGFloat {
        // override
        return 0
    }
    
    public func getGraphBottom() -> CGFloat {
        // override
        return height
    }
    
    public func setFrame() {
        let width: CGFloat = 1000
        frame = CGRectMake(left, top, width, height)
    }
    
    public override func setWidthWithContents() {
        // potentitally something here
        super.setWidthWithContents()
    }
    
}

public protocol LineAction {
    var x: CGFloat { get set }
}

public struct LineActionStart: LineAction {
    public var x: CGFloat
    public init(x: CGFloat) {
        self.x = x
    }
}

public struct LineActionStop: LineAction {
    public var x: CGFloat
    public init(x: CGFloat) {
        self.x = x
    }
}

public enum GraphType {
    case Staff, Cue, ContinuousController, Switch, Waveform
}

