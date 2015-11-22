//
//  PitchDyadSpellerTests.swift
//  denm
//
//  Created by James Bean on 3/23/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest

/*
class PitchDyadSpellerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(65))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
    }
    
    func testOneSpelled() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(67.25))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
    }
    
    func testStepPreserving() {
        let p0 = Pitch(midi: MIDI(63.0))
        let p1 = Pitch(midi: MIDI(68.25))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        print("STEP PRESERVING: \(speller.stepPreserving)")
    }
    
    func testCoarseMatching() {
        let nat0 = Pitch(midi: MIDI(60))
        let nat1 = Pitch(midi: MIDI(65))
        let natDyad = PitchDyad(pitch0: nat0, pitch1: nat1)
        let natSpeller = PitchDyadSpeller(dyad: natDyad)
        print("NATURAL COARSE MATCHING: \(natSpeller.coarseMatching)")
        
        let sharpFlat0 = Pitch(midi: MIDI(61))
        let sharpFlat1 = Pitch(midi: MIDI(63))
        let sharpFlatDyad = PitchDyad(pitch0: sharpFlat0, pitch1: sharpFlat1)
        let sharpFlatSpeller = PitchDyadSpeller(dyad: sharpFlatDyad)
        print("SHARP / FLAT COARSE MATCHING: \(sharpFlatSpeller.coarseMatching)")
    }
    
    func testCoarseDirectionMatching() {
        let p0 = Pitch(midi: MIDI(61.0))
        let p1 = Pitch(midi: MIDI(63.0))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        print("COARSE DIRECTION MATCHING: \(speller.coarseDirectionMatching)")
    }
    
    func testCoarseResolutionMatching() {
        let p0 = Pitch(midi: MIDI(69.25))
        let p1 = Pitch(midi: MIDI(71.75))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        print("COARSE RESOLUTION MATCHING: \(speller.coarseResolutionMatching)")
    }
    
    func testFineMatching() {
        let p0 = Pitch(midi: MIDI(69.25))
        let p1 = Pitch(midi: MIDI(71.75))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        print("FINE MATCHING: \(speller.fineMatching)")
    }
    
    func testAllPreferenceArrays() {
        let p0 = Pitch(midi: MIDI(63.5))
        let p1 = Pitch(midi: MIDI(69.75))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        
        print("pitch0: \(p0) || pitch1: \(p1) =============================================")
        print("step preserving: \(speller.stepPreserving)")
        print("coarse matching: \(speller.coarseMatching)")
        print("coarse resolution matching: \(speller.coarseResolutionMatching)")
        print("coarse direction matching: \(speller.coarseDirectionMatching)")
        print("fine matching: \(speller.fineMatching)")
    }
    
    func testOneSpelledNatural() {
        let pitchPairs: [[Float]] = [[60,63],[60,66],[60,68],[60,71],[60,72],[60,73]]
        for pair in pitchPairs {
            let p0 = Pitch(midi: MIDI(pair.first!))
            let p1 = Pitch(midi: MIDI(pair.last!))
            let dyad = PitchDyad(pitch0: p0, pitch1: p1)
            let speller = PitchDyadSpeller(dyad: dyad)
            print("dyad: \(dyad)")
        }
    }
    
    func testOneSpelledQuarterTone() {
        let pitchPairs: [[Float]] = [[59.5,63],[62.5,66],[65.5,68],[65.5,69],[65.5,66]]
        for pair in pitchPairs {
            let p0 = Pitch(midi: MIDI(pair.first!))
            let p1 = Pitch(midi: MIDI(pair.last!))
            let dyad = PitchDyad(pitch0: p0, pitch1: p1)
            let speller = PitchDyadSpeller(dyad: dyad)
            print("dyad: \(dyad)")
        }
    }
    
    func testOneSpelledNaturalEighthTone() {
        let p0 = Pitch(midi: MIDI(60.25))
        p0.setPitchSpelling(GetPitchSpellings.forPitch(p0).first!)
        print("PITCH 0: \(p0)")
        
        let p1 = Pitch(midi: MIDI(63))
        let p2 = Pitch(midi: MIDI(63.25))
        let p3 = Pitch(midi: MIDI(64.5))
        
        let dyad0 = PitchDyad(pitch0: p0, pitch1: p1)
        let speller0 = PitchDyadSpeller(dyad: dyad0)
        print("dyad: \(dyad0)")
        
        let dyad1 = PitchDyad(pitch0: p0, pitch1: p2)
        let speller1 = PitchDyadSpeller(dyad: dyad1)
        print("dyad: \(dyad1)")
        
        let dyad2 = PitchDyad(pitch0: p0, pitch1: p3)
        let speller2 = PitchDyadSpeller(dyad: dyad2)
        print("dyad: \(dyad2)")
    }
    
    func testOneSpelledQuarterEighthTone() {
        let p0 = Pitch(midi: MIDI(60.25))
        p0.setPitchSpelling(GetPitchSpellings.forPitch(p0).second!)
        print("PITCH 0: \(p0)")
        
        let p1 = Pitch(midi: MIDI(63))
        let p2 = Pitch(midi: MIDI(63.25))
        let p3 = Pitch(midi: MIDI(64.5))
        
        let dyad0 = PitchDyad(pitch0: p0, pitch1: p1)
        let speller0 = PitchDyadSpeller(dyad: dyad0)
        print("dyad: \(dyad0)")
        
        let dyad1 = PitchDyad(pitch0: p0, pitch1: p2)
        let speller1 = PitchDyadSpeller(dyad: dyad1)
        print("dyad: \(dyad1)")
        
        let dyad2 = PitchDyad(pitch0: p0, pitch1: p3)
        let speller2 = PitchDyadSpeller(dyad: dyad2)
        print("dyad: \(dyad2)")
    }
    
    func testCNaturalENaturalDown() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(63.75))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        print("dyad: \(dyad)")
    }
    
    func testNeitherSpelled() {
        var pitch0MIDI: Float = 60.0
        while pitch0MIDI < 72 {
            print("\(pitch0MIDI) ==========================================================")
            var pitch1MIDI: Float = pitch0MIDI + 0.25
            while pitch1MIDI < pitch0MIDI + 12.0 {
                let pitch0 = Pitch(midi: MIDI(pitch0MIDI))
                let pitch1 = Pitch(midi: MIDI(pitch1MIDI))
                let dyad = PitchDyad(pitch0: pitch0, pitch1: pitch1)
                let speller = PitchDyadSpeller(dyad: dyad)
                print(dyad)
                if speller.bothPitchesHaveBeenSpelled { print("success") }
                else { print("fail") }
                pitch1MIDI += 0.25
            }
            pitch0MIDI += 0.25
        }
    }
    
    func testSpellWithDesiredFine_0() {
        let p0 = Pitch(midi: MIDI(60.25))
        let p1 = Pitch(midi: MIDI(65))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        assert(p0.spelling == nil, "spelling not nil initially")
        assert(p1.spelling == nil, "spelling not nil initially")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(0.25)
        assert(p0.spelling!.fine == 0.25, "fine match not enforced")
        print(p0)
        print(p1)
        p0.spelling = nil
        p1.spelling = nil
        assert(p0.spelling == nil, "spelling not nil after")
        assert(p1.spelling == nil, "spelling not nil after")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(-0.25)
        assert(p0.spelling!.fine == -0.25, "fine match not enforced")
        print(p0)
        print(p1)
    }
    
    func testSpellWithDesiredFine_1() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(65.25))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        assert(p0.spelling == nil, "spelling not nil initially")
        assert(p1.spelling == nil, "spelling not nil initially")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(0.25)
        assert(p1.spelling!.fine == 0.25, "fine match not enforced")
        print(p0)
        print(p1)
        p0.spelling = nil
        p1.spelling = nil
        assert(p0.spelling == nil, "spelling not nil after")
        assert(p1.spelling == nil, "spelling not nil after")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(-0.25)
        assert(p1.spelling!.fine == -0.25, "fine match not enforced")
        print(p0)
        print(p1)
    }
    
    func testSpellWithDesiredFine_2() {
        let p0 = Pitch(midi: MIDI(61))
        let p1 = Pitch(midi: MIDI(65.25))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        assert(p0.spelling == nil, "spelling not nil initially")
        assert(p1.spelling == nil, "spelling not nil initially")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(0.25)
        //assert(p1.spelling!.fine == 0.25, "fine match not enforced")
        print(p0)
        print(p1)
        p0.spelling = nil
        p1.spelling = nil
        assert(p0.spelling == nil, "spelling not nil after")
        assert(p1.spelling == nil, "spelling not nil after")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(-0.25)
        assert(p1.spelling!.fine == -0.25, "fine match not enforced")
        print(p0)
        print(p1)
    }
 
    func testSpellWithDesiredFine_3() {
        let p0 = Pitch(midi: MIDI(58))
        let p1 = Pitch(midi: MIDI(60.25))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        assert(p0.spelling == nil, "spelling not nil initially")
        assert(p1.spelling == nil, "spelling not nil initially")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(0.25)
        //assert(p1.spelling!.fine == 0.25, "fine match not enforced")
        print(p0)
        print(p1)
        p0.spelling = nil
        p1.spelling = nil
        assert(p0.spelling == nil, "spelling not nil after")
        assert(p1.spelling == nil, "spelling not nil after")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(-0.25)
        assert(p1.spelling!.fine == -0.25, "fine match not enforced")
        print(p0)
        print(p1)
    }
    
    func testSpellWithDesiredFine_4() {
        let p0 = Pitch(midi: MIDI(58.25))
        let p1 = Pitch(midi: MIDI(60.25))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        assert(p0.spelling == nil, "spelling not nil initially")
        assert(p1.spelling == nil, "spelling not nil initially")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(0.25)
        //assert(p1.spelling!.fine == 0.25, "fine match not enforced")
        print(p0)
        print(p1)
        p0.spelling = nil
        p1.spelling = nil
        assert(p0.spelling == nil, "spelling not nil after")
        assert(p1.spelling == nil, "spelling not nil after")
        speller.spellPitchesObjectivelyIfPossible()
        speller.spellWithDesiredFine(-0.25)
        assert(p1.spelling!.fine == -0.25, "fine match not enforced")
        print(p0)
        print(p1)
    }
    
    // test enforced fine match with non-objectively spelled pitches
    
    // test enforced fine match with mutlitple pitches with res == 0.25
    
    /*
    func testAllPitchSpellings() {
        var pitch0MIDI: Float = 48.0
        while pitch0MIDI < 75 {
            println("PITCH 0: \(pitch0MIDI) ------------------------------------------------------------------------")
            var pitch1MIDI: Float = 48.0
            while pitch1MIDI < 84 {
                let pitch0 = Pitch(midi: MIDI(pitch0MIDI))
                for pitchSpelling in GetPitchSpellings.forPitch(pitch0) {
                    println(pitchSpelling)
                    pitch0.setPitchSpelling(pitchSpelling)
                    let pitch1 = Pitch(midi: MIDI(pitch1MIDI))
                    let dyad = PitchDyad(pitch0: pitch0, pitch1: pitch1)
                    let speller = PitchDyadSpeller(dyad: dyad)
                    println("dyad: \(dyad)")
                    if speller.bothPitchesHaveBeenSpelled {
                        println("success")
                    }
                    else {
                        println("fail")
                    }
                }
                pitch1MIDI += 0.25
            }
            pitch0MIDI += 0.25
        }
    }
    */
}

*/