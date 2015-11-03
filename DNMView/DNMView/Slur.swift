//
//  Slur.swift
//  denm_view
//
//  Created by James Bean on 8/21/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMUtility

// consider making this clean
typealias Radians = CGFloat
typealias Degrees = CGFloat

// SETTINGS FOR 3 POINT vs 5 POINT SLURS?
// STYLING: DASHES, COLORS, THICKNESS, ETC
public class Slur: Ligature {
    
    public var g: CGFloat = 10
    public var stemDirection: StemDirection = .Down // only one for now; more complex later

    public var controlPoint1: CGPoint!
    public var controlPoint2: CGPoint!
    
    // hmmmm....
    private var angle_degrees: Degrees = 0
    private var angle_radians: Radians = 0
    
    // at some point, these will be unnecessary, as they will be derived from controlPoint1/2
    private var controlPoint1_angle: CGFloat = 0
    private var controlPoint2_angle: CGFloat = 0
    private var controlPoint1_length: CGFloat = 0
    private var controlPoint2_length: CGFloat = 0
    
    public var pointToAvoid: CGPoint?
    public var pointsToAvoid: [CGPoint] = [] // in future development

    // also, probably unnecessary to be this global
    private var controlPoint1_outside: CGPoint? // make getter
    private var controlPoint2_outside: CGPoint? // make getter
    private var controlPoint2_inside: CGPoint? // make getter
    private var controlPoint1_inside: CGPoint? // make getter
    
    private var bezierPath: BezierPath!
    
    // get rid of this soon ...
    private var testDots: [CAShapeLayer] = []

    // Create a Slur
    public init(
        point1: CGPoint,
        point2: CGPoint,
        stemDirection: StemDirection = .Down,
        g: CGFloat = 10,
        pointToAvoid: CGPoint? = nil
    )
    {
        self.stemDirection = stemDirection
        self.g = g
        self.pointToAvoid = pointToAvoid
        super.init(point1: point1, point2: point2)
        setDefaultControlPointAttributes()
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func setPoint1(point1: CGPoint, andPoint2 point2: CGPoint) {
        self.point1 = point1
        self.point2 = point2
        setDefaultControlPointAttributes()
        animateToPath()
        // something
    }
    
    public override func setPoint1(point: CGPoint) {
        // something
    }
    
    public override func setPoint2(point: CGPoint) {
        // something
    }
    
    public func adjustToAvoidPoint(point: CGPoint) {
        switch stemDirection {
        case .Down: withinStemDirectionDownAdjustToAvoidPoint(point)
        case .Up: withinStemDirectionUpAdjustToAvoidPoint(point)
        }
        build()
    }
    
    private func withinStemDirectionDownAdjustToAvoidPoint(point: CGPoint) {
        if let point1 = point1, point2 = point2, run = run {
            
            // if not in range, get out of here
            if point.x < point1.x || point.x > point2.x { return }

            // get x weighting
            let x_weight = (point.x - point1.x) / run
            let stepSizeY: CGFloat = 5
            let stepSizeX: CGFloat = abs(stepSizeY) * (0.5 + x_weight)
            
            let minSlurYValue = bezierPath.getYValuesAtX(point.x).minElement()
            if point.y < minSlurYValue { return }
            
            while true {
                if let minSlurYValue = bezierPath.getYValuesAtX(point.x).minElement()
                    where minSlurYValue < point.y
                {
                    // regenerates bezier path
                    adjustControlPointsByX(stepSizeX, andY: stepSizeY)
                }
                else { break }
            }
        }
    }
    
    private func withinStemDirectionUpAdjustToAvoidPoint(point: CGPoint) {
        if let point1 = point1, point2 = point2, run = run {
            
            // if not in range, get out of here
            if point.x < point1.x || point.x > point2.x { return }
            
            // get x weighting
            let x_weight = (point.x - point1.x) / run
            
            let stepSizeY: CGFloat = -5
            let stepSizeX: CGFloat = abs(stepSizeY) * (0.5 * x_weight)
            
            let maxSlurYValue = bezierPath.getYValuesAtX(point.x).maxElement()
            if point.y > maxSlurYValue { return }
            
            while true {
                if let maxSlurYValue = bezierPath.getYValuesAtX(point.x).maxElement()
                    where maxSlurYValue > point.y
                {
                    // regenerates bezierPath
                    adjustControlPointsByX(stepSizeX, andY: stepSizeY)
                }
                else { break }
            }
        }
    }
    
    private func adjustControlPointsByX(x: CGFloat, andY y: CGFloat) {
        
        print("adjust control points by x: \(x); and y: \(y)")
        
        /*
        // DEAL WITH THE SCALING OF X,Y HERE
        var x1: CGFloat = 0
        var x2: CGFloat = 0
        if x > y {
            x2 = x
        }
        else {
            x1 = x
        }
        */
        
        if let point1 = point1, point2 = point2 {
            
            // Adjust Control Point 1
            let newControlPoint1 = CGPoint(x: controlPoint1.x /*- x1*/, y: controlPoint1.y + y)
            let newLength1 = getLengthFromPoint(newControlPoint1, toPoint: point1)
            let newAngle1 = getAngleBetweenPoint(newControlPoint1, andPoint: point1)
            setControlPoint1WithLength(newLength1, andAngle: newAngle1)
            
            // Adjust Control Point 2
            let newControlPoint2 = CGPoint(x: controlPoint2.x /*+ x2*/, y: controlPoint2.y + y)
            let newLength2 = -getLengthFromPoint(newControlPoint2, toPoint: point2)
            let newAngle2 = getAngleBetweenPoint(newControlPoint2, andPoint: point2)
            setControlPoint2WithLength(newLength2, andAngle: newAngle2)
            
            // Reset the private inner and outer control points
            setInnerAndOuterControlPointsWithAbstractControlPoints()
            createBezierPath()
        }
        else { print("cannot adjust control points because points 1 and 2 are no definted") }
    }
    
    public func adjustControlPointsByY(y: CGFloat) {
        if let point1 = point1, point2 = point2 {
            
            // Adjust Control Point 1
            let newControlPoint1 = CGPoint(x: controlPoint1.x /*SOMETHING*/, y: controlPoint1.y + y)
            let newLength1 = getLengthFromPoint(newControlPoint1, toPoint: point1)
            let newAngle1 = getAngleBetweenPoint(newControlPoint1, andPoint: point1)
            setControlPoint1WithLength(newLength1, andAngle: newAngle1)
            
            // Adjust Control Point 2
            let newControlPoint2 = CGPoint(x: controlPoint2.x /*SOMETHING*/, y: controlPoint2.y + y)
            let newLength2 = -getLengthFromPoint(newControlPoint2, toPoint: point2)
            let newAngle2 = getAngleBetweenPoint(newControlPoint2, andPoint: point2)
            setControlPoint2WithLength(newLength2, andAngle: newAngle2)
            
            // Reset the private inner and outer control points
            setInnerAndOuterControlPointsWithAbstractControlPoints()
            createBezierPath()
        }
        else { print("cannot adjust control points because points 1 and 2 are no definted") }
    }
    
    private func setDefaultControlPointAttributes() {
        if let angle = angle, length = length, run = run {
            
            // set default control point lengths
            controlPoint1_length = 0.309 * length
            controlPoint2_length = 0.309 * length

            var ratio: CGFloat = 1.236
            
            // in the case of distant slur connection points, make less bulbous
            if run > 100 {
                let diff = run - 100
                ratio -= 0.004 * diff
            }
            
            let controlPointAngle = RADIANS_TO_DEGREES(atan(ratio))
            let dir: CGFloat = stemDirection == .Down ? 1 : -1
            
            // set compound angles (angle of slur and control point angle) in RADIANS
            controlPoint1_angle = DEGREES_TO_RADIANS(dir * controlPointAngle + angle)
            controlPoint2_angle = DEGREES_TO_RADIANS(180 - (dir * controlPointAngle - angle))
            
            // set control points with values
            setControlPoint1WithLength(controlPoint1_length, andAngle: controlPoint1_angle)
            setControlPoint2WithLength(controlPoint2_length, andAngle: controlPoint2_angle)
            setInnerAndOuterControlPointsWithAbstractControlPoints()
        }
    }
    
    internal func setInnerAndOuterControlPointsWithAbstractControlPoints() {
        if let point1 = point1, point2 = point2 {
            let dir: CGFloat = stemDirection == .Down ? 1 : -1

            // width at middle, vaguely ...
            let w: CGFloat = 0.382 * g // factor of run
            
            controlPoint1_outside = getPointWithLength(
                controlPoint1_length,
                andAngle: controlPoint1_angle,
                fromPoint: point1
            )
            
            controlPoint1_inside = CGPoint(
                x: controlPoint1_outside!.x,
                y: controlPoint1_outside!.y - dir * w
            )
            
            controlPoint2_outside = getPointWithLength(
                controlPoint2_length,
                andAngle: controlPoint2_angle,
                fromPoint: point2
            )
            
            controlPoint2_inside = CGPoint(
                x: controlPoint2_outside!.x,
                y: controlPoint2_outside!.y - dir * w
            )
            
            // GET RID OF THIS
            // add test dots
            //testDots.map { $0.removeFromSuperlayer() }
            for dot in testDots { dot.removeFromSuperlayer() }
            testDots = []
            for point in [
                controlPoint1_inside!,
                controlPoint1_outside!,
                controlPoint2_outside!,
                controlPoint2_inside!
            ]
            {
                let dot = CAShapeLayer()
                dot.frame = CGRect(origin: CGPointZero, size: CGSize(width: 0.25 * g, height: 0.25 * g))
                dot.path = UIBezierPath(ovalInRect: dot.bounds).CGPath
                dot.fillColor = UIColor.greenColor().CGColor
                dot.opacity = 0.618
                dot.position = CGPoint(x: point.x, y: point.y)
                addSublayer(dot)
                testDots.append(dot)
            }
        }
    }
    
    private func createBezierPath() {
        
        // initial bezier path for the first time
        if bezierPath == nil { bezierPath = BezierPath() }
        
        if let point1 = point1, point2 = point2,
            cp1_outside = controlPoint1_outside, cp2_outside = controlPoint2_outside,
            cp2_inside = controlPoint2_inside, cp1_inside = controlPoint1_inside
        {
            
            let curveOutside = BezierCurveCubic(
                point1: point1,
                controlPoint1: cp1_outside,
                controlPoint2: cp2_outside,
                point2: point2
            )
            
            let curveInside = BezierCurveCubic(
                point1: point2,
                controlPoint1: cp2_inside,
                controlPoint2: cp1_inside,
                point2: point1
            )
            bezierPath.clearCurves()
            bezierPath.addCurve(curveOutside)
            bezierPath.addCurve(curveInside)
        }

    }
    
    internal override func makePath() -> CGPath {
        createBezierPath()
        return bezierPath.cgPath
    }
    
    /*
    public func build() {
        path = makePath()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    */
    
    private func setControlPoint1WithLength(length: CGFloat, andAngle angle: CGFloat) {
        if let point1 = point1 {
            controlPoint1 = getPointWithLength(
                length,
                andAngle: angle,
                fromPoint: point1
            )
            controlPoint1_length = length
            controlPoint1_angle = angle
        }
    }
    
    private func setControlPoint2WithLength(length: CGFloat, andAngle angle: CGFloat) {
        if let point2 = point2 {
            controlPoint2 = getPointWithLength(
                length,
                andAngle: angle,
                fromPoint: point2
            )
            controlPoint2_length = length
            controlPoint2_angle = angle
        }
    }
    
    // ANGLE IN RADIANS: MAKE THIS A MORE GLOBAL FUNCTION!
    private func getPointWithLength(length: CGFloat,
        andAngle angle: CGFloat, fromPoint point: CGPoint
    ) -> CGPoint
    {
        let x = point.x + length * cos(angle)
        let y = point.y + length * sin(angle)
        return CGPoint(x: x, y: y)
    }
    
    private func getLengthFromPoint(point: CGPoint, toPoint otherPoint: CGPoint) -> CGFloat {
        if point != otherPoint {
            let rise = otherPoint.y - point.y
            let run = otherPoint.x - point.x
            return sqrt(rise * rise + run * run)
        }
        return 0
    }
    
    // RADIANS
    private func getAngleBetweenPoint(point: CGPoint, andPoint otherPoint: CGPoint) -> CGFloat {
        if point != otherPoint {
            let rise = otherPoint.y - point.y
            let run = otherPoint.x - point.x
            return atan(rise / run)
        }
        return 0
    }
    
    public override func setVisualAttributes() {
        fillColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        strokeColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        lineWidth = g / 16
        lineJoin = kCALineJoinRound
        lineCap = kCALineCapRound
    }
}
