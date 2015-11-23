//
//  DNMScoreModelTests.swift
//  DNMModel
//
//  Created by James Bean on 11/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class DNMScoreModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        var scoreModel = DNMScoreModel()
        scoreModel.title = "best piece ever"
        print(scoreModel)
    }
    
    func testSetTitle() {
        var scoreModel = DNMScoreModel()
        scoreModel.title = "best piece ever"
        XCTAssert(scoreModel.title == "best piece ever", "not the best piece ever")
    }
    
    func testSetDurationNodes() {
        
    }
}
