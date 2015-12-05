//
//  DurationSpanning.swift
//  DNMModel
//
//  Created by James Bean on 11/27/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public protocol DurationSpanning {
    
    var durationInterval: DurationInterval { get }
    
    static func rangeFromArray<T: DurationSpanning>(array: [T],
        withinDurationInterval: DurationInterval
    ) throws -> [T]
}

extension DurationSpanning {

    
    public static func rangeFromArray<T: DurationSpanning>(array: [T],
        withinDurationInterval durationInterval: DurationInterval
    ) throws -> [T]
    {
        let validRelationships: IntervalRelationship = [.Starts, .Finishes, .During, .Equal]
        let filtered = array.filter {
            validRelationships.contains(
                $0.durationInterval.relationshipToDurationInterval(durationInterval)
            )
        }
        if filtered.count == 0 { throw DurationIntervalRangeError.Error }
        return filtered
    }
}

// are there other errortypes here?
public enum DurationIntervalRangeError: ErrorType {
    case Error
}