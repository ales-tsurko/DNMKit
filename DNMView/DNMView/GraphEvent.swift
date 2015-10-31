//
//  GraphEvent.swift
//  denm_view
//
//  Created by James Bean on 8/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

// consider protocol for Event
public class GraphEvent: CALayer, BuildPattern {
    
    public var graph: Graph?
    public var stem: Stem?
    public var isConnectedToStem: Bool = true // modify for
    
    public var next: GraphEvent? { get { return getNext() } }
    public var previous: GraphEvent? { get { return getPrevious() } }
    
    public var slurConnectionY: CGFloat?
    
    public var isRest: Bool = false
    
    public var articulations: [Articulation] = []
    public var labels: [Label] = []
    
    public static var articulationStackingOrder: [ArticulationType] = [
        .Staccato, .Accent, .Tenuto
    ]
    
    public var x: CGFloat = 0
    public var maxInfoY: CGFloat { get { return getMinInfoY() } }
    public var minInfoY: CGFloat { get { return getMaxInfoY() } }
    public var maxY: CGFloat { get { return getMaxY() } }
    public var minY: CGFloat { get { return getMinY() } }
    public var stemEndY: CGFloat { get { return getStemEndY() } }
    
    public var stemDirection: StemDirection = .Down
    
    // Scale of GraphEvent
    public var s: CGFloat = 1
    
    public init(x: CGFloat) {
        super.init()
        self.x = x
    }
    
    public init(x: CGFloat, stemDirection: StemDirection, stem: Stem? = nil) {
        super.init()
        self.x = x
        self.stemDirection = stemDirection
        self.stem = stem
    }
    
    public init(stemDirection: StemDirection) {
        super.init()
        self.stemDirection = stemDirection
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addLabel(label: Label) {
        labels.append(label)
        addSublayer(label)
        
        // HACK -- perhaps create LabelNode / LabelStratum
        label.position.y = stemDirection == .Down ? minY - 20 : maxY + 20
    }
    
    public func addArticulationWithType(type: ArticulationType) {
        
        // HACK: g
        if let articulation = Articulation.withType(type, x: 0, y: 0, g: 12) {
            addArticulation(articulation)
        }
    }
    
    public func addArticulation(articulation: Articulation) {
        articulations.append(articulation)
        addSublayer(articulation)
    }
    
    internal func moveArticulations() {
        sortArticulationsByType()
        let yRef: CGFloat = stemDirection == .Down ? maxInfoY : minInfoY
        let dir: CGFloat = stemDirection == .Down ? 1 : -1
        let ΔY: CGFloat = 7.5
        
        // set initial position
        var y = yRef + 1.618 * ΔY * dir
        
        //print("moveArticulations: initial_y: \(y)")
        
        // ISSUE WITH STEM UP -- Initial Y is too far above?
        
        // increment outwards
        for articulation in articulations {
            articulation.position.y = y
            articulation.position.x = 0.5 * frame.width
            y += ΔY * dir
        }
        slurConnectionY = y
    }
    
    public func showArticulations() {
        
        // adjust slurConnectionY
        
        for articulation in articulations {
            if !sublayers!.contains(articulation) {
                CATransaction.setDisableActions(true)
                addSublayer(articulation)
                CATransaction.setDisableActions(false)
            }
        }
    }
    
    public func hideArticulations() {

        // adjust slurConnectionY
        
        if let sublayers = sublayers {
            for sublayer in sublayers {
                if let articulation = sublayer as? Articulation {
                    CATransaction.setDisableActions(true)
                    articulation.removeFromSuperlayer()
                    CATransaction.setDisableActions(false)
                }
            }
        }
    }
    
    public func clear() {
        sublayers = [] // this is not a good way to do this
        // clear ledgerLines
    }
    
    public func build() {
        moveArticulations()
    }
    
    public func getMaxInfoY() -> CGFloat {
        return 0.5 * frame.height
    }
    
    public func getMinInfoY() -> CGFloat {
        return 0.5 * frame.height
    }
    
    internal func getMinY() -> CGFloat {
        return 0.5 * frame.height
    }
    
    internal func getMaxY() -> CGFloat {
        return 0.5 * frame.height
    }
    
    private func getStemEndY() -> CGFloat {
        switch stemDirection {
        case .Up: return minInfoY
        case .Down: return maxInfoY
        }
    }
    
    internal func sortArticulationsByType() {
        // sort as far as possible, then just tack everything else onto the end
        var articulations_sorted: [Articulation] = []
        for articulationType in GraphEvent.articulationStackingOrder {
            switch articulationType {
            case .Staccato:
                for articulation in articulations {
                    if articulation is ArticulationStaccato {
                        articulations_sorted.append(articulation)
                    }
                }
            case .Accent:
                for articulation in articulations {
                    if articulation is ArticulationAccent {
                        articulations_sorted.append(articulation)
                    }
                }
            case .Tenuto:
                for articulation in articulations {
                    if articulation is ArticulationTenuto {
                        articulations_sorted.append(articulation)
                    }
                }
            default: break
            }
        }
        let complement = articulations.filter { !articulations_sorted.contains($0) }
        articulations = articulations_sorted + complement
    }
    
    private func getPrevious() -> GraphEvent? {
        if graph == nil { return nil }
        if let index = graph!.events.indexOf(self) {
            if index > 0 { return graph!.events[index - 1] }
        }
        return nil
    }
    
    private func getNext() -> GraphEvent? {
        if graph == nil { return nil }
        if let index = graph!.events.indexOf(self) {
            if index < graph!.events.count - 1 { return graph!.events[index + 1] }
        }
        return nil
    }
}