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

    func testAdditionHomogenous() {
        let d1 = Duration(1,8)
        let d2 = Duration(2,8)
        let d3 = Duration(3,8)
        XCTAssert(d1 + d2 == d3, "Durations do not add properly")
    }
}
