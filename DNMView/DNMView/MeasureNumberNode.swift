//
//  MeasureNumberNode.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

// TO-DO: PADS AT INIT
public class MeasureNumberNode: ViewNode {

    public var height: CGFloat = 0
    public var measureNumbers: [MeasureNumber] = []
    
    public init(height: CGFloat = 0) {
        self.height = height
        super.init()
        layoutFlow_vertical = .Top
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func addMeasureNumber(measureNumber: MeasureNumber) {
        measureNumbers.append(measureNumber)
        addNode(measureNumber)
    }
    
    public func addMeasureNumberWithNumber(number: Int, atX x: CGFloat) {
        let measureNumber = MeasureNumber(number: number, x: x, top: 0, height: height)
        addMeasureNumber(measureNumber)
    }
    
    public func getMeasureNumberAtX(x: CGFloat) -> MeasureNumber? {
        for measureNumber in measureNumbers {
            if measureNumber.position.x == x { return measureNumber }
        }
        return nil
    }
}