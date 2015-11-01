//
//  RehearsalMarkingView.swift
//  DNMView
//
//  Created by James Bean on 10/18/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore


// Make a subclass of Label: See MeasureNumber
public class RehearsalMarkingView: ViewNode {
    
    private var margin: CGFloat { get { return 0.25 * height } }
    public var borderLayer: CAShapeLayer!
    public var textLayer: TextLayerConstrainedByHeight!
    
    public var index: Int = 0
    public var text: String = ""
    public var x: CGFloat = 0
    public var height: CGFloat = 20
    
    public var type: RehearsalMarkingType = .Alphabetical
    
    public init(
        index: Int = 0,
        x: CGFloat = 0,
        top: CGFloat = 0,
        height: CGFloat,
        type: RehearsalMarkingType = .Alphabetical
    )
    {
        super.init()
        self.index = index
        self.text = "A" // getText()
        self.x = x
        self.top = top
        self.height = height
        self.type = type
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        addTextLayer()
        setFrame()
        addBorderLayer()
    }
    
    private func addTextLayer() {
        let textHeight = height - 2 * margin
        textLayer = TextLayerConstrainedByHeight(
            text: text,
            x: 0,
            top: margin,
            height: textHeight,
            alignment: .Center,
            fontName: "AvenirNext-Medium"
        )
        textLayer.foregroundColor = UIColor.grayscaleColorWithDepthOfField(.Foreground).CGColor
        addSublayer(textLayer)
    }
    
    private func addBorderLayer() {
        borderLayer = CAShapeLayer()
        let borderPath = UIBezierPath(rect: bounds)
        borderLayer!.path = borderPath.CGPath
        borderLayer!.lineWidth = 0.0236 * height
        borderLayer!.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        borderLayer!.fillColor = DNMColorManager.backgroundColor.CGColor
        borderLayer!.lineJoin = kCALineJoinBevel
        insertSublayer(borderLayer, atIndex: 0)
    }
    
    private func setFrame() {
        frame = CGRectMake(
            x - 0.5 * textLayer.frame.width - margin,
            top,
            textLayer.frame.width + 2 * margin,
            height
        )
        textLayer.position.x = 0.5 * frame.width
    }

    private func getText() -> String {
        switch type {
        case .Alphabetical:
            return "A"
        case .Numerical:
            return "1"
        }
    }
    
    public override func hitTest(p: CGPoint) -> CALayer? {
        if containsPoint(p) { return self }
        else { return nil }
    }
    
    public override func containsPoint(p: CGPoint) -> Bool {
        return CGRectContainsPoint(frame, p)
    }
}

public enum RehearsalMarkingType: String {
    case Alphabetical
    case Numerical
}