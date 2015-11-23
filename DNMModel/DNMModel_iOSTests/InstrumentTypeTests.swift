//
//  InstrumentTypeTests.swift
//  DNMModel
//
//  Created by James Bean on 11/22/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class InstrumentTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testFamilyContainsInstrument() {
        let strings: [InstrumentType] = [.Violin, .Viola, .Violoncello, .Guitar]
        
        for string in strings {
            XCTAssert(Strings.containsInstrumentType(string.self), "strings doesn't contain \(string)")
        }
        
        let flutes: [InstrumentType] = [.Flute_Piccolo, .Flute_C, .Flute_Alto, .Flute_Bass, .Flute_Contrabass]
        
        for flute in flutes {
            
            // make sure flutes contain each flute
            XCTAssert(Flute.containsInstrumentType(flute.self), "flute doesn't contain \(flute)")
            
            // and woodwinds also contains each flute
            XCTAssert(Woodwinds.containsInstrumentType(flute.self), "woodwinds doesn't contain \(flute)")
        }
        
        let clarinets: [InstrumentType] = [.Clarinet_Bflat, .Clarinet_A, .Clarinet_Bass, .Clarinet_Contrabass]
        
        for clarinet in clarinets {
            
            XCTAssert(Clarinet.containsInstrumentType(clarinet.self), "clarinet doesn't contain: \(clarinet)")
            XCTAssert(Woodwinds.containsInstrumentType(clarinet.self), "woodwinds doesn't contain: \(clarinet)")
        }
    }
    
    // TODO: testPreferredClefsAndTransposition
}
