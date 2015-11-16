//
//  DMLigatureSegment.swift
//  denm_view
//
//  Created by James Bean on 9/14/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class DMLigatureSegment: CAShapeLayer, BuildPattern {
    
    public var height: CGFloat = 0
    public var left: CGFloat = 0
    public var right: CGFloat = 0
    public var percentageLeft: CGFloat = 0
    public var percentageRight: CGFloat = 0
    public var lineStyle: DMLigatureSegmentStyle = .Solid
    // exponent
    //public var style: Int = 0

    public var hasBeenBuilt: Bool = false
    
    
    public init(
        height: CGFloat,
        left: CGFloat,
        right: CGFloat,
        percentageLeft: CGFloat,
        percentageRight: CGFloat,
        lineStyle: DMLigatureSegmentStyle = .Solid
    )
    {
        super.init()
        self.height = height
        self.left = left
        self.right = right
        self.percentageLeft = percentageLeft
        self.percentageRight = percentageRight
        self.lineStyle = lineStyle
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        self.path = makePath()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    private func makePath() -> CGPath {
        let path = UIBezierPath()
        
        // not dealing with exponents yet!!
        
        // top line
        path.moveToPoint(CGPointMake(left, (0.5 - 0.5 * percentageLeft) * height))
        path.addLineToPoint(CGPointMake(right, (0.5 - 0.5 * percentageRight) * height))
        
        // bottom line
        path.moveToPoint(CGPointMake(left, (0.5 + 0.5 * percentageLeft) * height))
        path.addLineToPoint(CGPointMake(right, (0.5 + 0.5 * percentageRight) * height))
        
        return path.CGPath
    }
    
    private func setVisualAttributes() {
        strokeColor = UIColor.lightGrayColor().CGColor
        fillColor = UIColor.whiteColor().CGColor
        lineJoin = kCALineJoinBevel
        lineWidth = 0.1236 * height
        
        switch lineStyle {
        case .Dashed: lineDashPattern = [0.309 * height]
        default: break
        }
    }
}

public enum DMLigatureSegmentStyle {
    case Dashed, Solid // others
}