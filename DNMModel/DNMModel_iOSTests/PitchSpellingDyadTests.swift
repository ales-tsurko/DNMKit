//
//  PitchSpellingDyadTests.swift
//  denm
//
//  Created by James Bean on 3/25/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class PitchSpellingDyadTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // TODO: make assertions
    func testGetSteps() {
        let p0 = Pitch(midi: MIDI(63.25))
        let p1 = Pitch(midi: MIDI(67.5))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        for spellingDyad in speller.coarseResolutionMatching {
            print("spellingDyad: \(spellingDyad)")
            print("steps: \(spellingDyad.steps)")
        }
    }
    
    func testIsStepPreserving() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(61))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        let speller = PitchDyadSpeller(dyad: dyad)
        for spellingDyad in speller.coarseResolutionMatching {
            print(spellingDyad)
            print("isStepPreserving: \(spellingDyad.isStepPreserving)")
            
        }
        
        let p3 = Pitch(midi: MIDI(60))
        let p4 = Pitch(midi: MIDI(63))
        let dyad1 = PitchDyad(pitch0: p3, pitch1: p4)
        let speller1 = PitchDyadSpeller(dyad: dyad1)
        for spellingDyad in speller1.coarseResolutionMatching {
            print(spellingDyad)
            print("isStepPreserving: \(spellingDyad.isStepPreserving)")
        }
        
        let p5 = Pitch(midi: MIDI(60))
        let p6 = Pitch(midi: MIDI(66))
        let dyad2 = PitchDyad(pitch0: p5, pitch1: p6)
        let speller2 = PitchDyadSpeller(dyad: dyad2)
        for spellingDyad in speller2.coarseResolutionMatching {
            print(spellingDyad)
            print("isStepPreserving: \(spellingDyad.isStepPreserving)")
        }
        
        let p7 = Pitch(midi: MIDI(60))
        let p8 = Pitch(midi: MIDI(71))
        let dyad3 = PitchDyad(pitch0: p7, pitch1: p8)
        let speller3 = PitchDyadSpeller(dyad: dyad3)
        for spellingDyad in speller3.coarseResolutionMatching {
            print(spellingDyad)
            print("isStepPreserving: \(spellingDyad.isStepPreserving)")
        }
    }
    
    func testEquivalence() {
        let pitch: Pitch = Pitch(midi: MIDI(60))
        let ps0 = PitchSpelling(pitch: pitch, coarse: 0.0, fine: 0.0, letterName: .C, octave: 4)
        let ps1 = PitchSpelling(pitch: pitch, coarse: 1.0, fine: 0.25, letterName: .D, octave: 4)
        let psd0 = PitchSpellingDyad(ps0: ps0, ps1: ps1)
        
        let ps2 = PitchSpelling(pitch: pitch, coarse: 0.0, fine: 0.0, letterName: .C, octave: 4)
        let ps3 = PitchSpelling(pitch: pitch, coarse: 1.0, fine: 0.25, letterName: .D, octave: 4)
        let psd1 = PitchSpellingDyad(ps0: ps2, ps1: ps3)
        
        XCTAssert(psd0 == psd1, "pitch spelling dyads not equiv")
    }
}