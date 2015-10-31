//
//  BezierPath.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BezierPath: CustomStringConvertible {
    
    public var description: String { get { return getDescription() } }
    
    public var curves: [BezierCurve] = []
    
    public var uiBezierPath: UIBezierPath { get { return getUIBezierPath() } }
    public var cgPath: CGPath { get { return uiBezierPath.CGPath } }

    public init() { }
    
    public func addCurve(curve: BezierCurve) {
        curves.append(curve)
    }
    
    public func clearCurves() {
        curves = []
    }
    
    public func getUIBezierPath() -> UIBezierPath {
        var lastPoint: CGPoint?
        let path = UIBezierPath()
        for (c, curve) in curves.enumerate() {
            switch curve {
            case let linear as BezierCurveLinear:
                if c == 0 {
                    path.moveToPoint(linear.p1)
                    path.addLineToPoint(linear.p2)
                }
                else if let _ = lastPoint where lastPoint == linear.p1 {
                    path.addLineToPoint(linear.p2)
                }
                else {
                    path.addLineToPoint(linear.p1)
                    path.addLineToPoint(linear.p2)
                }
            case let quadratic as BezierCurveQuadratic:
                if c == 0 {
                    path.moveToPoint(quadratic.p1)
                    path.addQuadCurveToPoint(quadratic.p2,
                        controlPoint: quadratic.cp
                    )
                }
                else if let lastPoint = lastPoint where lastPoint == quadratic.p1 {
                    path.addQuadCurveToPoint(quadratic.p2,
                        controlPoint: quadratic.cp
                    )
                }
                else {
                    path.addLineToPoint(quadratic.p1)
                    path.addQuadCurveToPoint(quadratic.p2,
                        controlPoint: quadratic.cp
                    )
                }
            case let cubic as BezierCurveCubic:
                if c == 0 {
                    path.moveToPoint(cubic.p1)
                    path.addCurveToPoint(cubic.p2,
                        controlPoint1: cubic.cp1, controlPoint2: cubic.cp2
                    )
                }
                else if let lastPoint = lastPoint where lastPoint == cubic.p1 {
                    path.addCurveToPoint(cubic.p2,
                        controlPoint1: cubic.cp1, controlPoint2: cubic.cp2
                    )
                }
                else {
                    path.addLineToPoint(cubic.p1)
                    path.addCurveToPoint(cubic.p2,
                        controlPoint1: cubic.cp1, controlPoint2: cubic.cp2
                    )
                }
            default: break
            }
            lastPoint = curve.p2
        }
        path.closePath()
        return path
    }
    
    public func getYValuesAtX(x: CGFloat) -> [CGFloat] {
        var values: [CGFloat] = []
        for curve in curves { for y in curve.getYValuesAtX(x) { values.append(y) } }
        return values
    }
    
    internal func getDescription() -> String {
        var description: String = ""
        for curve in curves { description += "\n-- \(curve)" }
        return description
    }
}
