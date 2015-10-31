//
//  Measure_model.swift
//  denm_model
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//


import Foundation

public struct Measure {
    
    public var duration: Duration = DurationZero
    public var offsetDuration: Duration = DurationZero
    
    public var hasTimeSignature: Bool = true
    
    public init(offsetDuration: Duration) {
        self.offsetDuration = offsetDuration
    }
    
    public mutating func setHasTimeSignature(hasTimeSignature: Bool) {
        self.hasTimeSignature = hasTimeSignature
    }
}