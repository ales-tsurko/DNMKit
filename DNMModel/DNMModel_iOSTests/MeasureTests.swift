//
//  MeasureTests.swift
//  DNMModel
//
//  Created by James Bean on 11/22/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import XCTest
@testable import DNMModel

class MeasureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let m0 = Measure()
        XCTAssert(m0.duration == DurationZero, "duration somehow not nothing")
        let _m = Measure(offsetDuration: Duration(2,8))
        XCTAssert(_m.offsetDuration == Duration(2,8), "offset duration set incorrectly")
        let m_ = Measure(duration: Duration(3,16))
        XCTAssert(m_.duration == Duration(3,16), "duration set incorrectly")
        let _m_ = Measure(duration: Duration(2,8), offsetDuration: Duration(3,16))
        XCTAssert(_m_.offsetDuration == Duration(3,16), "offset duration set incorrectly")
        XCTAssert(_m_.duration == Duration(2,8), "duration set incorrectly")
    }
    
    func testDurationSpan() {
        let m = Measure(duration: Duration(3,16), offsetDuration: Duration(2,8))
        XCTAssert(m.durationSpan.duration == Duration(3,16), "duration span duration wrong")
        XCTAssert(m.durationSpan.startDuration == Duration(2,8), "duration span start duration wrong")
        XCTAssert(m.durationSpan.stopDuration == Duration(7,16), "duration span stop duration wrong")
    }
    
    func testHasTimeSignature() {
        var m = Measure()
        m.setHasTimeSignature(true)
        XCTAssert(m.hasTimeSignature, "has time signature not set correctly")
    }
    
    func testEquality() {
        let m1 = Measure(duration: Duration(3,16), offsetDuration: Duration(2,8))
        let m2 = Measure(duration: Duration(6,32), offsetDuration: Duration(1,4))
        XCTAssert(m1 == m2, "measures not equiv")
    }
    
    func testRangeFromMeasures() {
        let maximumDuration = Duration(19, 16)
        var measures: [Measure] = []
        var accumDur: Duration = DurationZero
        for _ in 0..<8 {
            let measure = Measure(duration: Duration(4,8), offsetDuration: accumDur)
            measures.append(measure)
            accumDur += measure.duration
        }
        
        let range = Measure.rangeFromMeasures(measures, startingAtIndex: 0, constrainedByDuration: maximumDuration)
        XCTAssert(range != nil, "no range possible")
        XCTAssert(range!.count == 2, "range calculated incorrectly")
        
        // TODO: more robust tests
    }
    
    func testRangeFromMeasuresMeasureTooBig() {
        let maximumDuration = Duration(3,8)
        let measures = [ Measure(duration: Duration(4,8)) ]
        let range = Measure.rangeFromMeasures(measures, startingAtIndex: 0, constrainedByDuration: maximumDuration)
        XCTAssert(range == nil, "somehow not measure range not nil")
    }
}
