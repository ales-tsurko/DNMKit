//
//  TempoMarking.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

// Make TempoMarkingView -- mirror with TempoMarking in Model
// Make subclass of Label
// ViewNode?
public class TempoMarkingView: CALayer {
    
    public var left: CGFloat = 0
    public var top: CGFloat = 0
    
    public var height: CGFloat = 0
    
    public var subdivisionLevel: Int = 1 // eighth note
    public var value: Int = 60 // at 60 bpm
    
    public var subdivisionGraphic: SubdivisionGraphic!
    public var numberLayer: TextLayerConstrainedByHeight!
    
    public init(
        left: CGFloat = 0,
        top: CGFloat = 0,
        height: CGFloat,
        value: Int = 60,
        subdivisionLevel: Int = 1
    )
    {
        super.init()
        self.left = left
        self.top = top
        self.height = height
        self.value = value
        self.subdivisionLevel = subdivisionLevel
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        addSubdivisionGraphic()
        addNumberLayer()
        let pad = 0.1618 * height
        numberLayer.position.x = 0.5 * numberLayer.frame.width + subdivisionGraphic.frame.maxX + pad
        frame = CGRectMake(left, top, numberLayer.frame.maxX, height)
    }
    
    
    
    public func addNumberLayer() {
        numberLayer = TextLayerConstrainedByHeight(
            text: "\(value)",
            x: 0,
            top: 0,
            height: 0.618 * height,
            alignment: .Center,
            fontName: "AvenirNextCondensed-DemiBold"
        )
        numberLayer.foregroundColor = UIColor.grayscaleColorWithDepthOfField(.MiddleForeground).CGColor
        numberLayer.position.y = 0.5 * height
        addSublayer(numberLayer)
    }
    
    public func addSubdivisionGraphic() {
        subdivisionGraphic = SubdivisionGraphic(
            x: 0, top: 0, height: height, stemDirection: .Down, amountBeams: subdivisionLevel
        )
        subdivisionGraphic.position.x = 0.5 * subdivisionGraphic.frame.width
        addSublayer(subdivisionGraphic)
    }
}
