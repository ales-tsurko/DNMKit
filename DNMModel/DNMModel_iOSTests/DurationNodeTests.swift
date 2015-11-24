//
//  DurationNodeTests.swift
//  denm_2
//
//  Created by James Bean on 3/21/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class DurationNodeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testInit() {
        var durNode: DurationNode = DurationNode(duration: Duration(5,16))
        XCTAssert(durNode.duration == Duration(5,16))
    }
    
    func testDurationSpan() {
        let dn = DurationNode(duration: (9,16), offsetDuration: (2,8), sequence: [])
        let ds = DurationSpan(duration: Duration(9,16), startDuration: Duration(2,8))
        XCTAssert(dn.durationSpan == ds, "duration span wrong")
    }
    
    func testSetDuration() {
        let dn = DurationNode(duration: Duration(3,16))
        dn.setDuration(Duration(9,8))
        XCTAssert(dn.duration == Duration(9,8), "duration not set correctly")
    }
    
    func testClearComponents() {
        let dn = DurationNode(duration: Duration(3,16))
        dn.addComponent(ComponentExtensionStart(performerID: "", instrumentID: ""))
        dn.addComponent(ComponentExtensionStop(performerID: "", instrumentID: ""))
        dn.addComponent(ComponentPitch(performerID: "", instrumentID: "", values: [60]))
        XCTAssert(dn.components.count > 0, "should have components in there")
        dn.clearComponents()
        XCTAssert(dn.components.count == 0, "should have no components")
        XCTAssert(dn.instrumentIDsByPerformerID.count == 0, "all iids and pids should be cleared")
    }
    
    func testHasOnlyExtensionComponents() {
        let dn = DurationNode(duration: Duration(3,16))
        
        // add extension start
        dn.addComponent(ComponentExtensionStart(performerID: "", instrumentID: ""))
        XCTAssert(dn.hasOnlyExtensionComponents, "should only have one extension component")
        
        XCTAssert(dn.hasExtensionStart, "should have extension start")
        XCTAssert(!dn.hasExtensionStop, "should not have extension start")
        
        // add extension stop
        dn.addComponent(ComponentExtensionStop(performerID: "", instrumentID: ""))
        XCTAssert(dn.hasOnlyExtensionComponents, "should have two extension components")
        
        XCTAssert(dn.hasExtensionStart, "should have extension start")
        XCTAssert(dn.hasExtensionStop, "should have extension start")
        
        // add pitch
        dn.addComponent(ComponentPitch(performerID: "", instrumentID: "", values: [60]))
        XCTAssert(!dn.hasOnlyExtensionComponents, "should not have only extension components")
    }
    
    func testInstrumentIDsByPerformerID() {
        let root = DurationNode(duration: Duration(3,16))
        
        let c1 = DurationNode(duration: Duration(1,16))
        c1.addComponent(ComponentPitch(performerID: "VN", instrumentID: "vn", values: [60]))
        c1.addComponent(ComponentPitch(performerID: "VN", instrumentID: "vx", values: [60.25]))
        root.addChild(c1)
        
        let c2 = DurationNode(duration: Duration(1,16))
        c2.addComponent(ComponentPitch(performerID: "VC", instrumentID: "vc", values: [40]))
        root.addChild(c2)
        
        let c3 = DurationNode(duration: Duration(1,16))
        c3.addComponent(ComponentPitch(performerID: "VC", instrumentID: "vc", values: [60.5]))
        root.addChild(c3)
        
        XCTAssert(root.instrumentIDsByPerformerID == ["VN": ["vn","vx"], "VC": ["vc"]], "iids wrong")
    }
    
    func testSubdivisionOfChildren() {
        let root = DurationNode(duration: (1,8), sequence: [1,1,1])
        XCTAssert(root.subdivisionOfChildren != nil, "should not be nil")
        XCTAssert(root.subdivisionOfChildren! == Subdivision(value: 16), "subdivision wrong")
        
        // go deeper
    }
    
    func testIsSubdividable() {
        let root_s = DurationNode(duration: Duration(2,8), sequence: [1,1,1,1])
        XCTAssert(root_s.isSubdividable, "should be subdividable")
        
        let root_ns0 = DurationNode(duration: Duration(2,8), sequence: [1,1,1])
        XCTAssert(!root_ns0.isSubdividable, "should not be subdividable")
        
        let root_ns1 = DurationNode(duration: (3,8), sequence: [1,1,1,1])
        XCTAssert(!root_ns1.isSubdividable, "should not be subdividable")
    }
    
    // test class func
    func testRangeRangeFromDurationNodes() {
        let dn0 = DurationNode(duration: (3,8), offsetDuration: (0,8), sequence: [])
        let dn1 = DurationNode(duration: (2,8), offsetDuration: (3,8), sequence: [])
        let dn2 = DurationNode(duration: (4,8), offsetDuration: (5,8), sequence: [])
        let dns = [dn0, dn1, dn2]
        let maximumDuration = Duration(6,8)
        let range = DurationNode.rangeFromDurationNodes(dns,
            afterDuration: DurationZero, untilDuration: maximumDuration
        )
        XCTAssert(range.count == 2, "should have 2 dns in there")
        XCTAssert(range.containsObject(dn0), "should have dn0 in there")
        XCTAssert(range.containsObject(dn1), "should have dn1 in there")
        XCTAssert(!range.containsObject(dn2), "should not have dn2 in there")
    }
    
    func testCopy() {
        let durNode: DurationNode = DurationNode(duration: Duration(5,16))
        let child1 = DurationNode(duration: Duration(3,16))
        let child2 = DurationNode(duration: Duration(4,32))
        let child3 = DurationNode(duration: Duration(13,128))
        durNode.addChild(child1)
        durNode.addChild(child2)
        durNode.addChild(child3)
        
        // copy duration node
        let newDurNode: DurationNode = durNode.copy()
        XCTAssert(durNode.duration == newDurNode.duration, "dur not set correctly")
        XCTAssert((newDurNode.children[0] as! DurationNode).duration == child1.duration,
            "child dur not set correctly")
        XCTAssert(newDurNode.children[0] !== child1, "durNodes equiv")
        XCTAssert(newDurNode.children.count == 3, "all durNodes not added")
        XCTAssert(durNode !== newDurNode, "nodes are equiv")
    }
    
    /*
    func testGetRelativeDurationsOfChildren() {
        let durNode: DurationNode = DurationNode(duration: Duration(5,16))
        let child1 = DurationNode(duration: Duration(3,16))
        let child2 = DurationNode(duration: Duration(4,16))
        durNode.addChild(child1)
        durNode.addChild(child2)
        XCTAssert(durNode.children.count == 2, "children not added correctly")
        XCTAssert(durNode.relativeDurationsOfChildren! == [3,4], "rel durs incrorrect")
    }
    */
    
    func testLevelChildren() {
        let durNode: DurationNode = DurationNode(duration: Duration(5,16))
        let child1 = DurationNode(duration: Duration(3,16))
        let child2 = DurationNode(duration: Duration(4,32))
        let child3 = DurationNode(duration: Duration(13,128))
        durNode.addChild(child1)
        durNode.addChild(child2)
        durNode.addChild(child3)
        print("durNode before level: \(durNode)")
        XCTAssert(durNode.getMaximumSubdivisionOfChildren()! == Subdivision(value: 128), "getMaxSubdivision not called correctly")
        durNode.levelDurationsOfChildren()
        print("durNode after level: \(durNode)")
        
        durNode.levelDurationsOfChildren()
        print("durNode after second level: \(durNode)")
    }
    
    func testReduceChildren() {
        let durNode: DurationNode = DurationNode(duration: Duration(5,16))
        let child1 = DurationNode(duration: Duration(3,16))
        let child2 = DurationNode(duration: Duration(4,32))
        let child3 = DurationNode(duration: Duration(13,128))
        durNode.addChild(child1)
        durNode.addChild(child2)
        durNode.addChild(child3)
        print("durNode before reduce: \(durNode)")
        durNode.reduceDurationsOfChildren()
        print("durNode after reduce: \(durNode)")
        XCTAssert(child1.duration.subdivision!.value == 128, "subdivision incorrect")
        XCTAssert(child2.duration.beats!.amount == 16, "beats incorrect")
        durNode.reduceDurationsOfChildren()
        print("durNode after second reduce: \(durNode)")
    }
    
    func testMatchDurationsOfChildren() {
        let durNode: DurationNode = DurationNode(duration: Duration(5,16))
        let child1 = DurationNode(duration: Duration(3,16))
        let child2 = DurationNode(duration: Duration(4,32))
        let child3 = DurationNode(duration: Duration(13,128))
        durNode.addChild(child1)
        durNode.addChild(child2)
        durNode.addChild(child3)
        print("durNode before matchDurationsOfChildren: \(durNode)")
        durNode.matchDurationsOfChildren()
        print("durNode after matchDurationsOfChildren: \(durNode)")
        XCTAssert(child1.duration.subdivision!.value == 128, "subdivision incorrect")
        XCTAssert(child2.duration.beats!.amount == 16, "beats incorrect")
    }
    
    func testGetMaximumSubdivisionOfSequence() {
        let dn0 = DurationNode(duration: Duration(1,32))
        let dn1 = DurationNode(duration: Duration(1,8))
        let dn2 = DurationNode(duration: Duration(1,64))
        let sequence: [DurationNode] = [dn0, dn1, dn2]
        let maxSubd = DurationNode.getMaximumSubdivisionOfSequence(sequence)
        XCTAssert(maxSubd! == Subdivision(value: 64), "not correct max subdivision")
    }
    
    func testGetMinimumSubdivisionOfSequence() {
        let dn0 = DurationNode(duration: Duration(1,32))
        let dn1 = DurationNode(duration: Duration(1,8))
        let dn2 = DurationNode(duration: Duration(1,64))
        let sequence: [DurationNode] = [dn0, dn1, dn2]
        let minSubd = DurationNode.getMinimumSubdivisionOfSequence(sequence)
        XCTAssert(minSubd! == Subdivision(value: 8), "not correct min subdivision")
    }
    
    func testGetRelativeDurationsOfSequence() {
        let dn0 = DurationNode(duration: Duration(1,32))
        let dn1 = DurationNode(duration: Duration(1,8))
        let dn2 = DurationNode(duration: Duration(1,64))
        let sequence: [DurationNode] = [dn0, dn1, dn2]
        let relDurs = DurationNode.getRelativeDurationsOfSequence(sequence)
        print("sequence before relDur get: \(sequence)")
        XCTAssert(relDurs == [2,8,1], "relative durations incorrect")
        print("sequence after relDur get: \(sequence)")
    }
    
    func testGetRelativeDurationsOfChildren() {
        
        /*
        let dn = DurationNode(duration: Duration(4,32))
        let dn0 = DurationNode(duration: Duration(1,32))
        let dn1 = DurationNode(duration: Duration(1,8))
        let dn2 = DurationNode(duration: Duration(1,64))
        dn.addChild(dn0)
        dn.addChild(dn1)
        dn.addChild(dn2)
        let relDurs = dn.relativeDurationsOfChildren!
        XCTAssert(relDurs == [2,8,1], "relative durations incorrect")
        */
    }
    
    func testAllSubdivisionsOfSequenceAreEquivalent() {
        let dn0 = DurationNode(duration: Duration(1,32))
        let dn1 = DurationNode(duration: Duration(1,8))
        let dn2 = DurationNode(duration: Duration(1,64))
        let sequence: [DurationNode] = [dn0, dn1, dn2]
        let areEquiv = DurationNode.allSubdivisionsOfSequenceAreEquivalent(sequence)
        XCTAssert(areEquiv == false, "subd equiv incorrect")
        
        let dn3 = DurationNode(duration: Duration(1,32))
        let dn4 = DurationNode(duration: Duration(1,32))
        let dn5 = DurationNode(duration: Duration(1,32))
        let sequence2: [DurationNode] = [dn3, dn4, dn5]
        let areEquiv2 = DurationNode.allSubdivisionsOfSequenceAreEquivalent(sequence2)
        XCTAssert(areEquiv2 == true, "subd equiv incorrect")
    }
    
    
    // perhaps split up into multiple tests:
    // -- match durations equiv subd
    // -- match durations > subd
    // -- match durations < subd
    
    // are the correct subdivision values getting set?
    
    func testMatchDurationToChildren_nodeUpToChildren() {
        let durNode = DurationNode(duration: Duration(5,32))
        let child1 = DurationNode(duration: Duration(4,32))
        let child2 = DurationNode(duration: Duration(2,32))
        let child3 = DurationNode(duration: Duration(3,32))
        durNode.addChild(child1)
        durNode.addChild(child2)
        durNode.addChild(child3)
        print("durNode before matchDurationsToChildren: \(durNode)")
        durNode.matchDurationToChildren()
        print("durNode after matchDurationsToChildren: \(durNode)")
    }
    
    
    func testMatchDurationToChildren_childrenUpToNode() {
        let durNode: DurationNode = DurationNode(duration: Duration(13,16))
        let child1 = DurationNode(duration: Duration(4,32))
        let child2 = DurationNode(duration: Duration(2,8))
        let child3 = DurationNode(duration: Duration(4,16))
        durNode.addChild(child1)
        durNode.addChild(child2)
        durNode.addChild(child3)
        
        print("durNode before matchDurationsToChildren: \(durNode)")
        
        durNode.matchDurationToChildren()
        
        print("durNode after matchDurationsToChildren: \(durNode)")
    }
    
    func testEmbeddedDurationNodeOperations() {
        
        /*
        let dn = DurationNode(
            duration: (13,16),
            sequence: [2,[4,[8,1,1,2,[1,[1,2,1,1]]]]]
        )
        println(dn)
        println(dn.relativeDurationsOfChildren!)
        */
    }
    
    func testAddChildrenWithSequence() {
        let singleDepth = DurationNode(duration: Duration(5,16))
        singleDepth.addChildrenWithSequence([4,2,1])
        print("durNode with seq: \(singleDepth)")
        
        let doubleDepth = DurationNode(duration: Duration(5,16))
        doubleDepth.addChildrenWithSequence([[4,[3,4,2]],2,1])
        print("double depth: \(doubleDepth)")
        
        let tripleDepth = DurationNode(duration: Duration(5,16))
        tripleDepth.addChildrenWithSequence([[4,[2,[3,[3,1,3]]]],2,1])
        print("triple depth: \(tripleDepth)")
    }

    func testScaleDurationsOfChildren() {
        let durNode = DurationNode(duration: (5,16), sequence: [[4,[2,2,[3,[2,3]],2]],2,1])
        print("durNode: \(durNode)")
    }
    
    func testAdjacentSubdivisionLevels() {
        let durationNode = DurationNode(
            duration: Duration(5,16),
            sequence: [3,[2,[1,1,2,1]],[2,[1,2]]]
        )
        print("durationNode: \(durationNode)")
        
        for leaf in durationNode.leaves as! [DurationNode] {
            print(leaf)
            let cur = leaf.duration.subdivisionLevel!
            print("cur: \(cur)")
            if leaf.leafLeft != nil {
                let prev = (leaf.leafLeft! as! DurationNode).duration.subdivisionLevel!
                print("prev: \(prev)")
            }
            if leaf.leafRight != nil {
                let next = (leaf.leafRight! as! DurationNode).duration.subdivisionLevel!
                print("next: \(next)")
            }
        }
    }
    
    func testRest() {
        let durationNode = DurationNode(duration: Duration(3,16))
        XCTAssert(durationNode.isRest, "durationNode with no components should be a rest")
        let restComponent = ComponentRest(performerID: "", instrumentID: "")
        durationNode.addComponent(restComponent)
        XCTAssert(durationNode.isRest, "durationNode with only rest components should be a rest")
        print("durationNode: \(durationNode)")
    }
}