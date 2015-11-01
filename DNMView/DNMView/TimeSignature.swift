//
//  TimeSignature.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class TimeSignature: ViewNode, BuildPattern {
    
    public var measure: MeasureView?
    
    public var numeratorLayer: TextLayerConstrainedByHeight?
    public var denominatorLayer: TextLayerConstrainedByHeight?
    
    public var numerator: String = ""
    public var denominator: String = "" // perhaps make string to include: ?/16 or Δ/32
    public var x: CGFloat = 0
    public var height: CGFloat = 0
    
    private var pad_between: CGFloat { get { return 0.0618 * height } }
    private var numberHeight: CGFloat { get { return (height - pad_between) / 2 } }
    
    public init(numerator: Int, denominator: Int, x: CGFloat, top: CGFloat, height: CGFloat) {
        self.numerator = "\(numerator)"
        self.denominator = "\(denominator)"
        self.x = x
        self.height = height
        super.init()
        self.top = top
        build()
    }
    
    override init() {
        super.init()
        layoutFlow_horizontal = .Center
        setsWidthWithContents = true // override
    }
    
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        addNumeratorLayer()
        addDenominatorLayer()
        setFrame()
        flowHorizontally()
    }
    
    private func addNumeratorLayer() {
        numeratorLayer = TextLayerConstrainedByHeight(
            text: numerator,
            x: 0,
            top: 0,
            height: numberHeight,
            alignment: .Center,
            fontName: "Baskerville-SemiBold"
        )
        numeratorLayer?.foregroundColor = UIColor.brownColor().CGColor
        addSublayer(numeratorLayer!)
    }
    
    private func addDenominatorLayer() {
        denominatorLayer = TextLayerConstrainedByHeight(
            text: denominator,
            x: 0,
            top: numberHeight + pad_between,
            height: numberHeight,
            alignment: .Center,
            fontName: "Baskerville-SemiBold"
        )
        denominatorLayer?.foregroundColor = UIColor.brownColor().CGColor
        addSublayer(denominatorLayer!)
    }
    
    private func setFrame() {
        setWidthWithContents()
        frame = CGRectMake(x - 0.5 * frame.width, top, frame.width, height)
    }
    
    override func setWidthWithContents() {
        let maxWidth: CGFloat = numeratorLayer!.frame.width > denominatorLayer!.frame.width
            ? numeratorLayer!.frame.width
            : denominatorLayer!.frame.width
        frame = CGRectMake(frame.minX, frame.minY, maxWidth, frame.height)
    }
    
    override func flowHorizontally() {
        numeratorLayer!.position.x = 0.5 * frame.width
        denominatorLayer!.position.x = 0.5 * frame.width
    }
    
    public override func hitTest(p: CGPoint) -> CALayer? {
        if containsPoint(p) { return self }
        else { return nil }
    }
    
    public override func containsPoint(p: CGPoint) -> Bool {
        return CGRectContainsPoint(frame, p)
    }
}