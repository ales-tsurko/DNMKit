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
        XCTAssert((newDurNode.children[0] as! DurationNode).duration == child1.duration, "child dur not set correctly")
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