//
//  BeatsTests.swift
//  DNMModel
//
//  Created by James Bean on 11/3/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest

class BeatsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let b = Beats(amount: 4)
        XCTAssert(b.amount == 4, "Beats amount set incorrectly")
    }
    
    func testDescription() {
        let b = Beats(amount: 5)
        XCTAssert(b.description == "5", "Description incorrect")
    }
    
    func testSetAmount() {
        var b = Beats(amount: 1)
        b.setAmount(5)
        XCTAssert(b.amount == 5, "Amount incorrect")
    }
    
    func testIsEqual() {
        let b1a = Beats(amount: 1)
        let b1b = Beats(amount: 1)
        let b2 = Beats(amount: 2)
        XCTAssert(b1a == b1b, "Not equal")
        XCTAssert(b1a != b2, "Equal")
    }
    
    func testComparison() {
        let b1a = Beats(amount: 1)
        let b1b = Beats(amount: 1)
        let b2 = Beats(amount: 2)
        XCTAssert(b1a <= b1b, "Not equal to or less than")
        XCTAssert(b1b <= b2, "Not equal to or less than")
        XCTAssert(b1a < b2, "Not less than")
        XCTAssert(b2 >= b1a, "Not greater than or equal")
        XCTAssert(b2 > b1a, "Not greater than")
    }
    
    func testAddition() {
        let b1 = Beats(amount: 1)
        let b2 = Beats(amount: 2)
        XCTAssert(b1 + b2 == Beats(amount: 3), "Not added correctly")
        
        var b3 = Beats(amount: 3)
        b3 += Beats(amount: 2)
        XCTAssert(b3.amount == 5, "Not added to itself correctly")
    }
    
    func testSubtraction() {
        let b2 = Beats(amount: 2)
        let b1 = Beats(amount: 1)
        XCTAssert(b2 - b1 == Beats(amount: 1), "Not subtracted correctly")
        
        var b3 = Beats(amount: 3)
        b3 -= Beats(amount: 1)
        XCTAssert(b3 == Beats(amount: 2), "Not subtracted from itself correctly")
    }
}
