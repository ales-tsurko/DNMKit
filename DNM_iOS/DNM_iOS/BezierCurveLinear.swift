//
//  BezierCurveLinear.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BezierCurveLinear: BezierCurve {
    
    // First point
    public var p1: CGPoint
    
    // Second point
    public var p2: CGPoint
    
    public var uiBezierPath: UIBezierPath { get { return getUIBezierPath() } }
    public var cgPath: CGPath { get { return uiBezierPath.CGPath } }
    
    public init(point1: CGPoint, point2: CGPoint) {
        self.p1 = point1
        self.p2 = point2
    }
    
    public func getYValuesAtX(x: CGFloat) -> [CGFloat] {
        let y = ((x - p1.x) / (p2.x - p1.x)) * (p2.y - p1.y) + p1.y
        return [y]
    }
    
    public func getXAtY(y: CGFloat) -> [CGFloat] {
        // TODO
        return []
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
        path.addLineToPoint(p2)
        return path
    }
}
