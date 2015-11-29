//
//  PitchSpellingTests.swift
//  denm_0
//
//  Created by James Bean on 3/18/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

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
        XCTAssert(ps.coarse == -1.0, "coarse not set correctly")
        XCTAssert(ps.fine == -0.25, "fine not set correctly")
        XCTAssert(ps.letterName == PitchLetterName.E, "letter name not set correctly")
        XCTAssert(ps.coarseDirection == -1, "coarse direction incorrect")
        XCTAssert(ps.fineDirection == -1, "fine direction incorrect")
        XCTAssert(ps.coarseResolution == 1.0, "coarse resolution incorrect")
        XCTAssert(ps.fineResolution == 0.25, "fine resolution incorrect")
        XCTAssert(ps.sharpness == -2, "sharpness incorrect")
    }
    
    func testResolution() {
        let c = Pitch(midi: MIDI(60))
        let psC = PitchSpelling(pitch: c, coarse: 0, fine: 0, letterName: .C)
        XCTAssert(psC.resolution == 1, "c nat not half step res")
        
        let cs = Pitch(midi: MIDI(61))
        let psCs = PitchSpelling(pitch: cs, coarse: 1, fine: 0, letterName: .C)
        XCTAssert(psCs.resolution == 1, "c sharp not half step res")
        
        let cqs = Pitch(midi: MIDI(60.5))
        let psCqs = PitchSpelling(pitch: cqs, coarse: 0.5, fine: 0, letterName: .C)
        XCTAssert(psCqs.resolution == 0.5, "c quarter sharp not quarter step res")
        
        let cqsup = Pitch(midi: MIDI(60.75))
        let psCqsup = PitchSpelling(pitch: cqsup, coarse: 0.5, fine: 0.25, letterName: .C)
        XCTAssert(psCqsup.resolution == 0.25, "c quarter sharp up not eighth step res")
    }
    
    func testFineDirection() {
        let cup = Pitch(midi: MIDI(60.25))
        let psCup = PitchSpelling(pitch: cup, coarse: 0, fine: 0.25, letterName: .C)
        XCTAssert(psCup.fineDirection == 1, "c up fine direction not up")
        
        let cdown = Pitch(midi: MIDI(59.75))
        let psCdown = PitchSpelling(pitch: cdown, coarse: 0, fine: -0.25, letterName: .C)
        XCTAssert(psCdown.fineDirection == -1, "c down fine direction not down")
    }
    
    func testAllSharpness() {
        var p: Float = 60.0
        while p < 84 {
            let pitch: Pitch = Pitch(midi: MIDI(p))
            for spelling in PitchSpelling.pitchSpellingsForPitch(pitch: pitch) {
                print("PitchSpelling: \(spelling): sharpness: \(spelling.sharpness)")
            }
            p += 0.25
        }
    }
    
    func testSharpness() {
        let bf = Pitch(midi: MIDI(58))
        let bFlat = PitchSpelling(pitch: bf, coarse: -1.0, fine: 0.0, letterName: .B)
        XCTAssert(bFlat.sharpness == -1, "Bflat sharpness incorrect")
        
        let bqf = Pitch(midi: MIDI(58.5))
        let bQuarterFlat = PitchSpelling(pitch: bqf, coarse: -0.5, fine: -0.25, letterName: .B)
        XCTAssert(bQuarterFlat.sharpness == -1, "BquarterFlat sharpness incorrect")
        
        let cn = Pitch(midi: MIDI(60))
        let cNatural = PitchSpelling(pitch: cn, coarse: 0, fine: 0, letterName: .C)
        XCTAssert(cNatural.sharpness == 0, "Cnatural sharpness incorrect")
        
        let fs = Pitch(midi: MIDI(66))
        let fSharp = PitchSpelling(pitch: fs, coarse: 1, fine: 0, letterName: .F)
        XCTAssert(fSharp.sharpness == 1, "Fsharp sharpness incorrect")
        
        let fqs = Pitch(midi: MIDI(65.5))
        let fQuarterSharp = PitchSpelling(pitch: fqs, coarse: 0.5, fine: 0, letterName: .F)
        XCTAssert(fQuarterSharp.sharpness == 1, "FquarterSharp sharpness incorrect")
    }
    
    func testEquivalent() {
        let pitch: Pitch = Pitch(midi: MIDI(60))
        let ps0 = PitchSpelling(pitch: pitch, coarse: 0.0, fine: 0.0, letterName: .C, octave: 4)
        let ps1 = PitchSpelling(pitch: pitch, coarse: 0.0, fine: 0.0, letterName: .C, octave: 4)
        XCTAssert(ps0 == ps1, "pitch spellings not equiv")
    }
    
    func testGreaterThanAndLessThan() {
        let fs = Pitch(midi: MIDI(66))
        let fSharp = PitchSpelling(pitch: fs, coarse: 1, fine: 0, letterName: .F)
        
        let gb = Pitch(midi: MIDI(66))
        let gFlat = PitchSpelling(pitch: gb, coarse: -1, fine: 0, letterName: .G)
        
        XCTAssert(fSharp < gFlat, "g flat not greater than f sharp")
        XCTAssert(fSharp <= gFlat, "g flat not greater than or equal to f sharp")
        XCTAssert(gFlat > fSharp, "g flat not less than f sharp")
        XCTAssert(gFlat >= fSharp, "g flat not less than or equal to f sharp")
        
        // fill out for more complex relationships
    }
    
    
}