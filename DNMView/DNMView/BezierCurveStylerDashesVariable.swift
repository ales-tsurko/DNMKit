//
//  BezierCurveStylerDashesVariable.swift
//  DNMView
//
//  Created by James Bean on 11/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BezierCurveStylerDashesVariable: BezierCurveStyler {
    
    public var dashWidthAtBeginning: CGFloat = 5
    public var dashWidthAtEnd: CGFloat = 5
    
    public init(
        styledBezierCurve: StyledBezierCurve,
        dashWidthAtBeginning: CGFloat,
        dashWidthAtEnd: CGFloat
    )
    {
        super.init(styledBezierCurve: styledBezierCurve)
        self.dashWidthAtBeginning = dashWidthAtBeginning
        self.dashWidthAtEnd = dashWidthAtEnd
        addDashes()
    }
    
    public required init(styledBezierCurve: StyledBezierCurve) {
        super.init(styledBezierCurve: styledBezierCurve)
        addDashes()
    }

    private func addDashes() {
        
        
    }
    
}
