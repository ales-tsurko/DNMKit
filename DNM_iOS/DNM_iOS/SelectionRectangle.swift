//
//  SelectionRectangle.swift
//  denm_view
//
//  Created by James Bean on 10/5/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class SelectionRectangle: CAShapeLayer {
    
    public var initialPoint: CGPoint!
    
    public init(initialPoint: CGPoint) {
        super.init()
        self.initialPoint = initialPoint
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func build() {
        setFrameWithWidth(0, andHeight: 0)
        setVisualAttributes()
    }
    
    public func scaleToPoint(point newPoint: CGPoint) {
        let width = newPoint.x - initialPoint.x
        let height = newPoint.y - initialPoint.y
        
        CATransaction.setDisableActions(true)
        setFrameWithWidth(width, andHeight: height)
        CATransaction.setDisableActions(false)
    }
    
    public func setFrameWithWidth(width: CGFloat, andHeight height: CGFloat) {
        frame = CGRectMake(initialPoint.x, initialPoint.y, width, height)
    }
    
    public func setVisualAttributes() {
        backgroundColor = UIColor.lightGrayColor().CGColor
        borderColor = UIColor.blackColor().CGColor
        borderWidth = 1
        opacity = 0.1
    }
}
