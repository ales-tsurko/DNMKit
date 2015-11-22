//
//  DurationTests.swift
//  DurationTests
//
//  Created by James Bean on 3/13/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class DurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDuration() {
        var dur: Duration = Duration(beats: 4)
        assert(dur.beats != nil, "beats is nil")
        assert(dur.beats!.amount == 4, "beats not set correctly")
        assert(dur.subdivision != nil, "subdivision nil")
        assert(dur.subdivision!.value == 1, "subdivision not set correctly")
        dur.setSubdivisionValue(32)
        assert(dur.beats!.amount == 4, "beats reset incorrectly")
        assert(dur.subdivision != nil, "subdivision not set")
        assert(dur.subdivision!.value == 32, "subdivision not set correctly")
        assert(dur.subdivision!.level == 3, "subdiviion level not set correctly")
    }
    
    func testInheritedScale() {
        var d1 = Duration(7,16)
        assert(d1.scale == 1.0, "inherited scale not defaulted to 1.0")
        d1.setScale(0.75)
        assert(d1.scale == 0.75, "inherited scale not set correctly")
    }
    
    func testDurationCompare() {
        var d1 = Duration(7, 16)
        var d2 = Duration(3,8)
        assert(d1 != d2, "non equiv durs are equiv")
        assert(d1 >= d2, "d1 not less than or equal to d2")
        assert(d2 <= d1, "d2 not greater than or equal to d1")
        d2.setSubdivisionValue(32)
        d2.setBeats(14)
        assert(d1 == d2, "equiv durs not equiv")
        d1.setBeats(30)
        assert(d1 > d2, "d1 not greater than d2")
        assert(d2 < d1, "d2 not less than d1")
    }
    
    func testDurationAdd() {
        var d1 = Duration(7,16)
        let d2 = Duration(3,8)
        assert(d1 + d2 == Duration(13,16), "durs not added correctly")
        let d3 = Duration(2,4)
        var d4 = Duration(13,32)
        assert(d3 + d4 == Duration(29,32), "durs not added correctly")
        let d5 = d3 - d4
        assert(d5 == Duration(3,32), "durs not subtracted correctly")
        var d6 = Duration(17,16)
        let d7 = Duration(3,8)
        assert(d6 - d7 == Duration(11,16), "durs not subtracted correctly")
        d6 += d7
        assert(d6 == Duration(23,16), "durs not added correctly")
        d1 -= d2
        assert(d1 == Duration(1,16), "durs not subdtracted correctly")
    }
    
    func testDurationMultiplyDivide() {
        let d1 = Duration(7,16)
        var d2 = d1 * 2
        assert(d2 == Duration(14,16), "dur not multplied correctly")
        d2 *= 2
        assert(d2 == Duration(28,16), "dur not multiplied correctly")
        let d3 = Duration(6,8)
        let d4 = d3 / 2
        assert(d4 == Duration(3,8), "dur not divided correctly")
        let d5 = Duration(13,16)
        let d6 = d5 / 2
        assert(d6 == Duration(13,32), "dur not divided correctly")
    }
    
    func testDurationRespellAccordingToBeats() {
        var d1 = Duration(7,16)
        d1.respellAccordingToBeats(Beats(amount: 14))
        assert(d1 == Duration(7,16), "not respelled correctly")
        assert(d1.beats!.amount == 14, "beats not respelled correctly")
        assert(d1.subdivision!.value == 32, "subdivision not respelled correctly")
        d1.respellAccordingToBeats(28)
        assert(d1 == Duration(28,64), "not respelled correctly")
        d1.respellAccordingToBeats(7)
        assert(d1 == Duration(7,16), "not respelled correctly")
        // d1.respellAccordingToBeats(13) // must fail
    }
    
    func testDurationRespellAccordingToSubdivision() {
        var d1 = Duration(7,16)
        d1.respellAccordingToSubdivision(Subdivision(value: 32))
        assert(d1 == Duration(7,16), "not respelled correctly")
        assert(d1.beats!.amount == 14, "beats not respelled correctly")
        assert(d1.subdivision!.value == 32, "subdivision not respelled correctly")
        d1.respellAccordingToSubdivisionValue(64)
        assert(d1 == Duration(28,64), "not respelled correctly")
        d1.respellAccordingToSubdivisionValue(16)
        assert(d1 == Duration(7,16), "not respelled correctly")
        // md1.respellAccordingToSubdivisionValue(8) // must fail
    }
}