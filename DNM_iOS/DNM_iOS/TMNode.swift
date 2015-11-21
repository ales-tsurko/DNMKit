//
//  TMNode.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class TMNode: ViewNode {
    
    public var height: CGFloat = 0
    public var tempoMarkings: [TempoMarkingView] = []
    
    public init(height: CGFloat) {
        super.init()
        self.height = height
        frame = CGRectMake(0, 0, 0, height)
    }
    
    public override init() { super.init() }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func addSampleTempoMarking() {
        let tempoMarking = TempoMarkingView(height: 30)
        addTempoMarking(tempoMarking)
    }

    public func addSampleTempoMarkingAtX(x: CGFloat) {
        let tempoMarking = TempoMarkingView(left: x, height: 30)
        addTempoMarking(tempoMarking)
    }
    
    public func addTempoMarking(tempoMarking: TempoMarkingView) {
        tempoMarkings.append(tempoMarking)
        addSublayer(tempoMarking)
    }
    
    public func addTempoMarking(tempoMarking: TempoMarkingView, atX x: CGFloat) {
        tempoMarking.height = height
        tempoMarking.left = x
        addTempoMarking(tempoMarking)
    }
    
    public func addTempoMarkingAtX(x: CGFloat, value: Int, subdivisionLevel: Int) {
        let tempoMarking = TempoMarkingView(
            left: x, top: 0, height: height, value: value, subdivisionLevel: subdivisionLevel
        )
        addTempoMarking(tempoMarking)
    }
}