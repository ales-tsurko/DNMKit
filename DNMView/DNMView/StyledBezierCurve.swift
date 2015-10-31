//
//  StyledBezierCurve.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public protocol StyledBezierCurve {

    var carrierCurve: BezierCurve { get set }
    var bezierPath: BezierPath! { get set }
    var uiBezierPath: UIBezierPath { get }
    
    //var styledBezierCurve: ConcreteStyledBezierCurve { get set }
    
    //init(styledBezierCurve: ConcreteStyledBezierCurve)
}