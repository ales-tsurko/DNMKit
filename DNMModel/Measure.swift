//
//  Measure.swift
//  DNMModel
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Musical Measure
*/
public struct Measure: DurationSpanning, Equatable {
  
    // TODO: DurationSpan
    
    // 1-based count of numbers (index + 1)
    public var number: Int = 0
    
    // DEPRECATE THESE?
    /// Duration of Measure
    public var duration: Duration = DurationZero
    
    /// Offset Duration of Measure (in current implementation: from the beginning of the piece)
    public var offsetDuration: Duration = DurationZero
    
    // CLEAN UP
    public var durationInterval: DurationInterval {
        return DurationInterval(duration: duration, startDuration: offsetDuration)
    }
    
    // deprecate
    // make this the default object that is interfaced with
    public var durationSpan: DurationSpan {
        return DurationSpan(duration: duration, startDuration: offsetDuration)
    }
    
    /** 
    When graphically represented, 
    should the Duration of this Measure be shown with a TimeSignature
    */
    public var hasTimeSignature: Bool = true
    
    /*
    public static func rangeFromArray<T : DurationSpanning>(array: [T],
        withinDurationInterval durationInterval: DurationInterval)
    throws -> [T]
    {
        let validRelationships: IntervalRelationship = [.Starts, .Finishes, .During]
        let filtered = array.filter {
            validRelationships.contains(
                $0.durationInterval.relationshipToDurationInterval(durationInterval)
            )
        }
        if filtered.count == 0 { throw DurationIntervalRangeError.Error }
        return filtered
    }
    */
    
    // throws instead of nil
    // Measure should have DurationInterval set properly by the time this should come up
    public static func _rangeFromMeasures(measures: [Measure],
        withinDurationInterval durationInterval: DurationInterval
    ) -> [Measure]?
    {

        let validRelationships: IntervalRelationship = [.Starts, .Finishes, .During]
        let filtered = measures.filter {
            return validRelationships.contains(
                $0.durationInterval.relationshipToDurationInterval(durationInterval)
            )
        }
        print("filtered: \(filtered)")
        if filtered.count == 0 { return nil }
        return filtered
    }
    
    // TODO: Test this
    public static func rangeFromMeasures(
        measures: [Measure],
        startingAtIndex index: Int,
        constrainedByDuration maximumDuration: Duration
    ) -> [Measure]?
    {
        var measureRange: [Measure] = []
        var m: Int = index
        var accumDur: Duration = DurationZero
        while m < measures.count && accumDur < maximumDuration {
            if accumDur + measures[m].duration <= maximumDuration {
                measureRange.append(measures[m])
                accumDur += measures[m].duration
                m++
            }
            else { break }
        }
        if measureRange.count == 0 { return nil }
        return measureRange
    }
    
    /**
    Create a Measure with an Duration offset from the beginning of the piece
    
    - parameter offsetDuration: Duration offset from the beginning of the piece
    
    - returns: Measure
    */
    public init(duration: Duration = DurationZero, offsetDuration: Duration = DurationZero) {
        self.duration = duration
        self.offsetDuration = offsetDuration
    }
    
    /**
    Set if when graphically represented,
    should the Duration of this Measure be shown with a TimeSignature
    
    - parameter hasTimeSignature: If a TimeSignature should be shown in the score.
    */
    public mutating func setHasTimeSignature(hasTimeSignature: Bool) {
        self.hasTimeSignature = hasTimeSignature
    }
}

public func ==(lhs: Measure, rhs: Measure) -> Bool {
    return lhs.durationSpan == rhs.durationSpan
}