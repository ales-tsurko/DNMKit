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
    
    public init(styledBezierCurve: StyledBezierCurve, widthAtBeginning: CGFloat, widthAtEnd: CGFloat) {
        super.init(styledBezierCurve: styledBezierCurve)
        self.widthAtBeginning = widthAtBeginning
        self.widthAtEnd = widthAtEnd
        addWidths()
    }
    
    public required init(styledBezierCurve: StyledBezierCurve) {
        super.init(styledBezierCurve: styledBezierCurve)
        addWidths()
    }
    
    private func addWidths() {

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