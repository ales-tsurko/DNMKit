//
//  PitchVerticalitySpeller.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/// Spells PitchVerticalities
public class PitchVerticalitySpeller {
    
    public var verticality: PitchVerticality
    
    public var prevailingFine: Float?
    
    public var allPitchesHaveBeenSpelled: Bool { get { return getAllPitchesHaveBeenSpelled() } }
    
    public var allFineValuesMatch: Bool { get { return getAllFineValuesMatch() } }
    
    public init(verticality: PitchVerticality) {
        self.verticality = verticality
    }
    
    public func spell() {
        switch verticality.pitches.count {
        case 0:
            break
            //assertionFailure("no pitches: can't spell")
        case 1:
            let singlePitch = verticality[0]
            let leastSharp = getLeastSharp(PitchSpelling.pitchSpellingsForPitch(pitch: singlePitch))
            //let leastSharp = getLeastSharp(GetPitchSpellings.forPitch(singlePitch))
            singlePitch.setPitchSpelling(leastSharp)
        default:

            // make PitchDyadSpellers: encapsulate
            var amountSpellableObjectively: Int = 0
            var pitchDyadSpellers: [PitchDyadSpeller] = []
            for dyad in verticality.dyads! {
                print(dyad, terminator: "")
                let speller = PitchDyadSpeller(dyad: dyad)
                if speller.canBeSpelledObjectively { amountSpellableObjectively++ }
                pitchDyadSpellers.append(speller)
            }
            
            // ENCAPSULATE
            if amountSpellableObjectively == 0 {
                pitchDyadSpellers.first!.neitherSpelled()
            }
            else {
                // ENCAPSULATE
                for speller in pitchDyadSpellers {
                    speller.spellPitchesObjectivelyIfPossible()
                }
            }
            
            for speller in pitchDyadSpellers {
                
                // ENCAPSULATE
                if prevailingFine != nil { speller.spellWithDesiredFine(prevailingFine!) }
                else { speller.spell() }
                
                // ENCAPSULATE
                if self.prevailingFine == nil && speller.prevailingFine != nil {
                    self.prevailingFine = speller.prevailingFine
                }
                
                // ENCAPSULATE
                var amountUnspelled: Int = 0
                for pitch in verticality.pitches {
                    if !pitch.hasBeenSpelled { amountUnspelled++ }
                }
                if amountUnspelled == 0 { break }
            }
        }
    }
    
    private func getAllPitchesHaveBeenSpelled() -> Bool {
        for pitch in verticality.pitches {
            if !pitch.hasBeenSpelled { return false }
        }
        return true
    }
    
    private func getAllFineValuesMatch() -> Bool {
        assert(allPitchesHaveBeenSpelled, "all pitches must be spelled to do this")
        var fine: Float?
        for pitch in verticality.pitches {
            if fine == nil && pitch.spelling!.fine != 0 {
                fine = pitch.spelling!.fine
            }
            else {
                if pitch.spelling!.fine != 0 && pitch.spelling!.fine != fine { return false }
            }
        }
        return true
    }
    
    // copied from PitchDyadSpeller -- perhaps make these a subclass of another superclass?
    private func getLeastSharp(pitchSpellings: [PitchSpelling]) -> PitchSpelling {
        var leastSharp: PitchSpelling?
        for pitchSpelling in pitchSpellings {
            if leastSharp == nil { leastSharp = pitchSpelling }
            else if abs(pitchSpelling.sharpness) < abs(leastSharp!.sharpness) {
                leastSharp = pitchSpelling
            }
        }
        return leastSharp!
    }
}