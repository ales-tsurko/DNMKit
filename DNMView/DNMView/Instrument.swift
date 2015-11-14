//
//  Instrument.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMUtility
import DNMModel

// container 0 -> n Graphs (Staffs for now)
public class Instrument: ViewNode {
    
    //public var uiView: InstrumentView?
    

    // phase out
    public var id: String = ""
    
    public var identifier: String = ""
    public var instrumentType: InstrumentType?
    
    public var graphOrder: [String] = []
    public var graphs: [Graph] = []
    public var graphByID: [String: Graph] = [:]
    
    // just add the primary graphs (wait on the supplementary graphs, for user selection)
    public var primaryGraphs: [Graph] = []
    public var supplementaryGraphs: [Graph] = []
    
    public var performer: Performer?
    
    // consider protocol or superclass : See Performer
    public var bracket: CAShapeLayer? // make subclass
    public var label: TextLayerConstrainedByHeight?
    
    public var minGraphsTop: CGFloat? { get { return getMinGraphsTop() } }
    public var maxGraphsBottom: CGFloat? { get { return getMaxGraphsBottom() } }
    
    // maybe just make this an initializer
    public class func withType(instrumentType: InstrumentType) -> Instrument? {
        if instrumentType.isInInstrumentFamily(Strings) {
            let instrument = InstrumentString()
            instrument.instrumentType = instrumentType
            return instrument
        }
        //else if instrumentType.isInInstrumentFamily(Woodwinds) {}
        //else if instrumentType.isInInstrumentFamily(Brass) {}

        let instrument = Instrument()
        instrument.instrumentType = instrumentType
        return instrument
    }
    
    public init(id: String) {
        super.init()
        self.id = id
        layoutAccumulation_vertical = .Top
    }
    
    public override init() {
        super.init()
        layoutAccumulation_vertical = .Top
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func addGraph(graph: Graph, isPrimary: Bool = true) {
        graphByID[graph.id] = graph
        graphs.append(graph)
        isPrimary ? primaryGraphs.append(graph) : supplementaryGraphs.append(graph)
        
        // view shit should be isolated for organizational shit?
        graph.pad_bottom = 5 // hack
        graph.instrument = self
        
        if primaryGraphs.containsObject(graph) { addNode(graph) }
    }
    
    // FIXME: re new Component structure
    public func createInstrumentEventWithComponent(component: Component,
        atX x: CGFloat, withStemDirection stemDirection: StemDirection
    ) -> InstrumentEvent?
    {
        
        switch component {
        case is ComponentPitch, is ComponentStringArtificialHarmonic:
            assert(graphByID["staff"] != nil, "can't find staff!")
            if let staff = graphByID["staff"] {
                let graphEvent = staff.startEventAtX(x, withStemDirection: stemDirection)
                let instrumentEvent = InstrumentEvent(x: x, stemDirection: stemDirection)
                instrumentEvent.instrument = self
                instrumentEvent.addGraphEvent(graphEvent)
                return instrumentEvent
            }
        case let graphNode as ComponentGraphNode:
            assert(graphByID["node"] != nil, "can't find node graph")
            if let graph = graphByID["node"] {
                let graphEvent = (graph as? GraphContinuousController)!.addNodeEventAtX(x,
                    withValue: graphNode.value, andStemDirection: stemDirection
                )
                let instrumentEvent = InstrumentEvent(x: x, stemDirection: stemDirection)
                instrumentEvent.instrument = self
                instrumentEvent.addGraphEvent(graphEvent)
                return instrumentEvent
            }
        case is ComponentGraphEdgeStart: break
        case is ComponentGraphEdgeStop: break
        case is ComponentWaveform: break

        // TODO: flesh out
        
            
        default: break
        }
        
        /*
        //let pID = component.pID, iID = component.iID
        switch component.property {
        case .Pitch, .StringArtificialHarmonic:
            
            assert(graphByID["staff"] != nil, "can't find staff!")
            
            if let staff = graphByID["staff"] {
                let graphEvent = staff.startEventAtX(x, withStemDirection: stemDirection)
                let instrumentEvent = InstrumentEvent(x: x, stemDirection: stemDirection)
                instrumentEvent.instrument = self
                instrumentEvent.addGraphEvent(graphEvent)
                return instrumentEvent
            }
            
        case .Node(let value):
            assert(graphByID["node"] != nil, "can't find node graph")
            if let graph = graphByID["node"] {
                let graphEvent = (graph as? GraphContinuousController)!.addNodeEventAtX(x,
                    withValue: value, andStemDirection: stemDirection
                )
                let instrumentEvent = InstrumentEvent(x: x, stemDirection: stemDirection)
                instrumentEvent.instrument = self
                instrumentEvent.addGraphEvent(graphEvent)
                return instrumentEvent
            }
            /*
            case .Wave:
            assert(graphByID["wave"] != nil, "can't find wave graph")
            if let graph = graphByID["wave"] {
            let graphEvent = (graph as? GraphWaveform)?.addSampleWaveformAtX(x,
            withDuration: Duration(2,8), andBeatWidth: 120
            ) // HACK
            return graphEvent
            }
            */
        default:
            break
        }
        */
        return nil
    }
    
    public func createGraphsWithComponent(component: Component, andG g: CGFloat) {
        if !component.isGraphBearing { return }
        
        switch component {
            
        case is ComponentPitch, is ComponentStringArtificialHarmonic:
            // create graph if necessary
            if graphByID["staff"] == nil {
                let staff = Staff(id: "staff", g: g)
                if let (clefType, transposition, _) = instrumentType?
                    .preferredClefsAndTransposition.first
                {
                    staff.id = "staff" // hack
                    staff.pad_bottom = g
                    staff.pad_top = g
                    staff.addClefWithType(clefType, withTransposition: transposition, atX: 15) // HACK
                    addGraph(staff)
                }
                else { fatalError("Can't find a proper clef and transposition") }
            }

        case is ComponentGraphNode:
            if graphByID["node"] == nil {
                let graph = GraphContinuousController(id: "node")
                graph.height = 25 // hack
                graph.pad_bottom = 5 // hack
                graph.pad_top = 5 // hack
                graph.addClefAtX(15) // hack
                addGraph(graph)
            }
        case is ComponentWaveform:
            if graphByID["wave"] == nil {
                let graph = GraphWaveform(id: "wave", height: 60, width: frame.width) // hack
                graph.addClefAtX(15) // hack
                addGraph(graph)
            }
            
        // TODO: flesh out
            
        default: break
        }
        
        /*
        // FOR NOW, JUST MAKING SINGLE GRAPH, LATER: MAKE MULTIPLE AS NECESSARY
        // ------------------------------------------------------------------------------------
        switch component.property {
        case .Pitch, .StringArtificialHarmonic:
            
            // CREATE GRAPH IF NECESSARY
            if graphByID["staff"] == nil {
                let staff = Staff(id: "staff", g: g)
                if let (clefType, transposition, _) = instrumentType?
                    .preferredClefsAndTransposition.first
                {
                    staff.id = "staff" // hack
                    staff.pad_bottom = g
                    staff.pad_top = g
                    staff.addClefWithType(clefType, withTransposition: transposition, atX: 15) // HACK
                    addGraph(staff)
                }
                else { fatalError("Can't find a proper clef and transposition") }
            }
        case .Node:
            if graphByID["node"] == nil {
                let graph = GraphContinuousController(id: "node")
                graph.height = 25 // hack
                graph.pad_bottom = 5 // hack
                graph.pad_top = 5 // hack
                graph.addClefAtX(15) // hack
                addGraph(graph)
            }
        case .Wave:
            if graphByID["wave"] == nil {
                let graph = GraphWaveform(id: "wave", height: 60, width: frame.width) // hack
                graph.addClefAtX(15) // hack
                addGraph(graph)
            }
        default: break
        }
        // ------------------------------------------------------------------------------------
        */
    }
    
    // public funcs for handling events internally
    
    public override func layout() {
        super.layout()
        
        // encapsulate: updateBracket
        if bracket == nil {
            if bracket == nil {
                bracket = CAShapeLayer()
                addSublayer(bracket!)
            }
        }
        else {
            
            // this is inexcusable
            if let minGraphsTop = minGraphsTop, maxGraphsBottom = maxGraphsBottom {
                let path = UIBezierPath()
                path.moveToPoint(CGPointMake(7, minGraphsTop))
                path.addLineToPoint(CGPointMake(7, maxGraphsBottom))
                bracket!.path = path.CGPath
                bracket!.strokeColor = UIColor.grayscaleColorWithDepthOfField(
                    .MiddleBackground
                ).CGColor
                bracket!.lineWidth = 3
            }
        }
    }
    
    private func getMinGraphsTop() -> CGFloat? {
        var minY: CGFloat?
        for graph in graphs {
            if !hasNode(graph) { continue }
            let graphTop = convertY(graph.graphTop, fromLayer: graph)
            if minY == nil { minY = graphTop }
            else if graphTop < minY! { minY = graphTop }
        }
        return minY
    }
    
    private func getMaxGraphsBottom() -> CGFloat? {
        var maxY: CGFloat?
        for graph in graphs {
            if !hasNode(graph) { continue }
            let graphBottom = convertY(graph.graphBottom, fromLayer: graph)
            if maxY == nil { maxY = graphBottom }
            else if graphBottom > maxY! { maxY = graphBottom }
        }
        return maxY
    }
}