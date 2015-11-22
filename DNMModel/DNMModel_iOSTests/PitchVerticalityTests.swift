//
//  PitchVerticalityTests.swift
//  denm
//
//  Created by James Bean on 3/26/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest

/*
class PitchVerticalityTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitWithOnePitch() {
        let p0 = Pitch(midi: MIDI(60))
        let verticality = PitchVerticality(pitches: [p0])
        assert(verticality.pitches.count == 1, "pitch not added corectly")
        assert(verticality.pitches.first! == p0, "pitch not set correctly")
    }
    
    func testInitWithTwoPitches() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(67))
        let verticality = PitchVerticality(pitches: [p0,p1])
        assert(verticality.pitches.count == 2, "pitches not added correctly")
        assert(verticality.pitches.first! == p0, "pitches not set correctly")
        assert(verticality.pitches.second! == p1, "pitches not set correctly")
    }
    
    func testInitWithManyPitches() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(67))
        let p2 = Pitch(midi: MIDI(69))
        let verticality = PitchVerticality(pitches: [p0,p1,p2])
        assert(verticality.pitches.count == 3, "pitches not added correctly")
        assert(verticality.pitches.first! == p0, "pitches not set correctly")
        assert(verticality.pitches.second! == p1, "pitches not set correctly")
        assert(verticality.pitches.last! == p2, "pitches not set correctly")
    }
    
    func testDyadsWithOnePitch() {
        let p0 = Pitch(midi: MIDI(60))
        let verticality = PitchVerticality(pitches: [p0])
        print("dyads: \(verticality.dyads)")
    }
    
    func testDyadsWithTwoPitches() {
        let p0 = Pitch(midi: MIDI(67))
        let p1 = Pitch(midi: MIDI(69))
        let verticality = PitchVerticality(pitches: [p0,p1])
        print("dyads: \(verticality.dyads)")
    }
    
    func testDyadsWithThreePitches() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(67))
        let p2 = Pitch(midi: MIDI(69))
        let verticality = PitchVerticality(pitches: [p0,p1,p2])
        print("dyads: \(verticality.dyads)")
    }
    
    func testDyadsWithManyPitches() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(67))
        let p2 = Pitch(midi: MIDI(69))
        let p3 = Pitch(midi: MIDI(71.5))
        let p4 = Pitch(midi: MIDI(74.25))
        let p5 = Pitch(midi: MIDI(81.0))
        let p6 = Pitch(midi: MIDI(81.5))
        let verticality = PitchVerticality(pitches: [p0,p1,p2,p3,p4,p5,p6])
        for dyad in verticality.dyads! {
            print("dyad: \(dyad)")
            print("complexity: \(dyad.interval.complexity!)")
        }
    }
    
    func testInitWithNoPitches() {
        let verticality = PitchVerticality()
        assert(verticality.pitches.count == 0, "pitches not set correctly")
        print(verticality)
        verticality.addPitch(Pitch.random())
        assert(verticality.pitches.count == 1, "pitch not added correctly")
        print(verticality)
        verticality.addPitch(Pitch.random())
        assert(verticality.pitches.count == 2, "pitch not added correctly")
        assert(verticality[0] <= verticality[1], "pitches not sorted when added")
        print(verticality)
        verticality.addPitches(Pitch.random(5))
        assert(verticality.pitches.count == 7, "pitches not added correctly")
        print(verticality)
        print("dyads: \(verticality.dyads!)")
    }
    
    func testRemoveDuplicates() {
        let verticality: PitchVerticality = PitchVerticality()
        for _ in 0..<4 {
            let randomPitch = Pitch.random()
            verticality.addPitch(randomPitch)
            verticality.addPitch(randomPitch)
        }
        print(verticality)
        assert(verticality.pitches.count == 8, "pitches not added correctly")
        verticality.removeDuplicates()
        print(verticality)
        assert(verticality.pitches.count == 4, "duplicated not removed correctly")
    }
    
    func testInitWithTwoVerticalities() {
        let verticality0 = PitchVerticality(pitches: Pitch.random(5))
        let verticality1 = PitchVerticality(pitches: Pitch.random(3))
        let newVerticality = PitchVerticality(
            verticality0: verticality0,
            verticality1: verticality1
        )
        assert(newVerticality.pitches.count == 8, "pitches not added correctly")
    }
}

*/