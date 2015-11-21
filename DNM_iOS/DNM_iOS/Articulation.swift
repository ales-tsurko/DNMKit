//
//  Articulation.swift
//  denm_view
//
//  Created by James Bean on 8/21/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class Articulation: CAShapeLayer, BuildPattern, Guido {
    
    public var point: CGPoint = CGPointZero
    public var g: CGFloat = 12
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }

    public var scale: CGFloat = 1 // deprecate!
    
    public var hasBeenBuilt: Bool = false
    
    public class func withType(type: ArticulationType, x: CGFloat, y: CGFloat, g: CGFloat, s: CGFloat = 1.0) -> Articulation? {
        var articulation: Articulation?
        switch type {
        case .Accent: articulation = ArticulationAccent()
        case .Staccato: articulation = ArticulationStaccato()
        case .Tenuto: articulation = ArticulationTenuto()
        default: break
        }
        if articulation != nil {
            articulation!.point = CGPointMake(x, y)
            articulation!.g = g
            articulation!.s = s
            articulation!.build()
            return articulation!
        }
        return nil
    }
    
    public class func articulationWithType(type: ArticulationType, point: CGPoint, g: CGFloat)
        -> Articulation?
    {
        var articulation: Articulation?
        switch type {
        case .Accent: articulation = ArticulationAccent()
        case .Staccato: articulation = ArticulationStaccato()
        case .Tenuto: articulation = ArticulationTenuto()
        default: break
        }
        articulation!.point = point
        articulation!.g = g
        articulation!.build()
        return articulation
    }
    
    public init(point: CGPoint, g: CGFloat) {
        self.point = point
        self.g = g
        super.init()
    }
    
    public func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    private func makePath() -> CGPath {
        return UIBezierPath().CGPath
        // override
    }
    
    private func setVisualAttributes() {
        // override
    }
    
    private func setFrame() {
        // override
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
}

public func ArticulationTypeWithMarking(marking: String) -> ArticulationType? {
    switch marking {
    case ".": return ArticulationType.Staccato
    case ">": return ArticulationType.Accent
    case "-": return ArticulationType.Tenuto
    case "trem": return ArticulationType.Tremolo
    default: return nil
    }
}

public enum ArticulationType {
    case Accent, Staccato, Tenuto, Tremolo
    
    public static func random() -> ArticulationType {
        let types: [ArticulationType] = [.Accent, .Staccato, .Tenuto, .Tremolo]
        return types.random()
    }
}


public class ArticulationTenuto: Articulation {
    
    public override func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
    }
    
    private override func makePath() -> CGPath {
        let path = UIBezierPath(rect: CGRectMake(0, 0, frame.width, frame.height))
        return path.CGPath
    }
    
    private override func setVisualAttributes() {
        fillColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        strokeColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        lineWidth = 0
    }
    
    private override func setFrame() {
        let width = g
        let height = 0.1236 * g
        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * height, width, height)
    }
}

public class ArticulationStaccato: Articulation {
    
    public override func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
    }
    
    private override func makePath() -> CGPath {
        let path = UIBezierPath(ovalInRect: CGRectMake(0, 0, frame.width, frame.height))
        return path.CGPath
    }
    
    private override func setVisualAttributes() {
        fillColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        strokeColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        lineWidth = 0
    }
    
    override func setFrame() {
        let width = 0.382 * g
        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * width, width, width)
    }
}

public class ArticulationAccent: Articulation {
    
    public override func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
    }
    
    override func makePath() -> CGPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(frame.width, 0.5 * frame.height))
        path.addLineToPoint(CGPointMake(0, frame.height))
        return path.CGPath
    }
    
    override func setVisualAttributes() {
        fillColor = UIColor.clearColor().CGColor
        strokeColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        lineWidth = 0.1236 * g
        lineJoin = kCALineJoinBevel
    }
    
    override func setFrame() {
        let width = 1 * g
        let height = 0.5 * g
        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * height, width, height)
    }
}

public class ArticulationStemDirectionDependent: Articulation {
    
    public var stemDirection: StemDirection = .Down
}

public class ArticulationString: Articulation {

    // OTHER THINGS?
}

public class ArticulationStringBowPosition: ArticulationString {
    
    public class func withType(type: BowPosition) -> ArticulationStringBowPosition? {
        switch type {
        case .Frog: break
        case .Tip: break
        case .Middle: break
        }
        return nil
    }
}

public enum BowPosition: String {
    // flesh out
    case Frog
    case Middle
    case Tip
}

public class ArticulationStringBowPlacement: ArticulationString {
 
    // for now, just use text layer, switch text string
    
    public class func withType(type: BowPlacement) -> ArticulationStringBowPlacement? {
        switch type {
        case .Bridge: break
        case .MoltoSulPonticello: break
        case .SulPonticello: break
        case .Ord: break
        case .SulTasto: break
        case .MoltoSulTasto: break
        }
        return nil
    }
}

public enum BowPlacement: Int {
    
    case Bridge = 0
    case MoltoSulPonticello
    case SulPonticello
    case Ord
    case SulTasto
    case MoltoSulTasto
}

public class ArticulationStringBowDirection: ArticulationString {
    
    public class func withType(type: BowDirection) -> ArticulationStringBowDirection? {
        switch type {
        case .Up: return ArticulationStringBowDirectionUp()
        case .Down: return ArticulationStringBowDirectionDown()
        }
    }
}

public class ArticulationStringBowDirectionUp: ArticulationStringBowDirection {
    
    override func makePath() -> CGPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(0.5 * frame.width, frame.height))
        path.addLineToPoint(CGPointMake(frame.width, 0))

        return path.CGPath
    }
    
    public override func setFrame() {
        let height = g
        let width = 0.5 * g

        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * height, width, height)
    }
    
    private override func setVisualAttributes() {
        lineWidth = 0.1 * g
        strokeColor = UIColor.grayscaleColorWithDepthOfField(.Foreground).CGColor
        fillColor = nil
        lineJoin = kCALineJoinBevel
    }
}

public class ArticulationStringBowDirectionDown: ArticulationStringBowDirection {
    
    private var thinLineWidth: CGFloat { get { return 0.15 * g } }
    private var blockWidth: CGFloat { get { return 0.5 * frame.height } }
    
    private override func makePath() -> CGPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(thinLineWidth, frame.height))
        path.addLineToPoint(CGPointMake(0, frame.height))
        path.addLineToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(frame.width, 0))
        path.addLineToPoint(CGPointMake(frame.width, frame.height))
        path.addLineToPoint(CGPointMake(frame.width - thinLineWidth, frame.height))
        path.addLineToPoint(CGPointMake(frame.width - thinLineWidth, blockWidth))
        path.addLineToPoint(CGPointMake(thinLineWidth, blockWidth))
        path.closePath()
        return path.CGPath
    }
    
    public override func setFrame() {
        let width = g
        let height = 0.875 * width
        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * height, width, height)
    }
    
    private override func setVisualAttributes() {
        fillColor = UIColor.grayscaleColorWithDepthOfField(.Foreground).CGColor
    }
}

public enum BowDirection: String {
    case Up
    case Down
}

public class ArticulationStringNumber: Articulation {
    
    public var romanNumeralString: String!
    public var textLayer: TextLayerConstrainedByHeight!
    
    public init(point: CGPoint = CGPointZero, g: CGFloat = 12, romanNumeralString: String) {
        super.init(point: point, g: g)
        self.romanNumeralString = romanNumeralString
        addTextLayer()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    private func addTextLayer() {
        let height: CGFloat = g
        
        textLayer = TextLayerConstrainedByHeight(
            text: romanNumeralString,
            x: 0,
            top: 0,
            height: height,
            alignment: .Center,
            fontName: "Baskerville-SemiBold"
        )
        addSublayer(textLayer)
    }
    
    public override func setFrame() {
        let width = textLayer.frame.width
        let height = g
        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * height, width, height)
        textLayer.position.x = 0.5 * frame.width
        //textLayer.position.y = 0.5 * frame.height
    }
    
    public override func setVisualAttributes() {
        textLayer.foregroundColor = UIColor.grayscaleColorWithDepthOfField(.Foreground).CGColor
    }
    
    
}



















































