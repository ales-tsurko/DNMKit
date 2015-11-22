//
//  Node.swift
//  denm_model
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Node: Underlying tree structure for many objects in denm

TO-DO: removeChild(node) needs to get working again
-- --  siblingLeft / Right needs to be rewritten (get rid of too abstracted compass directions)
-- -- .Left, .Right instead

**/
public class Node {
    
    // MARK: String Representation
    
    /// Printed description of Node
    public var description: String { get { return getDescription() } }
    
    // MARK: Organization
    
    /// Parent Node
    public var parent: Node?
    
    /// Sibling Node to left
    public var siblingLeft: Node? { get { return getSiblingToDirection(.West) } }
    
    /// Sibling Node to Right
    public var siblingRight: Node? { get { return getSiblingToDirection(.East) } }
    
    /// Leaf Node to Left (may cross hierarchical levels)
    public var leafLeft: Node? { get { return getLeafToDirection(.West) } }
    
    /// Lead Node to Right (may cross hierarchical levels)
    public var leafRight: Node? { get { return getLeafToDirection(.East) } }
    
    /// Children Nodes
    public var children: [Node] = []
    
    /// All Leaf Nodes
    public var leaves: [Node] { get { return getLeaves() } }
    
    // MARK: Analyze Node
    
    /// If Node is a Leaf (has no children Nodes)
    public var isLeaf: Bool { get { return getIsLeaf() } }
    
    /// If Node is a Container (has children Nodes)
    public var isContainer: Bool { get { return getIsContainer() } }
    
    /// If Node is the Root of a Tree (has no parent Node)
    public var isRoot: Bool { get { return getIsRoot() } }
    
    /// The Root Node of Tree containing Node
    public var root: Node { get { return getRoot() } }
    
    /// Collection of Nodes, ascending until the Root Node of Tree containing Node
    public var pathToRoot: [Node] { get { return getPathToRoot() } }
    
    /// Height of Tree containing Node
    public var heightOfTree: Int { get { return getHeightOfTree() } }
    
    /// Height of Node in Tree (amount of levels before Leaf descendent)
    public var height: Int { get { return getHeight() } }
    
    /// Depth of Node in Tree (amount of levels from Root)
    public var depth: Int { get { return getDepth() } }
    
    public var positionInTree: NodePositionTree? { get { return getPositionInTree() } }
    
    
    public var positionInContainer: NodePositionContainer? {
        get { return getPositionInContainer() }
    }
    
    // DEPRECATED
    /*
    internal func getPositionInTree() -> NodePosition {
    if !isLeaf { return .Container }
    if leafLeft == nil && leafRight == nil { return .SingleInTree }
    
    if leafLeft == nil && siblingLeft == nil { return .FirstInTree }
    if leafLeft != nil && siblingLeft == nil { return .FirstInContainer }
    }
    */
    
    // MARK: Create a Node
    
    /**
    Create a Node
    
    - returns: Initialized Node object
    */
    public init() { }
    
    // MARK: Set Attributes of Node
    
    /**
    Set Parent Node of Node
    
    - parameter parent: parent Node
    
    - returns: Node object
    */
    public func setParent(parent: Node) -> Self {
        self.parent = parent
        return self
    }
    
    // MARK: Tree Operations
    
    /**
    Add child Node to Node
    
    - parameter node: child Node
    
    - returns: Node object
    */
    public func addChild(node: Node) -> Self {
        children.append(node)
        node.parent = self
        return self
    }
    
    /**
    Insert child Node at index of Children
    
    - parameter child: child Node
    - parameter index: index at which to add Node
    
    - returns: Node object
    */
    public func insert(child: Node, atIndex index: Int) -> Self {
        children.insert(child, atIndex: index)
        child.parent = self
        return self
    }
    
    
    /**
    Remove child Node residing at a given index
    
    - parameter node: child Node to remove
    */
    public func removeChild(node: Node) {
        guard !isLeaf && hasChild(node) else { return }
        if let index: Int? = children.indexOfObject(node) {
            children.removeAtIndex(index!)
        }
    }
    
    /**
    Deep copy of Node. A new Node is created with all attributes equivalant to original.
    When comparing a Node that has been copied from another,
    "===" will return false, while "==" will return true (NYI).
    
    - returns: Node object
    */
    public func copy() -> Self {
        // override in subclasses
        return self
    }
    
    // MARK: Get information about Node
    
    /**
    Check if Node has a specific Child
    
    - parameter node: potential child Node
    
    - returns: If Node has this child Node
    */
    public func hasChild(node: Node) -> Bool {
        for child in children { if child === node { return true } }
        return false
    }
    
    /**
    Get Node at a given distance above Node
    
    - parameter distance: distance above Node
    
    - returns: Ancestor Node, if it exists
    */
    public func getAncestorAtDistance(distance: Int) -> Node? {
        var node: Node = self
        var distance: Int = distance
        ascendToGetAncestorAtDistance(&node, distance: &distance)
        return node
    }
    
    /**
    Get child Node at index
    
    - parameter index: index at which Child resides
    
    - returns: child Node residing at index, if it exists
    */
    public func getChildAtIndex(index: Int) -> Node {
        assert(children.count >= index, "Index out of bounds")
        return children[index]
    }
    
    public func descendToCopy(inout node: Node) {
        // override in subclasses
    }
    
    private func getHeight() -> Int {
        if self.isLeaf { return 0 }
        else {
            var node: Node = self
            var height: Int = 0
            descendToGetHeight(&node, height: &height)
            return height
        }
    }
    
    private func descendToGetHeight(inout node: Node, inout height: Int) {
        if node.isLeaf { return }
        else {
            var heights: [Int] = []
            height++
            for child in node.children {
                var node: Node = child
                descendToGetHeight(&node, height: &height)
                heights.append(height)
            }
            height = heights.reduce(Int.min, combine: max)
        }
    }
    
    private func getHeightOfTree() -> Int {
        return root.height
    }
    
    private func getDepth() -> Int {
        var depth: Int = 0
        if parent != nil { ascendToGetDepth(parent!, depth: &depth) }
        return depth
    }
    
    private func ascendToGetDepth(node: Node, inout depth: Int) {
        depth++
        if node.parent == nil { return }
        else { ascendToGetDepth(node.parent!, depth: &depth) }
    }
    
    internal func getLeaves() -> [Node] {
        var leaves: [Node] = []
        descendToGetLeaves(self, leaves: &leaves)
        return leaves
    }
    
    private func descendToGetLeaves(node: Node, inout leaves: [Node]) {
        var l = leaves
        if node.isLeaf {
            l.append(node)
            leaves = l
        }
        else { for child in node.children {descendToGetLeaves(child, leaves: &leaves) } }
    }
    
    private func getRoot() -> Node {
        var node = self
        ascendToGetRoot(&node)
        return node
    }
    
    private func ascendToGetRoot(inout node: Node) {
        if node.parent != nil {
            node = node.parent!
            ascendToGetRoot(&node)
        }
    }
    
    private func getPathToRoot() -> [Node] {
        var pathToRoot: [Node] = []
        var node: Node = self
        ascendToGetPathToRoot(&node, pathToRoot: &pathToRoot)
        return pathToRoot
    }
    
    private func ascendToGetAncestorAtDistance(inout node: Node, inout distance: Int) {
        distance--
        if distance == 0 { node = node.parent! }
        else {
            if node.parent == nil { assertionFailure("no node at distance") }
            else {
                node = node.parent!
                ascendToGetAncestorAtDistance(&node, distance: &distance)
            }
        }
    }
    
    private func ascendToGetPathToRoot(inout node: Node, inout pathToRoot: [Node]) {
        if node.parent != nil {
            pathToRoot.append(node)
            node = node.parent!
            ascendToGetPathToRoot(&node, pathToRoot: &pathToRoot)
        }
    }
    
    
    internal func getSiblingToDirection(direction: Direction) -> Node? {
        if parent == nil { return nil }
        assert(direction == .West || direction == .East, "must be east / west")
        let index: Int? = parent!.children.indexOfObject(self)
        switch direction {
        case .West:
            if index == nil || index == 0 { return nil }
            if !parent!.children[index! - 1].isLeaf { return nil }
            return parent!.children[index! - 1]
        default:
            if index == nil || index == parent!.children.count - 1 { return nil }
            if !parent!.children[index! + 1].isLeaf { return nil }
            return parent!.children[index! + 1]
        }
    }
    
    internal func getLeafToDirection(direction: Direction) -> Node? {
        if parent == nil { return nil }
        assert(direction == .West || direction == .East, "must be east / west")
        let index: Int? = root.leaves.indexOfObject(self)
        switch direction {
        case .West:
            if index == nil || index == 0 { return nil }
            return root.leaves[index! - 1]
        default:
            if index == nil || index == root.leaves.count - 1 { return nil }
            return root.leaves[index! + 1]
        }
    }
    
    internal func getPositionInContainer() -> NodePositionContainer? {
        //if !isLeaf { return nil }
        if (
            (siblingLeft == nil || siblingLeft!.isContainer) &&
                (siblingRight == nil || siblingRight!.isContainer)
            ) { return .SingleInContainer }
        if (
            (siblingLeft == nil || siblingLeft!.isContainer) &&
                (siblingRight != nil && siblingRight!.isLeaf)
            ) { return .FirstInContainer }
        if (
            (siblingLeft != nil && siblingLeft!.isLeaf) &&
                (siblingRight == nil || siblingRight!.isContainer)
            ) { return .LastInContainer }
        else { return .MiddleInContainer }
        /*
        if siblingLeft == nil && siblingRight == nil { return .SingleInContainer }
        if siblingLeft == nil && siblingRight != nil { return .FirstInContainer }
        if siblingLeft != nil && siblingRight == nil { return .LastInContainer }
        else { return .MiddleInContainer }
        */
    }
    
    internal func getPositionInTree() -> NodePositionTree? {
        //if !isLeaf { return nil }
        if leafLeft == nil && leafRight == nil { return .SingleInTree }
        if leafLeft == nil && leafRight != nil { return .FirstInTree }
        if leafLeft != nil && leafRight == nil { return .LastInTree }
        else { return .MiddleInTree }
    }

    
    private func getIsLeaf() -> Bool {
        return children.count == 0
    }
    
    private func getIsContainer() -> Bool {
        return children.count > 0
    }
    
    private func getIsRoot() -> Bool {
        return parent == nil
    }
    
    public func getDescription() -> String {
        var description: String = "Node:"
        if children.count == 1 { description += "1 child" }
        else { description += "\(children.count) children" }
        return description
    }
}

/*
protocol Copyable {
    func copy() -> Node
}
*/