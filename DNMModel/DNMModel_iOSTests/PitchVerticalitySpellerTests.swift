//
//  PitchVerticalitySpellerTests.swift
//  denm
//
//  Created by James Bean on 3/26/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class PitchVerticalitySpellerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithOnePitch() {
        let p0 = Pitch(midi: MIDI(60.25))
        let verticality = PitchVerticality(pitches: [p0])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
    }
    
    func testInitWithTwoPitches() {
        let p0 = Pitch(midi: MIDI(70.5))
        let p1 = Pitch(midi: MIDI(60.75))
        let verticality = PitchVerticality(pitches: [p0,p1])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
    }
    
    func testInitWithThreePitches() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(67))
        let p2 = Pitch(midi: MIDI(69))
        let verticality = PitchVerticality(pitches: [p0,p1,p2])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
    }
    
    func testOctatonicVerticality() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(62))
        let p2 = Pitch(midi: MIDI(63))
        let p3 = Pitch(midi: MIDI(65))
        let p4 = Pitch(midi: MIDI(66))
        let p5 = Pitch(midi: MIDI(68))
        let p6 = Pitch(midi: MIDI(69))
        let p7 = Pitch(midi: MIDI(71))
        let p8 = Pitch(midi: MIDI(72))
        let verticality = PitchVerticality(pitches: [p0,p1,p2,p3,p4,p5,p6,p7,p8])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for pitch in verticality.pitches {
            print(pitch)
        }
    }
    
    func testInitWithManyHalfTonePitches() {
        let p0 = Pitch(midi: MIDI(60))
        let p1 = Pitch(midi: MIDI(63))
        let p2 = Pitch(midi: MIDI(64))
        let p3 = Pitch(midi: MIDI(68))
        let p4 = Pitch(midi: MIDI(70))
        let p5 = Pitch(midi: MIDI(71))
        let p6 = Pitch(midi: MIDI(72))
        let p7 = Pitch(midi: MIDI(74))
        let p8 = Pitch(midi: MIDI(75))
        let verticality = PitchVerticality(pitches: [p0,p1,p2,p3,p4,p5,p6,p7,p8])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for pitch in verticality.pitches {
            print(pitch)
        }
    }
    
    func testInitWithManyQuarterTonePitches() {
        let p0 = Pitch(midi: MIDI(60.5))
        let p1 = Pitch(midi: MIDI(63.5))
        let p2 = Pitch(midi: MIDI(64.5))
        let p3 = Pitch(midi: MIDI(68.5))
        let p4 = Pitch(midi: MIDI(70.5))
        let p5 = Pitch(midi: MIDI(71.5))
        let p6 = Pitch(midi: MIDI(72.5))
        let p7 = Pitch(midi: MIDI(74.5))
        let p8 = Pitch(midi: MIDI(75.5))
        let verticality = PitchVerticality(pitches: [p0,p1,p2,p3,p4,p5,p6,p7,p8])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for pitch in verticality.pitches {
            print(pitch)
        }
    }
    
    func testInitWithManyPitchesOfAllResolutions() {
        let p0 = Pitch(midi: MIDI(60.25))
        let p1 = Pitch(midi: MIDI(63.5))
        let p2 = Pitch(midi: MIDI(64.75))
        let p3 = Pitch(midi: MIDI(68))
        let p4 = Pitch(midi: MIDI(70.25))
        let p5 = Pitch(midi: MIDI(71.75))
        let p6 = Pitch(midi: MIDI(72.5))
        let p7 = Pitch(midi: MIDI(74))
        let p8 = Pitch(midi: MIDI(75.5))
        let verticality = PitchVerticality(pitches: [p0,p1,p2,p3,p4,p5,p6,p7,p8])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for pitch in verticality.pitches {
            print(pitch)
        }
    }
    
    func testInitWithOnePitchNotSpellableObjectively() {
        let p0 = Pitch(midi: MIDI(61))
        let verticality = PitchVerticality(pitches: [p0])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        // ...
    }
    
    func testInitWithTwoPitchesNotSpellableObjectively() {
        let p0 = Pitch(midi: MIDI(61))
        let p1 = Pitch(midi: MIDI(63))
        let verticality = PitchVerticality(pitches: [p0,p1])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for p in verticality.pitches { print(p) }
    }
    
    func testInitWithTwoPitchesEighthToneResNotSpellableObjectively() {
        let p0 = Pitch(midi: MIDI(61.75))
        let p1 = Pitch(midi: MIDI(64.25))
        let verticality = PitchVerticality(pitches: [p0,p1])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for p in verticality.pitches { print(p) }
    }
    
    func testInitWithTwoPitchesEighthToneResNotSpellableObjectively_again() {
        let p0 = Pitch(midi: MIDI(61))
        let p1 = Pitch(midi: MIDI(63.25))
        let verticality = PitchVerticality(pitches: [p0,p1])
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for p in verticality.pitches { print(p) }
    }
    
    /*
    func testInitWithAnyNumberOfPitchesNotSpellableObjectively() {
        for _ in 0..<1000 {
            let pitches: [Pitch] = Pitch.random(randomInt(randomInt(2, max: 7)))
            let verticality = PitchVerticality(pitches: pitches)
            let speller = PitchVerticalitySpeller(verticality: verticality)
            speller.spell()
            for p in verticality.pitches { print(p) }
            assert(speller.allPitchesHaveBeenSpelled, "not all pitches have been spelled")
            assert(speller.allFineValuesMatch, "not all fine values match")
        }
    }
    */
    
    /*
    func testSpellThreePitches() {
        for _ in 0..<100 {
            var pitches: [Pitch] = []
            for _ in 0..<3 { pitches.append(Pitch.random()) }
            let verticality = PitchVerticality(pitches: pitches)
            let speller = PitchVerticalitySpeller(verticality: verticality)
            speller.spell()
            for p in verticality.pitches { print(p) }
        }
    }
    */
    
    func testSpellEflatAFlatFNatural() {
        let p0 = Pitch(midi: MIDI(63))
        let p1 = Pitch(midi: MIDI(65))
        let p2 = Pitch(midi: MIDI(68))
        let pitches = [p0,p1,p2]
        let verticality = PitchVerticality(pitches: pitches)
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for p in pitches { print(p) }
    }
    
    func testSpellTwoVerticalitiesMerged() {
        for _ in 0..<25 {
            let verticality0 = PitchVerticality(pitches: Pitch.random(4, min: 60, max: 84, resolution: 0.25))
            let verticality1 = PitchVerticality(pitches: Pitch.random(5, min: 60, max: 84, resolution: 0.25))
            let newVerticality = PitchVerticality(
                verticality0: verticality0,
                verticality1: verticality1
            )
            let speller = PitchVerticalitySpeller(verticality: newVerticality)
            speller.spell()
            print("COMPOSITE")
            for p in newVerticality.pitches { print(p) }
            print("FIRST")
            for p in verticality0.pitches { print(p) }
            print("SECOND")
            for p in verticality1.pitches { print(p) }
        }
    }
    
    func testA_Gsharp_Bflat() {
        let midi: [Float] = [68.0,69.0,70.0]
        var pitches: [Pitch] = []
        for p in midi {
            pitches.append(Pitch(midi: MIDI(p)))
        }
        let verticality = PitchVerticality(pitches: pitches)
        let speller = PitchVerticalitySpeller(verticality: verticality)
        speller.spell()
        for pitch in pitches {
            print(pitch)
        }
    }
}