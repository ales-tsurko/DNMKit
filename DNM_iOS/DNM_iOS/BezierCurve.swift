//
//  BezierCurve.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

/**
 Bezier Curve
*/
public protocol BezierCurve {

    /// First point
    var p1: CGPoint { get set }

    /// Second point
    var p2: CGPoint { get set }

    /// UIBezierPath computed
    var uiBezierPath: UIBezierPath { get }

    /// CGPath computed
    var cgPath: CGPath { get }

    /**
    Get an array of all y values for a given x

    - parameter x: x value

    - returns: Array of y values for a given x
    */
    func getYValuesAtX(x: CGFloat) -> [CGFloat]
    func getXAtY(y: CGFloat) -> [CGFloat]

    func isWithinBounds(x x: CGFloat) -> Bool
    func isWithinBounds(y y: CGFloat) -> Bool
}
