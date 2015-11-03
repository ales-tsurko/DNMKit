//
//  PitchTests.swift
//  DNMModel
//
//  Created by James Bean on 11/3/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest

class PitchTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMIDI() {
        let m = MIDI(62.25)
        XCTAssert(m.value == 62.25, "Value set wrong")
        
        let mf = MIDI(frequency: Frequency(440))
        XCTAssert(mf.value == 69.0, "Value set wrong")
    }
    
    func testFrequency() {
        let f = Frequency(440)
        XCTAssert(f.value == 440, "Value set wrong")
        
        let fm = Frequency(midi: MIDI(69))
        XCTAssert(fm.value == 440, "Value set wrong")
    }
    
    func testDescription() {
        let p = Pitch(midi: MIDI(60))
        print(p.description)
        XCTAssert(p.description == "Pitch: 60.0", "Description wrong")
    }
    
    func testInit() {
        let pm = Pitch(midi: MIDI(60.29), resolution: 0.25)
        XCTAssert(pm.midi.value == 60.25, "MIDI set wrong")
        let pf = Pitch(frequency: Frequency(445), resolution: 1.0)
        XCTAssert(pf.midi.value == 69, "MIDI set wrong")
    }
    
    func testMiddleC() {
        let middleC = Pitch.middleC()
        XCTAssert(middleC.midi.value == 60, "MIDI wrong")
    }
    
    func testFrequencyOfPartial() {
        let base = Pitch(midi: MIDI(69))
        let harmFreq0 = base.frequencyOfPartial(1)
        let harmFreq1 = base.frequencyOfPartial(2)
        let harmFreq2 = base.frequencyOfPartial(3)
        XCTAssert(harmFreq0 == base.frequency, "Frequencies not equal")
        XCTAssert(harmFreq1 == Frequency(880), "Frequencies not equal")
        XCTAssert(harmFreq2 == Frequency(1320), "Frequencies not equal")
    }
    
    func testComparison() {
        let p60a = Pitch(midi: MIDI(60))
        let p60b = Pitch(midi: MIDI(60))
        let p61 = Pitch(midi: MIDI(61))
        XCTAssert(p60a == p60b, "Pitches not equal")
        XCTAssert(p60a >= p60b, "Pitch not greater than or equal")
        XCTAssert(p60a <= p60b, "Pitch not less than or equal")
        XCTAssert(p61 > p60a, "Pitch not greater than")
        XCTAssert(p60a < p61, "Pitch not less than")
    }
}
