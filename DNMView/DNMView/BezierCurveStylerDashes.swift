//
//  BezierCurveStylerDashes.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BezierCurveStylerDashes: BezierCurveStyler {
    
    // TODO: Init with Dash Width
    
    public required init(styledBezierCurve: StyledBezierCurve) {
        super.init(styledBezierCurve: styledBezierCurve)
        addDashes()
    }
    
    private func addDashes() {
        let newPath: BezierPath = BezierPath()
        
        let path = styledBezierCurve.bezierPath
        let dash_w: CGFloat = 5
        var x: CGFloat = 0
        while x <= (carrierCurve.p2.x - carrierCurve.p1.x) - dash_w {
            
            let left = x + carrierCurve.p1.x
            let right = x + carrierCurve.p1.x + dash_w
            
            let y_top_left = path.getYValuesAtX(left).minElement()!
            let y_top_right = path.getYValuesAtX(right).minElement()!
            let y_bottom_right = path.getYValuesAtX(right).maxElement()!
            let y_bottom_left = path.getYValuesAtX(left).maxElement()!
            
            let topSide = BezierCurveLinear(
                point1: CGPointMake(left, y_top_left),
                point2: CGPointMake(right, y_top_right)
            )
            
            let rightSide = BezierCurveLinear(
                point1: CGPointMake(right, y_top_right),
                point2: CGPointMake(right, y_bottom_right)
            )
            
            let bottomSide = BezierCurveLinear(
                point1: CGPointMake(right, y_bottom_right),
                point2: CGPointMake(left, y_bottom_left)
            )
            
            let leftSide = BezierCurveLinear(
                point1: CGPointMake(left, y_bottom_left),
                point2: CGPointMake(left, y_top_left)
            )
            
            newPath.addCurve(topSide)
            newPath.addCurve(rightSide)
            newPath.addCurve(bottomSide)
            newPath.addCurve(leftSide)
            
            x += 2 * dash_w
        }
        bezierPath = newPath
    }

}