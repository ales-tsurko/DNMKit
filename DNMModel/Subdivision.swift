//
//  Subdivision.swift
//  denm_model
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Subdivision of a Duration
*/
public struct Subdivision {
    
    // MARK: String Representation
    
    /// Printed description of a Subdivision
    public var description: String { get { return "\(value)" } }
    
    // MARK: Attributes
    
    /// Value of a subdivision (8, 16, 32, 64, 128, etc)
    public var value: Int = 0
    
    /// Level of subdivision (amount of beams in Score Representation)
    public var level: Int = 0
    
    // MARK: Create a Subdivision
    
    /**
    Create a Subdivision with value
    
    - parameter value: value of Subdivision
    
    - returns: initialized Subdivision object
    */
    public init(value: Int) {
        self.value = value
        setLevelWithValue()
    }
    
    /**
    Create a Subdivision with level
    
    - parameter level: level of Subdivision
    
    - returns: Initialzed Subdivision Object
    */
    public init(level: Int) {
        self.level = level
        setValueWithLevel()
    }
    
    // MARK: Set attributes of a Subdivision
    
    /**
    Set value of Subdivision
    
    - parameter value: value of Subdivision
    */
    public mutating func setValue(value: Int) {
        self.value = value
        setLevelWithValue()
    }
    
    /**
    Set level of Subdivision
    
    - parameter level: level of Subdivision
    */
    public mutating func setLevel(level: Int) {
        self.level = level
        setValueWithLevel()
    }
    
    private mutating func setLevelWithValue() {
        self.level = Int(log(Double(value))/log(2)) - 2
    }
    
    private mutating func setValueWithLevel() {
        self.value = Int(pow(2.0, (Double(level) + 2.0)))
    }
}

// MARK: Compare Subdivisions

/**
Check if Subdivision is equal to Subdivision

- parameter left:  Subdivision
- parameter right: Subdivision

- returns: If Subdivision is equal to Subdivision
*/
public func == (left: Subdivision, right: Subdivision) -> Bool {
    return left.value == right.value
}

/**
Check if Subdivision is not equal to Subdivision

- parameter left:  Subdivision
- parameter right: Subdivision

- returns: If Subdivision is not equal to Subdivision
*/
public func != (left: Subdivision, right: Subdivision) -> Bool {
    return left.value != right.value
}

/**
Check is Subdivision is less than or equal to Subdivision

- parameter left:  Subdivision
- parameter right: Subdivision

- returns: If subdivision is less than or equal to Subdivision
*/
public func <= (left: Subdivision, right: Subdivision) -> Bool {
    return left.value <= right.value
}

/**
Check if Subdivision is greater than or equal to Subdivision

- parameter left:  Subdivision
- parameter right: Subdivision

- returns: If Subdivision is greater than or equal to Subdvision
*/
public func >= (left: Subdivision, right: Subdivision) -> Bool {
    return left.value >= right.value
}

/**
Check if Subdivision is less than Subdvision

- parameter left:  Subdivision
- parameter right: Subdivision

- returns: If Subdivision is less than Subdivision
*/
public func < (left: Subdivision, right: Subdivision) -> Bool {
    return left.value < right.value
}

/**
Check if Subdivision is greater than Subdivision

- parameter left:  Subdivision
- parameter right: Subdivision

- returns: If Subdivision is greater than Subdivision
*/
public func > (left: Subdivision, right: Subdivision) -> Bool {
    return left.value > right.value
}

// MARK: Modify Subdivisions

/**
Multiply Subdivision by value

- parameter left:  Subdivision
- parameter right: Value by which to multiply

- returns: Product of multiplication
*/
public func * (left: Subdivision, right: Int) -> Subdivision {
    return Subdivision(value: left.value * right)
}

/**
Multiply current Subdivision by value

- parameter left:  Subdivision
- parameter right: Value by which to multiply
*/
public func *= (inout left: Subdivision, right: Int) {
    left = left * right
}

/**
Divide Subdivision by value

- parameter left:  Subdivision
- parameter right: Value by which to divide

- returns: Quotient of division
*/
public func / (left: Subdivision, right: Int) -> Subdivision {
    return Subdivision(value: left.value / right)
}

/**
Divide current Subdivision by value

- parameter left:  Subdivision
- parameter right: Value by which to divide
*/
public func /= (inout left: Subdivision, right: Int) {
    left = left / right
}