//
//  Beats.swift
//  denm_model
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Amount of Beats in a metrically-defined Duration
*/
public struct Beats {
    
    // MARK: String Representation
    
    /// Printed description of Beats
    public var description: String { get { return "\(amount)" } }
    
    // MARK: Attributes
    
    /// Amount of Beats
    public var amount: Int
    
    // MARK: Create a Beats
    
    /**
    Create a Beats with amount
    
    - parameter amount: amount of Beats
    
    - returns: Initialzed Beats object
    */
    public init(amount: Int) {
        self.amount = amount
    }
    
    // MARK: Set attributes of a Beats
    
    /**
    Set amount of Beats
    
    - parameter amount: amount of Beats
    */
    public mutating func setAmount(amount: Int) {
        self.amount = amount
    }
}

// MARK: Compare Beats

/**
Check if Beats are equal

- parameter left:  Beats
- parameter right: Beats

- returns: If Beas objects are equal
*/
public func == (left: Beats, right: Beats) -> Bool {
    return left.amount == right.amount
}

/**
Check if Beats are not equal

- parameter left:  Beats
- parameter right: Beats

- returns: If Beats objects are not equal
*/
public func != (left: Beats, right: Beats) -> Bool {
    return left.amount != right.amount
}

/**
Check if Beats is less than or equal to Beats

- parameter left:  Beats
- parameter right: Beats

- returns: If Beats (left) is less than or equal to Beats (right)
*/
public func <= (left: Beats, right: Beats) -> Bool {
    return left.amount <= right.amount
}

/**
Check if Beats is greater than or equal to Beats

- parameter left:  Beats
- parameter right: Beats

- returns: If Beats (left) is greater than or equal to Beats (right)
*/
public func >= (left: Beats, right: Beats) -> Bool {
    return left.amount >= right.amount
}

/**
Check if Beats is less than Beats

- parameter left:  Beats
- parameter right: Beats

- returns: If Beats (left) less than Beats (right)
*/
public func < (left: Beats, right: Beats) -> Bool {
    return left.amount < right.amount
}

/**
Check if Beats is greater than Beats

- parameter left:  Beats
- parameter right: Beats

- returns: If Beats (left) greater than Beats (right)
*/
public func > (left: Beats, right: Beats) -> Bool {
    return left.amount > right.amount
}

// MARK: Modify Beats

/**
Add Beats to Beats

- parameter left:  Beats
- parameter right: Beats

- returns: Added Beats
*/
public func + (left: Beats, right: Beats) -> Beats {
    return Beats(amount: left.amount + right.amount)
}

/**
Add Beats to current Beats

- parameter left:  current Beats
- parameter right: Beats to add
*/
public func += (inout left: Beats, right: Beats) {
    left = left + right
}

/**
Subtract Beats from Beats

- parameter left:  Beats
- parameter right: Beats

- returns: Beats
*/
public func - (left: Beats, right: Beats) -> Beats {
    return Beats(amount: left.amount - right.amount)
}

/**
Subtract Beats from current Beats

- parameter left:  current Beats
- parameter right: Beats to subtract
*/
public func -= (inout left: Beats, right: Beats) {
    left = left - right
}

/**
Multiply Beats by amount

- parameter left:  Beats
- parameter right: Amount by which to multiply

- returns: Beats
*/
public func * (left: Beats, right: Int) -> Beats {
    return Beats(amount: left.amount * right)
}

/**
Multiply current Beats by amount

- parameter left:  current Beats
- parameter right: Amount by which to multipy
*/
public func *= (inout left: Beats, right: Int) {
    left = left * right
}

/**
Divide Beats by amount

- parameter left:  Beats
- parameter right: Amount by which to divide

- returns: Beats
*/
public func / (left: Beats, right: Int) -> Beats {
    return Beats(amount: left.amount / right)
}

/**
Divide current Beats by amount

- parameter left:  current Beats
- parameter right: Amount by which to divide
*/
public func /= (inout left: Beats, right: Int) {
    left = left / right
}
