//
//  GraphEventSwitch.swift
//  denm_view
//
//  Created by James Bean on 10/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class GraphEventSwitch: GraphEvent {
    
    public var value: Int = 0
    
    public init(x: CGFloat, value: Int, stemDirection: StemDirection, stem: Stem? = nil) {
        super.init()
        self.x = x
        self.value = value
        self.stemDirection = stemDirection
        self.stem = stem
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}
