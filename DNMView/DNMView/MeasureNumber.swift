//
//  MeasureNumber.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

// Consider as subclass of Label
public class MeasureNumber: ViewNode, BuildPattern {
    
    public var measure: Measure?
    
    private var margin: CGFloat { get { return 0.25 * height } }
    public var borderLayer: CAShapeLayer!
    public var numberLayer: TextLayerConstrainedByHeight!
    
    public var number: Int = 0
    public var x: CGFloat = 0
    public var height: CGFloat = 10
    
    public init(number: Int = 0, x: CGFloat = 0, top: CGFloat = 0, height: CGFloat = 10) {
        super.init()
        self.number = number
        self.x = x
        self.top = top
        self.height = height
        build()
    }

    public func build() {
        addNumberLayer()
        setFrame()
        addBorderLayer()
    }
    
    private func addNumberLayer() {
        let numberHeight: CGFloat = height - 2 * margin
        numberLayer = TextLayerConstrainedByHeight(
            text: "\(number)",
            x: 0,
            top: margin,
            height: numberHeight,
            alignment: .Center,
            fontName: "AvenirNext-Medium"
        )
        numberLayer.foregroundColor = JBColor.grayscaleColorWithDepthOfField(.Foreground).CGColor
        addSublayer(numberLayer)
    }
    
    private func addBorderLayer() {
        borderLayer = CAShapeLayer()
        let borderPath = UIBezierPath(rect: bounds)
        borderLayer.path = borderPath.CGPath
        borderLayer.lineWidth = 0.0236 * height
        borderLayer.strokeColor = JBColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        borderLayer.fillColor = ColorManager.backgroundColor.CGColor
        borderLayer.lineJoin = kCALineJoinBevel
        insertSublayer(borderLayer, atIndex: 0)
    }
    
    private func setFrame() {
        frame = CGRectMake(
            x - 0.5 * (numberLayer.frame.width + margin),
            top,
            numberLayer.frame.width + 2 * margin,
            height
        )
        numberLayer.position.x = 0.5 * frame.width
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    func highlight() {
        numberLayer.foregroundColor = UIColor.redColor().CGColor
        borderLayer.strokeColor = UIColor.redColor().CGColor
    }
    
    public override func hitTest(p: CGPoint) -> CALayer? {
        if containsPoint(p) { return self }
        else { return nil }
    }
    
    public override func containsPoint(p: CGPoint) -> Bool {
        return CGRectContainsPoint(frame, p)
    }
}