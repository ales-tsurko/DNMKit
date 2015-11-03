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
    
    func testEqualityHeterogeneous() {
        let d1 = Duration(1,8)
        let d2 = Duration(2,8)
        XCTAssert(d1 != d2, "Durations are not equated properly")
    }
    
    func testAdditionHeterogeneous() {
        let d1 = Duration(1,8)
        let d2 = Duration(2,16)
        let d3 = Duration(2,8)
        XCTAssert(d1 + d2 == d3, "Durations do not add properly")
    }
}
