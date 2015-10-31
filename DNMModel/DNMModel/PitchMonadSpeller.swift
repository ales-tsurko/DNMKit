//
//  PitchMonadSpeller.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Spells a single Pitch

TO-DO: getBestPitchSpelling needs to do a sorting of PitchSpellings by (Absolute)Sharpness
*/
public class PitchMonadSpeller {
    
    /// Pitch to be spelled
    public var pitch: Pitch
    
    /**
    Create a PitchMonadSpeller with a Pitch
    
    - parameter pitch: Pitch to be spelled
    
    - returns: Initialized PitchMonadObject
    */
    public init(pitch: Pitch) {
        self.pitch = pitch
    }
    
    /**
    Get the best PitchSpelling for this single Pitch
    
    - returns: Best PitchSpelling for this single Pitch
    */
    public func getBestPitchSpelling() -> PitchSpelling {
        return PitchSpelling.pitchSpellingsForPitch(pitch: pitch).first!
        //return GetPitchSpellings.forPitch(pitch.pitchClass).first!
    }
}