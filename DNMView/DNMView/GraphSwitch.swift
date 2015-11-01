//
//  GraphSwitch.swift
//  denm_view
//
//  Created by James Bean on 10/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class GraphSwitch: Graph {
    
    // if 1: states are Off, On; if 2: states are Off, 1, 2
    public var amountThrows: Int = 1
    
    public override init(id: String) {
        super.init(id: id)
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addSwitchEventAtX(x: CGFloat,
        withValue value: Int, andStemDirection stemDirection: StemDirection
    )
    {
        let switchEvent = GraphEventSwitch(x: x, value: value, stemDirection: stemDirection)
        events.append(switchEvent)
    }
    
    public override func build() {
        commitLines()
        setFrame()

        let shape = CAShapeLayer()
        let path = UIBezierPath()

        for (e, event) in (events as! [GraphEventSwitch]).enumerate() {
            let newY: CGFloat = height - height * CGFloat(event.value) // later height * amountThrows / value
            if e == 0 { path.moveToPoint(CGPointMake(event.x, newY)) }
            else {
                let lastEvent = events[e-1] as! GraphEventSwitch
                let oldY: CGFloat = height - height * CGFloat(lastEvent.value)
                path.addLineToPoint(CGPointMake(event.x, oldY))
                path.addLineToPoint(CGPointMake(event.x, newY))
            }
        }
        // last point at some x, at height
        // hack x -- make frame.width, but currently that isn't being set nicely!
        path.addLineToPoint(CGPointMake(250, height))
        path.addLineToPoint(CGPointMake((events.first as! GraphEventSwitch).x, height))
        path.closePath()
        
        
        //path.closePath()
        shape.path = path.CGPath
        shape.fillColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        shape.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        shape.lineWidth = 2
        addSublayer(shape)
    }
}
