//
//  PitchIntervalTests.swift
//  denm
//
//  Created by James Bean on 3/25/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest

/*
class PitchIntervalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAllIntervalsPresent() {
        var interval: Float = 0.0
        while interval < 12 {
            //assert(PitchInterval.intervalsSortedByComplexity.contains(interval), "interval not present")
            interval += 0.25
        }
    }
    
    func testComplexity() {
        let p0 = Pitch(midi: MIDI(65))
        let p1 = Pitch(midi: MIDI(77))
        let dyad = PitchDyad(pitch0: p0, pitch1: p1)
        //assert(dyad.interval.complexity! == 0, "interval complexity incorrect")
        
        let p3 = Pitch(midi: MIDI(60))
        let p4 = Pitch(midi: MIDI(61))
        let dyad1 = PitchDyad(pitch0: p3, pitch1: p4)
        //assert(dyad1.interval.complexity! == 1, "interval complexity incorrect")
        
        let pitch1 = Pitch(midi: MIDI(60))
        var pitch: Float = 60
        while pitch < 75 {
            let pitch2 = Pitch(midi: MIDI(pitch))
            let newDyad = PitchDyad(pitch0: pitch1, pitch1: pitch2)
            print("\(pitch1) || \(pitch2): complexity: \(newDyad.interval.complexity!)")
            pitch += 0.25
        }
    }
}

*/