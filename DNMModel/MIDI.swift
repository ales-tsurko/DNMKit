//
//  MIDI.swift
//  denm_model
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
MIDI (Musical Instrument Digital Interface) representation of Pitch
*/
public struct MIDI: Comparable, CustomStringConvertible {
    
    // MARK: String Representation
    
    /// Printed description of MIDI
    public var description: String { get { return "MIDI: \(value)" } }
    
    // MARK: Attribute
    
    /// Value of MIDI as Float (middle-c (C4) = 60.0, C5 = 72.0, C3 = 48.0)
    public var value: Float
    
    /**
    Create a MIDI with value
    
    - parameter value: Value of MIDI as Float (middle-c (C4) = 60.0, C5 = 72.0, C3 = 48.0)
    
    - returns: MIDI
    */
    public init(_ value: Float) {
        self.value = value
    }
    
    /**
     Create a MIDI with value and resolution (0.25 = 1/8th tone, 0.5 = 1/4-tone, etc)
     
     - parameter value:      Value of MIDI as Float (middle-c (C4) = 60.0, C5 = 72.0, C3 = 48.0)
     - parameter resolution: Resolution of MIDI (0.25 = 1/8th tone, 0.5 = 1/4-tone, 1 = chromatic)
     
     - returns: MIDI
     */
    public init(value: Float, resolution: Float? = nil) {
        if let resolution = resolution {
            self.value = round(value / resolution) * resolution
        } else {
            self.value = value
        }
    }
    
    /**
    Create a MIDI with Frequency
    
    - parameter frequency: Frequency representation of Pitch (middle-c = 261.6)
    
    - returns: MIDI
    */
    public init(frequency: Frequency) {
        self.value = 69.0 + (12.0 * (log(frequency.value / 440.0)/log(2.0)))
    }
    
    /**
    Quantizes MIDI to the desired resolution
    (chromatic = 1.0, 1/4-tone = 0.5, 1/8th-tone = 0.25)
    
    - parameter resolution: MIDI object
    */
    public mutating func quantizeToResolution(resolution: Float) {
        self.value = round(value / resolution) * resolution
    }
}

// MARK: Compare MIDI

public func ==(lhs: MIDI, rhs: MIDI) -> Bool {
    return lhs.value == rhs.value
}

public func !=(lhs: MIDI, rhs: MIDI) -> Bool {
    return lhs.value != rhs.value
}

public func <(lhs: MIDI, rhs: MIDI) -> Bool {
    return lhs.value < rhs.value
}

public func >(lhs: MIDI, rhs: MIDI) -> Bool {
    return lhs.value > rhs.value
}

public func <=(lhs: MIDI, rhs: MIDI) -> Bool {
    return lhs.value <= rhs.value
}

public func >=(lhs: MIDI, rhs: MIDI) -> Bool {
    return lhs.value >= rhs.value
}

// MARK: Modify MIDI

public func +(lhs: MIDI, rhs: MIDI) -> MIDI {
    return MIDI(lhs.value + rhs.value)
}

public func -(lhs: MIDI, rhs: MIDI) -> MIDI {
    return MIDI(lhs.value - rhs.value)
}

public func %(lhs: MIDI, rhs: Float) -> MIDI {
    return MIDI(Float.modulo(lhs.value, rhs))
}