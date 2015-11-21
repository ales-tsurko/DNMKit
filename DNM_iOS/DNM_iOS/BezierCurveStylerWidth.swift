//
//  BezierCurveStylerWidth.swift
//  DNMView
//
//  Created by James Bean on 11/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BezierCurveStylerWidth: BezierCurveStyler {
    
    public var width: CGFloat = 2
    
    public required init(styledBezierCurve: StyledBezierCurve) {
        super.init(styledBezierCurve: styledBezierCurve)
        addWidth()
    }
    
    public init(styledBezierCurve: StyledBezierCurve, width: CGFloat) {
        super.init(styledBezierCurve: styledBezierCurve)
        self.width = width
        addWidth()
    }
    
    private func addWidth() {
        let newPath: BezierPath = BezierPath()
        let c = carrierCurve
        
        // upper curve
        let left_upper = CGPoint(x: c.p1.x, y: c.p1.y - 0.5 * width)
        let right_upper = CGPoint(x: c.p2.x, y: c.p2.y - 0.5 * width)
        
        let upperCurve = BezierCurveLinear(point1: left_upper, point2: right_upper)
        newPath.addCurve(upperCurve)
        
        // lower curve
        let right_lower = CGPoint(x: c.p2.x, y: c.p2.y + 0.5 * width)
        let left_lower = CGPoint(x: c.p1.x, y: c.p1.y + 0.5 * width)
        
        let lowerCurve = BezierCurveLinear(point1: right_lower, point2: left_lower)
        newPath.addCurve(lowerCurve)
        
        bezierPath = newPath
    }
}
