//
//  BeatsTest.swift
//  Duration
//
//  Created by James Bean on 3/13/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class BeatsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBeats() {
        let beats: Beats = Beats(amount: 4)
        XCTAssert(beats.amount == 4, "beats amount not 4")
    }
    
    func testBeatsCompare() {
        var b1 = Beats(amount: 7)
        let b2 = Beats(amount: 7)
        XCTAssert(b1 == b2, "equiv subdivisions not equiv")
        XCTAssert(b1 <= b2, "equiv subdivision not less than or equal")
        b1.setAmount(6)
        XCTAssert(b1 <= b2, "lesser subdivision not less than or equal")
        XCTAssert(b1 < b2, "lesser subd not lesser")
        XCTAssert(b2 > b1, "greater subd not greater")
        XCTAssert(b1 != b2, "non equiv subd equiv")
    }
    
    func testBeatsAddSubtract() {
        let b1 = Beats(amount: 6)
        let b2 = Beats(amount: 7)
        let b3 = b1 + b2
        XCTAssert(b3.amount == 13, "b3.amount not 13")
        var b4 = b2 - b1
        XCTAssert(b4.amount == 1, "b4.amount not 1")
        b4 += Beats(amount: 2)
        print(b4.amount)
        XCTAssert(b4.amount == 3, "b4.amount not 3")
        b4 -= Beats(amount: 1)
        XCTAssert(b4.amount == 2, "b4.amount not 1")
    }
    
    func testBeatsMultiplyDivide() {
        let b1 = Beats(amount: 3)
        let b2 = b1 * 2
        XCTAssert(b2.amount == 6, "b2.amount not 6")
        var b3 = b2 / 3
        XCTAssert(b3.amount == 2, "b3.amount not 2")
        b3 *= 4
        XCTAssert(b3.amount == 8, "b3.amount not 8")
        b3 /= 2
        XCTAssert(b3.amount == 4, "b4.amount not 4")
    }
}