//
//  TokenTests.swift
//  DNMModel
//
//  Created by James Bean on 11/22/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class TokenTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTokenString() {
        let ts = TokenString(identifier: "testID", value: "testValue", startIndex: 4)
        XCTAssert(ts.identifier == "testID", "id incorrect")
        XCTAssert(ts.value == "testValue", "value incorrect")
        XCTAssert(ts.startIndex == 4, "start index incorrect")
        XCTAssert(ts.stopIndex == 12, "stop index incorrect")
        print("TokenString: \(ts)")
    }
    
    func testTokenInt() {
        let ti = TokenInt(identifier: "testID", value: 2, startIndex: 0, stopIndex: 1)
        XCTAssert(ti.identifier == "testID", "id incorrect")
        XCTAssert(ti.value == 2, "value incorrect")
        XCTAssert(ti.startIndex == 0, "start index incorrect")
        XCTAssert(ti.stopIndex == 1, "stop index incorrect")
        print("TokenInt: \(ti)")
    }
    
    func testTokenFloat() {
        let tf = TokenFloat(identifier: "testID", value: 60.25, startIndex: 3, stopIndex: 6)
        XCTAssert(tf.identifier == "testID", "id incorrect")
        XCTAssert(tf.value == 60.25, "value incorrect")
        XCTAssert(tf.startIndex == 3, "start index incorrect")
        XCTAssert(tf.stopIndex == 6, "stop index incorrect")
        print("TokenFloat: \(tf)")
    }
    
    func testTokenDuration() {
        let td = TokenDuration(identifier: "testID", value: (3,8), startIndex: 0, stopIndex: 2)
        XCTAssert(td.identifier == "testID", "id incorrect")
        XCTAssert(td.value == (3,8), "value incorrect")
        XCTAssert(td.startIndex == 0, "start index incorrect")
        XCTAssert(td.stopIndex == 2, "stop index incorrect")
        print("TokenDuration: \(td)")
    }
}
