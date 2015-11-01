//
//  Beam.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class Beam: CAShapeLayer {
    
    public override var description: String { get { return getDescription() } }
    
    public var g: CGFloat = 0
    
    public var scale: CGFloat = 1
    
    public var beamWidth: CGFloat { get { return 0.382 * g * scale } }
    
    public var start: CGPoint = CGPointZero
    public var stop: CGPoint = CGPointZero
    
    public init(g: CGFloat, scale: CGFloat, start: CGPoint, stop: CGPoint) {
        self.g = g
        self.scale = scale
        self.start = start
        self.stop = stop
        super.init()
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func build() {
        path = makePath()
        setVisualAttributes()
    }
    
    private func makePath() -> CGPath {
        //let width = stop.x - start.x
        let height = beamWidth
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(start.x, start.y - 0.5 * height))
        path.addLineToPoint(CGPointMake(stop.x, stop.y - 0.5 * height))
        path.addLineToPoint(CGPointMake(stop.x, stop.y + 0.5 * height))
        path.addLineToPoint(CGPointMake(start.x, start.y + 0.5 * height))
        path.closePath()
        return path.CGPath
    }
    
    private func setVisualAttributes() {
        fillColor = UIColor.blackColor().CGColor
        strokeColor = UIColor.blackColor().CGColor
        lineWidth = 0
    }
    
    internal func getDescription() -> String {
        let box = CGPathGetBoundingBox(path)
        return "BEAM: \(box)"
    }
}