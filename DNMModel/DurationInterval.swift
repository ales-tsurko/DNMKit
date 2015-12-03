//
//  DurationInterval.swift
//  DNMModel
//
//  Created by James Bean on 11/27/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct DurationInterval: Equatable, CustomStringConvertible {
    
    public var description: String { get { return getDescription() } }
    
    /// Duration starting this DurationInterval
    public var startDuration: Duration = DurationZero
    
    /// Duration stopping this DurationInterval
    public var stopDuration: Duration = DurationZero
    
    /// Span of this DurationInterval
    public var duration: Duration = DurationZero
    
    // add tests, doc comments
    public static func unionWithDurationIntervals(durationIntervals: [DurationInterval]) ->
        DurationInterval
    {
        let start = durationIntervals.sort {
            $0.startDuration < $1.startDuration
        }.first!.startDuration
        
        let stop = durationIntervals.sort {
            $0.stopDuration > $1.stopDuration
        }.first!.stopDuration
        
        return DurationInterval(startDuration: start, stopDuration: stop)
    }
    
    /**
    Create a DurationInterval

    - returns: DurationIntervalZero
    */
    public init() { }
    
    /**
    Create a DurationInterval with two Durations, which do not have to be in order.

    - parameter duration:      One Duration
    - parameter otherDuration: Another Duration

    - returns: DurationInterval
    */
    public init(oneDuration: Duration,
        andAnotherDuration otherDuration: Duration
    )
    {
        let durations: [Duration] = [oneDuration, otherDuration].sort(<)
        self.startDuration = durations.first!
        self.stopDuration = durations.last!
        self.duration = stopDuration - startDuration
    }
    
    /**
    Create a DurationInterval with two Durations (the first being before the second)

    - parameter startDuration: Duration to start the DurationInterval
    - parameter stopDuration:  Duration to stop the DurationInterval

    - returns: DurationInterval
    */
    public init(startDuration: Duration, stopDuration: Duration) {
        self.startDuration = startDuration
        self.stopDuration = stopDuration
        self.duration = stopDuration - startDuration
    }
    
    /**
    Create a DurationInterval with the total Duration and a start Duration

    - parameter duration:      Total Duration of DurationInterval
    - parameter startDuration: Duration to start the DurationInterval

    - returns: DurationInterval
    */
    public init(duration: Duration, startDuration: Duration) {
        self.duration = duration
        self.startDuration = startDuration
        self.stopDuration = duration + startDuration
    }
    
    /**
    If this DurationInterval contains Duration. Inclusive at start, exclusive at stop.

    - parameter duration: Duration to be check if contained within DurationInterval

    - returns: If this DurationInterval contains the Duration
    */
    public func containsDuration(duration: Duration) -> Bool {
        return duration >= startDuration && duration < stopDuration
    }
    
    // TODO DOC COMMENT
    public func makeUnionWithDurationInterval(other: DurationInterval) -> DurationInterval {
        let start = [startDuration, other.startDuration].sort(<).first!
        let stop = [stopDuration, other.stopDuration].sort(>).first!
        return DurationInterval(startDuration: start, stopDuration: stop)
    }
    
    /**
    Get the relationship between the DurationInterval and another.

    - parameter other: Another DurationInterval

    - returns: DurationInterval
    */
    public func relationshipToDurationInterval(other: DurationInterval)
        -> IntervalRelationship
    {
        switch (other.startDuration, other.stopDuration) {
        case (startDuration, stopDuration):
            return .Equal
        case _ where stopDuration < other.startDuration:
            return .TakesPlaceBefore
        case _ where startDuration > other.stopDuration:
            return .TakesPlaceAfter
        case _ where stopDuration == other.startDuration || startDuration == other.stopDuration:
            return .Meets
        case _ where startDuration < other.startDuration && other.containsDuration(stopDuration):
            return .Overlaps
        case _ where stopDuration > other.stopDuration && other.containsDuration(startDuration):
            return .Overlaps
        case _ where startDuration > other.startDuration && stopDuration < other.stopDuration:
            return .During
        case _ where startDuration == other.startDuration && stopDuration < other.stopDuration:
            return .Starts
        case _ where startDuration > other.startDuration && stopDuration == other.stopDuration:
            return .Finishes
        default: return .TakesPlaceBefore
        }
    }

    private func getDescription() -> String {
        return "(\(startDuration) -> (\(stopDuration): \(duration)))"
    }
}

public func ==(lhs: DurationInterval, rhs: DurationInterval) -> Bool {
    return lhs.relationshipToDurationInterval(rhs) == .Equal
}

/// Identity DurationInterval
public let DurationIntervalZero = DurationInterval()

