//
//  SubdivisionTests.swift
//  DNMModel
//
//  Created by James Bean on 11/3/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest

class SubdivisionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDescription() {
        let sv = Subdivision(value: 4)
        XCTAssert(sv.description == "4", "Description wrong")
        
        let sl = Subdivision(level: 1)
        XCTAssert(sl.description == "8", "Description wrong")
    }
    
    func testSetLevel() {
        var s = Subdivision(value: 8)
        s.setLevel(2)
        XCTAssert(s.level == 2, "Level set wrong")
        XCTAssert(s.value == 16, "Value set wrong")
    }
    
    func testComparison() {
        let s1a = Subdivision(level: 1)
        let s1b = Subdivision(level: 1)
        let s2 = Subdivision(level: 2)
        
        XCTAssert(s1a == s1b, "Not equal")
        XCTAssert(s1a <= s1b, "Not less than or equal to")
        XCTAssert(s1a >= s1b, "Not greater than or equal to")
        XCTAssert(s2 > s1a, "Not greater than")
        XCTAssert(s2 >= s1b, "Not greater than or equal to")
        XCTAssert(s1b < s2, "Not less than")
        XCTAssert(s1a != s2, "Equal")
    }
    
    
}
