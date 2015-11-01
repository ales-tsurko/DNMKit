//
//  RehearsalMarking_model.swift
//  denm_model
//
//  Created by James Bean on 10/18/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Structure indicating a establishment of a rehearsal section
*/
public struct RehearsalMarking {
    
    /// The index of this RehearsalMarking
    public var index: Int = 0
    
    /// The representation type of this RehearsalMarking ("Alphabetical or Numerical")
    public var type: String = "Alphabetical" // or "Numerical"
    
    /// The Duration that this RehearsalMarking is offset from the beginning of the piece
    public var offsetDuration: Duration = DurationZero
    
    /**
    Create a RehearsalMarking with the index, 
    representation type,
    and the offsetDuration.
    
    - parameter index:          Index of this RehearsalMarking
    - parameter type:           Representation type ("Alphabetical or Numerical")
    - parameter offsetDuration: Duration offset from the beginning of the piece
    
    - returns: RehearsalMarking
    */
    public init(index: Int, type: String, offsetDuration: Duration) {
        self.index = index
        self.type = type
        self.offsetDuration = offsetDuration
    }
}