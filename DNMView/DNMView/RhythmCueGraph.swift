//
//  RhythmCueGraph.swift
//  denm_view
//
//  Created by James Bean on 9/28/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class RhythmCueGraph: Graph {
    
    //public var height: CGFloat = 0
    public var g: CGFloat = 0
    
    public init(height: CGFloat, g: CGFloat) {
        super.init()
        self.height = height
        self.g = g
        setFrame()
        pad_bottom = 4
    }
    
    public override init() {
        super.init()
        pad_bottom = 4
    }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func build() {
        // addClefAWithtype(tX(x: )
        
    }
    
    public override func addClefAtX(x: CGFloat) {
        let clef = ClefCue()
        clef.g = g
        clef.x = x
        clef.height = height
        clef.build()
        addSublayer(clef)
    }

    public override func setFrame() {
        frame = CGRectMake(0, 0, 1000, height) // width is hack
    }
}