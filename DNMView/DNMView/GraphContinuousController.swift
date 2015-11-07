//
//  GraphContinuousController.swift
//  denm_view
//
//  Created by James Bean on 10/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public class GraphContinuousController: Graph {
    
    private struct Edge {
        var x: CGFloat
        var spannerArguments: SpannerArguments
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
    
    public func startEdgeAtX(x: CGFloat, spannerArguments: SpannerArguments) {
        let edge = Edge(x: x, spannerArguments: spannerArguments)
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
                            spannerArguments: edge.spannerArguments
                        )
                        
                        /*
                        let graphEventEdge = GraphEventEdge(
                            point1: point1,
                            point2: point2,
                            hasDashes: edge.hasDashes
                        )
                        */
                        insertSublayer(graphEventEdge, atIndex: 0)
                    }
                }
            }
        }
    }
}
