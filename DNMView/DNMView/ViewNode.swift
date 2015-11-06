//
//  ViewNode.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMUtility

public class ViewNode: CALayer {
    
    public var layoutFlow_horizontal: LayoutDirectionHorizontal = .None
    public var layoutFlow_vertical: LayoutDirectionVertical = .None
    
    public var layoutAccumulation_horizontal: LayoutDirectionHorizontal = .None
    public var layoutAccumulation_vertical: LayoutDirectionVertical = .None
    
    public var pad_top: CGFloat = 0
    public var pad_bottom: CGFloat = 0
    public var pad_left: CGFloat = 0
    public var pad_right: CGFloat = 0
    
    public var left: CGFloat = 0
    public var top: CGFloat = 0
    
    public var isContainer: Bool { get { return getIsContainer() } }
    
    public var setsWidthWithContents: Bool = true
    public var setsHeightWithContents: Bool = true
    
    public var container: ViewNode? // settable
    public var previous: ViewNode? // settable
    public var next: ViewNode?
    
    public var nodes: [ViewNode] = []
    
    public var positionByNode: [ViewNode : CGPoint] = [:]
    
    
    public init(accumulateVerticallyFrom layoutAccumulation_vertical: LayoutDirectionVertical) {
        super.init()
        self.layoutAccumulation_vertical = layoutAccumulation_vertical
        self.drawsAsynchronously = true
    }
    
    public init(accumulateHorizontallyFrom layoutAccumulation_horizontal: LayoutDirectionHorizontal) {
        super.init()
        self.layoutAccumulation_horizontal = layoutAccumulation_horizontal
        self.drawsAsynchronously = true
    }
    
    public init(flowVerticallyFrom layoutFlow_vertical: LayoutDirectionVertical) {
        super.init()
        self.layoutFlow_vertical = layoutFlow_vertical
        self.drawsAsynchronously = true
    }
    
    public init(flowHorizontallyFrom layoutFlow_horizontal: LayoutDirectionHorizontal) {
        super.init()
        self.layoutFlow_horizontal = layoutFlow_horizontal
        self.drawsAsynchronously = true
    }
    
    public init(
        flowVerticallyFrom layoutFlow_vertical: LayoutDirectionVertical,
        flowHorizontallyFrom layoutFlow_horizontal: LayoutDirectionHorizontal
    )
    {
        super.init()
        self.layoutFlow_vertical = layoutFlow_vertical
        self.layoutFlow_horizontal = layoutFlow_horizontal
        self.drawsAsynchronously = true
    }
    
    public override init() {
        super.init()
        self.drawsAsynchronously = true
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    // UI
    public func tap() {
        //println("\(self): tap; container? \(container)")
    }
    
    // Layout
    
    public func layout() {

        CATransaction.setAnimationDuration(0.125)
        
        if layoutAccumulation_vertical != .None { accumulateVertically() }
        if layoutAccumulation_horizontal != .None { accumulateHorizontally() }
        if layoutFlow_vertical != .None { flowVertically() }
        if layoutFlow_horizontal != .None { flowHorizontally() }
        
        if setsHeightWithContents { setHeightWithContents() }
        if setsWidthWithContents { setWidthWithContents() }

        self.container?.layout()
    }
    
    internal func flowVertically() {
        
        //print("flowVertically: \(self)")
        
        if setsHeightWithContents { setHeightWithContents() }
        switch layoutFlow_vertical {
        case .Top:
            for node in nodes {
                node.moveVerticallyToY(0)

                // test
                if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
                positionByNode[node]!.y = 0.5 * node.frame.height
            }
        case .Bottom:
            for node in nodes {
                node.moveVerticallyToY(frame.height - node.frame.height)
                
                // test
                if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
                positionByNode[node]!.y = frame.height - 0.5 * node.frame.height
            }
        case .Middle:
            for node in nodes {
                node.position.y = 0.5 * frame.height
                
                //test
                if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
                positionByNode[node]!.y = 0.5 * frame.height
            }
        default:
            break
        }
    }
    
    internal func flowHorizontally() {
        
        //print("flow horizontally: \(self)")
        
        if setsWidthWithContents { setWidthWithContents() }
        switch layoutFlow_horizontal {
        case .Left:
            for node in nodes {
                node.moveHorizontallyToX(0)
                
                if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
                positionByNode[node]!.x = 0.5 * node.frame.width
            }
        case .Right:
            for node in nodes {
                node.moveHorizontallyToX(frame.width - node.frame.width)
                
                if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
                positionByNode[node]!.x = frame.width - 0.5 * node.frame.width
            }
        case .Center:
            for node in nodes {
                node.position.x = position.x
                
                if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
                positionByNode[node]!.x = position.x
            }
        default: break
        }
    }
    
    internal func accumulateVertically() {
        if !isContainer { return }
        var accumHeight: CGFloat = 0
        let final: Int = layoutAccumulation_vertical == .Top ? nodes.count - 1 : 0
        var n: Int = layoutAccumulation_vertical == .Top ? 0 : nodes.count - 1
        while true {
            let node = nodes[n]
            
            node.moveVerticallyToY(accumHeight)
            
            // test
            if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
            positionByNode[node]!.y = accumHeight + 0.5 * node.frame.height
            
            
            accumHeight += node.frame.height
            
            // add pad
            if n != final {
                accumHeight = layoutAccumulation_vertical == .Top
                    ? accumHeight + nodes[n].pad_bottom
                    : accumHeight + nodes[n-1].pad_top
            }
            
            // escape if last
            if n == final { break }
                
                // continue on to next
            else { n = layoutAccumulation_vertical == .Top ? n + 1 : n - 1 }
        }
    }
    
    internal func accumulateHorizontally() {
        if !isContainer { return }
        var accumWidth: CGFloat = 0
        let final: Int = layoutAccumulation_horizontal == .Left ? nodes.count - 1 : 0
        var n: Int = layoutAccumulation_horizontal == .Left ? 0 : nodes.count - 1
        while true {
            let node = nodes[n]
            node.moveHorizontallyToX(accumWidth)
            
            if positionByNode[node] == nil { positionByNode[node] = CGPointZero }
            positionByNode[node]!.x = accumWidth + 0.5 * node.frame.width
            
            
            accumWidth += node.frame.width
            if n != final { accumWidth += node.pad_right }
            if n == final { break }
            else { n = layoutAccumulation_horizontal == .Left ? n + 1 : n - 1 }
        }
    }
    
    public func addNode(node: ViewNode, andLayout shouldLayout: Bool = true) {
        if node.container != nil {
            // make better
            let point = convertPoint(
                CGPointMake(node.frame.minX, node.frame.minY), fromLayer: node.container!
            )
            node.moveHorizontallyToX(point.x, animated: false)
            
            // consider adding point to positionByNode?
            
            node.container!.removeNode(node, animated: false)
        }
        node.container = self
        nodes.append(node)
        if shouldLayout { layout() }
        addSublayer(node)
    }
    
    public func addNode(node: ViewNode, withDelay isDelayed: Bool) {
        if isDelayed {
            delay(0.15) { self.addNode(node) }
        }
        else {
            addNode(node)
        }
        
    }
    
    public func removeNode(node: ViewNode, animated: Bool) {
        if !animated { CATransaction.setDisableActions(true) }
        removeNode(node)
        if !animated { CATransaction.setDisableActions(false) }
    }
    
    public func removeNode(node: ViewNode, andLayout shouldLayout: Bool = true) {
        nodes.removeObject(node)
        node.removeFromSuperlayer(animated: false)
        node.container = nil
        if shouldLayout { layout() }
    }
    
    public func hasNode(node: ViewNode) -> Bool {
        let index: Int? = nodes.indexOf(node)
        return index == nil ? false : true
    }
    
    public func removeFromSuperlayer(animated animated: Bool) {
        if !animated { CATransaction.setDisableActions(true) }
        removeFromSuperlayer()
        if !animated { CATransaction.setDisableActions(false) }
    }
    
    public func addNodes(node: [ViewNode]) {
        
    }
    
    public func moveNode(node: ViewNode, toIndex index: Int) {
        // ?
    }
    
    public func insertNodes(nodes: [ViewNode], afterNode otherNode: ViewNode) {
        let index: Int? = self.nodes.indexOfObject(otherNode)
        if index == nil { return }
        for n in 0..<nodes.count {
            let node = nodes[n]
            node.container = self
            node.beginTime = 0.075 // eh
            self.nodes.insert(node, atIndex: index! + 1 + n)
        }
        layout()
        for node in nodes {
            CATransaction.setDisableActions(true)
            addSublayer(node)
            CATransaction.setDisableActions(false)
        }
    }
    
    public func insertNodes(nodes: [ViewNode], beforeNode otherNode: ViewNode) {
        
    }
    
    public func insertNodes(nodes: [ViewNode], atIndex index: Int) {
        for n in 0..<nodes.count {
            let node = nodes[n]
            node.container = self
            node.beginTime = 0.075
            self.nodes.insert(node, atIndex: index + n)
        }
        layout()

        for node in nodes {
            CATransaction.setDisableActions(true)
            addSublayer(node)
            CATransaction.setDisableActions(false)
        }
    }
    
    
    public func removeNodes(nodes: [ViewNode]) {
        
        for node in nodes {
            self.nodes.removeObject(node)
            node.container = nil
            CATransaction.setDisableActions(true)
            node.removeFromSuperlayer(animated: false)
            CATransaction.setDisableActions(false)
        }
        layout()
    }
    
    public func replaceNode(node: ViewNode, withNode newNode: ViewNode) {
        if let index = nodes.indexOfObject(node) {
            newNode.container = self
            removeNode(node, animated: false)
            insertNode(newNode, atIndex: index)
        }
        return
        
    }
    
    public func insertNode(node: ViewNode,
        beforeNode otherNode: ViewNode, andLayout shouldLayout: Bool = true
    )
    {
        // only use one, and use the other as a public interface
        
        let index: Int? = nodes.indexOfObject(otherNode)
        if index == nil { return }
        
        

        node.container = self
        if !hasNode(node) { nodes.insert(node, atIndex: index!) }
        if shouldLayout { layout() }
        CATransaction.setDisableActions(true)
        addSublayer(node)
        CATransaction.setDisableActions(false)
    }
    
    public func insertNode(node: ViewNode,
        afterNode otherNode: ViewNode, andLayout shouldLayout: Bool = true
    )
    {
        let index: Int? = nodes.indexOfObject(otherNode)
        if index == nil { return }
        
        /*
        if node.container != nil {
        let point = convertPoint(
        CGPointMake(node.frame.minX, node.frame.minY), fromLayer: node.container!
        )
        node.moveHorizontallyToX(point.x, animated: false)
        node.container!.removeNode(node, animated: false)
        }
        */
        

        node.container = self
        if !hasNode(node) { nodes.insert(node, atIndex: index! + 1) }
        if shouldLayout { layout() }
        CATransaction.setDisableActions(true)
        addSublayer(node)
        CATransaction.setDisableActions(false)
    }
    
    public func insertNode(
        node: ViewNode, atIndex index: Int, andLayout shouldLayout: Bool = true
    )
    {
        node.container = self

        if !hasNode(node) { nodes.insert(node, atIndex: index) }
        if shouldLayout { layout() }
        CATransaction.setDisableActions(true)
        addSublayer(node)
        CATransaction.setDisableActions(false)
    }
    
    public func clearNodes() {
        // this is dangerous: iterating over an array while mutating it. Reconsider
        for node in nodes { node.removeFromSuperlayer(animated: false) }
        nodes = []
    }
    
    public func moveBy(ΔX: CGFloat, ΔY: CGFloat, animated: Bool) {
        moveBy(ΔX: ΔX, ΔY: ΔY)
    }
    
    public func moveBy(ΔX ΔX: CGFloat, ΔY: CGFloat) {
        position.x += ΔX
        position.y += ΔY
    }
    
    public func moveHorizontallyByX(ΔX: CGFloat, animated: Bool) {
        //if !animated { CATransaction.setDisableActions(true) }
        CATransaction.setDisableActions(true)
        moveHorizontallyByX(ΔX)
        CATransaction.setDisableActions(false)
    }
    
    public func moveHorizontallyByX(ΔX: CGFloat) {
        //let newLeft = frame.minX + ΔX
        //frame = CGRectMake(newLeft, frame.minY, frame.width, frame.height)
        CATransaction.setDisableActions(true)
        position.x += ΔX
        CATransaction.setDisableActions(false)
    }
    
    public func moveVerticallyByY(ΔY: CGFloat, animated: Bool) {
        // if !animated { CATransaction.setDisableActions(true) }
        CATransaction.setDisableActions(true)
        moveVerticallyByY(ΔY)
        CATransaction.setDisableActions(false)
    }
    
    public func moveVerticallyByY(ΔY: CGFloat) {
        position.y += ΔY
    }
    
    public func moveHorizontallyToX(x: CGFloat, animated: Bool) {
        CATransaction.setDisableActions(true)
        moveHorizontallyToX(x)
        CATransaction.setDisableActions(false)
    }
    
    public func moveVerticallyToY(y: CGFloat, animated: Bool) {
        if !animated { CATransaction.setDisableActions(true) }
        moveVerticallyToY(y)
        if !animated { CATransaction.setDisableActions(false) }
    }
    
    public func moveVerticallyToY(y: CGFloat) {
        //print("moveVerticallyToY: \(y); \(self)")
        //CATransaction.setDisableActions(true)
        if superlayer == nil { CATransaction.setDisableActions(true) }
        position.y = y + 0.5 * frame.height
        if superlayer == nil { CATransaction.setDisableActions(false) }
        //CATransaction.setDisableActions(true)
        
        self.top = y
    }
    
    public func moveHorizontallyToX(x: CGFloat) {
        
        CATransaction.setDisableActions(true)
        //if superlayer == nil { CATransaction.setDisableActions(true) }
        frame = CGRectMake(x, frame.minY, frame.width, frame.height)
        //if superlayer == nil { CATransaction.setDisableActions(false) }
        CATransaction.setDisableActions(false)
        
        self.left = x
    }
    
    public func moveTo(x x: CGFloat, y: CGFloat, animated: Bool) {
        CATransaction.setDisableActions(true)
        moveTo(x: x, y: y)
        CATransaction.setDisableActions(false)
    }
    
    public func moveTo(x x: CGFloat, y: CGFloat) {
        CATransaction.setDisableActions(true)
        position.x = x + 0.5 * frame.width
        position.y = y + 0.5 * frame.height
        CATransaction.setDisableActions(false)
    }
    
    public func moveTo(point point: CGPoint, animated: Bool) {
        CATransaction.setDisableActions(true)
        moveTo(point: point)
        CATransaction.setDisableActions(false)
    }
    
    public func moveTo(point point: CGPoint) {
        CATransaction.setDisableActions(true)
        position.x = point.x + 0.5 * frame.width
        position.y = point.y + 0.5 * frame.width
        CATransaction.setDisableActions(false)
    }
    
    internal func setHeightWithContents() {
        if !isContainer { return }
        var minY: CGFloat?
        var maxY: CGFloat?
        for node in nodes {
            if minY == nil { minY = node.frame.minY }
            else if node.frame.minY < minY { minY = node.frame.minY }
            if maxY == nil { maxY = node.frame.maxY }
            else if node.frame.maxY > maxY { maxY = node.frame.maxY }
        }
        let height = maxY! - minY!
        CATransaction.setDisableActions(true)
        frame = CGRectMake(left, top, frame.width, height)
        CATransaction.setDisableActions(false)
    }
    
    internal func setWidthWithContents() {
        if !isContainer { return }
        var minX: CGFloat?
        var maxX: CGFloat?
        for node in nodes {
            if minX == nil { minX = node.frame.minX }
            else if node.frame.minX < minX { minX = node.frame.minX }
            if maxX == nil { maxX = node.frame.maxX }
            else if node.frame.maxX > maxX { maxX = node.frame.maxX }
        }
        var width = maxX! - minX!
        if layoutFlow_horizontal == .None && layoutAccumulation_horizontal == .None {
            width = maxX!
        }
        CATransaction.setDisableActions(true)
        frame = CGRectMake(left, top, width, frame.height)
        CATransaction.setDisableActions(false)
    }
    
    internal func getIsContainer() -> Bool {
        return nodes.count > 0
    }
}