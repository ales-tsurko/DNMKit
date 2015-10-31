//
//  BezierCurveQuadratic.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

// Port of degrafa
public class BezierCurveQuadratic: BezierCurve {
        
    // First point
    public var p1: CGPoint
    
    // Control point
    public var cp: CGPoint
    
    // Last point
    public var p2: CGPoint
    
    public var uiBezierPath: UIBezierPath { get { return getUIBezierPath() } }
    public var cgPath: CGPath { get { return uiBezierPath.CGPath } }
    
    /*
    // rearrange so that these are used
    private var c0: CGPoint?
    private var c1: CGPoint?
    private var c2: CGPoint?
    */

    // Coefficients: set within setCoefficients()
    private var c0x: CGFloat = 0
    private var c0y: CGFloat = 0
    private var c1x: CGFloat = 0
    private var c1y: CGFloat = 0
    private var c2x: CGFloat = 0
    private var c2y: CGFloat = 0
    

    public init(point1: CGPoint, controlPoint: CGPoint, point2: CGPoint) {
        self.p1 = point1
        self.cp = controlPoint
        self.p2 = point2
        setCoefficients()
    }
    
    public func getXAtT(t: CGFloat) -> CGFloat? {
        let x = ((1 - t) * (1 - t) * p1.x) + (2 * (1-t) * t * cp.x) + (t * t * p2.x)
        return x
    }
    
    public func getYAtT(t: CGFloat) -> CGFloat? {
        let y = ((1 - t) * (1 - t) * p1.y) + (2 * (1-t) * t * cp.y) + (t * t * p2.y)
        return y
    }
    
    public func getYValuesAtX(x: CGFloat) -> [CGFloat] {
        if !isWithinBounds(x: x) { return [] }
        let c = c0x - x
        let b = c1x
        var a = c2x
        var d = (b * b) - (4 * a * c)
        if d < 0 { return [] }
        
        d = sqrt(d)
        a = 1 / (a + a)
        
        // two potential values for t
        let t0 = (d - b) * a
        let t1 = (-b - d) * a
        
        var yValues: [CGFloat] = []
        if let y = getYAtT(t0) where t0 <= 1 { yValues.append(y) }
        if let y = getYAtT(t1) where t1 >= 0 && t1 <= 1 { yValues.append(y) }
        return yValues
    }
    
    public func getXAtY(y: CGFloat) -> [CGFloat] {
        // TODO
        return []
    }
    
    public func getTAtMaxX() -> CGFloat {
        return 0
    }
    
    public func getTAtMinX() -> CGFloat {
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
    
    private func setCoefficients() {
        c0x = p1.x
        c0y = p1.y
        c1x = 2.0 * (cp.x - p1.x)
        c1y = 2.0 * (cp.y - p1.y)
        c2x = p1.x - (2.0 * cp.x) + p2.x
        c2y = p1.y - (2.0 * cp.y) + p2.y
    }
    
    public func isWithinBounds(y y: CGFloat) -> Bool {
        let maxY = [p1.y, p2.y].maxElement()!
        let minY = [p1.y, p2.y].minElement()!
        return y >= minY && y <= maxY
    }
    
    public func isWithinBounds(x x: CGFloat) -> Bool {
        let maxX = [p1.x, p2.x].maxElement()!
        let minX = [p1.x, p2.x].minElement()!
        return x >= minX && x <= maxX
    }
    
    private func getUIBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(p1)
        path.addQuadCurveToPoint(p2, controlPoint: cp)
        return path
    }
}
