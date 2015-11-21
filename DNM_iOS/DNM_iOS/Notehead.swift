//
//  Notehead.swift
//  denm_view
//
//  Created by James Bean on 8/17/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class Notehead: CALayer, StaffItem {
    
    // Size
    public var g: CGFloat = 0
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }
    
    public var width: CGFloat { get { return 1.236 * gS } }
    public var height: CGFloat { get { return width } }
    
    // Position
    public var x: CGFloat = 0
    public var y: CGFloat = 0
    
    public var shapeLayer: CAShapeLayer!
    
    public var hasBeenBuilt: Bool = false
    
    public class func withType(type: NoteheadType) -> Notehead? {
        switch type {
        case .Ord: return NoteheadOrd()
        case .DiamondEmpty: return NoteheadDiamondEmpty()
        case .CircleEmpty: return NoteheadCircleEmpty()
        case .CircleFull: return NoteheadCircleFull()
        }
    }
    
    public class func withType(type: NoteheadType, x: CGFloat, y: CGFloat, g: CGFloat, s: CGFloat = 1) -> Notehead? {
        let notehead = Notehead.withType(type)
        if notehead != nil {
            notehead!.x = x
            notehead!.y = y
            notehead!.g = g
            notehead!.s = s
            notehead!.build()
            return notehead
        }
        return nil
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        setFrame()
        commitComponents()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    public func commitComponents() {
        shapeLayer = CAShapeLayer()
        shapeLayer.path = makePath()
        shapeLayer.frame = CGRectMake(0, 0, width, height)
        addSublayer(shapeLayer)
    }
    
    private func makePath() -> CGPath {
        let path: UIBezierPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, width, height))
        path.rotate(degrees: -45)
        return path.CGPath
    }
    
    public func setFrame() {
        frame = CGRectMake(x - 0.5 * width, y - 0.5 * height, width, height)
    }
    
    public func setVisualAttributes() {
        shapeLayer.lineWidth = 0
        shapeLayer.fillColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor
    }
}

public class NoteheadOrd: Notehead {
    
    public override var height: CGFloat { get { return 0.75 * width } }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func makePath() -> CGPath {
        let path: UIBezierPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, width, height))
        path.rotate(degrees: -45)
        return path.CGPath
    }
}

public class NoteheadDiamondEmpty: Notehead {
    
    public override var width: CGFloat { get { return 0.75 * gS } }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func makePath() -> CGPath {
        let path: UIBezierPath = UIBezierPath(rect: CGRectMake(0, 0, width, width))
        path.rotate(degrees: 45)
        return path.CGPath
    }
    
    public override func setVisualAttributes() {
        shapeLayer.fillColor = DNMColorManager.backgroundColor.CGColor
        shapeLayer.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        shapeLayer.lineWidth = 0.236 * g
    }
}

public class NoteheadCircleEmpty: Notehead {
    
    public override var width: CGFloat { get { return gS } }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func makePath() -> CGPath {
        let path: UIBezierPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, width, width))
        return path.CGPath
    }
    
    public override func setVisualAttributes() {
        shapeLayer.fillColor = DNMColorManager.backgroundColor.CGColor
        shapeLayer.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        shapeLayer.lineWidth = 0.1236 * g
    }
}

public class NoteheadCircleFull: Notehead {
    
    public override var width: CGFloat { get { return gS } }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func makePath() -> CGPath {
        let path: UIBezierPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, width, width))
        return path.CGPath
    }
    
    public override func setVisualAttributes() {
        shapeLayer.fillColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        shapeLayer.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        shapeLayer.lineWidth = 0.1236 * g
    }
}

public enum NoteheadType {
    case Ord, DiamondEmpty, CircleEmpty, CircleFull
}

public class NoteheadDyad {
    
    public var g: CGFloat = 0
    public var notehead0: Notehead
    public var notehead1: Notehead
    
    public var occupiesSameLine: Bool { get { return getOccupiesSameLine() } }
    public var occupiesAdjacentLines: Bool { get { return getOccupiesAdjacentLines() } }
    
    public init(notehead0: Notehead, notehead1: Notehead) {
        self.g = notehead0.g
        var noteheads: [Notehead] = [notehead0, notehead1]
        noteheads.sortInPlace { $0.y > $1.y }
        self.notehead0 = noteheads[0]
        self.notehead1 = noteheads[1]
    }
    
    internal func getOccupiesSameLine() -> Bool {
        return notehead0.y == notehead1.y
    }
    
    internal func getOccupiesAdjacentLines() -> Bool {
        return notehead0.y == notehead1.y + 0.5 * g
    }
}

public class NoteheadVerticality {
    
    public var g: CGFloat = 0
    public var noteheads: [Notehead]
    public var dyads: [NoteheadDyad]? { get { return getDyads() } }
    
    public init(noteheads: [Notehead]) {
        self.noteheads = noteheads
        if noteheads.count > 0 { self.g = noteheads.first!.g }
        
        // sort noteheads better
        
        sortNoteheads()
    }
    
    internal func getDyads() -> [NoteheadDyad]? {
        if noteheads.count < 2 { return nil }
        var dyads: [NoteheadDyad] = []
        for n in 0..<noteheads.count - 1 {
            let dyad = NoteheadDyad(notehead0: noteheads[n], notehead1: noteheads[n + 1])
            dyads.append(dyad)
        }
        return dyads
    }
    
    internal func sortNoteheads() {
        noteheads.sortInPlace { $0.y > $1.y }
    }
}

public class NoteheadDyadMover {
    
    // NYI: Left- or Right-weighted, SAME LINE!

    public var g: CGFloat = 0
    public var dyad: NoteheadDyad
    
    public init(dyad: NoteheadDyad) {
        self.dyad = dyad
    }
    
    public func move(g: CGFloat) {
        if dyad.occupiesSameLine {
            dyad.notehead0.position.x -= 0.382 * dyad.notehead0.frame.width
            dyad.notehead1.position.x += 0.382 * dyad.notehead1.frame.width
        }
        else if dyad.occupiesAdjacentLines {
            dyad.notehead0.position.x -= 0.308 * dyad.notehead0.frame.width
            dyad.notehead1.position.x += 0.45 * dyad.notehead1.frame.width
        }
        else { /* ? */ }
    }
}

public class NoteheadVerticalityMover {
    
    public var staff: Staff? // not needed
    
    public var g: CGFloat = 0
    
    public var verticality: NoteheadVerticality
    public var stemDirection: StemDirection = .Down
    
    public var amountClusteredAtEnd: Int { get { return getAmountClusteredAtEnd() } }
    
    init(verticality: NoteheadVerticality) {
        self.verticality = verticality
    }
    
    init(verticality: NoteheadVerticality, g: CGFloat, stemDirection: StemDirection) {
        self.verticality = verticality
        self.g = g
        self.stemDirection = stemDirection
    }
    
    public func move() {
        if verticality.noteheads.count < 2 { return }
        else {
            if verticality.dyads!.count == 1 {
                let dyad = verticality.dyads!.first!
                NoteheadDyadMover(dyad: dyad).move(g)
            }
            else if amountClusteredAtEnd > 0 && amountClusteredAtEnd % 2 == 0 {
                //let dyads = Array(verticality.dyads!.reverse())
                var d: Int = 0
                while d < verticality.dyads!.count {
                    let dyad = verticality.dyads![d]
                    if dyad.occupiesSameLine || dyad.occupiesAdjacentLines {
                        // spell
                        NoteheadDyadMover(dyad: dyad).move(g)
                        d += 2
                    }
                    else { d++ }
                }
            }
            else {
                var d: Int = 0
                while d < verticality.dyads!.count {
                    let dyad = verticality.dyads![d]
                    if dyad.occupiesSameLine || dyad.occupiesAdjacentLines {
                        // spell
                        NoteheadDyadMover(dyad: dyad).move(g)
                        d += 2
                    }
                    else { d++ }
                }
            }
        }
    }
    
    // DEPRECATE
    public func move(g: CGFloat, stemDirection: StemDirection) {
        if verticality.noteheads.count < 2 { return }
        else {
            if verticality.dyads!.count == 1 {
                let dyad = verticality.dyads!.first!
                NoteheadDyadMover(dyad: dyad).move(g)
            }
            else if amountClusteredAtEnd > 0 && amountClusteredAtEnd % 2 == 0 {
                //let dyads = Array(verticality.dyads!.reverse())
                var d: Int = 0
                while d < verticality.dyads!.count {
                    let dyad = verticality.dyads![d]
                    if dyad.occupiesSameLine || dyad.occupiesAdjacentLines {
                        // spell
                        NoteheadDyadMover(dyad: dyad).move(g)
                        d += 2
                    }
                    else { d++ }
                }
            }
            else {
                var d: Int = 0
                while d < verticality.dyads!.count {
                    let dyad = verticality.dyads![d]
                    if dyad.occupiesSameLine || dyad.occupiesAdjacentLines {
                        // spell
                        NoteheadDyadMover(dyad: dyad).move(g)
                        d += 2
                    }
                    else { d++ }
                }
            }
        }
    }
    
    public func getAmountClusteredAtEnd() -> Int {
        var dyads = verticality.dyads!
        dyads = stemDirection == .Up ? dyads : Array(dyads.reverse())
        
        var amountClustered: Int = 0
        var index = 0
        while index < verticality.dyads!.count {
            let dyad: NoteheadDyad = verticality.dyads![index]
            if dyad.occupiesAdjacentLines || dyad.occupiesSameLine {
                amountClustered++
                index++
            }
            else { break }
        }
        return amountClustered
    }
}