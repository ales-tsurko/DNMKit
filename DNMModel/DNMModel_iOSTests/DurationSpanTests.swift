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
}
