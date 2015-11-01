//
//  BeamsLayerGroup.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class BeamsLayerGroup: ViewNode {
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public var stemDirection: StemDirection = .Down
    
    public init(stemDirection: StemDirection) {
        self.stemDirection = stemDirection
        super.init()
        //layoutRelationship = .AsSublayers // DEPRECATED
        setsHeightWithContents = true
        setsWidthWithContents = true
        layoutFlow_vertical = stemDirection == .Down ? .Top : .Bottom
    }
    
    // nervous: may have deleted something here?
    public override init() {
        super.init()
        setsHeightWithContents = true
        setsWidthWithContents = true
        layoutFlow_vertical = stemDirection == .Down ? .Top : .Bottom
    }
    
    public func switchIsMetrical() {
        print("beamsLayerGroup.switchIsMetrical", terminator: "")
        CATransaction.setDisableActions(true)
        descendToSwitchIsMetrical(self)
        CATransaction.setDisableActions(false)
    }
    
    private func descendToSwitchIsMetrical(beamsLayerGroup: BeamsLayerGroup) {
        print("descend to switch is metrical", terminator: "")
        for node in beamsLayerGroup.nodes {
            if let group = node as? BeamsLayerGroup {
                descendToSwitchIsMetrical(group)
            }
            else if let beamsLayer = node as? BeamsLayer {
                beamsLayer.switchIsMetrical()
            }
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