//
//  Stem.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

public class Stem: LigatureVertical {
    
    public override var description: String { get { return "Stem" } }

    public var instrumentEvent: InstrumentEvent?
    public var bgEvent: BGEvent?
    
    // deprecate
    public var graphEvent: GraphEvent?
    
    public var beamEndY: CGFloat = 0
    public var infoEndY: CGFloat = 0
    
    public var isHighlighted: Bool = false
    
    public var color: CGColorRef = UIColor.colorWithHue(HueByTupletDepth[0],
        andDepthOfField: .MostForeground).CGColor
    {
        didSet {
            strokeColor = color
        }
    }
    
    public var direction: DirectionRelative = .Down
    
    public init(x: CGFloat, beamEndY: CGFloat, infoEndY: CGFloat) {
        self.beamEndY = beamEndY
        self.infoEndY = infoEndY
        if beamEndY < infoEndY { super.init(x: x, top: beamEndY, bottom: infoEndY) }
        else { super.init(x: x, top: infoEndY, bottom: beamEndY) }
    }
    
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    public func setBeamEndY(beamEndY: CGFloat, andInfoEndY infoEndY: CGFloat) {
        self.beamEndY = beamEndY
        self.infoEndY = infoEndY
        if beamEndY < infoEndY { setTop(beamEndY, andBottom: infoEndY) }
        else { setTop(infoEndY, andBottom: beamEndY) }
    }
    
    private func getDescription() -> String {
        var description: String = "Stem"
        if graphEvent != nil { description += ": \(graphEvent!)" }
        if bgEvent != nil { description += "; \(bgEvent)" }
        return description
    }
    
    public func highlight() {
        CATransaction.setDisableActions(true)
        strokeColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        CATransaction.setDisableActions(false)
        isHighlighted = true
    }
    
    public func deHighlight() {
        CATransaction.setDisableActions(true)
        strokeColor = color
        CATransaction.setDisableActions(false)
        isHighlighted = false
    }
}

