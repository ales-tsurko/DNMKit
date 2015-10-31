//
//  Frequency.swift
//  denm_model
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Frequency of Pitch
*/
public struct Frequency: CustomStringConvertible {
    
    // MARK: String Representation
    
    /// Printed description of Frequency
    public var description: String { get { return "Freq: \(value)" } }
    
    // MARK: Attribute
    
    /// Value of Frequency as Float (middle-c = 261.6)
    public var value: Float
    
    // MARK: Create a Frequency
    
    /**
    Create a Frequency with value
    
    - parameter value: Value of Frequency as Float (middle-c = 261.6)
    
    - returns: Initialized Frequency object
    */
    public init(_ value: Float) {
        self.value = value
    }
    
    /**
    Create a Frequency with MIDI
    
    - parameter midi: MIDI representation of Pitch (middle-c = 60.0)
    
    - returns: Initialized Frequency object
    */
    public init(midi: MIDI) {
        self.value = 440 * pow(2.0, (midi.value - 69.0) / 12.0)
    }
    
    /**
    Quantizes Frequency to the desired resolution
    (chromatic = 1.0, 1/4-tone = 0.5, 1/8th-tone = 0.25)
    
    - parameter resolution: MIDI object
    */
    public mutating func quantizeToResolution(resolution: Float) {
        var midi = MIDI(frequency: self)
        midi.quantizeToResolution(resolution)
        self = Frequency(midi: midi)
    }
}


func ==(lhs: Frequency, rhs: Frequency) -> Bool {
    return lhs.value == rhs.value
}

func !=(lhs: Frequency, rhs: Frequency) -> Bool {
    return lhs.value != rhs.value
}

func <(lhs: Frequency, rhs: Frequency) -> Bool {
    return lhs.value < rhs.value
}

func >(lhs: Frequency, rhs: Frequency) -> Bool {
    return lhs.value > rhs.value
}

func <=(lhs: Frequency, rhs: Frequency) -> Bool {
    return lhs.value <= rhs.value
}

func >=(lhs: Frequency, rhs: Frequency) -> Bool {
    return lhs.value >= rhs.value
}

// MARK: Modify Frequency

func +(lhs: Frequency, rhs: Frequency) -> Frequency {
    return Frequency(lhs.value + rhs.value)
}

func -(lhs: Frequency, rhs: Frequency) -> Frequency {
    return Frequency(lhs.value - rhs.value)
}

func *(lhs: Frequency, rhs: Float) -> Frequency {
    return Frequency(lhs.value * rhs)
}

func %(lhs: Frequency, rhs: Float) -> Frequency {
    return Frequency(lhs.value % rhs)
}

