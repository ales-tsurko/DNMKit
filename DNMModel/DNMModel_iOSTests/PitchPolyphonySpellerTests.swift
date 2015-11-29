//
//  PitchPolyphonySpellerTests.swift
//  denm
//
//  Created by James Bean on 4/8/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

/*
class PitchPolyphonySpellerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let verticality0 = PitchVerticality(pitches: [Pitch(midi: MIDI(68))])
        let verticality1 = PitchVerticality(pitches: [
            Pitch(midi: MIDI(68)), Pitch(midi: MIDI(65))
        ])
        let verticality2 = PitchVerticality(pitches: [
            Pitch(midi: MIDI(68)), Pitch(midi: MIDI(64))
        ])
        let verticality3 = PitchVerticality(pitches: [
            Pitch(midi: MIDI(64)), Pitch(midi: MIDI(67))
        ])
        let verticality4 = PitchVerticality(pitches: [
            Pitch(midi: MIDI(64)), Pitch(midi: MIDI(69))
        ])
        let polyphony = PitchPolyphony(
            verticalities: [
                verticality0, verticality1, verticality2, verticality3, verticality4
            ]
        )
        let speller = PitchPolyphonySpeller(polyphony: polyphony)
        speller.spell()
    }
    
    func testNeighbors() {
        let midi: [Float] = [69,71,73,69,76,74,73,68,69,70,69,72,73,72,63,65,66,72,73,74,75,73,72]
        var verticalities: [PitchVerticality] = []
        for p in midi {
            verticalities.append(PitchVerticality(pitches: [Pitch(midi: MIDI(p))]))
        }
        let polyphony = PitchPolyphony(verticalities: verticalities)
        let speller = PitchPolyphonySpeller(polyphony: polyphony)
        speller.spell()
    }
    
    func testOctatonicScale() {
        let midi: [Float] = [60,62,63,65,66,68,69,71]
        var verticalities: [PitchVerticality] = []
        for p in midi {
            verticalities.append(PitchVerticality(pitches: [Pitch(midi: MIDI(p))]))
        }
        let polyphony = PitchPolyphony(verticalities: verticalities)
        let speller = PitchPolyphonySpeller(polyphony: polyphony)
        speller.spell()
    }
}
*/