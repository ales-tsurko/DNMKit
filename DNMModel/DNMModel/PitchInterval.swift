//
//  PitchInterval.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
The interval between a Dyad of Pitches
*/
public class PitchInterval: Pitch {
    
    /**
    All intervals sorted by their harmonic (and notational) complexity.
    At this point, minor 2nd and major 7th are prioritized, helping out with step preserving.
    */
    public static var intervalsSortedByComplexity: [Float] = [
        0, 1, 11, 2, 10, 7, 5, 3, 9,
        0.25, 11.75, 7.25, 6.75, 5.25, 4.75, 4.25, 3.75, 3.25, 2.75, 1.25, 0.75,
        11.25, 10.75, 2.25, 1.75, 10.25, 9.75, 9.25, 8.75,
        4, 6, 8,
        6.25, 5.75, 8.25, 7.75,
        0.5, 11.5, 7.5, 6.5, 5.5, 4.5, 3.5, 1.5, 10.5, 2.5, 9.5, 8.5
    ]
    
    /// Complexity of PitchInterval (P8, P5, P4 are least complex, 1/4-tone intervals are most)
    public var complexity: Int? { get { return getComplexity() } }
    
    private func getComplexity() -> Int? {
        var complexity: Int = abs(
            PitchInterval.intervalsSortedByComplexity.indexOf(pitchClass.midi.value)!
        )
        complexity += 5 * abs(octave + 1)
        return complexity
    }
}