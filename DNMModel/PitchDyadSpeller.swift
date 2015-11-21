//
//  PitchDyadSpeller.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Spells PitchDyads
*/
public class PitchDyadSpeller {
    
    // MARK: String Representation
    
    /// Printed description of PitchSpellerDyad
    public var description: String = "PitchSpellerDyad: ___"
    
    // MARK: Attributes
    
    /// PitchDyad spelled by PitchSpellerDyad
    public var dyad: PitchDyad
    
    public var prevailingFine: Float?
    
    /// All possible PitchSpelling combinations for PitchDyad
    public var allPSDyads: [PitchSpellingDyad] { get { return getAllPSDyads() } }
    
    public var stepPreserving: [PitchSpellingDyad] {
        get { return getStepPreserving() }
    }
    
    public var fineMatching: [PitchSpellingDyad] {
        get { return getFineMatching() }
    }
    
    public var coarseMatching: [PitchSpellingDyad] {
        get { return getCoarseMatching() }
    }
    
    public var desiredFine: Float?
    
    public var desiredCoarseDirection: Float?
    
    public var desiredCoarseResolution: Float?
    
    public var coarseDirectionMatching: [PitchSpellingDyad] {
        get { return getCoarseDirectionMatching() }
    }
    public var coarseResolutionMatching: [PitchSpellingDyad] {
        get { return getCoarseResolutionMatching() }
    }
    
    public var bothPitchesHaveBeenSpelled: Bool {
        get { return getBothPitchesHaveBeenSpelled() } }
    
    public var onePitchHasBeenSpelled: Bool {
        get { return getOnePitchHasBeenSpelled() }
    }
    
    public var neitherPitchHasBeenSpelled: Bool {
        get { return getNeitherPitchHasBeenSpelled() }
    }
    
    public var canBeSpelledObjectively: Bool {
        get { return getCanBeSpelledObjectively() }
    }
    
    public init(dyad: PitchDyad) {
        self.dyad = dyad
    }
    
    public func spellWithDesiredFine(fine: Float) {
        self.desiredFine = fine
        spell()
    }
    
    public func spellWithDesiredCoarseDirection(coarseDirection: Float) {
        self.desiredCoarseDirection = coarseDirection
        spell()
    }
    
    public func spellWithDesiredCoarseResolution(coarseResolution: Float) {
        self.desiredCoarseResolution = coarseResolution
        spell()
    }
    
    public func spell() {
        //spellPitchesObjectivelyIfPossible()
        if bothPitchesHaveBeenSpelled {
            //print("both have been spelled")
            /* pass */
        }
        else if neitherPitchHasBeenSpelled {
            //print("neither has been spelled")
            neitherSpelled()
        }
        else if onePitchHasBeenSpelled {
            //print("one has been spelled")
            oneSpelled()
        }
    }
    
    public func oneSpelled() {
        assert(onePitchHasBeenSpelled, "one pitch must be spelled")
        let unspelled: Pitch = dyad.pitch0.hasBeenSpelled ? dyad.pitch1 : dyad.pitch0
        let spelled: Pitch = dyad.pitch0.hasBeenSpelled ? dyad.pitch0 : dyad.pitch1
        switch spelled.resolution {
        case 0.50: oneSpelledQuarterTone(spelled: spelled, unspelled: unspelled)
        case 0.25: oneSpelledEighthTone(spelled: spelled, unspelled: unspelled)
        default: oneSpelledHalfTone(spelled: spelled, unspelled: unspelled)
        }
    }
    
    public func oneSpelledHalfTone(spelled spelled: Pitch, unspelled: Pitch) {
        // filter step preserving to include more-global fine-match: encapsulate
        if desiredFine != nil && unspelled.resolution == 0.25 {
            //sp = filterPSDyadsToIncludeDesiredFineMatching(sp)
            let all = filterPSDyadsToIncludeCurrentlySpelled(allPSDyads)
            let dfm = filterPSDyadsToIncludeDesiredFineMatching(all)
            switch dfm.count {
            case 0:
                break
            case 1:
                let spelling = getSpellingForUnspelledFromPSDyad(dfm.first!)
                spellPitch(unspelled, withSpelling: spelling)
                
            default:
                let sp = intersection(dfm, array1: stepPreserving)
                switch sp.count {
                case 0:
                    break
                case 1:
                    let spelling = getSpellingForUnspelledFromPSDyad(sp.first!)
                    spellPitch(unspelled, withSpelling: spelling)
                    break
                default:
                    break
                }
            }
        }
        else {
            let sp = filterPSDyadsToIncludeCurrentlySpelled(stepPreserving)
            switch sp.count {
            case 0:
                //print("none sp: big trouble")
                let crm = filterPSDyadsToIncludeCurrentlySpelled(coarseResolutionMatching)
                switch crm.count {
                case 0:
                    //print("none crm: really big trouble")
                    break
                case 1:
                    //print("one crm")
                    let spelling = getSpellingForUnspelledFromPSDyad(crm.first!)
                    spellPitch(unspelled, withSpelling: spelling)
                default:
                    //print("more than one crm")
                    let leastMeanSharp = getLeastMeanSharp(crm)
                    let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                    spellPitch(unspelled, withSpelling: spelling)
                }
            case 1:
                //print("one sp: spell")
                let spelling = getSpellingForUnspelledFromPSDyad(sp.first!)
                spellPitch(unspelled, withSpelling: spelling)
            default:
                //print("more than one sp")
                let sp_crm = intersection(sp, array1: coarseResolutionMatching)
                switch sp_crm.count {
                case 1:
                    //print("one sp_crm")
                    let spelling = getSpellingForUnspelledFromPSDyad(sp_crm.first!)
                    spellPitch(unspelled, withSpelling: spelling)
                    break
                default:
                    //print("more than one sp_crm")
                    let leastMeanSharp = getLeastMeanSharp(sp)
                    let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                    spellPitch(unspelled, withSpelling: spelling)
                }
            }
        }
    }
    
    public func oneSpelledQuarterTone(spelled spelled: Pitch, unspelled: Pitch) {
        
        
        
        // IF MORE-GLOBAL FINE MATCH REQUIRED
        
        
        
        // filter step preserving to include more-global fine-match: encapsulate
        if desiredFine != nil && unspelled.resolution == 0.25 {
            //sp = filterPSDyadsToIncludeDesiredFineMatching(sp)
            let all = filterPSDyadsToIncludeCurrentlySpelled(allPSDyads)
            let dfm = filterPSDyadsToIncludeDesiredFineMatching(all)
            switch dfm.count {
            case 0:
                break
            case 1:
                let spelling = getSpellingForUnspelledFromPSDyad(dfm.first!)
                spellPitch(unspelled, withSpelling: spelling)
            default:
                let sp = intersection(dfm, array1: stepPreserving)
                switch sp.count {
                case 0:
                    break
                case 1:
                    let spelling = getSpellingForUnspelledFromPSDyad(sp.first!)
                    spellPitch(unspelled, withSpelling: spelling)
                    break
                default:
                    break
                }
            }
        }
            
            // IF NO MORE-GLOBAL FINE MATCH REQUIRED
            
        else {
            let sp = filterPSDyadsToIncludeCurrentlySpelled(stepPreserving)
            switch sp.count {
            case 0:
                //print("none step preserving: big trouble")
                //let spelling = getLeastSharp(GetPitchSpellings.forPitch(unspelled))
                let spelling = getLeastSharp(PitchSpelling.pitchSpellingsForPitch(pitch: unspelled))
                spellPitch(unspelled, withSpelling: spelling)
            case 1:
                //print("one step preserving: spell")
                let spelling = getSpellingForUnspelledFromPSDyad(sp.first!)
                spellPitch(unspelled, withSpelling: spelling)
            default:
                //print("more than one step preserving")
                let sp_cdm = intersection(sp, array1: coarseDirectionMatching)
                switch sp_cdm.count {
                case 0:
                    //print("none sp_cdm")
                    let leastMeanSharp = getLeastMeanSharp(sp)
                    let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                    spellPitch(unspelled, withSpelling: spelling)
                case 1:
                    //print("one sp_cdm: spell")
                    let spelling = getSpellingForUnspelledFromPSDyad(sp_cdm.first!)
                    spellPitch(unspelled, withSpelling: spelling)
                default:
                    //print("more than one sp_cdm")
                    let sp_cdm_crm = intersection(sp_cdm, array1: coarseResolutionMatching)
                    switch sp_cdm_crm.count {
                    case 0:
                        //print("none sp_cdm_crm")
                        break
                    case 1:
                        //print("one sp_cdm_crm")
                        let spelling = getSpellingForUnspelledFromPSDyad(sp_cdm_crm.first!)
                        spellPitch(unspelled, withSpelling: spelling)
                    default:
                        //print("more than one sp_cdm_crm")
                        break
                    }
                }
            }
        }
        
    }
    
    public func oneSpelledEighthTone(spelled spelled: Pitch, unspelled: Pitch) {
        prevailingFine = spelled.spelling!.fine
        
        switch unspelled.resolution {
            
        // UNSPELLED HAS 1/8th-tone RESOLUTION
        case 0.25:
            let fm = filterPSDyadsToIncludeCurrentlySpelled(fineMatching)
            switch fm.count {
            case 0:
                //print("none fine matching: big trouble)")
                break
            case 1:
                //print("one fine matching: spell")
                let spelling = getSpellingForUnspelledFromPSDyad(fm.first!)
                spellPitch(unspelled, withSpelling: spelling)
            default:
                //print("more than one fine matching")
                let fm_sp = intersection(fm, array1: stepPreserving)
                switch fm_sp.count {
                case 0:
                    //print("none fm_sp: get least mean sharp of fm")
                    let leastMeanSharp = getLeastMeanSharp(fm)
                    let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                    spellPitch(unspelled, withSpelling: spelling)
                case 1:
                    //print("one fm_sp: spell")
                    let spelling = getSpellingForUnspelledFromPSDyad(fm_sp.first!)
                    spellPitch(unspelled, withSpelling: spelling)
                default:
                    //print("more than one fm_sp")
                    let fm_sp_cdm = intersection(fm_sp, array1: coarseDirectionMatching)
                    switch fm_sp_cdm.count {
                    case 0:
                        //print("none fm_sp_cdm")
                        let leastMeanSharp = getLeastMeanSharp(fm_sp)
                        let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                        spellPitch(unspelled, withSpelling: spelling)
                    case 1:
                        //print("one fm_sp_cdm: spell")
                        let spelling = getSpellingForUnspelledFromPSDyad(fm_sp_cdm.first!)
                        spellPitch(unspelled, withSpelling: spelling)
                    default:
                        //print("more than one fm_sp_cdm")
                        let leastMeanSharp = getLeastMeanSharp(fm_sp_cdm)
                        let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                        spellPitch(unspelled, withSpelling: spelling)
                    }
                }
            }
            
        // UNSPELLED HAS A 1/4 or 1/2-tone RESOLUTION
        default:
            //print("unspelled does not have 1/8th-tone resolution")
            let sp = filterPSDyadsToIncludeCurrentlySpelled(stepPreserving)
            switch sp.count {
            case 0:
                //print("none sp")
                let cdm = filterPSDyadsToIncludeCurrentlySpelled(coarseDirectionMatching)
                let spelling = getSpellingForUnspelledFromPSDyad(cdm.first!)
                spellPitch(unspelled, withSpelling: spelling)
            case 1:
                //print("one sp")
                let spelling = getSpellingForUnspelledFromPSDyad(sp.first!)
                spellPitch(unspelled, withSpelling: spelling)
            default:
                //print("more than one sp")
                let sp_cdm = intersection(sp, array1: coarseDirectionMatching)
                switch sp_cdm.count {
                case 0:
                    //print("none sp_cdm")
                    let leastMeanSharp = getLeastMeanSharp(sp)
                    let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                    spellPitch(unspelled, withSpelling: spelling)
                case 1:
                    //print("one sp_cdm")
                    let spelling = getSpellingForUnspelledFromPSDyad(sp_cdm.first!)
                    spellPitch(unspelled, withSpelling: spelling)
                default:
                    //print("more than one sp_cdm")
                    let sp_cdm_crm = intersection(sp_cdm, array1: coarseResolutionMatching)
                    switch sp_cdm_crm.count {
                    case 0:
                        //print("none sp_cdm_crm")
                        let leastMeanSharp = getLeastMeanSharp(sp_cdm)
                        let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                        spellPitch(unspelled, withSpelling: spelling)
                    case 1:
                        //print("one sp_cdm_crm: spell")
                        let spelling = getSpellingForUnspelledFromPSDyad(sp_cdm_crm.first!)
                        spellPitch(unspelled, withSpelling: spelling)
                    default:
                        //print("more than one sp_cdm_crm")
                        let leastMeanSharp = getLeastMeanSharp(sp_cdm_crm)
                        let spelling = getSpellingForUnspelledFromPSDyad(leastMeanSharp)
                        spellPitch(unspelled, withSpelling: spelling)
                    }
                }
            }
        }
    }
    
    public func neitherSpelled() {
        
        // ENCAPSULATE
        
        if dyad.pitch0.resolution == 1 && dyad.pitch1.resolution == 1 {
            var spellings: [PitchSpelling] = []
            
            for spelling in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
                spellings.append(spelling)
            }
            for spelling in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                spellings.append(spelling)
            }
            
            // DEPRECATED
            //for ps in GetPitchSpellings.forPitch(dyad.pitch0) { spellings.append(ps) }
            //for ps in GetPitchSpellings.forPitch(dyad.pitch1) { spellings.append(ps) }
            
            let leastSharp = getLeastSharp(spellings)
            spellPitch(leastSharp.pitch, withSpelling: leastSharp)
            oneSpelled()
        }
            
            // ENCAPSULATE
        else if desiredFine != nil {
            for pitch in [dyad.pitch0, dyad.pitch1] {
                //print(pitch)
                for spelling in PitchSpelling.pitchSpellingsForPitch(pitch: pitch) {
                    if spelling.fine == desiredFine! {
                        //print("FINE MATCH")
                        spellPitch(pitch, withSpelling: spelling)
                        if onePitchHasBeenSpelled { oneSpelled() }
                        break
                    }
                }
                
                // DEPRECATED
                /*
                for spelling in GetPitchSpellings.forPitch(pitch) {
                    print(spelling)
                    if spelling.fine == desiredFine! {
                        //print("FINE MATCH")
                        spellPitch(pitch, withSpelling: spelling)
                        if onePitchHasBeenSpelled { oneSpelled() }
                        break
                    }
                }
                */
            }
        }
            
            
        // ENCAPSULATE
            
        else {
            var containsNaturalSpelling: Bool = false
            for pitch in [dyad.pitch0, dyad.pitch1] {
                //for spelling in GetPitchSpellings.forPitch(pitch) {
                for spelling in PitchSpelling.pitchSpellingsForPitch(pitch: pitch) {
                    if spelling.coarse == 0.0 {
                        spellPitch(pitch, withSpelling: spelling)
                        containsNaturalSpelling = true
                        break
                    }
                }
                break
            }
            
            // ENCAPSULATE
            
            if containsNaturalSpelling { if onePitchHasBeenSpelled { oneSpelled() } }
            else {
                var containsFlatOrSharpSpelling: Bool = false
                for pitch in [dyad.pitch0, dyad.pitch1] {
                    
                    //for spelling in GetPitchSpellings.forPitch(pitch) {
                    
                    for spelling in PitchSpelling.pitchSpellingsForPitch(pitch: pitch) {
                        if spelling.coarseResolution == 1.0 {
                            spellPitch(pitch, withSpelling: spelling)
                            containsFlatOrSharpSpelling = true
                            break
                        }
                    }
                    break
                }
                
                // ENCAPSULATE
                
                if containsFlatOrSharpSpelling {
                    //print("contains flat or sharp spelling")
                    
                    if onePitchHasBeenSpelled { oneSpelled() }
                    
                    else {
                        
                        //print("still no pitches spelled")
                        
                        // get spelling with least sharp
                        var dyads: [PitchSpellingDyad] = []
                        
                        //for ps0 in GetPitchSpellings.forPitch(dyad.pitch0) {
                        
                        for ps0 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
                            
                            //for ps1 in GetPitchSpellings.forPitch(dyad.pitch1) {
                            
                            for ps1 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                            
                                let dyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
                                dyads.append(dyad)
                            }
                        }
                        let leastMeanSharp = getLeastMeanSharp(dyads)
                        spellPitch(dyad.pitch0, withSpelling: leastMeanSharp.pitchSpelling0)
                        spellPitch(dyad.pitch1, withSpelling: leastMeanSharp.pitchSpelling1)
                    }
                }
                else {
                    // this only happens if both pitches are 1/4 tone pitches: 4.5 / 11.5
                    
                    //for spelling in GetPitchSpellings.forPitch(dyad.pitch0) {
                    
                    for spelling in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
                        if spelling.coarse == 0.5 {
                            spellPitch(dyad.pitch0, withSpelling: spelling)
                            break
                        }
                    }
                    if onePitchHasBeenSpelled { oneSpelled() }
                }
            }
        }
    }
    
    private func filterPSDyadsToIncludeCurrentlySpelled(psDyads: [PitchSpellingDyad])
        -> [PitchSpellingDyad]
    {
        assert(onePitchHasBeenSpelled, "one pitch must be spelled")
        if dyad.pitch0.hasBeenSpelled {
            return psDyads.filter { $0.pitchSpelling0 == self.dyad.pitch0.spelling! }
        }
        else {
            return psDyads.filter { $0.pitchSpelling1 == self.dyad.pitch1.spelling! }
        }
    }
    
    private func filterPSDyadsToIncludeDesiredFineMatching(psDyads: [PitchSpellingDyad])
        -> [PitchSpellingDyad]
    {
        assert(desiredFine != nil, "desiredFine must be set for this to work")
        var psDyads = psDyads
        if dyad.pitch0.resolution == 0.25 {
            psDyads =  psDyads.filter { $0.pitchSpelling0.fine == self.desiredFine! }
        }
        else { psDyads = psDyads.filter { $0.pitchSpelling1.fine == self.desiredFine! } }
        return psDyads
    }
    
    public func spellPitchesObjectivelyIfPossible() {
        for pitch in [dyad.pitch0, dyad.pitch1] {
            if PitchSpelling.pitchSpellingsForPitch(pitch: pitch).count == 1 {
                let spelling = PitchSpelling.pitchSpellingsForPitch(pitch: pitch).first!
                pitch.setPitchSpelling(spelling)
            }
        }
    }
    
    private func getCanBeSpelledObjectively() -> Bool {
        let pitch0_count = PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0).count
        let pitch1_count = PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1).count
        return pitch0_count == 1 && pitch1_count == 1
    }
    
    private func getBothPitchesHaveBeenSpelled() -> Bool {
        return dyad.pitch0.hasBeenSpelled && dyad.pitch1.hasBeenSpelled
    }
    
    private func getOnePitchHasBeenSpelled() -> Bool {
        return (
            dyad.pitch0.hasBeenSpelled && !dyad.pitch1.hasBeenSpelled ||
                dyad.pitch1.hasBeenSpelled && !dyad.pitch0.hasBeenSpelled
        )
    }
    
    private func getNeitherPitchHasBeenSpelled() -> Bool {
        return !dyad.pitch0.hasBeenSpelled && !dyad.pitch1.hasBeenSpelled
    }
    
    public func getCoarseMatching() -> [PitchSpellingDyad] {
        var coarseMatching: [PitchSpellingDyad] = []
        
        /*
        for ps0 in GetPitchSpellings.forPitch(dyad.pitch0) {
            for ps1 in GetPitchSpellings.forPitch(dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        */

        for ps0 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
            for ps1 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
                if psDyad.isCoarseMatching { coarseMatching.append(psDyad) }
            }
        }
        return coarseMatching
    }
    
    public func getCoarseResolutionMatching() -> [PitchSpellingDyad] {
        var coarseResolutionMatching: [PitchSpellingDyad] = []
        
        
        /*
        for ps0 in GetPitchSpellings.forPitch(dyad.pitch0) {
            for ps1 in GetPitchSpellings.forPitch(dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
          */
                
                
        for ps0 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
            for ps1 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
                if psDyad.isCoarseResolutionMatching { coarseResolutionMatching.append(psDyad) }
            }
        }
        return coarseResolutionMatching
    }
    
    public func getCoarseDirectionMatching() -> [PitchSpellingDyad] {
        var coarseDirectionMatching: [PitchSpellingDyad] = []
        
        for ps0 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
            for ps1 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        
        /*
        for ps0 in GetPitchSpellings.forPitch(dyad.pitch0) {
            for ps1 in GetPitchSpellings.forPitch(dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)

        */
                if psDyad.isCoarseDirectionMatching { coarseDirectionMatching.append(psDyad) }
            }
        }
        return coarseDirectionMatching
    }
    
    public func getFineMatching() -> [PitchSpellingDyad] {
        var fineMatching: [PitchSpellingDyad] = []

        for ps0 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
            for ps1 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        
                
        /*
        for ps0 in GetPitchSpellings.forPitch(dyad.pitch0) {
            for ps1 in GetPitchSpellings.forPitch(dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        */


                if psDyad.isFineMatching { fineMatching.append(psDyad) }
            }
        }
        return fineMatching
    }
    
    public func getStepPreserving() -> [PitchSpellingDyad] {
        var stepPreserving: [PitchSpellingDyad] = []
        
        for ps0 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
            for ps1 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        
        /*
        for ps0 in GetPitchSpellings.forPitch(dyad.pitch0) {
            for ps1 in GetPitchSpellings.forPitch(dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        */
                if psDyad.isStepPreserving { stepPreserving.append(psDyad) }
            }
        }
        return stepPreserving
    }
    
    private func getAllPSDyads() -> [PitchSpellingDyad] {
        var allPSDyads: [PitchSpellingDyad] = []
        
        
        for ps0 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch0) {
            for ps1 in PitchSpelling.pitchSpellingsForPitch(pitch: dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        
        /*
        for ps0 in GetPitchSpellings.forPitch(dyad.pitch0) {
            for ps1 in GetPitchSpellings.forPitch(dyad.pitch1) {
                let psDyad = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        */
                
                allPSDyads.append(psDyad)
            }
        }
        return allPSDyads
    }
    
    private func getSpellingForUnspelledFromPSDyad(psDyad: PitchSpellingDyad) -> PitchSpelling {
        assert(onePitchHasBeenSpelled, "one pitch must be spelled")
        return dyad.pitch0.hasBeenSpelled ? psDyad.pitchSpelling1 : psDyad.pitchSpelling0
    }
    
    private func getLeastMeanSharp(psDyads: [PitchSpellingDyad]) -> PitchSpellingDyad {
        var leastMeanSharp: PitchSpellingDyad?
        for psDyad in psDyads {
            if leastMeanSharp == nil { leastMeanSharp = psDyad }
            else if abs(psDyad.meanSharpness) < abs(leastMeanSharp!.meanSharpness) {
                leastMeanSharp = psDyad
            }
        }
        return leastMeanSharp!
    }
    
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
    
    private func spellPitch(unspelled: Pitch, withSpelling spelling: PitchSpelling) {
        unspelled.setPitchSpelling(spelling)
        if spelling.fine != 0 { prevailingFine = spelling.fine }
    }
}
