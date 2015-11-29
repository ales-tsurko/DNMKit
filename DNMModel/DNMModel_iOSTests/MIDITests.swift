//
//  MIDITests.swift
//  denm_0
//
//  Created by James Bean on 3/17/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class MIDITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        let m = MIDI(60.0)
        XCTAssert(m.value == 60.0, "value not set correclty")
        print(m)
        
        let m_res = MIDI(value: 60.3, resolution: 0.25)
        XCTAssert(m_res.value == 60.25, "value not set correctly")
    }
    
    func testQuantizeToResolution() {
        var m = MIDI(60.23)
        m.quantizeToResolution(0.25)
        XCTAssert(m.value == 60.25, "value not quantized to resolution correctly")
        
        var n = MIDI(60.27)
        n.quantizeToResolution(0.5)
        XCTAssert(n.value == 60.5, "value not quantized to resolution correctly")
    }
    
    func testComparison() {
        let m0 = MIDI(60)
        let m1 = MIDI(65)
        let m2 = MIDI(65)
        
        XCTAssert(m0 < m1, "should be <")
        XCTAssert(m0 <= m1, "should be <=")
        XCTAssert(m0 != m1, "should be !=")
        XCTAssert(m1 > m0, "should be >")
        XCTAssert(m1 >= m0, "should be >=")
        XCTAssert(m1 == m2, "should be ==")
        XCTAssert(m1 >= m2, "should be >=")
        XCTAssert(m1 <= m2, "should be <=")
    }
    
    func testArithmetic() {
        let m0 = MIDI(60)
        let m1 = MIDI(9.5)
        XCTAssert(m0 + m1 == MIDI(69.5), "should be 69.5")

        let m2 = MIDI(62.25)
        XCTAssert(m2 % Float(12.0) == MIDI(2.25), "should be 2.25")
    }
}