//
//  TokenizerTests.swift
//  DNMModel
//
//  Created by James Bean on 11/22/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class TokenizerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let t = Tokenizer()
        print(t)
    }
    
    func tokenizePitch() {
        let string = "p 60.25"
        let t = Tokenizer()
        let tokenContainer = t.tokenizeString(string)
        
        // should have one token(container)
        XCTAssert(tokenContainer.tokens.count == 1, "tokens created incorrectly")
        
        // which is a pitch
        XCTAssert(tokenContainer.tokens.first!.identifier == "Pitch", "pitch token not created")
        
        // and is container itself
        XCTAssert(tokenContainer.tokens.first! is TokenContainer, "not token container")
        
        // and has a value
        let pitchContainer = tokenContainer.tokens.first as! TokenContainer
        XCTAssert(pitchContainer.tokens.first!.identifier == "Value", "value token not created")
        
        // ... of 60
        let pitchValueToken = pitchContainer.tokens.first as! TokenFloat
        XCTAssert(pitchValueToken.value == 60.25, "value not 60.25")
    }
    
    func tokenizerDynamicSingleValue() {
        let string = "d offfmp"
        let t = Tokenizer()
        let tokenContainer = t.tokenizeString(string)
        
        // should have one token(container)
        XCTAssert(tokenContainer.tokens.count == 1, "tokens created incorrectly")
        
        // which is a dynamic
        XCTAssert(tokenContainer.tokens.first!.identifier == "DynamicMarking", "dynamic marking token not created")
        
        // and is a container itself
        XCTAssert(tokenContainer.tokens.first! is TokenContainer, "not token container")
        
        // and has a value
        let dynamicMarkingContainer = tokenContainer.tokens.first as! TokenContainer
        XCTAssert(dynamicMarkingContainer.tokens.first!.identifier == "Value", "value token not created")
        
        // of offfpp
        let dmValueToken = dynamicMarkingContainer.tokens.first as! TokenString
        XCTAssert(dmValueToken.value == "offfmp", "dynamic marking not tokenized correctly")
    }
    
    func tokenizeArticulationSingleValue() {
        let string = "a - . >"
        let t = Tokenizer()
        let tokenContainer = t.tokenizeString(string)
        
        // should have one token(container)
        XCTAssert(tokenContainer.tokens.count == 1, "tokens created incorrectly")
        
        // which is a articulation
        XCTAssert(tokenContainer.tokens.first!.identifier == "Articulation", "articulation token not created")
        
        // and is a container itself
        XCTAssert(tokenContainer.tokens.first! is TokenContainer, "not token container")
        
        // and has three values tokens
        let articulationContainer = tokenContainer.tokens.first as! TokenContainer
        XCTAssert(articulationContainer.tokens.count == 3, "all three articulations not created")
        
        let tenutoToken = articulationContainer.tokens[0] as! TokenString
        let staccatoToken = articulationContainer.tokens[1] as! TokenString
        let accentToken = articulationContainer.tokens[2] as! TokenString
        
        XCTAssert(tenutoToken.identifier == "Value", "id incorrect")
        XCTAssert(tenutoToken.value == "-", "tenuto not set correctly")
        XCTAssert(staccatoToken.identifier == "Value", "id inccorect")
        XCTAssert(staccatoToken.value == ".", "staccato not set correctly")
        XCTAssert(accentToken.identifier == "Value", "id incorrect")
        XCTAssert(accentToken.value == ">", "accent not set correctly")
    }
    
    // TODO: check start / stop values
}
