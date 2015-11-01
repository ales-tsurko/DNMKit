//
//  ConcreteStyledBezierCurve.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class ConcreteStyledBezierCurve: StyledBezierCurve {
    
    public var carrierCurve: BezierCurve
    public var bezierPath: BezierPath! = BezierPath()
    public var uiBezierPath: UIBezierPath { get { return getUIBezierPath() } }
    
    // public var widthAtT: [CGFloat : CGFloat] = [0.0 : 1, 1.0 : 1]
    
    // for now only:
    public var widthAtBeginning: CGFloat = 1
    public var widthAtEnd: CGFloat = 1
    public var widthAtMiddle: CGFloat = 1
    public var widthExponent: CGFloat = 1
    
    public var upperBoundingCurve: BezierCurve!
    public var lowerBoundingCurve: BezierCurve!
    
    public var styledBezierCurve: ConcreteStyledBezierCurve!
    
    public required init(styledBezierCurve: ConcreteStyledBezierCurve) {
        self.styledBezierCurve = styledBezierCurve
        self.carrierCurve = styledBezierCurve.carrierCurve
        setBoundingCurves()
    }
    
    public init(carrierCurve: BezierCurve) {
        self.carrierCurve = carrierCurve
        setBoundingCurves()
    }
    
    public func setWidthAtBeginningWithWidth(width: CGFloat) {
        widthAtBeginning = width
    }
    
    public func setWidthAtEndWithWidth(width: CGFloat) {
        widthAtEnd = width
    }
    
    public func setWithAtMiddleWithWidth(width: CGFloat) {
        widthAtMiddle = width
    }
    
    /*
    public func setWidth(width: CGFloat, atT t: CGFloat) {
        assert(t >= 0.0 && t <= 1.0, "t must be between 0.0 and 1.0")
        widthAtT[t] = width
    }
    */
    
    public func setBoundingCurves() {
        bezierPath.curves = []
        
        let p1x = carrierCurve.p1.x
        let p1y = carrierCurve.p1.y
        let p2x = carrierCurve.p2.x
        let p2y = carrierCurve.p2.y

        let top_left = CGPoint(x: p1x, y: p1y - 0.5 * widthAtBeginning)
        let top_right = CGPoint(x: p2x, y: p2y - 0.5 * widthAtEnd)
        let bottom_right = CGPoint(x: p2x, y: p2y + 0.5 * widthAtEnd)
        let bottom_left = CGPoint(x: p1x, y: p1y + 0.5 * widthAtBeginning)

        switch carrierCurve {
        case let quadratic as BezierCurveQuadratic:
            
            let top_cp = CGPoint(x: quadratic.cp.x, y: quadratic.cp.y - 0.5 * widthAtBeginning)
            let bottom_cp = CGPoint(x: quadratic.cp.x, y: quadratic.cp.y + 0.5 * widthAtBeginning)
            
            upperBoundingCurve = BezierCurveQuadratic(
                point1: top_left,
                controlPoint: top_cp,
                point2: top_right
            )
            
            lowerBoundingCurve = BezierCurveQuadratic(
                point1: bottom_right,
                controlPoint: bottom_cp,
                point2: bottom_left
            )
            
            bezierPath.addCurve(upperBoundingCurve)
            bezierPath.addCurve(lowerBoundingCurve)
            
        case let linear as BezierCurveLinear:
            upperBoundingCurve = BezierCurveLinear(point1: top_left, point2: top_right)
            lowerBoundingCurve = BezierCurveLinear(point1: bottom_right, point2: bottom_left)
            bezierPath.addCurve(upperBoundingCurve)
            bezierPath.addCurve(lowerBoundingCurve)
        case let cubic as BezierCurveCubic:
            // TODO
            break
        default: break
        }
    }

    private func getUIBezierPath() -> UIBezierPath {
        return bezierPath.uiBezierPath
    }
}