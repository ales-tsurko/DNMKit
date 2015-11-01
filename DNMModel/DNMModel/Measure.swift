//
//  Measure_model.swift
//  denm_model
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//


import Foundation

public struct Measure {
    
    public var duration: Duration = DurationZero
    public var offsetDuration: Duration = DurationZero
    
    public var hasTimeSignature: Bool = true
    
    public static func rangeFromMeasures(
        measures: [Measure],
        startingAtIndex index: Int,
        constrainedByMaximumTotalDuration maximumDuration: Duration
    ) -> [Measure]
    {
        var measureRange: [Measure] = []
        var m: Int = index
        //var accumLeft: CGFloat = 0
        var accumDur: Duration = DurationZero
        while m < measures.count && accumDur < maximumDuration {
            if accumDur + measures[m].duration <= maximumDuration {
                measureRange.append(measures[m])
                accumDur += measures[m].duration
                //accumLeft += measures[m].frame.width
                m++
            }
            else { break }
        }
        return measureRange
    }
    
    public init(offsetDuration: Duration) {
        self.offsetDuration = offsetDuration
    }
    
    public mutating func setHasTimeSignature(hasTimeSignature: Bool) {
        self.hasTimeSignature = hasTimeSignature
    }
    
    
    
}