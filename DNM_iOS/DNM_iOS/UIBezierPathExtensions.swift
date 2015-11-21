//
//  UIBezierPathExtensions.swift
//  denm_view
//
//  Created by James Bean on 8/17/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

extension UIBezierPath {
    
    public func rotate(degrees degrees: Float) {
        let bounds = CGPathGetBoundingBox(self.CGPath)
        let center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        let toOrigin = CGAffineTransformMakeTranslation(-center.x, -center.y)
        let rotation = CGAffineTransformMakeRotation(CGFloat(DEGREES_TO_RADIANS(degrees)))
        let fromOrigin = CGAffineTransformMakeTranslation(center.x, center.y)
        self.applyTransform(toOrigin)
        self.applyTransform(rotation)
        self.applyTransform(fromOrigin)
    }
    
    public func mirror() {
        let mirrorOverXOrigin = CGAffineTransformMakeScale(-1, 1)
        let translate = CGAffineTransformMakeTranslation(bounds.width, 0)
        self.applyTransform(mirrorOverXOrigin)
        self.applyTransform(translate)
    }
    
    public func scale(sx: CGFloat, sy: CGFloat) {
        let scale = CGAffineTransformMakeScale(sx, sy)
        let beforeBounds = CGPathGetBoundingBox(self.CGPath)
        let beforeCenter = CGPointMake(CGRectGetMidX(beforeBounds), CGRectGetMidY(beforeBounds))
        self.applyTransform(scale)
        let afterBounds = CGPathGetBoundingBox(self.CGPath)
        let afterCenter = CGPointMake(CGRectGetMidX(afterBounds), CGRectGetMidY(afterBounds))
        let ΔY: CGFloat = -(afterCenter.y - beforeCenter.y)
        let ΔX: CGFloat = -(afterCenter.x - beforeCenter.x)
        let backToCenter = CGAffineTransformMakeTranslation(ΔX, ΔY)
        self.applyTransform(backToCenter)
    }
}
