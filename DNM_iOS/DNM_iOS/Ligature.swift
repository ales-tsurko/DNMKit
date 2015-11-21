//
//  Ligature.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

public class Ligature: CAShapeLayer, BuildPattern {
    
    public var point1: CGPoint?
    public var point2: CGPoint?
    
    internal var rise: CGFloat? { return getRise() }
    internal var run: CGFloat? { return getRun() }
    internal var length: CGFloat? { return getLength() }
    internal var slope: CGFloat? { return getSlope() }
    internal var angle: CGFloat? { return getAngle() }
    
    public var hasBeenBuilt: Bool = false
    
    public init(point1: CGPoint, point2: CGPoint) {
        self.point1 = point1
        self.point2 = point2
        super.init()
        build()
    }
    
    public override init() {
        super.init()
        build()
    }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    

    public func setPoint1(point: CGPoint) {
        if point1 == nil {
            point1 = point
            if point2 != nil { self.path = makePath() }
        }
        else {
            point1 = point
            if point2 != nil { animateToPath() }
        }
    }
    
    public func setPoint2(point: CGPoint) {
        if point2 == nil {
            point2 = point
            if point1 != nil { self.path = makePath() }
        }
        else {
            point2 = point
            if point1 != nil { animateToPath() }
        }
    }
    
    public func setPoint1(point1: CGPoint, andPoint2 point2: CGPoint) {
        self.point1 = point1
        self.point2 = point2
        animateToPath()
    }
    
    public func build() {
        if point1 != nil && point2 != nil {
            path = makePath()
            hasBeenBuilt = true
        }
        setVisualAttributes()
    }
    
    internal func animateToPath() {
        path = makePath() // have to test in actual animating circumstance
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animation.toValue = makePath()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        // for testing!
        animation.duration = 0.0000000001 // ?
        
        addAnimation(animation, forKey: nil)
    }
    
    internal func makePath() -> CGPath {
        let path = UIBezierPath()
        assert(point1 != nil && point2 != nil, "can't build path without initialized points")
        path.moveToPoint(point1!)
        path.addLineToPoint(point2!)
        return path.CGPath
    }
    
    public func setVisualAttributes() {
        // line width
        lineWidth = 2
        strokeColor = UIColor.grayColor().CGColor
        fillColor = nil
    }
    
    private func getRise() -> CGFloat? {
        if let point1 = point1, point2 = point2 { return point2.y - point1.y }
        return nil
    }
    
    private func getRun() -> CGFloat? {
        if let point1 = point1, point2 = point2 { return point2.x - point1.x }
        return nil
    }
    
    private func getSlope() -> CGFloat? {
        if let rise = rise, run = run { return rise / run }
        return nil
    }
    
    // DEGREES?!
    private func getAngle() -> CGFloat? {
        if let slope = slope { return RADIANS_TO_DEGREES(atan(slope)) }
        return nil
    }
    
    private func getLength() -> CGFloat? {
        if let rise = rise, run = run {
            return sqrt(rise * rise + run * run)
        }
        return nil
    }
}

public class LigatureHorizontal: Ligature {
    
    public var y: CGFloat = 0
    public var left: CGFloat = 0
    public var right: CGFloat = 0
    
    public init(y: CGFloat) {
        self.y = y
        super.init()
    }
    
    public init(y: CGFloat, left: CGFloat, right: CGFloat) {
        self.y = y
        self.left = left
        self.right = right
        super.init(point1: CGPointMake(left, y), point2: CGPointMake(right, y))
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func setLeftWithX(x: CGFloat) {
        self.left = x
        setPoint1(CGPointMake(x, y))
    }
    
    public func setRightWithX(x: CGFloat) {
        self.right = x
        setPoint2(CGPointMake(x, y))
    }
}

public class LigatureVertical: Ligature {
    
    public var x: CGFloat = 0
    
    public init(x: CGFloat) {
        self.x = x
        super.init()
    }
    
    public init(x: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.x = x
        super.init(point1: CGPointMake(x, top), point2: CGPointMake(x, bottom))
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func setTop(y: CGFloat) {
        setPoint1(CGPointMake(x, y))
    }
    
    public func setBottom(y: CGFloat) {
        setPoint2(CGPointMake(x, y))
    }
    
    public func setTop(top: CGFloat, andBottom bottom: CGFloat) {
        setPoint1(CGPointMake(x, top), andPoint2: CGPointMake(x, bottom))
    }
}
