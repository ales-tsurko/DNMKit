//
//  BezierCurve.swift
//  BezierCurve
//
//  Created by James Bean on 10/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public protocol BezierCurve {

    // First Point
    var p1: CGPoint { get set }
    
    // Second Point
    var p2: CGPoint { get set }
    
    var uiBezierPath: UIBezierPath { get }
    var cgPath: CGPath { get }
    
    func getYValuesAtX(x: CGFloat) -> [CGFloat]
    func getXAtY(y: CGFloat) -> [CGFloat]
    
    func isWithinBounds(x x: CGFloat) -> Bool
    func isWithinBounds(y y: CGFloat) -> Bool
}
