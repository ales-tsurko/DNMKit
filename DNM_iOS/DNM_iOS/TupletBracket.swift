//
//  TupletBracket.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

public class TupletBracket: ViewNode, BuildPattern {
    
    public var stemDirection: StemDirection = .Down
    
    public var subdivisionGraphic: SubdivisionGraphic?
    
    public var text_left: TextLayerConstrainedByHeight?
    public var text_right: TextLayerConstrainedByHeight?
    public var arm_left: TupletBracketArm?
    public var arm_right: TupletBracketArm?
    
    public var height: CGFloat = 0
    public var width: CGFloat = 0
    
    public var sum: Int = 0
    public var beats: Int = 0
    public var subdivisionLevel: Int = 0
    
    public var textHeight: CGFloat { get { return 0.691 * height } }
    
    public var hasBeenBuilt: Bool = false
    
    public var components: [CALayer] {
        get { return [subdivisionGraphic!, arm_left!, arm_right!] }
    }
    
    public init(
        left: CGFloat,
        top: CGFloat,
        width: CGFloat,
        height: CGFloat,
        stemDirection: StemDirection,
        sum: Int,
        beats: Int,
        subdivisionLevel: Int
        )
    {
        self.height = height
        self.width = width
        self.sum = sum
        self.beats = beats
        self.subdivisionLevel = subdivisionLevel
        self.stemDirection = stemDirection
        super.init()
        self.left = left
        self.top = top
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func build() {
        setFrame()
        addComponents()
        hasBeenBuilt = true
    }
    
    private func setFrame() {
        frame = CGRectMake(left, top, width, height)
    }
    
    private func addComponents() {
        
        let pad = 0.236 * height
        addSubdivisionGraphic()
        var x_left: CGFloat = 0.5 * width - 0.5 * subdivisionGraphic!.frame.width - pad
        var x_right: CGFloat = 0.5 * width + 0.5 * subdivisionGraphic!.frame.width + pad
        addBeatsTextAtX(x_left)
        addSubdivisionTextAtX(x_right)
        x_left -= (text_left!.frame.width + pad)
        x_right += text_right!.frame.width + pad
        
        // check here for collsions: avoid if necessary
        
        addArmLeftToX(x_left)
        addArmRightFromX(x_right)
    }
    
    private func addSubdivisionGraphic() {
        let subdivisionGraphic = SubdivisionGraphic(
            x: 0.5 * width,
            top: 0,
            height: height,
            stemDirection: stemDirection,
            amountBeams: subdivisionLevel
        )
        self.subdivisionGraphic = subdivisionGraphic
        addSublayer(subdivisionGraphic)
    }
    
    private func addArmLeftToX(x: CGFloat) {
        
        // calculate stop
        let top = stemDirection == .Down ? 0.5 * height : 0
        let arm = TupletBracketArm(
            left: 0,
            top: top,
            width: x,
            height: 0.5 * height,
            stemDirection: stemDirection,
            side: .Left
        )
        arm_left = arm
        addSublayer(arm)
    }
    
    private func addArmRightFromX(x: CGFloat) {
        
        // calculate start
        let top = stemDirection == .Down ? 0.5 * height : 0
        let pad_right: CGFloat = 0.382 * height
        
        let arm = TupletBracketArm(
            left: x,
            top: top,
            width: width - x - pad_right,
            height: 0.5 * height,
            stemDirection: stemDirection,
            side: .Right
        )
        arm_right = arm
        addSublayer(arm)
    }
    
    private func addBeatsTextAtX(x: CGFloat) {
        let top = 0.5 * (height - textHeight)
        let text = TextLayerConstrainedByHeight(
            text: "\(sum)",
            x: x,
            top: top,
            height: textHeight,
            alignment: .Right,
            fontName: "AvenirNextCondensed-Regular"
        )
        text.foregroundColor = UIColor.grayscaleColorWithDepthOfField(.Foreground).CGColor
        text.backgroundColor = DNMColorManager.backgroundColor.CGColor
        text_left = text
        addSublayer(text)
    }
    
    private func addSubdivisionTextAtX(x: CGFloat) {
        let top = 0.5 * (height - textHeight)
        let text = TextLayerConstrainedByHeight(
            text: "\(beats)",
            x: x,
            top: top,
            height: textHeight,
            alignment: .Left,
            fontName: "AvenirNextCondensed-Regular"
        )
        text.foregroundColor = UIColor.grayscaleColorWithDepthOfField(.Foreground).CGColor
        text.backgroundColor = DNMColorManager.backgroundColor.CGColor
        text_right = text
        addSublayer(text)
    }
    
    public override func hitTest(p: CGPoint) -> CALayer? {
        if containsPoint(p) { return self }
        else { return nil }
    }
    
    public override func containsPoint(p: CGPoint) -> Bool {
        return CGRectContainsPoint(frame, p)
    }
}

public class TupletBracketArm: CAShapeLayer, BuildPattern {
    
    public var stemDirection: StemDirection = .Down
    
    public var side: DirectionRelative = .Left
    
    public var height: CGFloat = 0
    public var width: CGFloat = 0
    public var left: CGFloat = 0
    public var top: CGFloat = 0
    
    public var hasBeenBuilt: Bool = false
    
    public init(
        left: CGFloat,
        top: CGFloat,
        width: CGFloat,
        height: CGFloat,
        stemDirection: StemDirection,
        side: DirectionRelative
        )
    {
        self.left = left
        self.top = top
        self.width = width
        self.height = height
        self.stemDirection = stemDirection
        self.side = side
        super.init()
        build()
    }
    
    public func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    private func makePath() -> CGPath {
        
        var inset: CGFloat { get { return 0.5 * height } }
        
        let path = UIBezierPath()
        switch side {
        case .Left:
            switch stemDirection {
            case .Up:
                path.moveToPoint(CGPointMake(0, 0))
                path.addLineToPoint(CGPointMake(0, height))
                path.addLineToPoint(CGPointMake(width, height))
            case .Down:
                path.moveToPoint(CGPointMake(0, height))
                path.addLineToPoint(CGPointMake(0, 0))
                path.addLineToPoint(CGPointMake(width, 0))
            }
        case .Right:
            switch stemDirection {
            case .Up:
                path.moveToPoint(CGPointMake(0, height))
                path.addLineToPoint(CGPointMake(width - inset, height))
                path.addLineToPoint(CGPointMake(width, 0))
            case .Down:
                path.moveToPoint(CGPointMake(0, 0))
                path.addLineToPoint(CGPointMake(width - inset, 0))
                path.addLineToPoint(CGPointMake(width, height))
            }
            
        default: break
        }
        return path.CGPath
    }
    
    private func setFrame() {
        frame = CGRectMake(left, top, width, height)
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    private func setVisualAttributes() {
        lineWidth = 0.0875 * height
        strokeColor = UIColor.grayColor().CGColor // make colorByDepth[depth].lightColor
        fillColor = UIColor.clearColor().CGColor
        lineJoin = kCALineJoinBevel
    }
}

// TO-DO: PADS
public class TBGroup: ViewNode {
    
    public var bgStratum: BGStratum?
    public var depth: Int = 0
    
    // SET IN INIT
    //public override var pad_below: CGFloat { get { return 0.236 * frame.height } }
    //public override var pad_above: CGFloat { get { return 0.236 * frame.height } }
    
    public override init() {
        super.init()
        //layoutRelationship = .AsSublayers // deprecate
        setsHeightWithContents = true
        setsWidthWithContents = true
        layoutFlow_vertical = .Top
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    public var stemDirection: StemDirection = .Down {
        didSet { for node in nodes as! [TupletBracket] { node.stemDirection = stemDirection } }
    }
    
    public override func hitTest(p: CGPoint) -> CALayer? {
        if containsPoint(p) { return self }
        else { return nil }
    }
    
    public override func containsPoint(p: CGPoint) -> Bool {
        return CGRectContainsPoint(frame, p)
    }
}

public class TBLigature: CALayer, BuildPattern {
    
    public var x: CGFloat = 0
    public var g: CGFloat = 0
    public var beamEndY: CGFloat = 0
    public var bracketEndY: CGFloat = 0
    
    public var stemDirection: StemDirection { get { return getStemDirection() } }
    
    
    
    public var line: TBLigatureLine!
    public var ornament_beamEnd: TBLigatureOrnament?
    public var ornament_bracketEnd: TBLigatureOrnament?
    public var ornaments: [TBLigatureOrnament] = []
    
    public var hasBeenBuilt: Bool = false
    
    public class func ligatureWithType(
        type: TBLigatureType,
        x: CGFloat,
        beamEndY: CGFloat,
        bracketEndY: CGFloat,
        g: CGFloat
    ) -> TBLigature?
    {
        var ligature: TBLigature?
        switch type {
        case .Begin: ligature = TBLigatureBegin()
        case .Resume: ligature = TBLigatureResume()
        case .End: ligature = TBLigatureEnd()
        }
        ligature!.x = x
        ligature!.beamEndY = beamEndY
        ligature!.bracketEndY = bracketEndY
        ligature!.g = g
        ligature!.build()
        return ligature!
    }
    
    public init(x: CGFloat, beamEndY: CGFloat, bracketEndY: CGFloat, g: CGFloat) {
        self.x = x
        self.beamEndY = beamEndY
        self.bracketEndY = bracketEndY
        self.g = g
        super.init()
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }

    public func setBeamEndY(beamEndY: CGFloat, andBracketEndY bracketEndY: CGFloat) {
        self.beamEndY = beamEndY
        self.bracketEndY = bracketEndY
        line.setBeamEndY(beamEndY, andBracketEndY: bracketEndY)
        ornament_bracketEnd?.position.y = bracketEndY
        ornament_beamEnd?.position.y = beamEndY
    }
    
    public func build() {
        addComponents()
        hasBeenBuilt = true
    }
    
    func addLine() {
        let line = TBLigatureLine(x: x, beamEndY: beamEndY, bracketEndY: bracketEndY)
        addSublayer(line)
        self.line = line
    }
    
    func addOrnament_bracketEnd() {
        
    }
    
    func addOrnament_beamEnd() {
        
    }
    
    private func addComponents() {
        addLine()
    }
    
    private func getStemDirection() -> StemDirection {
        return beamEndY > bracketEndY ? .Down : .Up
    }
}

public class TBLigatureBegin: TBLigature {
    
    override func addComponents() {
        addLine()
        addOrnament_beamEnd()
    }
    
    override func addOrnament_beamEnd() {
        let arrow = TBLigatureOrnament.ornamentWithType(.Arrow,
            point: CGPointMake(x, beamEndY), g: g, stemDirection: stemDirection
            )!
        self.ornament_beamEnd = arrow
        addSublayer(arrow)
    }
}

public class TBLigatureResume: TBLigature {
    
    override func addComponents() {
        addLine()
        addOrnament_bracketEnd()
        addOrnament_beamEnd()
    }
    
    override func addLine() {
        let line = TBLigatureLine(x: x, beamEndY: beamEndY, bracketEndY: bracketEndY)
        line.lineWidth = 0.0618 * g
        line.lineDashPattern = [0.1236 * g] // related to g
        addSublayer(line)
        self.line = line
    }
    
    override func addOrnament_beamEnd() {
        let arrow = TBLigatureOrnament.ornamentWithType(.Arrow,
            point: CGPointMake(x, beamEndY), g: g, stemDirection: stemDirection
            )!
        self.ornament_beamEnd = arrow
        addSublayer(arrow)
    }
    
    override func addOrnament_bracketEnd() {
        let circle = TBLigatureOrnament.ornamentWithType(.Circle,
            point: CGPointMake(x, bracketEndY), g: g
            )!
        addSublayer(circle)
        ornament_bracketEnd = circle
    }
}

public class TBLigatureEnd: TBLigature {
    
    
}


public enum TBLigatureType {
    case Begin, Resume, End
}

public class TBLigatureLine: LigatureVertical {
    
    public var beamEndY: CGFloat = 0
    public var bracketEndY: CGFloat = 0
    
    public init(x: CGFloat, beamEndY: CGFloat, bracketEndY: CGFloat) {
        self.beamEndY = beamEndY
        self.bracketEndY = bracketEndY
        if beamEndY < bracketEndY { super.init(x: x, top: beamEndY, bottom: bracketEndY) }
        else { super.init(x: x, top: bracketEndY, bottom: beamEndY)  }
    }
    
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    public func setBeamEndY(beamEndY: CGFloat, andBracketEndY bracketEndY: CGFloat) {
        self.beamEndY = beamEndY
        self.bracketEndY = bracketEndY
        if beamEndY < bracketEndY { setTop(beamEndY, andBottom: bracketEndY) }
        else { setTop(bracketEndY, andBottom: beamEndY) }
    }
}

public class TBLigatureOrnament: CAShapeLayer {
    
    public var point: CGPoint = CGPointZero
    public var g: CGFloat = 0
    public var color: CGColor = UIColor.grayColor().CGColor
    
    public class func ornamentWithType(
        type: TBLigatureOrnamentType,
        point: CGPoint,
        g: CGFloat,
        stemDirection: StemDirection = .Down
        ) -> TBLigatureOrnament?
    {
        var ornament: TBLigatureOrnament?
        switch type {
        case .Circle: ornament = TBLigatureOrnamentCircle()
        case .Arrow: ornament = TBLigatureOrnamentArrow()
        case .Line: break
        }
        (ornament as? TBLigatureOrnamentArrow)?.stemDirection = stemDirection
        ornament!.point = point
        ornament!.g = g
        ornament!.build()
        return ornament!
    }
    
    public init(point: CGPoint, g: CGFloat) {
        self.point = point
        self.g = g
        super.init()
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func build() {
        setFrame()
        path = makePath()
        setVisualAttribtues()
    }
    
    private func setFrame() {
        // override
    }
    
    private func makePath() -> CGPath {
        return UIBezierPath().CGPath
    }
    
    func setVisualAttribtues() {
        // something
    }
}


public class TBLigatureOrnamentCircle: TBLigatureOrnament {
    
    override func makePath() -> CGPath {
        let path = UIBezierPath(ovalInRect: CGRectMake(0, 0, frame.width, frame.width))
        return path.CGPath
    }
    
    override func setVisualAttribtues() {
        strokeColor = color
        fillColor = UIColor.whiteColor().CGColor
        lineWidth = 0.0618 * g
    }
    
    override func setFrame() {
        let width: CGFloat = 0.618 * g
        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * width, width, width)
    }
}

public class TBLigatureOrnamentArrow: TBLigatureOrnament {
    
    public var stemDirection: StemDirection = .Down
    
    override func makePath() -> CGPath {
        let barbDepth = 0.309 * frame.height
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0.5 * frame.width, 0))
        path.addLineToPoint(CGPointMake(frame.width, frame.height))
        path.addLineToPoint(CGPointMake(0.5 * frame.width, frame.height - barbDepth))
        path.addLineToPoint(CGPointMake(0, frame.height))
        path.closePath()
        if stemDirection == .Down { path.rotate(degrees: 180) }
        return path.CGPath
    }
    
    override func setVisualAttribtues() {
        fillColor = UIColor.grayColor().CGColor
        strokeColor = UIColor.grayColor().CGColor
        lineWidth = 0
    }
    
    override func setFrame() {
        let height = 1 * g
        let width = 0.75 * height
        frame = CGRectMake(point.x - 0.5 * width, point.y - 0.5 * height, width, height)
    }
}

public class TBLigatureOrnamentLine: TBLigatureOrnament {
    
    override func makePath() -> CGPath {
        let path = UIBezierPath()
        return path.CGPath
    }
}


public enum TBLigatureOrnamentType {
    case Circle, Arrow, Line
}