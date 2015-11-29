//
//  ComponentTests.swift
//  DNMModel
//
//  Created by James Bean on 11/22/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class ComponentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let rest = ComponentRest(performerID: "p", instrumentID: "i")
        XCTAssert(rest.isGraphBearing == true, "rest not graph bearing")
        XCTAssert(rest.performerID == "p", "pid not set")
        XCTAssert(rest.instrumentID == "i", "iid not set")
        
        let pitchSingleValue = ComponentPitch(performerID: "p", instrumentID: "i", values: [60])
        XCTAssert(pitchSingleValue.identifier == "Pitch", "id not set")
        XCTAssert(pitchSingleValue.performerID == "p", "pid not set")
        XCTAssert(pitchSingleValue.instrumentID == "i", "iid not set")
        XCTAssert(pitchSingleValue.isGraphBearing == true, "not graph bearing")
        XCTAssert(pitchSingleValue.values == [60], "values not set")
        XCTAssert(pitchSingleValue.description == "Pitch: 60.0", "description wrong")
        
        let pitchMultipleValues = ComponentPitch(
            performerID: "p", instrumentID: "i", values: [60.25, 90.75]
        )
        
        XCTAssert(pitchMultipleValues.description == "Pitch: { 60.25, 90.75 }",
            "description wrong"
        )

        let dm = ComponentDynamicMarking(performerID: "p", instrumentID: "i", value: "offfmp")
        XCTAssert(dm.identifier == "DynamicMarking", "id wrong")
        XCTAssert(dm.performerID == "p", "pid wrong")
        XCTAssert(dm.instrumentID == "i", "iid wrong")
        XCTAssert(dm.description == "DynamicMarking: offfmp", "description wrong")
        
        let articulation = ComponentArticulation(
            performerID: "p", instrumentID: "i", values: [">", "-"]
        )
        XCTAssert(articulation.identifier == "Articulation", "id wrong")
        XCTAssert(articulation.performerID == "p", "pid wrong")
        XCTAssert(articulation.instrumentID == "i", "iid wrong")
        XCTAssert(articulation.description == "Articulation: { >, - }", "description wrong")
    }
}
