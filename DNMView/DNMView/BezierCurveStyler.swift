//
//  BezierCurveStyler.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BezierCurveStyler: StyledBezierCurve {
    
    public var bezierPath: BezierPath!
    public var carrierCurve: BezierCurve
    public var styledBezierCurve: StyledBezierCurve
    
    public var uiBezierPath: UIBezierPath { get { return getUIBezierPath() } }
    
    public required init(styledBezierCurve: StyledBezierCurve) {
        self.styledBezierCurve = styledBezierCurve
        self.carrierCurve = styledBezierCurve.carrierCurve
    }
    
    private func getUIBezierPath() -> UIBezierPath {
        return bezierPath.uiBezierPath
    }
}
