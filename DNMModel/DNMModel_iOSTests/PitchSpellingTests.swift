//
//  PitchSpellingTests.swift
//  denm_0
//
//  Created by James Bean on 3/18/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest

/*
class PitchSpellingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        let p = Pitch(midi: MIDI(60))
        let ps = PitchSpelling(pitch: p, coarse: -1.0, fine: -0.25, letterName: .E)
        assert(ps.coarse == -1.0, "coarse not set correctly")
        assert(ps.fine == -0.25, "fine not set correctly")
        assert(ps.letterName == PitchLetterName.E, "letter name not set correctly")
        assert(ps.coarseDirection == -1, "coarse direction incorrect")
        assert(ps.fineDirection == -1, "fine direction incorrect")
        assert(ps.coarseResolution == 1.0, "coarse resolution incorrect")
        assert(ps.fineResolution == 0.25, "fine resolution incorrect")
        assert(ps.sharpness == -2, "sharpness incorrect")
    }
    
    func testAllSharpness() {
        var p: Float = 60.0
        while p < 84 {
            let pitch: Pitch = Pitch(midi: MIDI(p))
            for spelling in GetPitchSpellings.forPitch(pitch) {
                print("PitchSpelling: \(spelling): sharpness: \(spelling.sharpness)")
            }
            p += 0.25
        }
    }
    
    func testSharpness() {
        let bf = Pitch(midi: MIDI(58))
        let bFlat = PitchSpelling(pitch: bf, coarse: -1.0, fine: 0.0, letterName: .B)
        assert(bFlat.sharpness == -1, "Bflat sharpness incorrect")
        
        let bqf = Pitch(midi: MIDI(58.5))
        let bQuarterFlat = PitchSpelling(pitch: bqf, coarse: -0.5, fine: -0.25, letterName: .B)
        assert(bQuarterFlat.sharpness == -1, "BquarterFlat sharpness incorrect")
        
        let cn = Pitch(midi: MIDI(60))
        let cNatural = PitchSpelling(pitch: cn, coarse: 0, fine: 0, letterName: .C)
        assert(cNatural.sharpness == 0, "Cnatural sharpness incorrect")
        
        let fs = Pitch(midi: MIDI(66))
        let fSharp = PitchSpelling(pitch: fs, coarse: 1, fine: 0, letterName: .F)
        assert(fSharp.sharpness == 1, "Fsharp sharpness incorrect")
        
        let fqs = Pitch(midi: MIDI(65.5))
        let fQuarterSharp = PitchSpelling(pitch: fqs, coarse: 0.5, fine: 0, letterName: .F)
        assert(fQuarterSharp.sharpness == 1, "FquarterSharp sharpness incorrect")
    }
    
    func testEquivalent() {
        let pitch: Pitch = Pitch(midi: MIDI(60))
        let ps0 = PitchSpelling(pitch: pitch, coarse: 0.0, fine: 0.0, letterName: .C, octave: 4)
        let ps1 = PitchSpelling(pitch: pitch, coarse: 0.0, fine: 0.0, letterName: .C, octave: 4)
        assert(ps0 == ps1, "pitch spellings not equiv")
    }
}

*/