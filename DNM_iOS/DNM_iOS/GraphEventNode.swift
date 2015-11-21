//
//  GraphEventNode.swift
//  denm_view
//
//  Created by James Bean on 9/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class GraphEventNode: GraphEvent {
    
    public var edge: GraphEventEdge?
    
    public var hasEdge: Bool = false
    
    public var y: CGFloat = 0
    public var width: CGFloat = 0
    
    public init(x: CGFloat, y: CGFloat, width: CGFloat = 10, stemDirection: StemDirection) {
        self.y = y
        self.width = width
        super.init()
        self.stemDirection = stemDirection
        self.x = x
    }

    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addEdge() {
        hasEdge = true
    }
    
    public override func build() {
        setFrame()
        
        // encapuslate: circle path
        let dot = CAShapeLayer()
        let path = UIBezierPath(ovalInRect: bounds)
        dot.path = path.CGPath
        dot.fillColor = UIColor.grayscaleColorWithDepthOfField(.MiddleForeground).CGColor
        addSublayer(dot)
        moveArticulations()
    }
    
    public func setFrame() {
        frame = CGRectMake(x - 0.5 * width, y - 0.5 * width, width, width)
    }
    
    public override func getMaxInfoY() -> CGFloat {
        return y
    }
    
    public override func getMinInfoY() -> CGFloat {
        return y
    }
}
