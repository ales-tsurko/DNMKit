//
//  PitchPolyphonyTests.swift
//  denm
//
//  Created by James Bean on 4/8/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class PitchPolyphonyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitWithNoPolyphonies() {
        let polyphony = PitchPolyphony()
        XCTAssert(polyphony.verticalities.count == 0, "somehow >0 verticalities")
    }
    
    func testInitWithSinglePolyphony() {
        let verticality = PitchVerticality(pitches: Pitch.random(4))
        let polyphony = PitchPolyphony(verticalities: [verticality])
        XCTAssert(polyphony.verticalities.count == 1, "verticality not added correctly")
    }
}