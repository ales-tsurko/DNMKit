//
//  Duration.swift
//  denm_model
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Duration of time. Currently existing in a metrically-defined context. This will be extended for
clock-time-defined contexts, as well as "free" contexts, which defer concepts of spacing and
timing to the graphical context.
*/
public struct Duration: Comparable, CustomStringConvertible {
    
    // MARK: String Representation
    
    /// Printed description of Duration
    public var description: String { get { return getDescription() } }
    
    // MARK: Attributes
    
    /// Beats of Duration
    public var beats: Beats?
    
    /// Subdivision of Duration
    public var subdivision: Subdivision?
    
    /// The amount of beams in the Score Representation of a Duration
    public var subdivisionLevel: Int? // make getter
    
    /// Inherited scale of a duration, in the case of (embedded-)tuplets
    public var scale: Float = 1.0
    
    public var floatValue: Float? { get { return getFloatValue() } }
    
    public static func random() -> Duration {
        let beatsAmount: Int = randomInt(3, max: 8)
        let subdivisionLevel: Int = 2
        return Duration(
            beats: Beats(amount: beatsAmount),
            subdivision: Subdivision(level: subdivisionLevel)
        )
    }
    
    // MARK: Create a Duration
    
    /**
    Create a Duration with Beats object. Subdivision set automatically with a value of 1.
    
    - parameter beats: Beats object
    
    - returns: Initialzed Duration object
    */
    public init(beats: Int) {
        self.beats = Beats(amount: beats)
        self.subdivision = Subdivision(value: 1)
    }
    
    /**
    Create a Duration with amount of Beats and value of Subdivision
    
    - parameter beats:       amount of Beats
    - parameter subdivision: value of Subdivision
    
    - returns: Initialzed Duration object
    */
    public init(_ beats: Int, _ subdivision: Int) {
        self.beats = Beats(amount: beats)
        self.subdivision = Subdivision(value: subdivision)
        setSubdivisionLevel()
    }
    
    /**
    Create a Duration with Beats and Subdivision objects
    
    - parameter beats:       Beats object
    - parameter subdivision: Subdivision object
    
    - returns: Initialzed Duration object
    */
    public init(beats: Beats, subdivision: Subdivision) {
        self.beats = beats
        self.subdivision = subdivision
        setSubdivisionLevel()
    }
    
    /**
    Create a Duration with a Subdivision object. Duration set automatically with an amount of 1.
    
    - parameter subdivision: Subdivision object
    
    - returns: Initialzed Duration object
    */
    public init(subdivision: Subdivision) {
        self.beats = Beats(amount: 1)
        self.subdivision = subdivision
        setSubdivisionLevel()
    }
    
    public init(floatValue: Float) {
        var subdivisionValue: Int = 8
        var beatsAsFloat = floatValue
        while beatsAsFloat % 1 != 0 {
            beatsAsFloat *= 2
            subdivisionValue *= 2
        }
        self.beats = Beats(amount: Int(beatsAsFloat))
        self.subdivision = Subdivision(value: subdivisionValue)
    }
    
    // MARK: Set Attributes of a Duration
    
    /**
    Set Beats of Duration with Beats object
    
    - parameter beats: Beats object
    */
    public mutating func setBeats(beats: Beats) {
        self.beats = beats
        setSubdivisionLevel()
    }
    
    /**
    Set Subdivision of Duration with Subdivision object
    
    - parameter subdivision: Subdivision object
    */
    public mutating func setSubdivision(subdivision: Subdivision) {
        self.subdivision = subdivision
        setSubdivisionLevel()
    }
    
    /**
    Set amount of Beats of Duration
    
    - parameter beats: amount of Beats
    */
    public mutating func setBeats(beats: Int) {
        self.beats = Beats(amount: beats)
        setSubdivisionLevel()
    }
    
    /**
    Set value of Subdivision
    
    - parameter subdivisionValue: value of Subdivision
    */
    public mutating func setSubdivisionValue(subdivisionValue: Int) {
        self.subdivision!.setValue(subdivisionValue)
        setSubdivisionLevel()
    }
    
    /**
    Set inherited scale of Duration. This value is defaulted to 1.0. Changed only in the case of (embedded-)tuplets.
    
    - parameter inheritedScale:: inherited scale
    */
    public mutating func setScale(scale: Float) {
        self.scale = scale
    }
    
    public mutating func respellAccordingToBeats(amountBeats: Int) {
        respellAccordingToBeats(Beats(amount: amountBeats))
    }
    
    public mutating func respellAccordingToSubdivisionValue(subdivisionValue: Int) {
        respellAccordingToSubdivision(Subdivision(value: subdivisionValue))
    }
    
    // MARK: Respelling a Duration
    
    /**
    Respell Duration to match Beats
    
    - parameter newBeats: Beats object
    */
    public mutating func respellAccordingToBeats(newBeats: Beats) {
        // to-do: inconvenient numbers
        if newBeats > beats! {
            let ratio_float = Float(newBeats.amount) / Float(beats!.amount)
            let newSubdivision_float = Float(subdivision!.value) * ratio_float
            assert(newSubdivision_float % 1 == 0, "respelling must be by valid integer value")
            let ratio_int: Int = Int(ratio_float)
            subdivision! *= ratio_int
            beats = newBeats
        }
        else if newBeats < beats! {
            let ratio_float = Float(beats!.amount) / Float(newBeats.amount)
            let newSubdivision_float = Float(subdivision!.value) * ratio_float
            assert(newSubdivision_float % 1 == 0, "respelling must be by valid integer value")
            let ratio_int: Int = Int(ratio_float)
            subdivision! /= ratio_int
            beats = newBeats
        }
    }
    
    /**
    Respell Duration to match Subdivision
    
    - parameter newSubdivision: Subdivision object
    */
    public mutating func respellAccordingToSubdivision(newSubdivision: Subdivision) {
        if newSubdivision > subdivision! {
            let ratio_float = Float(newSubdivision.value) / Float(subdivision!.value)
            let newBeats_float = Float(beats!.amount) * ratio_float
            assert(newBeats_float % 1 == 0, "respelling must be by valid integer value")
            let ratio_int = Int(ratio_float)
            beats! *= ratio_int
            subdivision = newSubdivision
        }
        else {
            let ratio_float = Float(subdivision!.value) / Float(newSubdivision.value)
            let newBeats_float = Float(beats!.amount) / ratio_float
            assert(newBeats_float % 1 == 0, "respelling must be by valid integer value")
            let ratio_int = Int(ratio_float)
            beats! /= ratio_int
            subdivision = newSubdivision
        }
    }
    
    // make extension in global space
    /*
    public func getGraphicalWidth(beatWidth beatWidth: CGFloat) -> CGFloat {
        return CGFloat(floatValue! * scale) * 8.0 * beatWidth
    }
    */
    
    /*
    public func getDurationInMilliseconds(tempo tempo: Tempo) -> Float {
        return tempo.ms * floatValue! * 8.0 * scale
    }
    */
    
    /*
    public func getDurationInSamples(tempo tempo: Tempo, samplingRate: Float) -> Float {
        let samples = (getDurationInMilliseconds(tempo: tempo) / 1000) * samplingRate * scale
        return samples
    }
    */
    
    internal mutating func setSubdivisionLevel() {
        //assert(beats!.amount > 0, "can't have zero beats for now?")
        var a: Float
        var b: Float
        if beats!.amount == 0 { subdivisionLevel = 0 }
        else {
            if beats!.amount % 7 == 0 { a = 7; b = 4 }
            else if beats!.amount % 3 == 0 { a = 3; b = 2 }
            else { a = 2; b = 2 }
            subdivisionLevel = Int(
                Float(subdivision!.level) - (log(Float(beats!.amount)/a*b)/log(2))
            )
        }
    }
    
    private func getFloatValue() -> Float? {
        if subdivision == nil || beats == nil { return nil }
        return Float(beats!.amount) / Float(subdivision!.value) * scale
    }
    
    private func getDescription() -> String {
        var description: String = beats!.amount == 0
            ? "DurationZero"
            : "\(beats!.amount)/\(subdivision!.value)"
        if scale != 1.0 { description += " * \(scale)" }
        return description
    }
}

// MARK: Compare Durations

/**
Check if Duration is equal to Duration

- parameter left:  Duration
- parameter right: Duration

- returns: If Durations are equal
*/
public func == (left: Duration, right: Duration) -> Bool {
    if let left_floatValue = left.floatValue, right_floatValue = right.floatValue {
        return left_floatValue == right_floatValue
    }
    
    let leftFloatVal: Float = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let rightFloatVal: Float = Float(right.beats!.amount) / Float(right.subdivision!.value)
    return leftFloatVal == rightFloatVal
}

/**
Check if Duration is not equal to Duration

- parameter left:  Duration
- parameter right: Duration

- returns: If Duration is not equal to Duration
*/
public func != (left: Duration, right: Duration) -> Bool {
    if let left_floatValue = left.floatValue, right_floatValue = right.floatValue {
        return left_floatValue != right_floatValue
    }
    
    let leftFloatVal: Float = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let rightFloatVal: Float = Float(right.beats!.amount) / Float(right.subdivision!.value)
    return leftFloatVal != rightFloatVal
}

/**
Check if Duration is less than or equal to Duration

- parameter left:  Duration
- parameter right: Duration

- returns: If Duration is less than or equal to Duration
*/
public func <= (left: Duration, right: Duration) -> Bool {
    if let left_floatValue = left.floatValue, right_floatValue = right.floatValue {
        return left_floatValue <= right_floatValue
    }
    
    let leftFloatVal: Float = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let rightFloatVal: Float = Float(right.beats!.amount) / Float(right.subdivision!.value)
    return leftFloatVal <= rightFloatVal
}

/**
Check if Duration is greater than or equal to Duration

- parameter left:  Duration
- parameter right: Duration

- returns: If Duration is greater than or equal to Duration
*/
public func >= (left: Duration, right: Duration) -> Bool {
    if let left_floatValue = left.floatValue, right_floatValue = right.floatValue {
        return left_floatValue >= right_floatValue
    }
    // use float value directly
    let leftFloatVal: Float = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let rightFloatVal: Float = Float(right.beats!.amount) / Float(right.subdivision!.value)
    return leftFloatVal >= rightFloatVal
}

/**
Check if Duration is less than Duration

- parameter left:  Duration
- parameter right: Duration

- returns: If Duration is less than Duration
*/
public func < (left: Duration, right: Duration) -> Bool {
    if let left_floatValue = left.floatValue, right_floatValue = right.floatValue {
        return left_floatValue < right_floatValue
    }
    
    let leftFloatVal: Float = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let rightFloatVal: Float = Float(right.beats!.amount) / Float(right.subdivision!.value)
    return leftFloatVal < rightFloatVal
}

/**
Check if Duration is greater than Duration

- parameter left:  Duration
- parameter right: Duration

- returns: If Duration is greater than Duration
*/
public func > (left: Duration, right: Duration) -> Bool {
    if let left_floatValue = left.floatValue, right_floatValue = right.floatValue {
        return left_floatValue > right_floatValue
    }

    let leftFloatVal: Float = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let rightFloatVal: Float = Float(right.beats!.amount) / Float(right.subdivision!.value)
    return leftFloatVal > rightFloatVal
}

// MARK: Modify Durations

/**
Add Duration to Duration

- parameter left:  Duration
- parameter right: Duration

- returns: Sum of Durations
*/
public func + (left: Duration, right: Duration) -> Duration {
    var duration: Duration
    if left.subdivision! == right.subdivision! {
        duration = Duration(beats: left.beats! + right.beats!, subdivision: left.subdivision!)
    }
    else {
        if left.subdivision! > right.subdivision! {
            let ratio = left.subdivision!.value / right.subdivision!.value
            let newBeats = left.beats! + (right.beats! * ratio)
            duration = Duration(beats: newBeats, subdivision: left.subdivision!)
        }
        else {
            let ratio: Int = right.subdivision!.value / left.subdivision!.value
            let newBeats = right.beats! + (left.beats! * ratio)
            duration =  Duration(beats: newBeats, subdivision: right.subdivision!)
        }
    }
    // return if equivalent scale
    if left.scale == 1.0 && right.scale == 1.0 { return duration }
    
    // ENCAPSULATE: setScaleForHeterogeneousScaledDurations
    // otherwise, calculate a new scale for this summed duration
    let left_floatValue = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let right_floatValue = Float(right.beats!.amount) / Float(right.subdivision!.value)
    let total_floatValue = Float(duration.beats!.amount) / Float(duration.subdivision!.value)
    let left_proportion = left_floatValue / total_floatValue
    let right_proportion = right_floatValue / total_floatValue
    let left_scaledScale = left.scale * left_proportion
    let right_scaledScale = right.scale * right_proportion
    let newScale = left_scaledScale + right_scaledScale
    duration.setScale(newScale)
    return duration
}

/**
Add Duration to current Duration

- parameter left:  Duration
- parameter right: Duration to add
*/
public func += (inout left: Duration, right: Duration) {
    left = left + right
}

/**
Subtract Duration from Duration

- parameter left:  Duration
- parameter right: Duration

- returns: Difference of Durations
*/
public func - (left: Duration, right: Duration) -> Duration {
    
    assert(left.floatValue! - right.floatValue! >= 0, "can't have a negative duration")
    var duration: Duration
    //if left == right { return DurationZero }
    if left.subdivision! == right.subdivision! {
        duration = Duration(beats: left.beats! - right.beats!, subdivision: left.subdivision!)
    }
    else {
        if left.subdivision! > right.subdivision! {
            let ratio = left.subdivision!.value / right.subdivision!.value
            let newBeats = left.beats! - (right.beats! * ratio)
            duration = Duration(beats: newBeats, subdivision: left.subdivision!)
        }
        else {
            let ratio: Int = right.subdivision!.value / left.subdivision!.value
            let newBeats = (left.beats! * ratio) - right.beats!
            duration = Duration(beats: newBeats, subdivision: right.subdivision!)
        }
    }
    if left.scale == 1 && right.scale == 1 { return duration }

    // do the normal thing
    let floatValueDiff = left.floatValue! * 8 - right.floatValue! * 8
    let beatsDiff = Float(left.beats!.amount) - Float(right.beats!.amount)
    if beatsDiff > 0 {
        let scale = floatValueDiff / beatsDiff
        duration.setScale(scale)
        return duration
    }
    // adjust to make artificial, one beat duration with extremely weird scale
    else {
        duration = Duration(1, duration.subdivision!.value)
        duration.setScale(floatValueDiff) // this may be weird?
        return duration
    }
    /*
    print("-------------------------------------------------------------------------")
    // DOES NOT WORK FOR SUBTRACTION YET
    // ENCAPSULATE: setScaleForHeterogeneousScaledDurations
    // otherwise, calculate a new scale for this summed duration
    let left_floatValue = Float(left.beats!.amount) / Float(left.subdivision!.value)
    let right_floatValue = Float(right.beats!.amount) / Float(right.subdivision!.value)
    let total_floatValue = left_floatValue + right_floatValue
    
    print("left: \(left)")
    print("right: \(right)")
    
    print("diff dur: \(duration)")
    
    print("left_floatValue: \(left_floatValue)")
    print("right_floatValue: \(right_floatValue)")
    print("total_floatValue: \(total_floatValue)")
    
    let left_proportion = left_floatValue / total_floatValue
    let right_proportion = right_floatValue / total_floatValue
    
    print("left_proportion: \(left_proportion)")
    print("right_proporation: \(right_proportion)")
    
    let left_scaledScale = left.scale * left_proportion
    let right_scaledScale = right.scale * right_proportion
    
    print("left_scaledScale: \(left_scaledScale)")
    print("right_scaledScale: \(right_scaledScale)")
    
    // ? !? ?!?! ?!!? !?
    var newScale = 2 - (left_scaledScale + right_scaledScale)
    
    print("newScale: \(newScale)")
    if duration == DurationZero {
        duration = Duration(1, duration.subdivision!.value)
        newScale = right.scale
    }
    duration.setScale(newScale)
    return duration
    */
}

/**
Subtract Duration from current Duration

- parameter left:  current Duration
- parameter right: Duration to subtract
*/
public func -= (inout left: Duration, right: Duration) {
    assert(left > right, "can't have a negative duration")
    left = left - right
}

/**
Multiply Duration by amount

- parameter left:  Duration
- parameter right: Amount by which to multiply

- returns: Product of multiplication
*/
public func * (left: Duration, right: Int) -> Duration {
    // to-do: inconvenient numbers!
    return Duration(beats: left.beats! * right, subdivision: left.subdivision!)
}

/**
Multiply current Duration by amount

- parameter left:  Duration
- parameter right: Amount by which to Multiply
*/
public func *= (inout left: Duration, right: Int) {
    left = left * right
}

/**
Divide Duration by Duration

- parameter left:  Duration
- parameter right: Amount

- returns: Quotient of division
*/
public func / (left: Duration, right: Int) -> Duration {
    // to-do: inconvenient numbers!
    return Duration(beats: left.beats!, subdivision: left.subdivision! * right)
}

/**
Divide current Duration by amount

- parameter left:  Duration
- parameter right: Amount by which to divide
*/
public func /= (inout left: Duration, right: Int) {
    left = left / right
}

/// Duration with value of Zero
public var DurationZero: Duration = Duration(0,8)