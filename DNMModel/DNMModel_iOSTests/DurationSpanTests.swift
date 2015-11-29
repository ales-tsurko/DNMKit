//
//  DurationSpanTests.swift
//  DNMModel
//
//  Created by James Bean on 11/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class DurationSpanTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let ds0 = DurationSpan()
        XCTAssert(ds0.startDuration == DurationZero, "should be 0")
        XCTAssert(ds0.stopDuration == DurationZero, "should be 0")
        XCTAssert(ds0.duration == DurationZero, "should be 0")
        print(ds0)
        
        let ds1 = DurationSpan(startDuration: Duration(3,8), stopDuration: Duration(4,4))
        XCTAssert(ds1.startDuration == Duration(3,8), "start dur wrong")
        XCTAssert(ds1.stopDuration == Duration(4,4), "stop dur wrong")
        XCTAssert(ds1.duration == Duration(5,8), "dur wrong")
        
        let ds2 = DurationSpan(duration: Duration(13,16), startDuration: Duration(11,8))
        XCTAssert(ds2.duration == Duration(13,16), "dur wrong")
        XCTAssert(ds2.startDuration == Duration(11,8), "start dur wrong")
        XCTAssert(ds2.stopDuration == Duration(35, 16), "stop dur wrong")
        
        let ds3 = DurationSpan(duration: Duration(9,16), andAnotherDuration: Duration(1,8))
        XCTAssert(ds3.startDuration == Duration(1,8), "start dur wrong")
        XCTAssert(ds3.stopDuration == Duration(9,16), "stop dur wrong")
        XCTAssert(ds3.duration == Duration(7,16), "dur wrong")
    }
    
    func testEquivalence() {
        let ds0 = DurationSpan(startDuration: Duration(2,8), stopDuration: Duration(5,8))
        let ds1 = DurationSpan(startDuration: Duration(4,16), stopDuration: Duration(20,32))
        let ds2 = DurationSpan(startDuration: Duration(4,8), stopDuration: Duration(9,8))
        XCTAssert(ds0 == ds1, "should be ==")
        XCTAssert(ds0 != ds2, "should be !=")
        XCTAssert(ds1 != ds2, "should be !=")
    }
    
    func testContainsDuration() {
        let ds = DurationSpan(duration: Duration(9,16), andAnotherDuration: Duration(1,8))
        
        // duration in duration span
        let d0 = Duration(2,8)
        XCTAssert(ds.containsDuration(d0), "should contain the duration")
        XCTAssert(d0.isContainedWithinDurationSpan(ds), "should be contained within duration")
        
        // not in duration span
        let d1 = Duration(11,16)
        XCTAssert(
            !d1.isContainedWithinDurationSpan(ds),
            "should not be contained within the duration"
        )
    }
    
    func testRelationshipWithDurationSpan() {
        
        // test none
        let dsn_0a = DurationSpan(startDuration: Duration(2,8), stopDuration: Duration(5,8))
        let dsn_1a = DurationSpan(startDuration: Duration(6,8), stopDuration: Duration(9,8))
        XCTAssert(dsn_0a.relationShipWithDurationSpan(dsn_1a) == .None, "should be none")
        XCTAssert(dsn_1a.relationShipWithDurationSpan(dsn_0a) == .None, "should be none")
        
        // test overlapping
        let dso_0 = DurationSpan(startDuration: Duration(2,8), stopDuration: Duration(5,8))
        let dso_1 = DurationSpan(startDuration: Duration(3,8), stopDuration: Duration(9,8))
        XCTAssert(
            dso_0.relationShipWithDurationSpan(dso_1) == .Overlapping, "should be overlapping"
        )
        XCTAssert(
            dso_1.relationShipWithDurationSpan(dso_0) == .Overlapping, "should be overlapping"
        )
        
        // test adjacent before
        let dsa_0a = DurationSpan(startDuration: Duration(2,8), stopDuration: Duration(5,8))
        let dsa_1a = DurationSpan(startDuration: DurationZero, stopDuration: Duration(2,8))
        XCTAssert(dsa_0a.relationShipWithDurationSpan(dsa_1a) == .Adjacent, "should be adjacent")
        XCTAssert(dsa_1a.relationShipWithDurationSpan(dsa_0a) == .Adjacent, "should be adjacent")
        
        // test adjacent after
        let dsa_0b = DurationSpan(startDuration: Duration(2,8), stopDuration: Duration(5,8))
        let dsa_1b = DurationSpan(startDuration: Duration(5,8), stopDuration: Duration(9,8))
        XCTAssert(dsa_0a.relationShipWithDurationSpan(dsa_1b) == .Adjacent, "should be adjacent")
        XCTAssert(dsa_1b.relationShipWithDurationSpan(dsa_0b) == .Adjacent, "should be adjacent")
    }

}
