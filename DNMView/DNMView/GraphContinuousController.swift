//
//  GraphContinuousController.swift
//  denm_view
//
//  Created by James Bean on 10/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class GraphContinuousController: Graph {
    
    private struct Edge {
        var x: CGFloat
        var hasDashes: Bool
    }
    
    public var edges: [GraphEventEdge] = []
    public var startEdgesAtXValues: [CGFloat] = []
    

    
    // temporary array of structs with basic info, to be elaborated on: REPLACE with GraphEventEdgeHandlers
    private var _edges: [Edge] = []
    public var graphEventEdgeHandlers: [Int] = []
    
    public override init(id: String) {
        super.init(id: id)
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func startEdgeAtX(x: CGFloat, withDashes hasDashes: Bool = false) {
        //startEdgesAtXValues.append(x)

        let edge = Edge(x: x, hasDashes: hasDashes)
        _edges.append(edge)
    }
    
    // value = CGFloat between 0. and 1.
    public func addNodeEventAtX(x: CGFloat,
        withValue value: Float, andStemDirection stemDirection: StemDirection
    ) -> GraphEvent
    {
        let node = GraphEventNode(
            x: x,
            y: height * CGFloat(value),
            width: 8, // HACK
            stemDirection: stemDirection
        )
        events.append(node)
        node.graph = self
        return node
    }
    
    public override func build() {
        commitLines()
        setFrame()
        commitEvents()
        createEdges()
        hasBeenBuilt = true
    }
    
    private func commitEvents() {
        for event in events {
            event.build()
            addSublayer(event)
        }
    }
    
    private func createEdges() {
        for edge in _edges {
            if let node_start = getEventAtX(edge.x) as? GraphEventNode {
                if let index = events.indexOfObject(node_start) where index < events.count - 1 {
                    if let node_stop = events[index + 1] as? GraphEventNode {
                        let point1 = CGPoint(x: node_start.x, y: node_start.y)
                        let point2 = CGPoint(x: node_stop.x, y: node_stop.y)
                        let graphEventEdge = GraphEventEdge(
                            point1: point1,
                            point2: point2,
                            hasDashes: edge.hasDashes
                        )
                        insertSublayer(graphEventEdge, atIndex: 0)
                    }
                }
            }
        }
        
        
        
        /*
        for x in startEdgesAtXValues {
            if let node0 = getEventAtX(x) as? GraphEventNode {
                if let index = events.indexOf(node0) {
                    
                    // If not last, manage externally otherwise
                    if index < events.count - 1 {
                        if let node1 = events[index + 1] as? GraphEventNode {
                            let point1 = CGPoint(x: node0.x, y: node0.y)
                            let point2 = CGPoint(x: node1.x, y: node1.y)
                            let edge = GraphEventEdge(point1: point1, point2: point2)
                            insertSublayer(edge, atIndex: 0)
                        }
                    }
                }
            }
        }
        */

        /*
        for (e, event) in events.enumerate() {
            if e < events.count - 1 {
                let node0 = events[e] as! GraphEventNode
                let node1 = events[e + 1] as! GraphEventNode
                let point1 = CGPoint(x: node0.x, y: node0.y)
                let point2 = CGPoint(x: node1.x, y: node1.y)
                let edge = GraphEventEdge(point1: point1, point2: point2)
                insertSublayer(edge, atIndex: 0)
            }
        }
        */
    }
}
