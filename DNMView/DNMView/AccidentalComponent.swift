//
//  AccidentalComponent.swift
//  denm_view
//
//  Created by James Bean on 8/18/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMUtility

// Notes for refactor: AccidentalPolygon NOT BezierPathPoints?
public class AccidentalComponent: CAShapeLayer, Guido, BuildPattern {
    
    public override var description: String { get { return "AccidentalComponent" } }
    
    public var g: CGFloat = 0
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }
    
    //public var scale: CGFloat = 0
    public var minimumDistance: CGFloat?
    public var canContract: Bool { get { return minimumDistance != nil } } // override
    public var hasBeenContracted: Bool = false
    
    public var alignment: Alignment = .Center // override
    
    public var accidental: Accidental?
    
    public var collisionFrame: CGRect {
        get {
            return self.frame.insetBy(dx: -0.15 * gS, dy: -0.15 * gS)
        }
    }
    
    internal var collisionPadding: CGFloat { get { return 0.125 * g } }
    
    public var collisionPolygonPoints: [CGPoint] { get { return makeCollisionPolygonPoints() } }
    
    public var polygon: Polygon { get { return makeCollisionPolygon() } }
    
    /*
    public var collisionPathPoints: [BezierPathPoint] {
        get { return makeCollisionPathPoints() }
    }
    */
    
    internal var thinLineWidth: CGFloat { get { return 0.0875 * gS } }
    
    /*
    public override class func makePDFDocumentation() {
        // body natural, flat, quartersharp, quarterflat, sharp
        // column
        // arrow
    }
    */
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    private func setVisualAttributes() {
        fillColor = UIColor.blackColor().CGColor
        lineWidth = 0
    }
    
    public func build() {
        path = makePath()
        setFrame()
        setVisualAttributes()
    }
    
    private func makePath() -> CGPath {
        return UIBezierPath().CGPath
    }
    
    private func setFrame() {
        // something
    }
    
    /*
    internal func makeCollisionPathPoints() -> [BezierPathPoint] {
        // override
        return []
    }
    */
    
    internal func makeCollisionPolygonPoints() -> [CGPoint] {
        // override
        return []
    }
    
    internal func makeCollisionPolygon() -> Polygon {
        return Polygon(vertices: collisionPolygonPoints)
    }
}

public enum AccidentalComponentType {
    case Body, Column, Arrow
}

public class AccidentalComponentArrow: AccidentalComponent {
    
    public override var description: String { get { return "Arrow" } }
    
    public var point: CGPoint = CGPointZero
    
    public var direction: Direction = .None
    
    public var column: AccidentalComponentColumn?
    
    public var contractionStepSize: CGFloat { get { return 0.25 * gS } }
    
    internal var top: CGFloat { get { return point.y - 0.5 * height } }
    internal var left: CGFloat { get { return point.x - 0.5 * width } }
    internal var width: CGFloat { get { return 0.618 * gS } }
    internal var height: CGFloat { get { return 0.75 * gS } }
    internal var barbDepth: CGFloat { get { return 0.236 * gS } }
    
    /*
    public override class func makePDFDocumentation() {
        let arrow_up = AccidentalComponentArrow(
            g: 40, scale: 1,
            point: CGPointZero,
            direction: .North
        )
        arrow_up.makePDF(name: "AccidentalComponentArrowUp")
        
        let arrow_down = AccidentalComponentArrow(
            g: 40, scale: 1,
            point: CGPointZero,
            direction: .South
        )
        arrow_down.makePDF(name: "AccidentalComponentArrowDown")
    }
    */
    
    public init(g: CGFloat, scale: CGFloat, point: CGPoint, direction: Direction) {
        self.point = point
        self.direction = direction
        super.init()
        self.g = g
        self.s = scale
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    public func contractByStep() {
        if direction == .North { position.y += contractionStepSize }
        else { position.y -= contractionStepSize }
        hasBeenContracted = true
    }
    
    public func contractByAmount(amount: CGFloat) {
        if !hasBeenContracted {
            if direction == .North { position.y += amount }
            else { position.y -= amount }
            hasBeenContracted = true
        }
    }
    
    public func contract() {
        if canContract {
            if direction == .North { position.y += 0.5 * gS }
            else { position.y -= 0.5 * gS }
        }
        hasBeenContracted = true
    }
    
    internal override func makePath() -> CGPath {
        setFrame()
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0.5 * width, 0))
        path.addLineToPoint(CGPointMake(width, height))
        path.addLineToPoint(CGPointMake(0.5 * width, height - barbDepth))
        path.addLineToPoint(CGPointMake(0, height))
        path.closePath()
        if direction == .South { path.rotate(degrees: 180.0) }
        return path.CGPath
    }
    
    internal override func setFrame() {
        frame = CGRectMake(left, top, width, height)
    }
    
    /*
    internal override func makeCollisionPathPoints() -> [BezierPathPoint] {
        var points: [BezierPathPoint] = []
        if direction == .North {
            points = [
                BezierPathPoint.Vertex(point: CGPointMake(0.5 * width, 0)),
                BezierPathPoint.Vertex(point: CGPointMake(width, height)),
                BezierPathPoint.Vertex(point: CGPointMake(0, height))
            ]
        }
        else {
            points = [
                BezierPathPoint.Vertex(point: CGPointMake(0.5 * width, height)),
                BezierPathPoint.Vertex(point: CGPointMake(width, 0)),
                BezierPathPoint.Vertex(point: CGPointMake(0, 0))
            ]
        }
        return points
    }
    */
    
    internal override func makeCollisionPolygonPoints() -> [CGPoint] {
        var points: [CGPoint] = []
        if direction == .North {
            points = [
                CGPointMake(0.5 * width, 0),
                CGPointMake(width, height),
                CGPointMake(0, height)
            ]
        }
        else {
            points = [
                CGPointMake(0.5 * width, height),
                CGPointMake(width, 0),
                CGPointMake(0, 0)
            ]
        }
        return points
    }
}

public class AccidentalComponentBody: AccidentalComponent {
    
    /*
    public var y: CGFloat = 0
    public var x: CGFloat = 0
    */
    
    public override var description: String { get { return "Body" } }
    
    public var point: CGPoint = CGPointZero
    
    internal var yRef: CGFloat { get { return 0 } }
    internal var xRef: CGFloat { get { return 0 } }
    
    public var midWidth: CGFloat { get { return 0.575 * gS } }
    public var flankWidth: CGFloat { get { return 0.15 * gS } }
    
    public var thickLineSlope: CGFloat = 0.25
    public var thickLineWidth: CGFloat { get { return 0.382 * gS } }
    public var thickLineLength: CGFloat { get { return midWidth + 2 * flankWidth } }
    
    public var thickLineΔY: CGFloat { get { return 0.4125 * gS } }
    
    internal var width: CGFloat { get { return 0 } }
    internal var height: CGFloat { get { return 0 } }
    
    /*
    public override class func makePDFDocumentation() {
        let body = AccidentalComponentBodyNatural(g: 40, scale: 1, point: CGPointZero)
        body.makePDF(name: "AccidentalComponentBodyNatural")
    }
    */
    
    /*
    public class func accidentalComponentBodyWithType(type: AccidentalComponentBodyType)
    -> AccidentalComponentBody?
    {
    switch type {
    case .Natural: return AccidentalComponentBodyNatural()
    case .Sharp: return AccidentalComponentBodySharp()
    case .Flat: return AccidentalComponentBodyFlat()
    case .QuarterSharp: return AccidentalComponentBodyQuarterSharp()
    case .QuarterFlat: return AccidentalComponentBodyQuarterFlat()
    default: return nil
    }
    }
    */
    
    public func getYAtX(x: CGFloat) -> CGFloat {
        // mx + b
        return yRef - thickLineSlope * (x - 0.5 * width)
    }
    
    internal func getHeight() -> CGFloat {
        return 0 // override
    }
}

public class AccidentalComponentBodyFlat: AccidentalComponentBody {
    
    internal override var width: CGFloat { get { return midWidth } }
    internal override var height: CGFloat { get { return 1.25 * gS } }
    
    internal override var yRef: CGFloat { get { return 0.4 * height } }
    internal override var xRef: CGFloat { get { return 0.5 * width } }
    
    public var bowlLineWidthTop: CGFloat { get { return 0.1875 * gS } }
    public var bowlLineWidthBottom: CGFloat { get { return 0.382 * gS } }
    public var bowlLineWidthStress: CGFloat { get { return 0.25 * gS } }
    
    /*
    public override class func makePDFDocumentation() {
        let body = AccidentalComponentBodyFlat(g: 40, scale: 1, point: CGPointZero)
        body.makePDF(name: "AccidentalComponentBodyFlat")
    }
    */
    
    public init(g: CGFloat, scale: CGFloat, point: CGPoint) {
        super.init()
        self.point = point
        self.g = g
        self.s = scale
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal override func makePath() -> CGPath {
        setFrame()
        let path = UIBezierPath()
        
        // outside
        path.moveToPoint(CGPointMake(0, 0))
        path.addCurveToPoint(CGPointMake(width, 0),
            controlPoint1: CGPointMake(0, 0),
            controlPoint2: CGPointMake(width - 0.125 * gS, -0.125 * gS)
        )
        path.addCurveToPoint(CGPointMake(0, height),
            controlPoint1: CGPointMake(width + 0.25 * gS, 0.309 * gS),
            controlPoint2: CGPointMake(0.125 * gS, height - 0.33 * gS)
        )
        
        // inside
        path.addLineToPoint(CGPointMake(0, height - bowlLineWidthBottom))
        
        path.addCurveToPoint(CGPointMake(width - bowlLineWidthStress, 0.75 * bowlLineWidthStress),
            controlPoint1: CGPointMake(
                0.5 * bowlLineWidthBottom, height - 1.25 * bowlLineWidthBottom
            ),
            controlPoint2: CGPointMake(width - 0.5 * bowlLineWidthBottom, 1.333 * bowlLineWidthStress)
        )
        path.addCurveToPoint(CGPointMake(0, bowlLineWidthTop),
            controlPoint1: CGPointMake(width - 1.309 * bowlLineWidthStress, 0.309 * bowlLineWidthStress),
            controlPoint2: CGPointMake(0, bowlLineWidthTop)
        )
        path.closePath()
        
        //fillRule = kCAFillRuleEvenOdd
        
        return path.CGPath
    }
    
    internal override func setFrame() {
        // something
        frame = CGRectMake(point.x - xRef, point.y - yRef, width, height)
    }
    
    internal override func getHeight() -> CGFloat {
        // something
        return 0
    }
    
    /*
    internal override func makeCollisionPathPoints() -> [BezierPathPoint] {
        let points: [BezierPathPoint] = [
            BezierPathPoint.Vertex(point: CGPointMake(0, 0)),
            BezierPathPoint.Vertex(point: CGPointMake(width, 0)),
            BezierPathPoint.Vertex(point: CGPointMake(width, 0.5 * height)),
            BezierPathPoint.Vertex(point: CGPointMake(0, height))
        ]
        return points
    }
    */
    
    internal override func makeCollisionPolygonPoints() -> [CGPoint] {
        let points: [CGPoint] = [
            CGPointMake(0, 0),
            CGPointMake(width, 0),
            CGPointMake(width, 0.5 * height),
            CGPointMake(0, height)
        ]
        return points
    }
}

public class AccidentalComponentBodyNatural: AccidentalComponentBody {
    
    internal override var width: CGFloat { get { return thickLineLength } }
    internal override var height: CGFloat { get { return getHeight() } }
    
    internal override var yRef: CGFloat { get { return 0.5 * height } }
    internal override var xRef: CGFloat { get { return 0.5 * width } }
    
    public override var thickLineLength: CGFloat { get { return midWidth + thinLineWidth } }
    
    /*
    public override class func makePDFDocumentation() {
        let body = AccidentalComponentBodyNatural(g: 40, scale: 1, point: CGPointZero)
        body.makePDF(name: "AccidentalComponentBodyNatural")
    }
    */
    
    public init(g: CGFloat, scale: CGFloat, point: CGPoint) {
        super.init()
        self.point = point
        self.g = g
        self.s = scale
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal override func makePath() -> CGPath {
        setFrame()
        let thickLine_top = ParallelogramVertical(
            x: xRef,
            y: yRef - thickLineΔY,
            width: thickLineWidth,
            length: thickLineLength,
            slope: thickLineSlope
        )
        let thickLine_bottom = ParallelogramVertical(
            x: xRef,
            y: yRef + thickLineΔY,
            width: thickLineWidth,
            length: thickLineLength,
            slope: thickLineSlope
        )
        thickLine_top.appendPath(thickLine_bottom)
        return thickLine_top.CGPath
    }
    
    internal override func setFrame() {
        frame = CGRectMake(point.x - xRef, point.y - yRef, width, height)
    }
    
    internal override func getHeight() -> CGFloat {
        return 2 * thickLineΔY + thickLineWidth + thickLineSlope * width
    }
    
    /*
    internal override func makeCollisionPathPoints() -> [BezierPathPoint] {
        let points: [BezierPathPoint] = ParallelogramVertical(
            x: xRef,
            y: yRef,
            width: 2 * thickLineWidth + thickLineΔY,
            length: thickLineLength,
            slope: thickLineSlope
            ).getBezierPathPoints()
        return points
    }
    */
    
    internal override func makeCollisionPolygonPoints() -> [CGPoint] {
        let points: [CGPoint] = ParallelogramVertical(
            x: xRef,
            y: yRef,
            width: 2 * thickLineWidth + thickLineΔY,
            length: thickLineLength,
            slope: thickLineSlope
        ).getVertices()
        return points
    }
}

public class AccidentalComponentBodyQuarterFlat: AccidentalComponentBodyFlat {
    
    /*
    public override class func makePDFDocumentation() {
        let body = AccidentalComponentBodyQuarterFlat(g: 40, scale: 1, point: CGPointZero)
        body.makePDF(name: "AccidentalComponentBodyQuarterFlat")
    }
    */
    
    public override func build() {
        setFrame()
        mirrorPath()
        setVisualAttributes()
    }
    
    internal func mirrorPath() {
        path = makePath()
        let mirroredPath = UIBezierPath(CGPath: path!)
        mirroredPath.mirror()
        let adjustToTheLeft = CGAffineTransformMakeTranslation(-0.05 * gS, 0)
        mirroredPath.applyTransform(adjustToTheLeft)
        path = mirroredPath.CGPath
    }
    
    /*
    internal override func makeCollisionPathPoints() -> [BezierPathPoint] {
        let points: [BezierPathPoint] = [
            BezierPathPoint.Vertex(point: CGPointMake(0, 0)),
            BezierPathPoint.Vertex(point: CGPointMake(width, 0)),
            BezierPathPoint.Vertex(point: CGPointMake(width, height)),
            BezierPathPoint.Vertex(point: CGPointMake(0, 0.5 * height))
        ]
        return points
    }
    */
    
    internal override func makeCollisionPolygonPoints() -> [CGPoint] {
        let points: [CGPoint] = [
            CGPointMake(0, 0),
            CGPointMake(width, 0),
            CGPointMake(width, height),
            CGPointMake(0, 0.5 * height)
        ]
        return points
    }
}

public class AccidentalComponentBodyQuarterSharp: AccidentalComponentBody {
    
    internal override var width: CGFloat { get { return thickLineLength } }
    internal override var height: CGFloat { get { return getHeight() } }
    
    internal override var yRef: CGFloat { get { return 0.5 * height } }
    internal override var xRef: CGFloat { get { return 0.5 * width } }
    
    /*
    public override class func makePDFDocumentation() {
        let body = AccidentalComponentBodyQuarterSharp(g: 40, scale: 1, point: CGPointZero)
        body.makePDF(name: "AccidentalComponentBodyQuarterSharp")
    }
    */
    
    public init(g: CGFloat, scale: CGFloat, point: CGPoint) {
        super.init()
        self.point = point
        self.g = g
        self.s = scale
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal override func makePath() -> CGPath {
        setFrame()
        let path = ParallelogramVertical(
            x: xRef,
            y: yRef,
            width: thickLineWidth,
            length: thickLineLength,
            slope: thickLineSlope
        )
        return path.CGPath
    }
    
    internal override func setFrame() {
        frame = CGRectMake(point.x - xRef, point.y - yRef, width, height)
    }
    
    internal override func getHeight() -> CGFloat {
        return thickLineWidth + thickLineSlope * width
    }
    
    /*
    internal override func makeCollisionPathPoints() -> [BezierPathPoint] {
        let points: [BezierPathPoint] = ParallelogramVertical(
            x: xRef,
            y: yRef,
            width: thickLineWidth,
            length: thickLineLength,
            slope: thickLineSlope
            ).getBezierPathPoints()
        return points
    }
    */
    
    internal override func makeCollisionPolygonPoints() -> [CGPoint] {
        let points: [CGPoint] = ParallelogramVertical(
            x: xRef,
            y: yRef,
            width: thickLineWidth,
            length: thickLineLength,
            slope: thickLineSlope
            ).getVertices()
        return points
    }
}

public class AccidentalComponentBodySharp: AccidentalComponentBody {
    
    internal override var width: CGFloat { get { return thickLineLength } }
    internal override var height: CGFloat { get { return getHeight() } }
    
    internal override var yRef: CGFloat { get { return 0.5 * height } }
    internal override var xRef: CGFloat { get { return 0.5 * width } }
    
    /*
    public override class func makePDFDocumentation() {
        let body = AccidentalComponentBodySharp(g: 40, scale: 1, point: CGPointZero)
        body.makePDF(name: "AccidentalComponentBodySharp")
    }
    */
    
    public init(g: CGFloat, scale: CGFloat, point: CGPoint) {
        super.init()
        self.point = point
        self.g = g
        self.s = scale
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal override func makePath() -> CGPath {
        let thickLine_top = ParallelogramVertical(
            x: xRef,
            y: yRef - thickLineΔY,
            width: thickLineWidth,
            length: thickLineLength,
            slope: thickLineSlope
        )
        let thickLine_bottom = ParallelogramVertical(
            x: xRef,
            y: yRef + thickLineΔY,
            width: thickLineWidth,
            length: thickLineLength,
            slope: thickLineSlope
        )
        thickLine_top.appendPath(thickLine_bottom)
        return thickLine_top.CGPath
    }
    
    internal override func setFrame() {
        frame = CGRectMake(point.x - xRef, point.y - yRef, width, height)
    }
    
    internal override func getHeight() -> CGFloat {
        return 2 * thickLineΔY + thickLineWidth + thickLineSlope * width
    }
    
    /*
    internal override func makeCollisionPathPoints() -> [BezierPathPoint] {
        let points: [BezierPathPoint] = ParallelogramVertical(
            x: xRef,
            y: yRef,
            width: 2 * thickLineWidth + thickLineΔY,
            length: thickLineLength,
            slope: thickLineSlope
            ).getBezierPathPoints()
        return points
    }
    */
    
    internal override func makeCollisionPolygonPoints() -> [CGPoint] {
        let points: [CGPoint] = ParallelogramVertical(
            x: xRef,
            y: yRef,
            width: 2 * thickLineWidth + thickLineΔY,
            length: thickLineLength,
            slope: thickLineSlope
        ).getVertices()
        return points
    }
}

public class AccidentalComponentColumn: AccidentalComponent {
    
    public override var description: String { get { return "Column" } }
    
    public var width: CGFloat { get { return 0.0875 * gS } }
    
    public var x: CGFloat = 0
    public var y_internal: CGFloat = 0
    public var y_external: CGFloat = 0
    
    internal var top: CGFloat = 0
    internal var left: CGFloat = 0
    internal var height: CGFloat { get { return abs(y_internal - y_external) } }
    
    public var direction: Direction = .None // default?
    
    public var arrow: AccidentalComponentArrow?
    
    /*
    public override class func makePDFDocumentation() {
        let column = AccidentalComponentColumn(g: 40, scale: 1, x: 0, y_internal: 100, y_external: 0)
        column.makePDF(name: "AccidentalComponentColumn")
    }
    */
    
    public init(
        g: CGFloat,
        scale: CGFloat,
        x: CGFloat,
        y_internal: CGFloat,
        y_external: CGFloat
    )
    {
        self.y_internal = y_internal
        self.y_external = y_external
        self.x = x
        self.direction = y_external > y_internal ? .South : .North
        super.init()
        self.g = g
        self.s = scale
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    public func contractToY(y: CGFloat) {
        if canContract && !hasBeenContracted {
            y_external = direction == .North
                ? y_internal - (accidental!.point.y - y)
                : y_internal + y - accidental!.point.y
            setFrame()
            path = makePath()
            hasBeenContracted = true
        }
        
    }
    
    public func contractByAmount(amount: CGFloat) {
        
        let newLength = height - amount
        contractToLength(newLength)
    }
    
    public func contractToLength(length: CGFloat) {
        if canContract && !hasBeenContracted {
            y_external = direction == .North ? y_internal - length : y_internal + length
            setFrame()
            path = makePath()
            hasBeenContracted = true
        }
    }
    
    public func contractToMinimumDistance() {
        
        if canContract && !hasBeenContracted {
            y_external = direction == .North
                ? y_internal - minimumDistance!
                : y_internal + minimumDistance!
            setFrame()
            path = makePath()
            hasBeenContracted = true
        }
        
    }
    
    public override func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
    }
    
    internal override func makePath() -> CGPath {
        let path = UIBezierPath(rect: bounds)
        return path.CGPath
    }
    
    internal override func setFrame() {
        let left: CGFloat = x - 0.5 * width
        let top: CGFloat = y_external < y_internal ? y_external : y_internal
        CATransaction.setDisableActions(true)
        frame = CGRectMake(left, top, width, height)
        CATransaction.setDisableActions(false)
    }
    
    /*
    internal override func makeCollisionPathPoints() -> [BezierPathPoint] {
        let points = [
            BezierPathPoint.Vertex(point: CGPointMake(0, 0)),
            BezierPathPoint.Vertex(point: CGPointMake(width, 0)),
            BezierPathPoint.Vertex(point: CGPointMake(width, height)),
            BezierPathPoint.Vertex(point: CGPointMake(0, height))
        ]
        return points
    }
    */
    
    internal override func makeCollisionPolygonPoints() -> [CGPoint] {
        let points = [
            CGPointMake(0, -0.0618 * gS),
            CGPointMake(width, -0.0618 * gS),
            CGPointMake(width, height + 0.0618 * gS),
            CGPointMake(0, height + 0.0618 * gS)
        ]
        return points
    }
}

public class AccidentalComponentDyad: CustomStringConvertible {
    
    public var description: String { get { return getDescription() } }
    
    public var component0: AccidentalComponent
    public var component1: AccidentalComponent
    
    public init(component0: AccidentalComponent, component1: AccidentalComponent) {
        self.component0 = component0
        self.component1 = component1
    }
    
    internal func getDescription() -> String {
        let description: String = "\(component0, component1)"
        return description
    }
}

public enum AccidentalComponentBodyType {
    case Natural, Sharp, Flat, QuarterSharp, QuarterFlat
}