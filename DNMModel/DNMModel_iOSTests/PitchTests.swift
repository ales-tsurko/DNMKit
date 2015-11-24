
//
//  PitchTests.swift
//  denm_0
//
//  Created by James Bean on 3/17/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class PitchTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetOctave() {
        
    }
    
    func testPossibleSpellings() {
        var p: Float = 60.0
        while p < 72 {
            let pitch = Pitch(midi: MIDI(p))
            print(pitch.possibleSpellings)
            p += 0.25
        }
    }
    
    func testMiddleC() {
        let middleC = Pitch.middleC()
        XCTAssert(middleC.midi.value == 60.0, "should be 60")
    }
    
    func testCopy() {
        let p0 = Pitch(midi: MIDI(72.25))
        p0.spelling = p0.possibleSpellings.first!
        let p1 = p0.copy()
        XCTAssert(p0 == p1, "should be ==")
        XCTAssert(p1.spelling == nil, "should be nil")
    }

    func testInit() {
        // create pitch with midi
        let pM = Pitch(midi: MIDI(69.0))
        XCTAssert(pM.midi.value == 69.0, "midi not set correctly")
        XCTAssert(pM.frequency.value == 440, "frequency not set correctly")
        
        // change frequency
        pM.setFrequency(Frequency(880))
        XCTAssert(pM.midi.value == 81.0, "midi not set correctly")
        XCTAssert(pM.frequency.value == 880, "frequency not set correctly")
        
        // create pitch with frequency
        let pF = Pitch(frequency: Frequency(440))
        XCTAssert(pF.midi.value == 69.0, "midi not set correctly")
        XCTAssert(pF.frequency.value == 440.0, "frequency not set correctly")
        
        // change midi
        pF.setMIDI(MIDI(81.0))
        XCTAssert(pF.midi.value == 81.0, "midi not set correctly")
        XCTAssert(pF.frequency.value == 880.0, "frequency not set correctly")
    }
    
    func testComparison() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(60.25))
        XCTAssert(p1 >= p0, "should be >=")
    }
    
    func testGetMIDIOfPartial() {
        let p = Pitch(midi: MIDI(60))
        let p8va = p.getMIDIOfPartial(2)
        XCTAssert(p8va.value == 72, "midi of partial (2) incorrect")
    }
    
    func testGetFrequencyOfPartial() {
        let p = Pitch(midi: MIDI(69.0))
        let p8va = p.frequencyOfPartial(2)
        XCTAssert(p8va.value == 880.0, "freq of partial (2) incorrect")
    }
    
    func testPitchClass() {
        let p = Pitch(midi: MIDI(69.0))
        XCTAssert(p.pitchClass.midi.value == 9.0, "pitchClass not set correctly")
    }
    
    func testResolution() {
        let chromatic = Pitch(midi: MIDI(60.0))
        XCTAssert(chromatic.resolution == 1.0, "resolution incorrect")
        let quarterTone = Pitch(midi: MIDI(60.5))
        XCTAssert(quarterTone.resolution == 0.5, "resolution incorrect")
        let eighthTone = Pitch(midi: MIDI(60.25))
        XCTAssert(eighthTone.resolution == 0.25, "resolution incorrect")
    }
    
    func testOctave() {
        let pitches: [Float] = [60, 61, 59, 48, 72, 84]
        let octaves: [Int] = [4, 4, 3, 3, 5, 6]
        var index: Int = 0
        while index < pitches.count {
            let pitch = Pitch(midi: MIDI(pitches[index]))
            XCTAssert(pitch.octave == octaves[index], "octave incorrect")
            index++
        }
    }
    
    func testRandom() {
        for _ in 0..<50 {
            let pitch: Pitch = Pitch.random()
            print(pitch)
        }
        
        for _ in 0..<50 {
            let pitch: Pitch = Pitch.random(36.0, max: 50.0, resolution: 0.5)
            print(pitch)
        }
        
        let pitches = Pitch.random(10, min: 30, max: 90, resolution: 0.25)
        for p in pitches {
            print(p)
        }
    }
    
    func testRandomArray() {
        let randomPitches: [Pitch] = Pitch.random(5)
        print(randomPitches)
    }
}