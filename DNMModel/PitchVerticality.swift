//
//  PitchVerticality.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class PitchVerticality: CustomStringConvertible {
    
    public var description: String { get { return "\(pitches)" } }
    public var pitches: [Pitch]
    public var dyads: [PitchDyad]? { get { return getDyads() } }
    
    public var allPitchesHaveBeenSpelled: Bool { get { return getAllPitchesHaveBeenSpelled() } }
    
    public init() {
        pitches = []
    }
    
    public init(pitches: [Pitch]) {
        self.pitches = pitches
        sortPitches()
    }
    
    public init(verticality0: PitchVerticality, verticality1: PitchVerticality) {
        self.pitches = verticality0.pitches + verticality1.pitches
        sortPitches()
    }
    
    subscript(index: Int) -> Pitch {
        return pitches[index]
    }
    
    public func addPitch(pitch: Pitch) -> PitchVerticality {
        pitches.append(pitch)
        sortPitches()
        return self
    }
    
    public func addPitches(pitches: [Pitch]) -> PitchVerticality {
        let pitches = pitches
        self.pitches.appendContentsOf(pitches)
        sortPitches()
        return self
    }
    
    public func removeDuplicates() {
        let uniquePitches: [Pitch] = pitches.unique()
        self.pitches = uniquePitches
    }
    
    public func clearPitchSpellings() {
        for pitch in pitches { pitch.clearPitchSpelling() }
    }
    
    private func getDyads() -> [PitchDyad]? {
        sortPitches()
        if pitches.count < 2 { return nil }
        var dyads: [PitchDyad] = []
        var index0: Int = 0
        while index0 < pitches.count {
            var index1: Int = index0 + 1
            while index1 < pitches.count {
                let dyad = PitchDyad(pitch0: pitches[index0], pitch1: pitches[index1])
                dyads.append(dyad)
                index1++
            }
            index0++
        }
        sortDyadsByComplexity(&dyads)
        return dyads
    }
    
    private func sortPitches() {
        pitches.sortInPlace { $0.midi.value < $1.midi.value }
    }
    
    private func sortDyadsByComplexity(inout dyads: [PitchDyad]) {
        dyads.sortInPlace { $0.interval.complexity! < $1.interval.complexity! }
    }
    
    private func getAllPitchesHaveBeenSpelled() -> Bool {
        for pitch in pitches { if pitch.hasBeenSpelled == false { return false } }
        return true
    }
}