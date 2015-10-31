//
//  PitchSpeller.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//


// add some generalizable functions (shared) for 
// -- PitchMonody, PitchDyad, PitchPolyphony, PitchVerticality Spellers

import Foundation

/**
Provides the best PitchSpellings for a given sequence. With 1/8th-tone resolution.
*/
public class PitchSpeller {
    
    
    public class func spellDyad(dyad: PitchDyad) {
        //let speller: PitchDyadSpeller = PitchDyadSpeller(dyad: dyad)
        // what does the PitchDyad ... DO and what does it HAVE
        
        //let ps = GetPitchSpellings.forPitch(Pitch(midi: MIDI(0.0)))
        
        //let stepPreserving: [PitchSpellingDyad] = speller.stepPreserving
    }
    
    public class func spellVerticality(verticality: [Pitch]) {
        
    }
}