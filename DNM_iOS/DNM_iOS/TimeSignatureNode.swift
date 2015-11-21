//
//  TimeSignatureNode.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class TimeSignatureNode: ViewNode {
    
    public var height: CGFloat = 0
    public var timeSignatures: [TimeSignature] = []
    
    public init(height: CGFloat = 0) {
        self.height = height
        super.init()
        layoutFlow_vertical = .Middle
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func getTimeSignatureAtX(x: CGFloat) -> TimeSignature? {
        for timeSignature in timeSignatures {
            if timeSignature.position.x == x { return timeSignature }
        }
        return nil
    }
    
    public func addTimeSignature(timeSignature: TimeSignature) {
        timeSignatures.append(timeSignature)
        addNode(timeSignature)
    }
    
    public func addTimeSignatureWithNumerator(
        numerator: Int, andDenominator denominator: Int, atX x: CGFloat
    )
    {
        let timeSignature = TimeSignature(
            numerator: numerator, denominator: denominator, x: x, top: 0, height: height
        )
        addTimeSignature(timeSignature)
    }
}
