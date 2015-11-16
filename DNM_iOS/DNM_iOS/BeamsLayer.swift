//
//  BeamsLayer.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class BeamsLayer: ViewNode {
    
    /// Graphical height of a single Guidonian staff space
    public var g: CGFloat = 0
    
    /// Scale of BeamsLayer
    public var scale: CGFloat = 1
    
    /// Start point of BeamsLayer
    public var start: CGPoint = CGPointZero
    
    /// Stop point of BeamsLayer
    public var stop: CGPoint = CGPointZero
    
    /// Color of Beams
    public var color: CGColor = UIColor.blackColor().CGColor {
        didSet { for beam in beams { beam.fillColor = color } }
    }
    
    /// StemDirection of BeamsLayer
    public var stemDirection: StemDirection = .Down {
        didSet {
            //clearBeams()
            //addBeams()
            //layout()
        }
    }
    
    /// BeamJunctions in BeamsLayer
    public var beamJunctions: [BeamJunction] = []
    
    public var augmentationDots: [AugmentationDot] = []
    
    /// All Beams in Beamslayer
    public var beams: [Beam] = []
    
    /// Width of Beams
    private var beamWidth: CGFloat { get { return 0.382 * g * scale } }
    
    /// Displacement of one beam to the next
    private var beamΔY: CGFloat { get { return 1.5 * beamWidth } } // static compared with scale :|
    
    /// Length of beamlet
    private var beamletLength: CGFloat { get { return 0.618 * g * scale } }
    
    /// Last Start Point X of Beam
    private var lastBeamStartXOnLevel: [Int : CGFloat] = [:]
    
    public var stemWidth: CGFloat { get { return 0.0618 * g * scale } }
    
    public var isMetrical: Bool = true
    
    public var beamsHaveBeenPlaced: Bool = false
    
    public init(g: CGFloat) {
        self.g = g
        super.init()
    }
    
    public init(g: CGFloat, scale: CGFloat) {
        self.g = g
        self.scale = scale
        super.init()
    }
    
    public init(
        g: CGFloat,
        scale: CGFloat,
        start: CGPoint,
        stop: CGPoint,
        stemDirection: StemDirection,
        isMetrical: Bool = true
        )
    {
        self.g = g
        self.scale = scale
        self.start = start
        self.stop = stop
        self.stemDirection = stemDirection
        self.isMetrical = isMetrical
        super.init()
        
        setsHeightWithContents = true
        setsWidthWithContents = true
    }
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func switchIsMetrical() {
        
        // this needs to be optimized!! unnecessary to re-add beams every time!
        // instead, save multiple beamsLayers:
        // -- beamsLayerMetrical
        // -- beamsLayerSingleLevel
        // -- beamsLayerNone...
        
        //CATransaction.setDisableActions(true)
        if isMetrical {
            isMetrical = false
            clearBeams()
        }
        else {
            isMetrical = true
            clearBeams()
        }
        addBeams()
        for beam in beams { beam.fillColor = color } // make cleaner!!
        layout()
        container?.layout()
        //CATransaction.setDisableActions(false)
    }
    
    internal override func setHeightWithContents() {
        var minY: CGFloat?
        var maxY: CGFloat?
        for beam in beams {
            let box = CGPathGetBoundingBox(beam.path)
            if minY == nil { minY = box.minY }
            else if box.minY < minY { minY = box.minY }
            if maxY == nil { maxY = box.maxY }
            else if box.maxY > maxY { maxY = box.maxY }
        }
        var height: CGFloat = 0
        if maxY != nil && minY != nil { height = maxY! - minY! }
        for beam in beams { beam.position.y -= minY! }
        frame = CGRectMake(left, top, frame.width, height)
    }
    
    internal override func setWidthWithContents() {
        var minX: CGFloat?
        var maxX: CGFloat?
        for beam in beams {
            let box = CGPathGetBoundingBox(beam.path)
            if minX == nil { minX = box.minX }
            else if box.minX < minX { minX = box.minX }
            if maxX == nil { maxX = box.maxX }
            else if box.maxX > maxX { maxX = box.maxX }
        }
        var width: CGFloat = 0
        if maxX != nil && minX != nil { width = maxX! - minX! }
        frame = CGRectMake(left, top, width, frame.height)
    }
    
    public func dent(amount amount: Int, beforeJunctionAtIndex index: Int) {
        assert(index > 0 && index < beamJunctions.count, "index out of range")
        assert(beamJunctions.count > 1, "must have 2 or more events to make a dent")
        
        clearBeams()
        
        let j_c = beamJunctions[index]
        let j_p = beamJunctions[index - 1]
        
        let c = j_c.currentSubdivisionLevel
        let p = j_c.previousSubdivisionLevel!
        
        let second = 1
        //let second_to_last = beamJunctions.count - 1
        let last = beamJunctions.count - 1
        
        // FIRST COMPARISON
        if index == second {
            
            if index < last {
                let n = j_c.nextSubdivisionLevel!
                if c == p {
                    if c <= n {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Start, forLevelRange: range)
                    }
                    else if c > n {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                        j_c.beamletDirection = .East
                    }
                }
                else if c > p {
                    if c == n {
                        let range: [Int] = [p - amount, p - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Start, forLevelRange: range)
                    }
                    else if c > n {
                        let range: [Int] = [p - amount, p - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                    }
                    else if c < n {
                        let range: [Int] = [p - amount, p - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Start, forLevelRange: range)
                    }
                }
                else if c < p {
                    if c == n {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Start, forLevelRange: range)
                    }
                    else if c > n {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                        j_c.beamletDirection = .East
                    }
                    else if c < n {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Start, forLevelRange: range)
                    }
                }
            }
            else {
                if c == p {
                    let range: [Int] = [c - amount, c - 1]
                    j_p.setComponent(.Beamlet, forLevelRange: range)
                    j_c.setComponent(.Beamlet, forLevelRange: range)
                }
                else if c > p {
                    let range: [Int] = [p - amount, p - 1]
                    j_p.setComponent(.Beamlet, forLevelRange: range)
                    j_c.setComponent(.Beamlet, forLevelRange: range)
                }
                else if c < p {
                    let range: [Int] = [c - amount, c - 1]
                    j_p.setComponent(.Beamlet, forLevelRange: range)
                    j_c.setComponent(.Beamlet, forLevelRange: range)
                }
            }
        }
            // LAST COMPARISON
        else if index == last {
            if index > second {
                let pp = j_p.previousSubdivisionLevel!
                if c == p {
                    if p == pp {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Stop, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                    }
                    else if p > pp {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                        j_p.beamletDirection = .West
                    }
                    else if p < pp {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Stop, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                    }
                }
                else if c > p {
                    if p == pp {
                        let range: [Int] = [p - amount, p - 1]
                        j_p.setComponent(.Stop, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                    }
                    else if p > pp {
                        let range: [Int] = [p - amount, p - 1]
                        j_p.setComponent(.Beamlet, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                        j_p.beamletDirection = .West
                    }
                    else if p < pp {
                        let range: [Int] = [p - amount, p - 1]
                        j_p.setComponent(.Stop, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                    }
                }
                else if c < p {
                    if p == pp {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Stop, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                        
                    }
                    else if p > pp {
                        let range: [Int] = [c - amount, c - 1]
                        j_p.setComponent(.Stop, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                        j_p.beamletDirection = .West
                    }
                    else if p < pp {
                        let range: [Int] = [p - amount, p - 1]
                        j_p.setComponent(.Stop, forLevelRange: range)
                        j_c.setComponent(.Beamlet, forLevelRange: range)
                    }
                }
            }
        }
            // MIDDLE
        else {
            if index > second && index < last {
                let pp = j_p.previousSubdivisionLevel!
                let n = j_c.nextSubdivisionLevel!
                if c == p {
                    if c == n {
                        if p == pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p > pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p < pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                    }
                    else if c > n {
                        if p == pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                            j_c.beamletDirection = .East
                        }
                        else if p > pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                            j_p.beamletDirection = .West
                        }
                        else if p < pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                            j_c.beamletDirection = .East
                        }
                    }
                    else if c < n {
                        if p == pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p > pp {
                            let range: [Int] = [c - amount, c - 1] // p?
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p < pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                    }
                }
                else if c > p {
                    if c == n {
                        if p == pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                        }
                        else if p > pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                        }
                        else if p < pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                        }
                    }
                    else if c > n {
                        if p == pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                        }
                        else if p > pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                            j_p.beamletDirection = .West
                            j_c.beamletDirection = .East
                        }
                        else if p < pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                        }
                    }
                    else if c < n {
                        if p == pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                            j_c.beamletDirection = .East
                        }
                        else if p > pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p < pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                    }
                }
                    
                else if c < p {
                    if c == n {
                        if p == pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p > pp {
                            //
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                            j_p.beamletDirection = .West
                        }
                        else if p < pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                    }
                    else if c > n {
                        if p == pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p > pp {
                            let range: [Int] = [p - amount, p - 1]
                            j_p.setComponent(.Beamlet, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                            j_p.beamletDirection = .West
                            j_c.beamletDirection = .East
                        }
                        else if p < pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Beamlet, forLevelRange: range)
                            j_c.beamletDirection = .East
                        }
                    }
                    else if c < n {
                        if p == pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                        else if p > pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                            j_p.beamletDirection = .West
                        }
                        else if p < pp {
                            let range: [Int] = [c - amount, c - 1]
                            j_p.setComponent(.Stop, forLevelRange: range)
                            j_c.setComponent(.Start, forLevelRange: range)
                        }
                    }
                }
            }
            // make more subtle later with > 1 amount dent
            if c == p {
                j_p.beamletDirection = .East
                j_c.beamletDirection = .West
            }
        }
        addBeams()
        layout()
    }
    
    public func dent(amount amount: Int, afterJunctionAtIndex index: Int) {
        dent(amount: amount, beforeJunctionAtIndex: index + 1)
    }
    
    public func cut(beforeJunctionAtIndex index: Int) {
        assert(index >= 1 && index < beamJunctions.count, "index out of range")
        let c = beamJunctions[index].currentSubdivisionLevel
        dent(amount: c, beforeJunctionAtIndex: index)
    }
    
    public func cut(AfterJunctionAtIndex index: Int) {
        assert(index >= 0 && index < beamJunctions.count - 1, "index out of range")
        //let c = beamJunctions[index].currentSubdivisionLevel
    }
    
    // cut with extension before
    
    // cut with extension after
    
    
    public func addBeamJunction(beamJunction: BeamJunction, atX x: CGFloat) {
        beamJunction.x = x
        beamJunction.beamsLayer = self
        beamJunctions.append(beamJunction)
    }
    
    public func addBeams() {
        if beamJunctions.count == 0 { return }
        if isMetrical {
            for beamJunction in beamJunctions {
                let x = beamJunction.x
                for (level, component) in beamJunction.componentsOnLevel {
                    switch component {
                    case .Start:
                        startBeamAtX(x - 0.5 * stemWidth, onLevel: level)
                    case .Stop:
                        stopBeamAtX(x + 0.5 * stemWidth, onLevel: level)
                    case .Beamlet:
                        if beamJunction.beamletDirection == .West {
                            startBeamAtX(x + 0.5 * stemWidth, onLevel: level)
                            stopBeamAtX(x - beamletLength, onLevel: level)
                        }
                        else {
                            startBeamAtX(x - 0.5 * stemWidth, onLevel: level)
                            stopBeamAtX(x + beamletLength, onLevel: level)
                        }
                    case .Extended:
                        break
                    }
                }
            }
        }
        else {
            if beamJunctions.count > 1 {
                startBeamAtX(beamJunctions.first!.x - 0.5 * stemWidth, onLevel: 0)
                stopBeamAtX(beamJunctions.last!.x + 0.5 * stemWidth, onLevel: 0)
            }
            else {
                // beamlet only
                startBeamAtX(beamJunctions.first!.x - 0.5 * stemWidth, onLevel: 0)
                stopBeamAtX(beamJunctions.first!.x + beamletLength, onLevel: 0)
            }
        }
    }
    
    public func clearBeams() {
        CATransaction.setDisableActions(true)
        for beam in beams { beam.removeFromSuperlayer() }
        CATransaction.setDisableActions(false)
        beams = []
    }
    
    public func startBeamAtX(x: CGFloat, onLevel level: Int) {
        lastBeamStartXOnLevel[level] = x
    }
    
    public func stopBeamAtX(x: CGFloat, onLevel level: Int) {
        assert(lastBeamStartXOnLevel[level] != nil, "can't finish line that hasn't started")
        let start_x = lastBeamStartXOnLevel[level]!
        let stop_x = x
        let start_y = getYValueAtX(start_x, onLevel: level)
        let stop_y = getYValueAtX(x, onLevel: level)
        let beam = Beam(
            g: g,
            scale: scale,
            start: CGPointMake(start_x + start.x, start_y),
            stop: CGPointMake(stop_x + start.x, stop_y)
        )
        beams.append(beam)
        addSublayer(beam)
        lastBeamStartXOnLevel[level] = nil // consider again
    }
    
    public func startBeamsAtX(x: CGFloat, inRange range: (Int, Int)) {
        for level in range.0...range.1 { lastBeamStartXOnLevel[level] = x }
    }
    
    public func stopBeamsAtX(x: CGFloat, inRange range: (Int, Int)) {
        for level in range.0...range.1 {
            assert(lastBeamStartXOnLevel[level] != nil, "can't finish line that hasn't started")
            let start_x = lastBeamStartXOnLevel[level]!
            let stop_x = x
            let start_y = getYValueAtX(start_x, onLevel: level)
            let stop_y = getYValueAtX(x, onLevel: level)
            let beam = Beam(
                g: g,
                scale: scale,
                start: CGPointMake(start_x + start.x, start_y),
                stop: CGPointMake(stop_x + start.x, stop_y)
            )
            beams.append(beam)
            addSublayer(beam)
        }
    }
    
    private func getYValueAtX(x: CGFloat, onLevel level: Int) -> CGFloat {
        let rise: CGFloat = stop.y - start.y // for future use only
        let run: CGFloat = stop.x - start.x // for future use only
        let slope = rise / run
        let y = start.y + slope * x
        if stemDirection == .Up { return y - CGFloat(level) * beamΔY }
        else { return y + CGFloat(level) * beamΔY }
    }
}