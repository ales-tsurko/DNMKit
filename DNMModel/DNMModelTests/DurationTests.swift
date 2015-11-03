//
//  DurationTests.swift
//  DNMModel
//
//  Created by James Bean on 11/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest

class DurationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        let db = Duration(beats: 5)
        XCTAssert(db.beats != nil, "Duration beats nil")
        XCTAssert(db.beats! == Beats(amount: 5), "Duration beats set incorrectly")
        XCTAssert(db.subdivision != nil, "Duration subdivision nil")
        XCTAssert(db.subdivision! == Subdivision(value: 1), "Duration subdivision set incorrectly")
        
        let dbs = Duration(beats: Beats(amount: 5), subdivision: Subdivision(value: 16))
        XCTAssert(dbs.beats != nil, "Duration beats nil")
        XCTAssert(dbs.beats!.amount == 5, "Duration beats set incorrectly")
        XCTAssert(dbs.subdivision != nil, "Duration subdivision nil")
        XCTAssert(dbs.subdivision!.value == 16, "Duration subdivision set incorrectly")
        
        let ds = Duration(subdivision: Subdivision(value: 16))
        XCTAssert(ds.subdivision != nil, "Duration subdivision nil")
        XCTAssert(ds.subdivision!.value == 16, "Duration subdivision set incorrectly")
        
        let dfv = Duration(floatValue: 1.5)
        assert(dfv.beats != nil, "Duration beats nil")
        assert(dfv == Duration(3,16), "Duration properties not set correctly")
        
        let dfv2 = Duration(floatValue: 7.25)
        assert(dfv2 == Duration(29,32), "Duration properties not set correctly")
    }
    
    func testSetBeats() {
        var d1 = Duration(1,8)
        d1.setBeats(Beats(amount: 3))
        XCTAssert(d1.beats != nil, "Setting beats not setting beats")
        XCTAssert(d1.beats!.amount == 3, "Beats set incorrectly")
        XCTAssert(d1.subdivision!.value == 8, "Setting beats has broken subdivision property")
        
        d1.setBeats(14)
        XCTAssert(d1.beats!.amount == 14, "Beats set incorrectly")
    }
    
    func testSetSubdivision() {
        var d1 = Duration(1,8)
        d1.setSubdivision(Subdivision(value: 16))
        XCTAssert(d1.subdivision != nil, "Setting subdivision not setting subdivision")
        XCTAssert(d1.subdivision!.value == 16, "Subdivision set incorrecttly")
        
        d1.setSubdivisionValue(32)
        XCTAssert(d1.subdivision!.value == 32, "Subdivision value set incorrectly")
    }
    
    func testSetScale() {
        var d = Duration(1,8)
        d.setScale(0.5)
        XCTAssert(d.scale == 0.5, "Scale set incorrectly")
    }
    
    func testRespellAccordingToBeats() {
        var d = Duration(3,16)
        d.respellAccordingToBeats(Beats(amount: 6))
        XCTAssert(d.beats!.amount == 6, "Beats not respelled correctly")
        XCTAssert(d.subdivision!.value == 32, "Subdivision not respelled correctly")
        d.respellAccordingToBeats(3)
        XCTAssert(d.beats!.amount == 3, "Beats not respelled correctly")
        XCTAssert(d.subdivision!.value == 16, "Subdivision not respelled correctly")
    }
    
    func testRespellAccordingToSubdivision() {
        var d = Duration(3,16)
        d.respellAccordingToSubdivision(Subdivision(value: 64))
        XCTAssert(d.subdivision!.value == 64, "Subdivision not respelled correctly")
        XCTAssert(d.beats!.amount == 12, "Beats not respelled correctly")
        d.respellAccordingToSubdivisionValue(32)
        XCTAssert(d.subdivision!.value == 32, "Subdivision not respelled correctly")
        XCTAssert(d.beats!.amount == 6, "Beats not respelled correctly")
    }
    
    func testDescription() {
        let d = Duration(1,16)
        XCTAssert(d.description == "1/16", "Duration description incorrect")
        
        let d0a = DurationZero
        XCTAssert(d0a.description == "DurationZero", "Duration description incorrect")
        
        let d0b = Duration(0,8)
        XCTAssert(d0b.description == "DurationZero", "Duration description incorrect")
        
        var ds = Duration(1,8)
        ds.setScale(0.5)
        XCTAssert(ds.description == "1/8 * 0.5", "Duration description incorrect")
    }

    func testEqualityHomogeneous() {
        let d1a = Duration(1,8)
        let d1b = Duration(1,8)
        XCTAssert(d1a == d1b, "Duration are not equated properly")
    }
    
    func testAdditionHomogeneous() {
        let d1 = Duration(1,8)
        let d2 = Duration(2,8)
        let d3 = Duration(3,8)
        XCTAssert(d1 + d2 == d3, "Durations do not add properly")
    }
    
    func testSubtractionHomogeneous() {
        let d3 = Duration(3,8)
        let d2 = Duration(2,8)
        let d1 = Duration(1,8)
        XCTAssert(d3 - d2 == d1, "Durations do not add properly")
    }
    
    func testLessThanHomogeneous() {
        let d1 = Duration(1,8)
        let d1b = Duration(2,16)
        let d2 = Duration(2,8)
        let d2b = Duration(4,16)
        
        XCTAssert(d1 < d2, "Duration is not less than")
        XCTAssert(d1 <= d2, "Duration is not less than or equal to")
        XCTAssert(d1 <= d1b, "Duration is not less than or equal to an equivalent Duration")
    }
    
    func testGreaterThanHomogeneous() {
        let d1 = Duration(1,8)
        let d1b = Duration(2,16)
        let d2 = Duration(2,8)
        let d2b = Duration(2,8)

        XCTAssert(d2 > d1, "Duration is not greater than")
        XCTAssert(d1 >= d1b, "Duration is not greater or equal to an equivalent Duration")
        XCTAssert(d2 >= d1, "Duration is not greater than or equal to")
        XCTAssert(d2 >= d2b, "Duration is not greater or equal to an equivalent Duration")
    }
    
    func testEqualityHeterogeneous() {
        let d1 = Duration(1,8)
        let d2 = Duration(2,8)
        XCTAssert(d1 != d2, "Durations are not equated properly")
    }
    
    func testAdditionHeterogeneous() {
        var d1 = Duration(1,8)
        let d2 = Duration(2,16)
        let d3 = Duration(2,8)
        XCTAssert(d1 + d2 == d3, "Durations do not add properly")
        
        d1 += Duration(1,8)
        XCTAssert(d1 == Duration(2,8), "Durations not added correctly")
        
        let dfull = Duration(1,8)
        var dhalf = Duration(1,8)
        dhalf.setScale(0.5)
        
        var dsum = Duration(2,8)
        XCTAssert(dfull + dhalf != dsum, "Durations summed incorrectly with heterogeneous scales")
        dsum.setScale(0.75)
        XCTAssert(dfull + dhalf == dsum, "Durations with heterogeneous scales not added correctly")
    }

    func testSubtractionHeterogeneous() {
        var d3 = Duration(3,8)
        let d216 = Duration(2,16)
        let d28 = Duration(2,8)
        XCTAssert(d3 - d216 == d28, "Durations do not subtract properly")
        
        d3 -= Duration(1,8)
        XCTAssert(d3 == Duration(2,8), "Durations not added correctly")
        
        let dfull = Duration(2,8)
        var dhalf = Duration(1,8)
        dhalf.setScale(0.5)
        
        var ddiff = Duration(2,8)
        XCTAssert(dfull - dhalf != ddiff, "Durations summed incorrectly with heterogeneous scales")
        ddiff.setScale(0.75)
        XCTAssert(dfull - dhalf == ddiff, "Durations with heterogeneous scales not added correctly")
        
        let d4 = Duration(4,16)
        let d2 = Duration(1,8)
        XCTAssert(d4 - d2 == Duration(1,8), "Durations not subtracted correctly")
    }
    
    func testLessThanHeterogeneous() {
        let d1 = Duration(1,8)
        let d3 = Duration(3,16)
        XCTAssert(d1 < d3, "Duration is not less than")
    }
    
    func testGreaterThanHeterogenous() {
        let d1 = Duration(1,8)
        let d3 = Duration(3,16)
        XCTAssert(d3 > d1, "Duration is not greater than")
    }
    
    func testFloatValue() {
        let d = Duration(7,16)
        XCTAssert(d.floatValue != nil, "Duration float value nil")
        XCTAssert(d.floatValue! == (7/16), "Duration float value incorrect")
    }
    
    func testMultiplication() {
        let d = Duration(1,16)
        let d3 = d * 3
        XCTAssert(d3 == Duration(3,16), "Duration not multiplied correctly")
        
        var d2 = Duration(1,16)
        d2 *= 2
        XCTAssert(d2 == Duration(2,16), "Duration not multipled correctly")
    }
    
    func testDivision() {
        var d4 = Duration(4,16)
        let d2 = d4 / 2
        XCTAssert(d2 == Duration(2,16), "Duration not divided correctly")
        
        d4 /= 4
        XCTAssert(d4 == Duration(1,16), "Duration not divided correctly")
    }
}