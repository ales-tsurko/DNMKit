//
//  TokenContainerTests.swift
//  DNMModel
//
//  Created by James Bean on 11/22/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class TokenContainerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let tc = TokenContainer(identifier: "testContainer", openingValue: "t", startIndex: 9)
        XCTAssert(tc.identifier == "testContainer", "id incorrect")
        XCTAssert(tc.openingValue == "t", "opening val incorrect")
        XCTAssert(tc.startIndex == 9, "start index incorrect")
        XCTAssert(tc.stopIndex == 9, "stop index incorrect")
    }
    
    func testDescription() {
        let tc = TokenContainer(identifier: "container", openingValue: "C", startIndex: 0)
        XCTAssert(tc.description == "container: C; from 0 to 0", "description wrong")
    }
    
    func testAddToken() {
        let tc = TokenContainer(identifier: "testContainer", openingValue: "t", startIndex: 0)
        let childToken = TokenString(identifier: "token", value: "tttt", startIndex: 2)
        tc.addToken(childToken)
        XCTAssert(tc.tokens.count == 1, "child token not added correctly")
        
        let childTokenContainer = TokenContainer(
            identifier: "cont", openingValue: "cccc", startIndex: 4
        )
        tc.addToken(childTokenContainer)
        XCTAssert(tc.tokens.count == 2, "child token container not added correctly")
    }
}
