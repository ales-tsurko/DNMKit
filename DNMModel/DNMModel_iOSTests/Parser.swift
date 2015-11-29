//
//  Parser.swift
//  DNMModel
//
//  Created by James Bean on 11/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class Parser: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformerDeclaration() {
        let string = "P: VN vn Violin"
        let t = Tokenizer()
        let tc = t.tokenizeString(string)
        let p = DNMModel.Parser() // hmmm
        let scoreModel = p.parseTokenContainer(tc)
        XCTAssert(scoreModel.instrumentIDsAndInstrumentTypesByPerformerID.count == 1, "should have one perf decl")
    }
    
    
}
