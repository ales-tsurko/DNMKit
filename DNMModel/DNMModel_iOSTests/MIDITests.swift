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
        assert(m.value == 60.0, "value not set correclty")
    }
    
    func testQuantizeToResolution() {
        var m = MIDI(60.23)
        m.quantizeToResolution(0.25)
        assert(m.value == 60.25, "value not quantized to resolution correctly")
        
        var n = MIDI(60.27)
        n.quantizeToResolution(0.5)
        assert(n.value == 60.5, "value not quantized to resolution correctly")
    }
}