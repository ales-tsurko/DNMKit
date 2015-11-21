//
//  BezierCurveStyleWidthVariable.swift
//  DNMView
//
//  Created by James Bean on 11/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BezierCurveStyleWidthVariable: BezierCurveStyler {
    
    public var widthAtBeginning: CGFloat = 2
    public var widthAtEnd: CGFloat = 2
    public var exponent: CGFloat = 1
    
    public init(
        styledBezierCurve: StyledBezierCurve,
        widthAtBeginning: CGFloat,
        widthAtEnd: CGFloat,
        exponent: CGFloat = 1
    )
    {
        super.init(styledBezierCurve: styledBezierCurve)
        self.widthAtBeginning = widthAtBeginning
        self.widthAtEnd = widthAtEnd
        self.exponent = exponent
        addWidths()
    }
    
    public required init(styledBezierCurve: StyledBezierCurve) {
        super.init(styledBezierCurve: styledBezierCurve)
        addWidths()
    }
    
    private func addWidths() {
        switch exponent {
        case 1: addWidthsLinear()
        case _ where exponent > 1: addWidthsExponential()
        case _ where exponent < 1: addWidthsLogarithmic()
        default: break
        }
    }
    
    private func addWidthsExponential() {

        // make switch statement?
        if widthAtBeginning > widthAtEnd { addWidthsExponentialDecrease() }
        else if widthAtBeginning < widthAtEnd { addWidthsExponentialIncrease() }
        else { addWidthsLinear() }
    }
    
    private func addWidthsExponentialIncrease() {
        let newPath: BezierPath = BezierPath()
        let c = carrierCurve
        
        // upper curve
        let upper_left = CGPoint(x: c.p1.x, y: c.p1.y - 0.5 * widthAtBeginning)
        let upper_right = CGPoint(x: c.p2.x, y: c.p2.y - 0.5 * widthAtEnd)
        let upper_cp = CGPoint(x: c.p2.x, y: c.p2.y - 0.5 * widthAtBeginning)
        
        let upperCurve = BezierCurveQuadratic(
            point1: upper_left, controlPoint: upper_cp, point2: upper_right
        )
        newPath.addCurve(upperCurve)
        
        let lower_right = CGPoint(x: c.p2.x, y: c.p2.y + 0.5 * widthAtEnd)
        let lower_left = CGPoint(x: c.p1.x, y: c.p1.y + 0.5 * widthAtBeginning)
        let lower_cp = CGPoint(x: c.p2.x, y: c.p2.y + 0.5 * widthAtBeginning)
        
        let lowerCurve = BezierCurveQuadratic(
            point1: lower_right, controlPoint: lower_cp, point2: lower_left
        )
        newPath.addCurve(lowerCurve)
        
        bezierPath = newPath
    }
    
    private func addWidthsExponentialDecrease() {
        let newPath: BezierPath = BezierPath()
        let c = carrierCurve
        
        // upper curve
        let upper_left = CGPoint(x: c.p1.x, y: c.p1.y - 0.5 * widthAtBeginning)
        let upper_right = CGPoint(x: c.p2.x, y: c.p2.y - 0.5 * widthAtEnd)
        let upper_cp = CGPoint(x: c.p1.x, y: c.p1.y - 0.5 * widthAtEnd)
        
        let upperCurve = BezierCurveQuadratic(
            point1: upper_left, controlPoint: upper_cp, point2: upper_right
        )
        newPath.addCurve(upperCurve)
        
        let lower_right = CGPoint(x: c.p2.x, y: c.p2.y + 0.5 * widthAtEnd)
        let lower_left = CGPoint(x: c.p1.x, y: c.p1.y + 0.5 * widthAtBeginning)
        let lower_cp = CGPoint(x: c.p1.x, y: c.p1.y + 0.5 * widthAtEnd)
        
        let lowerCurve = BezierCurveQuadratic(
            point1: lower_right, controlPoint: lower_cp, point2: lower_left
        )
        newPath.addCurve(lowerCurve)
        
        bezierPath = newPath    }
    
    
    private func addWidthsLogarithmic() {
        // TODO
        addWidthsLinear()
    }
    
    private func addWidthsLinear() {
        let newPath: BezierPath = BezierPath()
        let c = carrierCurve
        
        // upper curve: currently linear
        let left_upper = CGPoint(x: c.p1.x, y: c.p1.y - 0.5 * widthAtBeginning)
        let right_upper = CGPoint(x: c.p2.x, y: c.p2.y - 0.5 * widthAtEnd)
        
        let upperCurve = BezierCurveLinear(point1: left_upper, point2: right_upper)
        newPath.addCurve(upperCurve)
        
        
        // lower curve: currently linear
        let right_lower = CGPoint(x: c.p2.x, y: c.p2.y + 0.5 * widthAtEnd)
        let left_lower = CGPoint(x: c.p1.x, y: c.p1.y + 0.5 * widthAtBeginning)
        
        let lowerCurve = BezierCurveLinear(point1: right_lower, point2: left_lower)
        newPath.addCurve(lowerCurve)
        
        bezierPath = newPath
    }
}