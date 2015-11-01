//
//  TemporalInfoNode.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class TemporalInfoNode: ViewNode {
    
    public var height: CGFloat = 0
    public var tempoMarkings: [TempoMarkingView] = []
    public var measureNumberNode: MeasureNumberNode?
    public var timeSignatureNode: TimeSignatureNode?
    public var rehearsalMarkingNode: ViewNode?
    
    private var pad: CGFloat { get { return 0.0618 * height } }
    
    public init(height: CGFloat) {
        self.height = height
        super.init()
        layoutAccumulation_vertical = .Top
    }
    
    public override init() { super.init() }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func addRehearsalMarking(rehearsalMarking: RehearsalMarkingView) {
        ensureRehearsalMarkingNode()
        rehearsalMarkingNode!.addNode(rehearsalMarking)
    }
    
    public func addRehearsalMarking(rehearsalMarking: RehearsalMarkingView, atX x: CGFloat) {
        
    }
    
    public func addRehearsalMarkingWithIndex(index: Int, type: RehearsalMarkingType, atX x: CGFloat) {
        
        // hack: height
        let rehearsalMarking = RehearsalMarkingView(
            index: index, x: x, top: 0, height: 40, type: type
        )
        addRehearsalMarking(rehearsalMarking)
    }
    
    private func ensureRehearsalMarkingNode() {
        if rehearsalMarkingNode == nil {
            rehearsalMarkingNode = ViewNode(flowVerticallyFrom: .Middle)
            rehearsalMarkingNode!.pad_bottom = 5
        }
        insertNode(rehearsalMarkingNode!, atIndex: 0)
    }
    
    // for fully completed time signature
    public func addTimeSignature(timeSignature: TimeSignature) {
        ensureTimeSignatureNode()
        timeSignatureNode!.addTimeSignature(timeSignature)
    }
    
    public func addTimeSignature(timeSignature: TimeSignature, atX x: CGFloat) {
        timeSignature.position.x = x
        addTimeSignature(timeSignature)
    }
    
    public func addTimeSignatureWithNumerator(
        numerator: Int, andDenominator denominator: Int, atX x: CGFloat
    )
    {
        ensureTimeSignatureNode()
        timeSignatureNode!.addTimeSignatureWithNumerator(numerator,
            andDenominator: denominator, atX: x
        )
    }
    
    public func addMeasureNumber(measureNumber: MeasureNumber, atX x: CGFloat) {
        measureNumber.position.x = x
        addMeasureNumber(measureNumber)
    }
    
    public func addMeasureNumberWithNumber(number: Int, atX x: CGFloat) {
        ensureMeasureNumberNode()
        measureNumberNode!.addMeasureNumberWithNumber(number, atX: x)
    }
    
    public func addMeasureNumber(measureNumber: MeasureNumber) {
        ensureMeasureNumberNode()
        measureNumberNode!.addMeasureNumber(measureNumber)
    }
    
    public func addTempoMarking(tempoMarking: TempoMarkingView) {
        tempoMarkings.append(tempoMarking)
        addSublayer(tempoMarking)
        
        // TODO: adjust position of TempoMarking, potentially just add to TimeSignatureNode
        
        if let timeSignatureNode = timeSignatureNode {
            tempoMarking.position.y = timeSignatureNode.frame.midY
        }
        else { tempoMarking.position.y = 0.5 * height }
    }
    
    public func addTempoMarkingWithValue(value: Int,
        andSubdivisionLevel subdivisionLevel: Int, atX x: CGFloat
    )
    {
        var x = x
        if let timeSignatureNode = timeSignatureNode {
            if let timeSignatureInTheWay = timeSignatureNode.getTimeSignatureAtX(x) {
                x = timeSignatureInTheWay.frame.maxX + 0.5 * timeSignatureInTheWay.frame.width
            }
        }

        let tempoMarking = TempoMarkingView(
            left: x, height: 0.382 * height, value: value, subdivisionLevel: subdivisionLevel
        )
        addTempoMarking(tempoMarking)
    }
    
    private func ensureTimeSignatureNode() {
        if timeSignatureNode == nil {
            timeSignatureNode = TimeSignatureNode(height: 0.618 * height - 0.5 * pad)
            addNode(timeSignatureNode!)
        }
    }
    
    private func ensureMeasureNumberNode() {
        if measureNumberNode == nil {
            measureNumberNode = MeasureNumberNode(height: 0.309 * height - 0.5 * pad)
            measureNumberNode!.pad_bottom = pad
            insertNode(measureNumberNode!, atIndex: 0)
        }
    }
}
