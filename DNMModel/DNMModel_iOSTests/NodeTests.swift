//
//  NodeTests.swift
//  TreeTest
//
//  Created by James Bean on 2/17/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import UIKit
import XCTest
@testable import DNMModel

class NodeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddChild() {
        let rootNode: Node = Node()
        let childNode: Node = Node()
        rootNode.addChild(childNode)
        assert(rootNode.hasChild(childNode), "child node not added correctly to root")
    }
    
    func testRemoveChild() {
        let rootNode: Node = Node()
        assert(rootNode.children.count == 0, "root node has children")
        let childNode: Node = Node()
        rootNode.addChild(childNode)
        assert(rootNode.hasChild(childNode), "child node not added correctly to root")
        rootNode.removeChild(childNode)
        assert(rootNode.children.count == 0, "child node not removed correctly")
    }
    
    func testInsertChild() {
        let rootNode: Node = Node()
        assert(rootNode.children.count == 0, "root node has children")
        let child1: Node = Node()
        let child2: Node = Node()
        let child3: Node = Node()
        rootNode.addChild(child1)
        assert(rootNode.children.count == 1, "child1 not added correctly")
        rootNode.addChild(child3)
        assert(rootNode.children.count == 2, "child3 not added correctly")
        rootNode.insert(child2, atIndex: 1)
        assert(rootNode.children.count == 3, "child2 not inserted correctly")
        
        // check that parent ref is set correctly
        assert(child1.parent === rootNode, "child1.parent is not rootNode")
        assert(child2.parent === rootNode, "child1.parent is not rootNode")
        assert(child3.parent === rootNode, "child1.parent is not rootNode")
        
        // check that sibling refs are set correctly
        assert(child1.siblingRight === child2, "child1.siblingRight is not child2")
        assert(child2.siblingLeft === child1, "child2.siblingLeft is not child1")
        assert(child2.siblingRight === child3, "child2.siblingRight is not child3")
        assert(child3.siblingLeft === child2, "child3.siblingLeft is not child2")
    }
    
    func testSiblingRefsSetUponRemoval() {
        let rootNode: Node = Node()
        assert(rootNode.children.count == 0, "root node has children")
        let child1: Node = Node()
        let child2: Node = Node()
        let child3: Node = Node()
        rootNode.addChild(child1)
        rootNode.addChild(child2)
        rootNode.addChild(child3)
        
        // check that parent ref is set correctly
        assert(child1.parent === rootNode, "child1.parent is not rootNode")
        assert(child2.parent === rootNode, "child1.parent is not rootNode")
        assert(child3.parent === rootNode, "child1.parent is not rootNode")
        
        // check that sibling refs are set correctly
        assert(child1.siblingRight === child2, "child1.siblingRight is not child2")
        assert(child2.siblingLeft === child1, "child2.siblingLeft is not child1")
        assert(child2.siblingRight === child3, "child2.siblingRight is not child3")
        assert(child3.siblingLeft === child2, "child3.siblingLeft is not child2")
        
        rootNode.removeChild(child2)
        assert(rootNode.children.count == 2, "child2 not removed correctly")
        assert(child3.siblingLeft === child1, "child3.siblingLeft is not child1")
        assert(child1.siblingRight === child3, "child1.siblingRight is not child3")
        assert(child3.siblingRight == nil, "child3.siblngRight is not nil")
        
        rootNode.removeChild(child3)
        assert(child1.siblingRight == nil, "only child has right sibling; that ain't right")
    }
    
    func testGetIsLeaf() {
        let node: Node = Node()
        assert(node.isLeaf, "root node not leaf")
        assert(!node.isContainer, "root node is container")
    }
    
    func testGetIsContainer() {
        let containerNode: Node = Node()
        let child1: Node = Node()
        containerNode.addChild(child1)
        assert(containerNode.isContainer, "container node is not container")
        assert(!containerNode.isLeaf, "container node is leaf")
    }
    
    func testGetIsRoot() {
        let rootNode: Node = Node()
        let child: Node = Node()
        rootNode.addChild(child)
        assert(rootNode.isRoot, "isRoot not set correctly")
        assert(!child.isRoot, "isRoot not set correctly")
    }
    
    func testGetRoot() {
        let rootNode: Node = Node()
        let child: Node = Node()
        rootNode.addChild(child)
        assert(child.root === rootNode, "root node is not the root of child")
        let grandchild: Node = Node()
        child.addChild(grandchild)
        assert(grandchild.root === rootNode, "root node is not root of grandchild")
    }
    
    func testGetPathToRoot() {
        let rootNode: Node = Node()
        let child: Node = Node()
        rootNode.addChild(child)
        assert(child.root === rootNode, "root node is not the root of child")
        let grandchild: Node = Node()
        child.addChild(grandchild)
        assert(grandchild.root === rootNode, "root node is not root of grandchild")
        assert(grandchild.pathToRoot.count == 2, "pathToRoot incorrect")
        assert(child.pathToRoot.count == 1, "pathToRoot incorrect")
        assert(rootNode.pathToRoot.count == 0, "pathToRoot incorrect")
    }
    
    // to-do: get ancestor at distance
    
    func testGetDepth() {
        let rootNode: Node = Node()
        let child1: Node = Node()
        let grandchild1: Node = Node()
        let child2: Node = Node()
        let grandchild2: Node = Node()
        let greatgrandchild2: Node = Node()
        rootNode.addChild(child1)
        child1.addChild(grandchild1)
        rootNode.addChild(child2)
        child2.addChild(grandchild2)
        grandchild2.addChild(greatgrandchild2)
        assert(child1.depth == 1, "child1.depth not 1")
        assert(child2.depth == 1, "not 1")
        assert(grandchild1.depth == 2, "not 2")
        assert(greatgrandchild2.depth == 3, "not 3")
    }
    
    func testGetAncestorAtDistance() {
        // create all nodes
        let rootNode: Node = Node()
        let child1: Node = Node()
        let grandchild1: Node = Node()
        let child2: Node = Node()
        let grandchild2: Node = Node()
        let greatgrandchild2: Node = Node()
        
        // add nodes to appropriate parents
        rootNode.addChild(child1)
        child1.addChild(grandchild1)
        rootNode.addChild(child2)
        child2.addChild(grandchild2)
        grandchild2.addChild(greatgrandchild2)
        
        // check relationships
        assert(greatgrandchild2.getAncestorAtDistance(1) === grandchild2, "not grandchild 2")
        assert(greatgrandchild2.getAncestorAtDistance(2) === child2, "not child 2")
        assert(greatgrandchild2.getAncestorAtDistance(3) === rootNode, "not rootNode")
    }
    
    
    func testGetHeight() {
        // create all nodes
        let root: Node = Node() // height: 3
        let a1 = Node() // height: 0
        let a2 = Node() // height: 2
        let a2b1 = Node() // height: 0
        let a2b2 = Node() // height: 1
        let a2b2c1 = Node() // height: 0
        let a2b2c2 = Node() // height: 0
        let a3 = Node()
        
        // add nodes to appropriate parents
        root.addChild(a1)
        root.addChild(a2)
        root.addChild(a3)
        a2.addChild(a2b1)
        a2.addChild(a2b2)
        a2b2.addChild(a2b2c1)
        a2b2.addChild(a2b2c2)
        
        // check relationships
        assert(root.height == 3, "root.height not 3")
        assert(a1.height == 0, "a1.height not 0")
        assert(a2.height == 2, "a2.height not 2")
        assert(a3.height == 0, "a3.height not 0")
        assert(a2b1.height == 0, "a2b1.height not 0")
        assert(a2b2.height == 1, "a2b2.height not 1")
        assert(a2b2c1.height == 0, "a2b2c1.height not 0")
        assert(a2b2c2.height == 0, "a2b2c2.height not 0")
        
        // check height of tree
        assert(a1.heightOfTree == 3, "a1.heightOfTree not 3")
        assert(a2b2c2.heightOfTree == 3, "a2b2c2.heightOfTree not 3")
    }
    
    func testCopy() {
        // create all nodes
        let root: Node = Node() // height: 3
        let a1 = Node() // height: 0
        let a2 = Node() // height: 2
        let a2b1 = Node() // height: 0
        let a2b2 = Node() // height: 1
        let a2b2c1 = Node() // height: 0
        let a2b2c2 = Node() // height: 0
        let a3 = Node()
        
        // add nodes to appropriate parents
        root.addChild(a1)
        root.addChild(a2)
        root.addChild(a3)
        a2.addChild(a2b1)
        a2.addChild(a2b2)
        a2b2.addChild(a2b2c1)
        a2b2.addChild(a2b2c2)
    }
    
    func testLeafAndSiblingOperations() {
        let root: Node = Node()
        let a0 = Node()
        let a1 = Node()
        let a2 = Node()
        let a0a = Node()
        let a0b = Node()
        let a0b0 = Node()
        let a0b1 = Node()
        let a2a = Node()
        let a2b = Node()
        
        root.addChild(a0)
        root.addChild(a1)
        root.addChild(a2)
        a0.addChild(a0a)
        a0.addChild(a0b)
        a0b.addChild(a0b0)
        a0b.addChild(a0b1)
        a2.addChild(a2a)
        a2.addChild(a2b)
        
        // check children
        //assert(a1.siblingLeft! === a0, "sibling left not set correctly")
        //assert(a2.siblingLeft! === a1, "sibling left not set correctly")
        //assert(a0.siblingRight! === a1, "sibling right not set correctly")
        //assert(a1.siblingRight! === a2, "sibling right not set correctly")
        
        // check leaves
        //assert(a1.leafLeft! === a0b1, "leaf left not set correctly")
        //assert(a0b1.leafRight! === a1 , "leaf right not set correctly")
        //assert(a2a.leafLeft! === a1, "leaf left not set correctly")
        //assert(a1.leafRight! === a2a, "leaf right not set correctly")
        
        //assert(a0a.positionInTree! == .FirstInTree, "position in tree incorrect")
        //assert(a0a.positionInContainer! == .FirstInContainer, "position in container incorrect")
        
        //assert(a2a.positionInContainer! == .FirstInContainer, "position in container incorrect")
        //assert(a2a.positionInTree! == .MiddleInTree, "position in tree incorrect")
    }
    
    func testSingleLeaf() {
        let root = Node()
        let a0 = Node()
        root.addChild(a0)
        assert(a0.positionInTree! == .SingleInTree, "single in tree not correct")
        assert(a0.positionInContainer! == .SingleInContainer, "single in container not correct")
    }
    
    func testSingleInContainer() {
        let root = Node()
        let a0 = Node()
        let a0a = Node()
        let a0b = Node()
        a0.addChild(a0a)
        a0.addChild(a0b)
        let a1 = Node()
        let a2 = Node()
        let a2a = Node()
        let a2b = Node()
        a2.addChild(a2a)
        a2.addChild(a2b)
        root.addChild(a0)
        root.addChild(a1)
        root.addChild(a2)
        
        assert(a1.positionInTree! == .MiddleInTree, "middle in tree not correct")
        assert(a1.positionInContainer! == .SingleInContainer, "single in container not correct")
        
    }
}