//
//  Barline.swift
//  denm_view
//
//  Created by James Bean on 10/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class Barline: LigatureVertical, Playable {
    
    public override func setVisualAttributes() {
        strokeColor = JBColor.grayscaleColorWithDepthOfField(.MostBackground).CGColor
    }
    
    public func play() {
        strokeColor = UIColor.redColor().CGColor
    }
    
    public func playNext() {
        // nothing, just to appease Playable protocol, will disappear
    }
}