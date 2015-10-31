//
//  TempoMarking_model.swift
//  denm_model
//
//  Created by James Bean on 10/7/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct TempoMarking {
    public var value: Int
    public var subdivisionLevel: Int
    public var offsetDuration: Duration
    
    public init(value: Int, subdivisionLevel: Int, offsetDuration: Duration) {
        self.value = value
        self.subdivisionLevel = subdivisionLevel
        self.offsetDuration = offsetDuration
    }
}