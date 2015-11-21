//
//  Tremolo.swift
//  denm_view
//
//  Created by James Bean on 9/24/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class Tremolo: CAShapeLayer, BuildPattern {
    
    public var x: CGFloat = 0
    public var barHeight: CGFloat { get { return 0.5 * width } }
    public var top: CGFloat = 0
    public var width: CGFloat = 0
    public var amountBars: Int = 3
    
    public var hasBeenBuilt: Bool = false
    
    public init(x: CGFloat, top: CGFloat, width: CGFloat, amountBars: Int = 3) {
        super.init()
        self.x = x
        self.top = top
        self.width = width
        self.amountBars = amountBars
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
        
    public func build() {
        path = makePath()
        setFrame()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    internal func makePath() -> CGPath {
        let path = UIBezierPath()
        var accumHeight: CGFloat = 0.5 * barHeight
        for _ in 0..<amountBars {
            let bar = ParallelogramVertical(
                x: 0.5 * width, y: accumHeight, width: 0.309 * width, length: width, slope: 0.25
            )
            accumHeight += barHeight
            path.appendPath(bar)
        }
        return path.CGPath
    }
    
    public func setVisualAttributes() {
        fillColor = UIColor.grayscaleColorWithDepthOfField(.MiddleForeground).CGColor
    }
    
    public func setFrame() {
        // something
        frame = CGPathGetBoundingBox(path)
        position.x = x // hack?
    }
}
