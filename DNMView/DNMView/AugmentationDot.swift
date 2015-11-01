//
//  AugmentationDot.swift
//  denm_view
//
//  Created by James Bean on 9/3/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class AugmentationDot: CAShapeLayer {
    
    public var x: CGFloat = 0
    public var y: CGFloat = 0
    public var width: CGFloat = 0
    
    public init(x: CGFloat, y: CGFloat, width: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        super.init()
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    public func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
    }
    
    private func setFrame() {
        frame = CGRectMake(x - 0.5 * width, y - 0.5 * width, width, width)
    }
    
    private func makePath() -> CGPath {
        let path = UIBezierPath(ovalInRect: bounds)
        return path.CGPath
    }
    
    private func setVisualAttributes() {
        fillColor = UIColor.darkGrayColor().CGColor
        lineWidth = 0
    }
}

