//
//  Clef.swift
//  denm_view
//
//  Created by James Bean on 8/17/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public protocol Clef: BuildPattern {
    
    var color: CGColor { get set }
    var top: CGFloat { get set }
    var x: CGFloat { get set }
    var height: CGFloat { get }
    var components: [ClefComponent] { get }
}

public class ClefStaff: CALayer, Clef, Guido {
    
    // Size
    //public var height: CGFloat = 0
    public var g: CGFloat = 0
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }
    
    public var lineWidth: CGFloat { get { return 0.1236 * gS } }
    public var graphHeight: CGFloat { get { return 4 * gS } }
    public var extenderHeight: CGFloat { get { return 0.5 * gS } }
    public var height: CGFloat { get { return graphHeight + (2 * extenderHeight) } }
    
    // Position
    public var x: CGFloat = 0
    public var top: CGFloat = 0
    
    // +/- octaves, for now
    public var transposition: Int = 0
    
    public var middleCPosition: CGFloat { get { return getMiddleCPosition() } }
    
    public var color: CGColor = UIColor.redColor().CGColor
    
    public var components: [ClefComponent] = []
    
    public var hasBeenBuilt: Bool = false
    
    public class func withType(type: ClefStaffType) -> ClefStaff? {
        switch type {
        case .Treble: return ClefStaffTreble()
        case .Bass: return ClefStaffBass()
        case .Alto: return ClefStaffAlto()
        case .Tenor: return ClefStaffTenor()
        }
    }
    
    public class func withType(type: String,
        transposition: Int = 0, x: CGFloat, top: CGFloat, g: CGFloat, s: CGFloat = 1) -> ClefStaff?
    {
        if let clefType = ClefStaffType(rawValue: type) {
            return ClefStaff.withType(clefType,
                transposition: transposition, x: x, top: top, g: g, s: s
            )
        }
        return nil
    }
    
    public class func withType(type: ClefStaffType,
        transposition: Int = 0, x: CGFloat, top: CGFloat, g: CGFloat, s: CGFloat = 1) -> ClefStaff?
    {
        let clefStaff = ClefStaff.withType(type)
        if clefStaff != nil {
            clefStaff!.transposition = transposition
            clefStaff!.x = x
            clefStaff!.top = top
            clefStaff!.g = g
            clefStaff!.s = s
            clefStaff!.build()
            return clefStaff!
        }
        return nil
    }

    public init(x: CGFloat, top: CGFloat, g: CGFloat, s: CGFloat = 1) {
        super.init()
        self.x = x
        self.top = top
        self.g = g
        self.s = s
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        addComponents()
        commitComponents()
        setFrame()
        hasBeenBuilt = true
    }
    
    internal func getMiddleCPosition() -> CGFloat {
        // override
        return 0
    }
    
    internal func adJustMiddleCPositionForTransposition(inout middleCPosition: CGFloat) {
        middleCPosition += 3.5 * g * CGFloat(transposition)
    }
    
    private func setFrame() {
        frame = CGRectMake(x, top, 0, height)
    }
    
    private func addComponents() {
        // transposition things here
        addGraphLine()
        addOrnament()
        if transposition != 0 { addTranspositionLabel() }
    }
    
    private func commitComponents() {
        for component in components { addSublayer(component) }
    }
    
    // make own class, make nice when time available
    internal func addTranspositionLabel() {
        
        func descriptorFromTransposition(transposition: Int) -> String {
            switch abs(transposition) {
            case 1: return "8"
            case 2: return "15"
            case 3: return "22"
            default: return "0"
            }
        }
        
        let pad = 0.236 * g
        let h = 1.236 * g
        let top = transposition > 0 ? -(h + pad) : height + pad
        let test_8 = TextLayerConstrainedByHeight(
            text: descriptorFromTransposition(transposition),
            x: 0,
            top: top,
            height: h,
            alignment: .Center,
            fontName: "AvenirNext-Regular"
        )
        test_8.foregroundColor = UIColor.grayColor().CGColor
        addSublayer(test_8)
        
    }
    
    private func addGraphLine() {
        let line = ClefGraphLine(x: 0, top: 0, height: height)
        line.lineWidth = lineWidth
        line.strokeColor = color
        components.append(line)
    }
    
    private func addOrnament() {
        // override
    }
}

public class ClefStaffTreble: ClefStaff {
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func addOrnament() {
        let circle = ClefOrnament.withType(.Circle,
            x: 0,
            y: 3 * gS + extenderHeight,
            width: 0.75 * gS
        )!
        circle.lineWidth = lineWidth
        circle.strokeColor = color
        components.append(circle)
    }
    
    internal override func getMiddleCPosition() -> CGFloat {
        var middleCPosition = 5 * g
        adJustMiddleCPositionForTransposition(&middleCPosition)

        return middleCPosition
    }
}

public class ClefStaffBass: ClefStaff {
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func addOrnament() {
        let xΔ: CGFloat = 0.5 * g
        let yΔ: CGFloat = 0.4 * g
        let yRef: CGFloat = extenderHeight + g
        for var i = -1; i < 2; i += 2 {
            let dot = ClefOrnamentDot()
            dot.x = xΔ
            dot.y = yRef + CGFloat(i) * yΔ
            dot.width = 0.382 * g
            dot.color = color
            dot.build()
            components.append(dot)
        }
    }
    
    internal override func getMiddleCPosition() -> CGFloat {
        var middleCPosition = -g
        adJustMiddleCPositionForTransposition(&middleCPosition)
        return middleCPosition
    }
}

public class ClefStaffAlto: ClefStaff {
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func addOrnament() {
        let diamond = ClefOrnamentDiamond()
        diamond.x = 0
        diamond.y = 2 * g + extenderHeight
        diamond.width = 1 * g
        diamond.lineWidth = lineWidth
        diamond.color = color
        diamond.build()
        components.append(diamond)
    }
    
    internal override func getMiddleCPosition() -> CGFloat {
        var middleCPosition = 2 * g
        adJustMiddleCPositionForTransposition(&middleCPosition)
        return middleCPosition
    }
}

public class ClefStaffTenor: ClefStaff {
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private override func addOrnament() {
        let diamond = ClefOrnamentDiamond()
        diamond.x = 0
        diamond.y = 1 * g + extenderHeight
        diamond.width = 1 * g
        diamond.lineWidth = lineWidth
        diamond.color = color
        diamond.build()
        components.append(diamond)
    }
    
    internal override func getMiddleCPosition() -> CGFloat {
        // check for transposition
        var middleCPosition = g
        adJustMiddleCPositionForTransposition(&middleCPosition)
        return middleCPosition
    }
}

public enum ClefStaffType: String {
    case Treble, Bass, Alto, Tenor
}

public class ClefCue: CALayer, Clef, BuildPattern {
    
    public var x: CGFloat = 0
    public var top: CGFloat = 0
    public var height: CGFloat = 0
    public var g: CGFloat = 0
    public var scale: CGFloat = 1
    public var lineWidth: CGFloat { get { return 0.1236 * g * scale } }
    public var color: CGColor = UIColor.redColor().CGColor
    
    public var components: [ClefComponent] = []

    public var hasBeenBuilt: Bool = false
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        setFrame()
        addComponents()
        commitComponents()
        hasBeenBuilt = true
    }
    
    private func commitComponents() {
        for component in components { addSublayer(component) }
    }
    
    private func addComponents() {
        addLine()
    }
    
    public func addLine() {
        let line = ClefGraphLine()
        line.lineWidth = lineWidth
        line.x = 0
        line.top = 0
        line.height = height
        line.color = UIColor.redColor().CGColor
        line.build()
        components.append(line)
    }
    
    private func setFrame() {
        frame = CGRectMake(x, top, 0, height)
    }
}

public class ClefComponent: CAShapeLayer, BuildPattern {
    
    public var color: CGColor = UIColor.blackColor().CGColor
    
    public var hasBeenBuilt: Bool = false
    
    public func build() {
        hasBeenBuilt = true
    }
    
    private func makePath() -> CGPath {
        // override in subclasses
        return UIBezierPath().CGPath
    }
    
    private func setFrame() {
        // override
    }
    
    private func setVisualAttributes() {
        // override
    }
}

public class ClefGraphLine: ClefComponent {
    
    public var x: CGFloat = 0
    public var top: CGFloat = 0
    public var height: CGFloat = 0
    
    public init(x: CGFloat, top: CGFloat, height: CGFloat) {
        super.init()
        self.x = x
        self.top = top
        self.height = height
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    public override func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    override private func makePath() -> CGPath {
        //setFrame()
        let path: UIBezierPath = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(0, frame.height))
        return path.CGPath
    }
    
    override private func setFrame() {
        frame = CGRectMake(x, top, 0, height)
    }
    
    override private func setVisualAttributes() {
        strokeColor = color
        fillColor = UIColor.clearColor().CGColor
        backgroundColor = UIColor.clearColor().CGColor
    }
}

public class ClefOrnament: ClefComponent {
    
    public var x: CGFloat = 0
    public var y: CGFloat = 0
    public var width: CGFloat = 0
    
    public class func withType(type: ClefOrnamentType) -> ClefOrnament? {
        switch type {
        case .Circle: return ClefOrnamentCircle()
        case .Dot: return ClefOrnamentDot()
        case .Diamond: return ClefOrnamentDiamond()
        }
    }
    
    public class func withType(type: ClefOrnamentType, x: CGFloat, y: CGFloat, width: CGFloat) -> ClefOrnament? {
        let clefOrnament = ClefOrnament.withType(type)
        if clefOrnament != nil {
            clefOrnament!.x = x
            clefOrnament!.y = y
            clefOrnament!.width = width
            clefOrnament!.build()
            return clefOrnament!
        }
        return nil
    }
    
    public override func build() {
        path = makePath()
        setFrame()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    override private func setVisualAttributes() {
        fillColor = DNMColorManager.backgroundColor.CGColor
        strokeColor = color
        backgroundColor = UIColor.clearColor().CGColor
    }
    
    override private func setFrame() {
        frame = CGRectMake(x - 0.5 * width, y - 0.5 * width, width, width)
    }
}

public class ClefOrnamentDot: ClefOrnament {
    
    override private func makePath() -> CGPath {
        setFrame()
        let path = UIBezierPath(ovalInRect: CGRectMake(0, 0, width, width))
        return path.CGPath
    }

    private override func setVisualAttributes() {
        fillColor = color
        lineWidth = 0
        backgroundColor = UIColor.clearColor().CGColor
    }
}

public class ClefOrnamentCircle: ClefOrnament {
    
    override private func makePath() -> CGPath {
        setFrame()
        let path = UIBezierPath(ovalInRect: CGRectMake(0, 0, width, width))
        return path.CGPath
    }
}

public class ClefOrnamentDiamond: ClefOrnament {
    
    override private func makePath() -> CGPath {
        setFrame()
        let path = UIBezierPath()
        // why not use rotate here as in Notehead? did this predate that extension?
        path.moveToPoint(CGPointMake(0.5 * width, 0))
        path.addLineToPoint(CGPointMake(width, 0.5 * width))
        path.addLineToPoint(CGPointMake(0.5 * width, width))
        path.addLineToPoint(CGPointMake(0, 0.5 * width))
        path.closePath()
        return path.CGPath
    }
}

public enum ClefOrnamentType {
    case Dot, Circle, Diamond
}
