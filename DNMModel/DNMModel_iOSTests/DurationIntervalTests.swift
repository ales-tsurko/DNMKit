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
}