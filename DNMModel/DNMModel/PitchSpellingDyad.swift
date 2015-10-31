//
//  PitchSpellingDyad.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Pair of PitchSpellings
*/
public struct PitchSpellingDyad: CustomStringConvertible, Equatable {
    
    // MARK: String representation
    
    /// Printed description of PitchSpellingDyad
    public var description: String { get { return getDescription() } }
    
    /// Lower of two PitchSpellings
    public var pitchSpelling0: PitchSpelling
    
    /// Higher of two PitchSpellings
    public var pitchSpelling1: PitchSpelling
    
    /// Staff representation steps between two PitchSpellings
    public var steps: Int { get { return getSteps() } }
    
    /// Mean distance of PitchSpellings from C on circle-of-fifths
    public var meanSharpness: Float { get { return getMeanSharpness() } }
    
    /**
    If PitchSpellingDyad preserves an appropriate amount of staff representation steps
    e.g. C natural and D flat are step preserving, while C natural and C sharp are not
    */
    public var isStepPreserving: Bool { get { return getIsStepPreserving() } }
    
    /// If the coarse values of each PitchSpelling are equivalent
    public var isCoarseMatching: Bool { get { return getIsCoarseMatching() } }
    
    /// If the coarse direction values of each PitchSpelling are equivalent
    public var isCoarseDirectionMatching: Bool { get { return getIsCoarseDirectionMatching() } }
    
    /// If the coarse resolution values of each PitchSpelling are equivalent
    public var isCoarseResolutionMatching: Bool { get { return getIsCoarseResolutionMatching() } }
    
    /// If the fine values of each PitchSpelling are equivalent
    public var isFineMatching: Bool { get { return getIsFineMatching() } }
    
    /**
    Create a PitchSpellingDyad with PitchSpellings
    
    - parameter pitchSpelling0: Lower of two PitchSpellings
    - parameter pitchSpelling1: Higher of two PitchSpellings
    
    - returns: Initialized PitchSpellingDyad object
    */
    public init(ps0 pitchSpelling0: PitchSpelling, ps1 pitchSpelling1: PitchSpelling) {
        self.pitchSpelling0 = pitchSpelling0
        self.pitchSpelling1 = pitchSpelling1
    }
    
    private func getIsStepPreserving() -> Bool {
        let intervalRangeBySteps: Dictionary<Int, [Float]> = [
            0: [0.00, 00.00],
            1: [0.25, 02.75],
            2: [2.25, 04.50],
            3: [4.25, 06.50],
            4: [6.00, 07.50],
            5: [7.50, 09.50],
            6: [9.50, 11.75],
            7: [0.00, 00.00]
        ]
        let intervalRange = intervalRangeBySteps[steps]!
        let interval = (
            pitchSpelling1.pitch.pitchClass.midi.value -
                pitchSpelling0.pitch.pitchClass.midi.value
        )
        return interval >= intervalRange.first! && interval <= intervalRange.last!
    }
    
    private func getIsCoarseMatching() -> Bool {
        return pitchSpelling0.coarse == pitchSpelling1.coarse
    }
    
    private func getIsCoarseDirectionMatching() -> Bool {
        return (
            pitchSpelling0.coarse == 0 ||
                pitchSpelling1.coarse == 0 ||
                pitchSpelling0.coarseDirection == pitchSpelling1.coarseDirection
        )
    }
    
    private func getIsCoarseResolutionMatching() -> Bool {
        return pitchSpelling0.coarseResolution == pitchSpelling1.coarseResolution
    }
    
    private func getIsFineMatching() -> Bool {
        return pitchSpelling0.fine == pitchSpelling1.fine
    }
    
    private func getMeanSharpness() -> Float {
        return Float(pitchSpelling0.sharpness + pitchSpelling1.sharpness) / 2.0
    }
    
    private func getSteps() -> Int {
        let letterNames: [PitchLetterName] = [.C, .D, .E, .F, .G, .A, .B]
        let index0: Int = letterNames.indexOf(pitchSpelling0.letterName)!
        let index1: Int = letterNames.indexOf(pitchSpelling1.letterName)!
        let steps = Int.modulo(index1 - index0, letterNames.count)
        return steps
    }
    
    private func getDescription() -> String {
        return "\(pitchSpelling0) || \(pitchSpelling1)"
    }
}

public func ==(lhs: PitchSpellingDyad, rhs: PitchSpellingDyad) -> Bool {
    return (
        lhs.pitchSpelling0 == rhs.pitchSpelling0 && lhs.pitchSpelling1 == rhs.pitchSpelling1
    )
}