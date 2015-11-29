//
//  FrequencyTests.swift
//  DNMModel
//
//  Created by James Bean on 11/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class FrequencyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let f = Frequency(440)
        print(f)
    }
    
    func testQuantizeToResolution() {
        var f = Frequency(443.7356)
        f.quantizeToResolution(1)
        XCTAssert(f.value == 440, "should be quantized to res")
        
        // perhaps more involved testing
    }
    
    func testComparison() {
        let f0 = Frequency(440)
        let f1 = Frequency(100)
        let f2 = Frequency(100)
        XCTAssert(f0 != f1, "should be !=")
        XCTAssert(f0 > f1, "should be >")
        XCTAssert(f0 >= f1, "should be >=")
        XCTAssert(f1 < f0, "should be <")
        XCTAssert(f1 <= f0, "should be <=")
        XCTAssert(f1 == f2, "should be ==")
        XCTAssert(f1 <= f2, "should be <=")
        XCTAssert(f1 >= f2, "should be >=")
    }
    
    func testArithmetic() {
        let f0 = Frequency(440)
        let f1 = Frequency(100)
        XCTAssert(f0 + f1 == Frequency(540), "should be 540")
        XCTAssert(f0 - f1 == Frequency(340), "should be 340")
    }
}
