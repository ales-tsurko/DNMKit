//
//  Staff.swift
//  denm_view
//
//  Created by James Bean on 8/17/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public class Staff: Graph, Guido {
    
    // Size
    public var g: CGFloat = 0
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }
    
    public var lineWidth: CGFloat { get { return 0.0618 * gS } }
    public var ledgerLineLength: CGFloat { get { return 2 * gS} }
    public var ledgerLineWidth: CGFloat { get { return 1.875 * lineWidth } }

    public var lines: [CAShapeLayer] = []
    
    public var currentEvent: StaffEvent? { get { return events.last as? StaffEvent } }

    public init(id: String, g: CGFloat) {
        super.init(id: id)
        self.g = g
    }
    
    public init(g: CGFloat, s: CGFloat = 1) {
        super.init()
        self.g = g
        self.s = s
    }
    
    public init(left: CGFloat, top: CGFloat, g: CGFloat, s: CGFloat = 1) {
        super.init()
        self.left = left
        self.top = top
        self.g = g
        self.s = s
        pad_top = 2 * g
        pad_bottom = 2 * g
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    public func addClefWithType(
        type: String,
        withTransposition transposition: Int = 0,
        atX x: CGFloat
    )
    {
        if let clefType = ClefStaffType(rawValue: type) {
            addClefWithType(clefType, withTransposition: transposition, atX: x)
        }
    }
    
    public func addClefWithType(
        type: ClefStaffType,
        withTransposition transposition: Int = 0,
        atX x: CGFloat
    )
    {
        if clefs.count > 0 && lastLinesX != nil { stopLinesAtX(x - 0.618 * gS) }
        let clef = ClefStaff.withType(type, transposition: transposition, x: x, top: 0, g: g, s: s)!
        clefsLayer.addSublayer(clef)
        clefs.append(clef)
        startLinesAtX(x)
    }
    
    public override func startEventAtX(x: CGFloat,
        withStemDirection stemDirection: StemDirection
    ) -> GraphEvent
    {
        let event = StaffEvent(x: x, stemDirection: stemDirection, staff: self, stem: nil)
        events.append(event)
        return event
    }
    
    public override func startEventAtX(x: CGFloat) -> StaffEvent {
        let event = StaffEvent(x: x, g: g, s: s, staff: self, stem: nil)
        events.append(event)
        return event
    }
    
    public func middleCPositionAtX(x: CGFloat) -> CGFloat? {
        if clefs.count == 0 { return nil }
        if let mostRecentClef = clefs.sort({$0.x < $1.x}).filter({$0.x <= x}).last as? ClefStaff {
            return mostRecentClef.middleCPosition
        }
        return nil
    }
    
    public func addPitchToCurrentEvent(pitch: Pitch) {
        assert(currentEvent != nil, "no current event")
        currentEvent?.addPitch(pitch, respellVerticality: false, andUpdateView: false)
    }
    
    public func addPitchToCurrentEvent(
        pitch pitch: Pitch,
        respellVerticality shouldRespellVerticality: Bool,
        andUpdateView shouldUpdateView: Bool
    )
    {
        assert(currentEvent != nil, "no current event")
        currentEvent?.addPitch(pitch,
            respellVerticality: shouldRespellVerticality,
            andUpdateView: shouldUpdateView
        )
    }
    
    public func addArticulationToCurrentEventWithType(type: ArticulationType) {
        assert(currentEvent != nil, "no current event")
        currentEvent?.addArticulationWithType(type)
    }
    
    public override func startLinesAtX(x: CGFloat) {
        lastLinesX = x
        lineActions.append(LineActionStart(x: x))
    }
    
    public override func stopLinesAtX(x: CGFloat) {
        assert(lastLinesX != nil, "must have started a line to stop a line")
        lineActions.append(LineActionStop(x: x))
        
        lastLinesX = nil
    }
    
    public func addLedgerLinesAtX(x: CGFloat, toLevel level: Int) -> [CAShapeLayer] {
        var ledgerLines: [CAShapeLayer] = []
        for l in 1...abs(level) {
            let y: CGFloat = level > 0 ? -CGFloat(l) * g : /*height + CGFloat(l) * g*/ 4 * g + CGFloat(l) * g
            let line = CAShapeLayer()
            let line_path = UIBezierPath()
            line_path.moveToPoint(CGPointMake(x - 0.5 * ledgerLineLength, y))
            line_path.addLineToPoint(CGPointMake(x + 0.5 * ledgerLineLength, y))
            line.path = line_path.CGPath
            line.lineWidth = ledgerLineWidth
            line.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
            addLine(line)
            ledgerLines.append(line)
        }
        return ledgerLines
    }
    
    public func addLine(line: CAShapeLayer) {
        lines.append(line)
        linesLayer.addSublayer(line)
    }
    
    // deprecate
    public func addClef(clef: ClefStaff) {
        clefsLayer.addSublayer(clef)
        clefs.append(clef)
    }
    
    public override func build() {
        commitLines()
        commitClefs()
        commitEvents()
        setFrame()
        adjustLayersYForMinY()
        //addSkylines()
        hasBeenBuilt = true
    }
    
    private func addSkylineAbove() {
        let skyline = CAShapeLayer()
        let path = UIBezierPath()
        for (g, graphEvent) in events.enumerate() {
            if g == 0 {
                let y = convertY(graphEvent.minY, fromLayer: eventsLayer)
                path.moveToPoint(CGPoint(x: graphEvent.x, y: y))
            }
            else {
                let y = convertY(graphEvent.minY, fromLayer: eventsLayer)
                path.addLineToPoint(CGPoint(x: graphEvent.x, y: y))
            }
        }
        skyline.path = path.CGPath
        skyline.strokeColor = UIColor.greenColor().CGColor
        skyline.lineWidth = 0.5
        skyline.opacity = 0.5
        skyline.fillColor = UIColor.clearColor().CGColor
        addSublayer(skyline)
    }
    
    private func addSkylineBelow() {
        let skyline = CAShapeLayer()
        let path = UIBezierPath()
        for (g, graphEvent) in events.enumerate() {
            if g == 0 {
                let y = convertY(graphEvent.maxY, fromLayer: eventsLayer)
                path.moveToPoint(CGPoint(x: graphEvent.x, y: y))
            }
            else {
                let y = convertY(graphEvent.maxY, fromLayer: eventsLayer)
                path.addLineToPoint(CGPoint(x: graphEvent.x, y: y))
            }
        }
        skyline.path = path.CGPath
        skyline.strokeColor = UIColor.greenColor().CGColor
        skyline.lineWidth = 0.5
        skyline.opacity = 0.5
        skyline.fillColor = UIColor.clearColor().CGColor
        addSublayer(skyline)
    }
    
    private func addSkylines() {
        addSkylineAbove()
        addSkylineBelow()
    }
 
    private func adjustLayersYForMinY() {
        linesLayer.position.y -= getMinY()
        eventsLayer.position.y -= getMinY()
        clefsLayer.position.y -= getMinY()
    }
    
    public override func setFrame() {
        let height: CGFloat = getMaxY() - getMinY()
        // temp
        let width: CGFloat = 1000
        frame = CGRectMake(left, top, width, height)
    }
    
    private func addTestSlurs() {
        // SLUR CONNECTION POINT FOR TESTING ONLY
        for e in 0..<events.count {
            let event = events[e] as! StaffEvent
            if e != 0 {
                let x0 = events[e - 1].x
                let y0 = (events[e - 1] as! StaffEvent).slurConnectionY!
                let x1 = event.x
                let y1 = event.slurConnectionY!
                let slur = Slur(point1: CGPointMake(x0, y0), point2: CGPointMake(x1, y1))
                eventsLayer.addSublayer(slur)
                slur.strokeColor = UIColor.orangeColor().CGColor
                slur.opacity = 0.25
            }
        }
    }
    
    public override func commitLines() {
        
        func commitLineFromLeft(left: CGFloat, toRight right: CGFloat) {
            for i in 0..<5 {
                let y: CGFloat = CGFloat(i) * gS
                let line: CAShapeLayer = CAShapeLayer()
                let line_path = UIBezierPath()
                line_path.moveToPoint(CGPointMake(left, y))
                line_path.addLineToPoint(CGPointMake(right, y))
                line.path = line_path.CGPath
                line.lineWidth = lineWidth
                line.strokeColor = UIColor.grayColor().CGColor
                addLine(line)
            }
        }
        
        lineActions.sortInPlace({ $0.x < $1.x })
        var allLineActions = lineActions
        var lastX: CGFloat?
        while allLineActions.count > 0 {
            let lineAction = allLineActions.first!
            let lineActionsWithCurrentXValue = allLineActions.filter({ $0.x == lineAction.x })
            if lineActionsWithCurrentXValue.filter({ $0 is LineActionStart }).count > 0 {
                if lastX == nil { lastX = lineAction.x }
            }
            else {
                commitLineFromLeft(lastX!, toRight: lineAction.x)
                lastX = nil
            }
            allLineActions = allLineActions.filter({ $0.x > lineAction.x })
        }
        addSublayer(linesLayer)
    }
    
    private func commitClefs() {
        if clefs.count > 0 { clefsLayer.position.y -= (clefs.first as! ClefStaff).extenderHeight }
        addSublayer(clefsLayer)
    }
    
    private func commitEvents() {
        for event in events {
            if let staffEvent = event as? StaffEvent {
                staffEvent.setMiddleCPosition(middleCPositionAtX(staffEvent.x))
            }
            event.build()
            eventsLayer.addSublayer(event)
        }
        addSublayer(eventsLayer)
    }
    
    public override func getGraphTop() -> CGFloat {
        return eventsLayer.frame.minY
    }
    
    public override func getGraphBottom() -> CGFloat {
        return graphTop + 4 * g // hack
    }
}

public enum PlacementInStaff {
    case Line, Space, Floating
}
