//
//  PerformerView.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// contains 0 -> n instruments
public class PerformerView: ViewNode {

    public override var description: String {
        get { return "PerformerView: ID: \(id); instrumentByID: \(instrumentByID)" }
    }
    
    public var id: String = ""
    
    public var instrumentOrder: [String]?
    public var instruments: [InstrumentView] = []
    public var instrumentByID: [String : InstrumentView] = [:]
    
    // consider protocol or superclass : See PerformerView
    public var bracket: CAShapeLayer? // make subclass
    public var label: TextLayerConstrainedByHeight?
    
    public var minInstrumentsTop: CGFloat? { get { return getMinInstrumentsTop() } }
    public var maxInstrumentsBottom: CGFloat? { get { return getMaxInstrumentsBottom() } }
    
    public init(id: String) {
        super.init()
        self.id = id
        layoutAccumulation_vertical = .Top
        addLabel()
    }
    
    public override init() {
        super.init()
        layoutAccumulation_vertical = .Top
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func addInstrument(instrument: InstrumentView) {
        instruments.append(instrument)
        instrumentByID[instrument.id] = instrument
        addNode(instrument)
        instrument.performer = self
        instrument.pad_bottom = 20 // hack
    }
    
    public func addInstrumentsWithInsturmentTypeByInstrumentID(
        instrumentTypeByInstrumentID: OrderedDictionary<String, InstrumentType>)
    {
        for (instrumentID, instrumentType) in instrumentTypeByInstrumentID {
            createInstrumentWithInstrumentType(instrumentType, andID: instrumentID)
        }
    }
    
    /*
    public func addInstrumentsWithIDsAndInstrumentTypes(
        idsAndInstrumentTypes: [(String, InstrumentType)]
    )
    {
        print("add instruments with ids and instrument types: \(idsAndInstrumentTypes)")
        for idAndInstrumentType in idsAndInstrumentTypes {
            let id = idAndInstrumentType.0
            let instrumentType = idAndInstrumentType.1
            createInstrumentWithInstrumentType(instrumentType, andID: id)
        }
    }
    */
    
    public func createInstrumentWithInstrumentType(instrumentType: InstrumentType,
        andID id: String
    )
    {
        if instrumentByID[id] == nil {
            if let instrument = InstrumentView.withType(instrumentType) {
                instrument.id = id
                instrument.pad_bottom = 20 // HACK
                addInstrument(instrument)
            }
        }
    }
    
    public override func layout() {
        super.layout()
        
        // encapsulate: updateBracket
        if bracket == nil {
            bracket = CAShapeLayer()
            addSublayer(bracket!)
        }
        else {
            
            // this is inexcusable
            if let minInstrumentsTop = minInstrumentsTop, maxInstrumentsBottom = maxInstrumentsBottom {
                let path = UIBezierPath()
                path.moveToPoint(CGPointMake(0, minInstrumentsTop))
                path.addLineToPoint(CGPointMake(0, maxInstrumentsBottom))
                bracket!.path = path.CGPath
                bracket!.strokeColor = UIColor.grayscaleColorWithDepthOfField(.MiddleBackground).CGColor
                bracket!.lineWidth = 3
                
                // hackish -- this is why we need more intelligent barline
                label?.position.y = minInstrumentsTop + 0.5 * (maxInstrumentsBottom - minInstrumentsTop)
            }
        }
    }
    
    private func addLabel() {
        // hack
        label = TextLayerConstrainedByHeight(
            text: id,
            x: -10,
            top: 0,
            height: 10,
            alignment: .Right,
            fontName: "Baskerville-SemiBold"
        )
        label!.foregroundColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        addSublayer(label!)
    }
    
    private func getMinInstrumentsTop() -> CGFloat? {
        var minY: CGFloat?
        for instrument in instruments {
            if !hasNode(instrument) { continue }
            if let minGraphsTop = instrument.minGraphsTop {
                let instrumentTop = convertY(minGraphsTop, fromLayer: instrument)
                if minY == nil { minY = instrumentTop }
                else if instrumentTop < minY! { minY = instrumentTop }
            }
        }
        return minY
    }
    
    private func getMaxInstrumentsBottom() -> CGFloat? {
        var maxY: CGFloat?
        for instrument in instruments {
            if !hasNode(instrument) { continue }
            if let maxGraphsBottom = instrument.maxGraphsBottom {
                let instrumentBottom = convertY(maxGraphsBottom, fromLayer: instrument)
                if maxY == nil { maxY = instrumentBottom }
                else if instrumentBottom > maxY! { maxY = instrumentBottom }
            }
        }
        return maxY
    }
}


