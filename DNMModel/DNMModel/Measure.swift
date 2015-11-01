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
public struct Measure {
  
    // TODO: DurationSpan
    
    /// Duration of Measure
    public var duration: Duration = DurationZero
    
    /// Offset Duration of Measure (in current implementation: from the beginning of the piece)
    public var offsetDuration: Duration = DurationZero
    
    /** 
    When graphically represented, 
    should the Duration of this Measure be shown with a TimeSignature
    */
    public var hasTimeSignature: Bool = true
    
    // TODO: Test this
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
    
    /**
    Create a Measure with an Duration offset from the beginning of the piece
    
    - parameter offsetDuration: Duration offset from the beginning of the piece
    
    - returns: Measure
    */
    public init(offsetDuration: Duration) {
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