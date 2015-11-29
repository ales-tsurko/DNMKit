//
//  DurationIntervalTests.swift
//  DNMModel
//
//  Created by James Bean on 11/27/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class DurationIntervalTests: XCTestCase {

    func testInit() {
        var di = DurationIntervalZero
        XCTAssert(di.startDuration == DurationZero, "should be 0")
        XCTAssert(di.stopDuration == DurationZero, "should be 0")
        XCTAssert(di.duration == DurationZero, "should be 0")
        print(di)
        
        di = DurationInterval(oneDuration: Duration(1,8), andAnotherDuration: Duration(3,8))
        XCTAssert(di.startDuration == Duration(1,8), "should be 1,8")
        XCTAssert(di.stopDuration == Duration(3,8), "should be 3,8")
        XCTAssert(di.duration == Duration(2,8), "should be 2,8")
        print(di)
        
        di = DurationInterval(duration: Duration(1,8), startDuration: Duration(6,8))
        XCTAssert(di.duration == Duration(1,8), "should be 1,8")
        XCTAssert(di.startDuration == Duration(6,8), "should be 6,8")
        XCTAssert(di.stopDuration == Duration(7,8), "should be 7,8")
        print(di)
        
        di = DurationInterval(startDuration: Duration(4,8), stopDuration: Duration(7,8))
        XCTAssert(di.startDuration == Duration(4,8), "should be 4,8")
        XCTAssert(di.stopDuration == Duration(7,8), "should be 7,8")
        XCTAssert(di.duration == Duration(3,8), "should be 3,8")
        print(di)
    }
    
    func testMakeUnionWithDurationInterval() {
        let di0 = DurationInterval(startDuration: Duration(2,8), stopDuration: Duration(5,8))
        let di1 = DurationInterval(startDuration: Duration(3,8), stopDuration: Duration(6,8))
        let union = di0.makeUnionWithDurationInterval(di1)
        XCTAssert(union.startDuration == Duration(2,8), "should be 2,8")
        XCTAssert(union.stopDuration == Duration(6,8), "should be 6,8")
    }
    
    func testUnionWithDurationIntervals() {
        let di0 = DurationInterval(startDuration: Duration(2,8), stopDuration: Duration(5,8))
        let di1 = DurationInterval(startDuration: Duration(3,8), stopDuration: Duration(4,8))
        let di2 = DurationInterval(startDuration: Duration(4,8), stopDuration: Duration(9,8))
        let union = DurationInterval.unionWithDurationIntervals([di0, di1, di2])
        XCTAssert(union.startDuration == Duration(2,8), "start duration should be 2,8")
        XCTAssert(union.stopDuration == Duration(9,8), "stop duration should be 9,8")
    }
    
    func containsDuration() {
        let di = DurationInterval(startDuration: Duration(3,8), stopDuration: Duration(7,8))
        XCTAssert(!di.containsDuration(Duration(2,8)), "should not contain duration before")
        XCTAssert(di.containsDuration(Duration(3,8)), "should contain start duration")
        XCTAssert(di.containsDuration(Duration(4,8)), "should contain duration in the middle")
        XCTAssert(!di.containsDuration(Duration(7,8)), "should not contain stop duration")
        XCTAssert(!di.containsDuration(Duration(9,8)), "should not contain duration after")
    }
    
    func testRelationshipToDurationInterval() {
        var di0 = DurationIntervalZero
        var di1 = DurationIntervalZero
        XCTAssert(di0.relationshipToDurationInterval(di1) == .Equal, "DIZero should be ==")
        
        
        // takes place before
        di1 = DurationInterval(startDuration: Duration(1,8), stopDuration: Duration(2,8))
        XCTAssert(di0.relationshipToDurationInterval(di1) == .TakesPlaceBefore,
            "should take place before"
        )
        
        // takes place after
        XCTAssert(di1.relationshipToDurationInterval(di0) == .TakesPlaceAfter,
            "should take place after"
        )
        
        // meets
        di0 = DurationInterval(startDuration: Duration(3,8), stopDuration: Duration(6,8))
        di1 = DurationInterval(startDuration: Duration(6,8), stopDuration: Duration(9,8))
        XCTAssert(di0.relationshipToDurationInterval(di1) == .Meets, "should be meets")
        XCTAssert(di1.relationshipToDurationInterval(di0) == .Meets, "should be meets?")
        
        // overlaps
        di1 = DurationInterval(startDuration: Duration(4,8), stopDuration: Duration(8,8))
        XCTAssert(di0.relationshipToDurationInterval(di1) == .Overlaps, "should be overlaps")
        XCTAssert(di1.relationshipToDurationInterval(di0) == .Overlaps, "should be overlaps")
        
        // during
        di0 = DurationInterval(startDuration: Duration(5,8), stopDuration: Duration(6,8))
        XCTAssert(di0.relationshipToDurationInterval(di1) == .During, "should be during")
        
        // start
        di0 = DurationInterval(startDuration: Duration(4,8), stopDuration: Duration(7,8))
        XCTAssert(di0.relationshipToDurationInterval(di1) == .Starts, "should be starts")
    
        // finishes
        di0 = DurationInterval(startDuration: Duration(6,8), stopDuration: Duration(8,8))
        XCTAssert(di0.relationshipToDurationInterval(di1) == .Finishes, "should be finishes")
    }
    
    func testEquality() {
        let di0 = DurationInterval(startDuration: Duration(1,8), stopDuration: Duration(2,8))
        var di1 = DurationInterval(startDuration: Duration(1,8), stopDuration: Duration(2,8))
        XCTAssert(di0 == di1, "should be equal")
        
        di1 = DurationInterval(startDuration: Duration(3,8), stopDuration: Duration(5,8))
        XCTAssert(di0 != di1, "should not be equal")
    }
}