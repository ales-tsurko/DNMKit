//
//  RehearsalMarking_model.swift
//  denm_model
//
//  Created by James Bean on 10/18/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct RehearsalMarking {
    
    public var index: Int = 0
    public var type: String = "Alphabetical" // or "Numerical"
    public var offsetDuration: Duration = DurationZero
    
    public init(index: Int, type: String, offsetDuration: Duration) {
        self.index = index
        self.type = type
        self.offsetDuration = offsetDuration
    }
}