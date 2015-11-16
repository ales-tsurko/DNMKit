//
//  BezierCurveCubic.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// Port of degrafa
public class BezierCurveCubic: BezierCurve {
    
    // Start point
    public var p1: CGPoint
    
    // End point
    public var p2: CGPoint
    
    // First control point
    public var cp1: CGPoint
    
    // Second control point
    public var cp2: CGPoint
    
    public var uiBezierPath: UIBezierPath { get { return getUIBezierPath() } }
    public var cgPath: CGPath { get { return uiBezierPath.CGPath } }
    
    // Coefficients
    private var c0x: CGFloat = 0
    private var c0y: CGFloat = 0
    private var c1x: CGFloat = 0
    private var c1y: CGFloat = 0
    private var c2x: CGFloat = 0
    private var c2y: CGFloat = 0
    private var c3x: CGFloat = 0
    private var c3y: CGFloat = 0
    
    // Limit on interval width before interval is considered completely bisected
    private var bisectLimit: CGFloat = 0.05
    
    // Bisection interval bounds
    private var bisectLeft: CGFloat = 0
    private var bisectRight: CGFloat = 0
    
    // Stationary points of x(t) and y(t) ?!?!?!?!?!
    private var t1x: CGFloat = 0
    private var t1y: CGFloat = 0
    private var t2x: CGFloat = 0
    private var t2y: CGFloat = 0
    
    private var twbrf: Int? = nil // TO BE SimpleRoot
    private var solver2x2: Int? = nil // TO BE Solve2x2
    
    public init(point1: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint, point2: CGPoint) {
        self.p1 = point1
        self.p2 = point2
        self.cp1 = controlPoint1
        self.cp2 = controlPoint2
        setCoefficients()
    }
    
    // test?
    public func getPointAtT(t: CGFloat) -> CGPoint? {
        if t < 0 || t > 1 { return nil }
        let x: CGFloat = c0x + t * (c1x + t * (c2x + t * c3x))
        let y: CGFloat = c0y + t * (c1y + t * (c2y + t * c3y))
        return CGPoint(x: x, y: y)
    }
    
    public func getYValuesAtX(x: CGFloat) -> [CGFloat] {

        // check x is in bounds -- TODO: change isWithinBounds to use tAtMinX, tAtMinY, etc...
        if !isWithinBounds(x: x) { return [] }
        
        // Find a root, then factor out (t-r) to get a quadratic poly for the remaining roots
        func f(t: CGFloat) -> CGFloat {
            let val = t * (c1x + t * (c2x + t * c3x)) + c0x - x
            return val
        }
        
        // Instantiate The World's Best Root Finder
        let twbrf = SimpleRoot()
        
        // Some cubic curves need to be bisected in case of curling around themselves
        bisectLeft = 0
        bisectRight = 1
        bisect(left: 0, right: 1, f: f)
    
        let t0: CGFloat = twbrf.findRoot(
            x0: bisectLeft,
            x2: bisectRight,
            maximumIterationLimit: 50,
            tolerance: 0.000001,
            f: f
        )

        // is this required?
        /*
        let eval = abs(f(t0))
        if eval > 0.00001 {
            print("eval > 0.00001; return [] ?!?!?!?")
            return []
        }
        */
        
        // this will contain 0 to 3 y values for specified x value
        var result: [CGFloat] = []
        
        // Add first point if present
        if t0 <= 1 { if let y = getPointAtT(t0)?.y { result.append(y) } }
        
        // Continue to check for remaining two points
        var a = c3x
        let b = (t0 * a) + c2x
        let c = (t0 * b) + c1x
        var d = (b * b) - (4 * a * c)
        
        // Can't do sqrt of negative number, get out of here
        if d < 0 { return result }
        
        // Otherwise, continue
        d = sqrt(d)
        a = 1 / (a + a)
        let t1 = (d - b) * a
        let t2 = (-b - d) * a
        
        // Add second point if present
        if t1 >= 0 && t1 <= 1 { if let y = getPointAtT(t1)?.y { result.append(y) } }
        
        // Add third point if present
        if t2 >= 0 && t2 <= 1 { if let y = getPointAtT(t2)?.y { result.append(y) } }
        
        return result
    }
    
    public func bisect(left l: CGFloat, right r: CGFloat, f: CGFloat -> CGFloat) {
        if abs(r - l) <= bisectLimit { return }
        
        // perhaps not necessary
        let left = l
        let right = r
        
        let middle = 0.5 * (left + right)
        if f(left) * f(right) <= 0 {
            bisectLeft = left
            bisectRight = right
            return
        }
        else {
            bisect(left: left, right: middle, f: f)
            bisect(left: middle, right: right, f: f)
        }
    }

    public func getXAtY(y: CGFloat) -> [CGFloat] {
        // TODO
        return []
    }
    
    public func getTAtMaxX() -> CGFloat {
        // TODO
        return 0
    }
    
    public func getTAtMinX() -> CGFloat {
        // TODO
        return 0
    }
    
    public func getTAtMinY() -> CGFloat {
        // TODO
        return 0
    }
    
    public func getTAtMaxY() -> CGFloat {
        // TODO
        return 0
    }
    
    public func isWithinBounds(x x: CGFloat) -> Bool {
        // TODO: With T AT MIN X, MAX X
        let maxX = [p1.x, p2.x].maxElement()!
        let minX = [p1.x, p2.x].minElement()!
        return x >= minX && x <= maxX
    }
    
    public func isWithinBounds(y y: CGFloat) -> Bool {
        // TODO: With T AT MIN Y, MAX Y
        let maxY = [p1.y, p2.y].maxElement()!
        let minY = [p1.y, p2.y].minElement()!
        return y >= minY && y <= maxY
    }
    
    private func setCoefficients() {
        c0x = p1.x
        c0y = p1.y
        c1x = 3 * (cp1.x - p1.x)
        c1y = 3 * (cp1.y - p1.y)
        c2x = 3 * (cp2.x - cp1.x) - c1x
        c2y = 3 * (cp2.y - cp1.y) - c1y
        c3x = p2.x - p1.x - c2x - c1x
        c3y = p2.y - p1.y - c2y - c1y
    }
    
    private func getUIBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(p1)
        path.addCurveToPoint(p2, controlPoint1: cp1, controlPoint2: cp2)
        return path
    }
}
