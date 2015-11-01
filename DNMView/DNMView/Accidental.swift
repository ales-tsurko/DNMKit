//
//  Accidental.swift
//  denm_view
//
//  Created by James Bean on 8/18/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

// TODO: Break out to individual files
public class Accidental: CALayer, Guido, BuildPattern {
    
    /// Position of Accidental
    public var point: CGPoint = CGPointZero
    
    public var g: CGFloat = 0
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }
    
    internal var xRef: CGFloat { get { return 0 } } // override
    internal var yRef: CGFloat { get { return 0 } } // override
    
    internal var left: CGFloat { get { return 0 } } // override
    internal var top: CGFloat { get { return 0 } } // override
    internal var width: CGFloat { get { return 0 } } // override
    internal var height: CGFloat { get { return 0 } } // override
    
    public var boundingWidth: CGFloat? { get { return getBoundingWidth() } }
    
    public var thickLineSlope: CGFloat = 0.25
    public var thickLineWidth: CGFloat { get { return 0.382 * gS } }
    public var thickLineLength: CGFloat { get { return midWidth + 2 * flankWidth } }
    
    public var midWidth: CGFloat { get { return 0.575 * gS } }
    public var flankWidth: CGFloat { get { return 0.15 * gS } }
    
    public var thinLineWidth: CGFloat { get { return 0.0875 * gS } }
    
    public var arrowHeight: CGFloat { get { return 0.618 * gS } }
    
    public var column: Int? // index, change !!P: VNII vn Violin
    
    public var components: [AccidentalComponent] = []
    
    public var arrow: AccidentalComponentArrow? { get { return getArrow() } }
    
    public var body: AccidentalComponentBody?
    
    public var column_left_up: AccidentalComponentColumn?
    public var column_left_down: AccidentalComponentColumn?
    
    public var column_center_up: AccidentalComponentColumn?
    public var column_center_down: AccidentalComponentColumn?
    
    public var column_right_up: AccidentalComponentColumn?
    public var column_right_down: AccidentalComponentColumn?
    
    public var arrow_left_up: AccidentalComponentArrow?
    public var arrow_left_down: AccidentalComponentArrow?
    
    public var arrow_center_up: AccidentalComponentArrow?
    public var arrow_center_down: AccidentalComponentArrow?
    
    public var arrow_right_up: AccidentalComponentArrow?
    public var arrow_right_down: AccidentalComponentArrow?
    
    public var hasArrow: Bool { get { return getHasArrow() } }
    
    public var color: CGColor = UIColor.grayscaleColorWithDepthOfField(.Foreground).CGColor {
        didSet { for component in components { component.fillColor = color } }
    }
    
    public var hasBeenBuilt: Bool = false
    
    /*
    public override class func makePDFDocumentation() {
        let accidentalsLayer = CALayer()
        let types: [AccidentalType] = [
            .Natural, .NaturalUp, .NaturalDown,
            .Sharp, .SharpUp, .SharpDown,
            .Flat, .FlatUp, .FlatDown,
            .QuarterSharp, .QuarterSharpUp, .QuarterSharpDown,
            .QuarterFlat, .QuarterFlatUp, .QuarterFlatDown
        ]
        for (i, type) in types.enumerate() {
            let accidental = Accidental.accidentalWithType(type,
                withStaffSpaceHeight: 40,
                scaledBy: 1,
                atPoint: CGPointMake(CGFloat(i) * 50 + 20, 75)
                )!
            accidentalsLayer.addSublayer(accidental)
        }
        accidentalsLayer.frame = CGRectMake(
            0, 0, accidentalsLayer.sublayers!.last!.frame.maxX, 150
        )
        accidentalsLayer.makePDF(name: "Accidental")
    }
    */
    
    public class func withType(type: AccidentalType,
        x: CGFloat, y: CGFloat, g: CGFloat, s: CGFloat = 1
    ) -> Accidental?
    {
        var accidental: Accidental?
        switch type {
        case .Natural: accidental = AccidentalNatural()
        case .NaturalUp: accidental = AccidentalNaturalUp()
        case .NaturalDown: accidental =  AccidentalNaturalDown()
        case .Sharp: accidental =  AccidentalSharp()
        case .SharpUp: accidental =  AccidentalSharpUp()
        case .SharpDown: accidental =  AccidentalSharpDown()
        case .Flat: accidental =  AccidentalFlat()
        case .FlatUp: accidental =  AccidentalFlatUp()
        case .FlatDown: accidental =  AccidentalFlatDown()
        case .QuarterSharp: accidental =  AccidentalQuarterSharp()
        case .QuarterSharpUp: accidental =  AccidentalQuarterSharpUp()
        case .QuarterSharpDown: accidental =  AccidentalQuarterSharpDown()
        case .QuarterFlat: accidental =  AccidentalQuarterFlat()
        case .QuarterFlatUp: accidental =  AccidentalQuarterFlatUp()
        case .QuarterFlatDown: accidental =  AccidentalQuarterFlatDown()
        }
        if accidental != nil {
            accidental!.point = CGPointMake(x, y)
            accidental!.g = g
            accidental!.s = s
            accidental!.build()
            accidental!.color = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
            return accidental!
        }
        return nil
    }
    
    public init(g: CGFloat) {
        self.g = g
        self.s = 1
        super.init()
        build()
    }
    
    public init(g: CGFloat, scale: CGFloat, point: CGPoint) {
        self.g = g
        self.s = scale
        self.point = point
        super.init()
        build()
    }

    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        addComponents()
        setAccidentalOfComponentsToSelf()
        commitComponents()
        setFrame()
        hasBeenBuilt = true
    }
    
    private func addComponents() {
        // add components
    }
    
    private func commitComponents() {
        for component in components {
            component.fillColor = color
            addSublayer(component)
        }
    }
    
    private func setFrame() {
        let left = point.x - xRef
        let top = point.y - yRef
        frame = CGRectMake(left, top, width, height)
    }
    
    private func getHeight() -> CGFloat {
        let minY: CGFloat = getMinY(components)
        let maxY: CGFloat = getMaxY(components)
        let height: CGFloat = -minY + maxY
        return height
    }
    
    internal func getBoundingWidth() -> CGFloat? {
        if components.count == 0 { return nil }
        var minX: CGFloat?
        var maxX: CGFloat?
        for component in components {
            if minX == nil { minX = component.frame.minX }
            else if component.frame.minX < minX { minX = component.frame.minX }
            if maxX == nil { maxX = component.frame.maxX }
            else if component.frame.maxX > maxX { maxX = component.frame.maxX }
        }
        return maxX! - minX!
    }
    
    // abstract these for more global usage with CALayers
    internal func getMinY(layers: [CALayer]) -> CGFloat {
        var newLayers: [CALayer] = layers
        newLayers.sortInPlace { $0.frame.minY < $1.frame.minY }
        return newLayers.first!.frame.minY
    }
    
    internal func getMaxY(layers: [CALayer]) -> CGFloat {
        var newLayers: [CALayer] = layers
        newLayers.sortInPlace { $0.frame.maxX > $1.frame.maxX }
        return newLayers.first!.frame.maxY
    }
    
    
    internal func setAccidentalOfComponentsToSelf() {
        for component in components {
            component.accidental = self
        }
    }
    
    
    internal func getHasArrow() -> Bool {
        for component in components {
            if component is AccidentalComponentArrow { return true }
        }
        return false
    }
    
    internal func getArrow() -> AccidentalComponentArrow? {
        if hasArrow {
            for component in components {
                if component is AccidentalComponentArrow {
                    return component as? AccidentalComponentArrow
                }
            }
        }
        return nil
    }
}

public class AccidentalNatural: Accidental {
    
    public override var description: String { get { return "Natural" } }
    
    //public var body: AccidentalComponentBody?
    
    internal var column_left_up_height: CGFloat { get { return 1.236 * gS } }
    internal var column_right_down_height: CGFloat { get { return 1.236 * gS } }
    
    internal override var height: CGFloat {
        get { return column_left_up_height + column_right_down_height }
    }
    
    internal override var width: CGFloat { get { return thickLineLength } }
    
    internal override var xRef: CGFloat { get { return 0.5 * width } }
    internal override var yRef: CGFloat { get { return column_left_up_height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalNatural(g: 40)
        accidental.makePDF(name: "AccidentalNatural")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addLeftColumnUp()
        addLeftColumnDown()
        addRightColumnDown()
        addRightColumnUp()
    }
    
    internal func addBody() {
        body = AccidentalComponentBodyNatural(
            g: g, scale: s, point: CGPointMake(xRef, yRef)
        )
        components.append(body!)
    }
    
    internal func addLeftColumnDown() {
        column_left_down = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef - 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef + 0.5 * gS
        )
        column_left_down!.alignment = .Left
        components.append(column_left_down!)
    }
    
    internal func addLeftColumnUp() {
        column_left_up = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef - 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef - column_left_up_height
        )
        column_left_up!.minimumDistance = 0.5 * g
        column_left_up!.alignment = .Left
        components.append(column_left_up!)
    }
    
    internal func addRightColumnDown() {
        column_right_down = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef + 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef + column_right_down_height
        )
        column_right_down!.minimumDistance = 0.5 * g
        column_right_down!.alignment = .Right
        components.append(column_right_down!)
    }
    
    internal func addRightColumnUp() {
        column_right_up = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef + 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef - 0.5 * gS
        )
        components.append(column_right_up!)
        column_right_up!.alignment = .Right
    }
}

public class AccidentalNaturalUp: AccidentalNatural {
    
    public override var description: String { get { return "NaturalUp" } }
    
    
    internal override var column_left_up_height: CGFloat { get { return 2 * gS } }
    
    internal override var height: CGFloat {
        get { return column_left_up_height + column_right_down_height + 0.5 * arrowHeight }
    }
    
    internal override var width: CGFloat { get { return thickLineLength } }
    internal override var xRef: CGFloat { get { return 0.5 * thickLineLength } }
    internal override var yRef: CGFloat {
        get { return column_left_up_height + 0.5 * arrowHeight }
    }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalNaturalUp(g: 40)
        accidental.makePDF(name: "AccidentalNaturalUp")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addLeftColumnUp()
        addLeftColumnDown()
        addRightColumnDown()
        addRightColumnUp()
        addArrow()
    }
    
    internal func addArrow() {
        arrow_left_up = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(xRef - 0.5 * midWidth, yRef - column_left_up_height),
            direction: .North
        )
        components.append(arrow_left_up!)
        arrow_left_up!.minimumDistance = 1.5 * g
        arrow_left_up!.column = column_left_up
        arrow_left_up!.alignment = .Left
        column_left_up?.minimumDistance = 1.5 * g
    }
}

public class AccidentalNaturalDown: AccidentalNatural {
    
    public override var description: String { get { return "NaturalDown" } }
    
    internal override var column_right_down_height: CGFloat { get { return 2 * gS } }
    
    internal override var height: CGFloat {
        get { return column_left_up_height + column_right_down_height + 0.5 * arrowHeight }
    }
    
    internal override var width: CGFloat { get { return thickLineLength } }
    internal override var xRef: CGFloat { get { return 0.5 * thickLineLength } }
    internal override var yRef: CGFloat { get { return column_left_up_height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalNaturalDown(g: 40)
        accidental.makePDF(name: "AccidentalNaturalDown")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addLeftColumnUp()
        addLeftColumnDown()
        addRightColumnDown()
        addRightColumnUp()
        addArrow()
    }
    
    internal func addArrow() {
        arrow_right_down = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(xRef + 0.5 * midWidth, yRef + column_right_down_height),
            direction: .South
        )
        components.append(arrow_right_down!)
        arrow_right_down!.minimumDistance = 1.25 * g
        arrow_right_down!.column = column_right_down
        arrow_right_down!.alignment = .Right
        column_right_down!.minimumDistance = 1.25 * g
    }
}

public class AccidentalSharp: Accidental {
    
    public override var description: String { get { return "Sharp" } }
    
    internal var column_left_up_height: CGFloat { get { return 0.95 * gS } }
    internal var column_left_down_height: CGFloat { get { return 1.05 * gS } }
    internal var column_right_up_height: CGFloat { get { return 1.05 * gS } }
    internal var column_right_down_height: CGFloat { get { return 0.95 * gS } }
    
    
    internal override var height: CGFloat {
        get { return column_right_up_height + column_left_down_height }
    }
    
    internal override var width: CGFloat { get { return thickLineLength } }
    
    internal override var xRef: CGFloat { get { return 0.5 * width } }
    internal override var yRef: CGFloat { get { return 0.5 * height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalSharp(g: 40)
        accidental.makePDF(name: "AccidentalSharp")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnLeftUp()
        addColumnLeftDown()
        addColumnRightUp()
        addColumnRightDown()
    }
    
    internal func addBody() {
        body = AccidentalComponentBodySharp(g: g, scale: s, point: CGPointMake(xRef, yRef))
        components.append(body!)
    }
    
    internal func addColumnLeftUp() {
        column_left_up = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef - 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef - column_left_up_height
        )
        components.append(column_left_up!)
        column_left_up!.minimumDistance = 0.382 * gS
        column_left_up!.alignment = .Left
    }
    
    internal func addColumnLeftDown() {
        column_left_down = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef - 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef + column_left_down_height
        )
        components.append(column_left_down!)
        column_left_down!.minimumDistance = 0.618 * gS
        column_left_down!.alignment = .Left
    }
    
    internal func addColumnRightUp() {
        column_right_up = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef + 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef - column_right_up_height
        )
        components.append(column_right_up!)
        column_right_up!.minimumDistance = 0.618 * gS
        column_right_up!.alignment = .Right
    }
    
    internal func addColumnRightDown() {
        column_right_down = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: xRef + 0.5 * midWidth,
            y_internal: yRef,
            y_external: yRef + column_right_down_height
        )
        components.append(column_right_down!)
        column_right_down!.minimumDistance = 0.382 * gS
        column_right_down!.alignment = .Right
    }
}

public class AccidentalSharpUp: AccidentalSharp {
    
    public override var description: String { get { return "SharpUp" } }
    
    internal override var column_right_up_height: CGFloat { get { return 2 * gS } }
    
    internal override var height: CGFloat {
        get { return column_right_up_height + column_left_down_height + 0.5 * arrowHeight }
    }
    
    internal override var width: CGFloat { get { return thickLineLength } }
    
    internal override var xRef: CGFloat { get { return 0.5 * thickLineLength } }
    internal override var yRef: CGFloat {
        get { return column_right_up_height + 0.5 * arrowHeight }
    }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalSharpUp(g: 40)
        accidental.makePDF(name: "AccidentalSharpUp")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnLeftUp()
        addColumnLeftDown()
        addColumnRightUp()
        addColumnRightDown()
        addArrowUp()
    }
    
    internal func addArrowUp() {
        arrow_right_up = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(xRef + 0.5 * midWidth, yRef - column_right_up_height),
            direction: .North
        )
        components.append(arrow_right_up!)
        arrow_right_up!.minimumDistance = 1.5 * g
        arrow_right_up!.column = column_left_up
        arrow_right_up!.alignment = .Right
        column_right_up!.minimumDistance = 1.5 * g
    }
}

public class AccidentalSharpDown: AccidentalSharp {
    
    public override var description: String { get { return "SharpDown" } }
    
    internal override var column_right_down_height: CGFloat { get { return 2 * gS } }
    
    internal override var height: CGFloat {
        get { return column_right_up_height + column_right_down_height + 0.5 * arrowHeight }
    }
    
    internal override var width: CGFloat { get { return thickLineLength } }
    internal override var xRef: CGFloat { get { return 0.5 * thickLineLength } }
    internal override var yRef: CGFloat { get { return column_right_up_height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalSharpDown(g: 40)
        accidental.makePDF(name: "AccidentalSharpDown")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnLeftUp()
        addColumnLeftDown()
        addColumnRightUp()
        addColumnRightDown()
        addArrowDown()
    }
    
    internal func addArrowDown() {
        arrow_right_down = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(xRef + 0.5 * midWidth, yRef + column_right_down_height),
            direction: .South
        )
        components.append(arrow_right_down!)
        arrow_right_down!.minimumDistance = 1.25 * g
        arrow_right_down!.column = column_right_down
        arrow_right_down!.alignment = .Right
        column_right_down?.minimumDistance = 1.25 * g
    }
}

public class AccidentalFlat: Accidental {
    
    public override var description: String { get { return "Flat" } }
    
    internal var column_up_height: CGFloat { get { return 1.618 * gS } }
    internal var column_down_height: CGFloat { get { return 0.75 * gS } }
    
    internal override var height: CGFloat {
        get { return column_up_height + column_down_height }
    }
    
    internal override var width: CGFloat { get { return midWidth } }
    internal override var xRef: CGFloat { get { return 0.5 * midWidth } }
    internal override var yRef: CGFloat { get { return column_up_height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalFlat(g: 40)
        accidental.makePDF(name: "AccidentalFlat")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
    }
    
    internal func addBody() {
        body = AccidentalComponentBodyFlat(
            g: g, scale: s, point: CGPointMake(xRef + 0.5 * thinLineWidth, yRef)
        )
        components.append(body!)
    }
    
    internal func addColumnUp() {
        column_left_up = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: 0,
            y_internal: yRef,
            y_external: yRef - column_up_height
        )
        components.append(column_left_up!)
        column_left_up!.minimumDistance = 0.5 * g
        column_left_up!.alignment = .Right
    }
    
    internal func addColumnDown() {
        column_left_down = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: 0,
            y_internal: yRef,
            y_external: yRef + column_down_height
        )
        components.append(column_left_down!)
        column_left_down!.alignment = .Left
    }
}

public class AccidentalFlatUp: AccidentalFlat {
    
    public override var description: String { get { return "FlatUp" } }
    
    internal override var column_up_height: CGFloat { get { return 2 * gS } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalFlatUp(g: 40)
        accidental.makePDF(name: "AccidentalFlatUp")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
        addArrowUp()
    }
    
    internal func addArrowUp() {
        // add arrow
        arrow_left_up = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(0, yRef - column_up_height),
            direction: .North
        )
        components.append(arrow_left_up!)
        arrow_left_up!.minimumDistance = 1.25 * gS
        arrow_left_up!.column = column_left_up
        arrow_left_up!.alignment = .Left
        column_left_up!.minimumDistance = 1.25 * gS
    }
}

public class AccidentalFlatDown: AccidentalFlat {
    
    public override var description: String { get { return "FlatDown" } }
    
    internal override var column_down_height: CGFloat { get { return 1.5 * gS } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalFlatDown(g: 40)
        accidental.makePDF(name: "AccidentalFlatDown")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
        addArrowDown()
    }
    
    internal func addArrowDown() {
        arrow_left_down = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(0, yRef + column_down_height),
            direction: .South
        )
        components.append(arrow_left_down!)
        arrow_left_down!.minimumDistance = 1.25 * gS
        arrow_left_down!.column = column_left_down
        arrow_left_down!.alignment = .Left
        column_left_down!.minimumDistance = 1.25 * gS
    }
}

public class AccidentalQuarterSharp: Accidental {
    
    public override var description: String { get { return "QuarterSharp" } }
    
    public var column_up_height: CGFloat { get { return 1.236 * gS } }
    public var column_down_height: CGFloat { get { return 1.236 * gS } }
    
    internal override var height: CGFloat { get { return column_up_height + column_down_height } }
    internal override var width: CGFloat { get { return thickLineLength } }
    
    internal override var xRef: CGFloat { get { return 0.5 * width } }
    internal override var yRef: CGFloat { get { return 0.5 * height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalQuarterSharp(g: 40)
        accidental.makePDF(name: "AccidentalQuarterSharp")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
    }
    
    internal func addBody() {
        body = AccidentalComponentBodyQuarterSharp(
            g: g, scale: s, point: CGPointMake(xRef, yRef)
        )
        components.append(body!)
    }
    
    internal func addColumnUp() {
        column_center_up = AccidentalComponentColumn(
            g: g, scale: s, x: xRef, y_internal: yRef, y_external: yRef - column_up_height
        )
        components.append(column_center_up!)
        column_center_up!.minimumDistance = 0.1 * gS
        column_center_up!.alignment = .Center
    }
    
    internal func addColumnDown() {
        column_center_down = AccidentalComponentColumn(
            g: g, scale: s, x: xRef, y_internal: yRef, y_external: yRef + column_down_height
        )
        components.append(column_center_down!)
        column_center_down!.minimumDistance = 0.1 * gS
        column_center_down!.alignment = .Center
    }
}

public class AccidentalQuarterSharpUp: AccidentalQuarterSharp {
    
    public override var description: String { get { return "QuarterSharpUp" } }
    
    public override var column_up_height: CGFloat { get { return  2 * gS } }
    
    internal override var height: CGFloat {
        get { return column_up_height + column_down_height + 0.5 * arrowHeight }
    }
    internal override var width: CGFloat { get { return thickLineLength } }
    
    internal override var yRef: CGFloat { get { return column_up_height + 0.5 * arrowHeight } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalQuarterSharpUp(g: 40)
        accidental.makePDF(name: "AccidentalQuarterSharpUp")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
        addArrow()
    }
    
    internal func addArrow() {
        arrow_center_up = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(xRef, yRef - column_up_height),
            direction: .North
        )
        components.append(arrow_center_up!)
        arrow_center_up!.minimumDistance = 1 * gS
        arrow_center_up!.column = column_center_up
        arrow_center_up!.alignment = .Center
        column_center_up!.minimumDistance = 1 * gS
        
    }
}

public class AccidentalQuarterSharpDown: AccidentalQuarterSharp {
    
    public override var description: String { get { return "QuarterSharpDown" } }
    
    public override var column_down_height: CGFloat { get { return 2 * gS } }
    
    internal override var height: CGFloat {
        get { return column_up_height + column_down_height + 0.5 * arrowHeight }
    }
    
    internal override var width: CGFloat { get { return thickLineLength } }
    
    internal override var yRef: CGFloat { get { return column_up_height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalQuarterSharpDown(g: 40)
        accidental.makePDF(name: "AccidentalQuarterSharpDown")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
        addArrow()
    }
    
    internal func addArrow() {
        arrow_center_down = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(xRef, yRef + column_down_height),
            direction: .South
        )
        components.append(arrow_center_down!)
        arrow_center_down!.minimumDistance = 1 * gS
        arrow_center_down!.column = column_center_down
        arrow_center_down!.alignment = .Center
        column_center_down!.minimumDistance = 1 * gS
        
    }
}

public class AccidentalQuarterFlat: Accidental {
    
    public override var description: String { get { return "QuarterFlat" } }
    
    public var column_up: AccidentalComponentColumn?
    public var column_down: AccidentalComponentColumn?
    
    internal var column_up_height: CGFloat { get { return 1.618 * gS } }
    internal var column_down_height: CGFloat { get { return 0.75 * gS } }
    
    internal override var height: CGFloat {
        get { return column_up_height + column_down_height }
    }
    
    internal override var width: CGFloat { get { return midWidth } }
    internal override var xRef: CGFloat { get { return 0.5 * midWidth } }
    internal override var yRef: CGFloat { get { return column_up_height } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalQuarterFlat(g: 40)
        accidental.makePDF(name: "AccidentalQuarterFlat")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
    }
    
    internal func addBody() {
        body = AccidentalComponentBodyQuarterFlat(
            g: g,
            scale: s,
            point: CGPointMake(xRef - 0.5 * thinLineWidth, yRef)
        )
        components.append(body!)
    }
    
    internal func addColumnUp() {
        column_right_up = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: width,
            y_internal: yRef,
            y_external: yRef - column_up_height
        )
        column_right_up!.minimumDistance = 0.5 * gS
        column_right_up!.alignment = .Right
        components.append(column_right_up!)
    }
    
    internal func addColumnDown() {
        column_right_down = AccidentalComponentColumn(
            g: g,
            scale: s,
            x: width,
            y_internal: yRef,
            y_external: yRef + column_down_height
        )
        components.append(column_right_down!)
        column_right_down!.alignment = .Right
    }
}

public class AccidentalQuarterFlatUp: AccidentalQuarterFlat {
    
    public override var description: String { get { return "QuarterFlatUp" } }
    
    public var arrow_up: AccidentalComponentArrow?
    
    internal override var column_up_height: CGFloat { get { return 2 * gS } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalQuarterFlatUp(g: 40)
        accidental.makePDF(name: "AccidentalQuarterFlatUp")
    }
    */
    
    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
        addArrowUp()
    }
    
    internal func addArrowUp() {
        arrow_right_up = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(width, yRef - column_up_height),
            direction: .North
        )
        components.append(arrow_right_up!)
        arrow_right_up!.minimumDistance = 1.5 * gS
        arrow_right_up!.column = column_right_up
        column_right_up!.minimumDistance = 1.5 * gS
    }
}

public class AccidentalQuarterFlatDown: AccidentalQuarterFlat {
    
    public override var description: String { get { return "QuarterFlatDown" } }
    
    public var arrow_down: AccidentalComponentArrow?
    
    internal override var column_down_height: CGFloat { get { return 1.5 * gS } }
    
    /*
    public override class func makePDFDocumentation() {
        let accidental = AccidentalQuarterFlatDown(g: 40)
        accidental.makePDF(name: "AccidentalQuarterFlatDown")
    }
    */

    internal override func addComponents() {
        addBody()
        addColumnUp()
        addColumnDown()
        addArrowDown()
    }
    
    internal func addArrowDown() {
        arrow_right_down = AccidentalComponentArrow(
            g: g,
            scale: s,
            point: CGPointMake(width, yRef + column_down_height),
            direction: .South
        )
        components.append(arrow_right_down!)
        arrow_right_down!.minimumDistance = 1.25 * gS
        arrow_right_down!.column = column_right_down
        arrow_right_down!.alignment = .Right
        column_right_down!.minimumDistance = 1.25 * gS
    }
}

public enum AccidentalType: String, CustomStringConvertible {
    case Natural = "Natural"
    case NaturalUp = "NaturalUp"
    case NaturalDown = "NaturalDown"
    case Sharp = "Sharp"
    case SharpUp = "SharpUp"
    case SharpDown = "SharpDown"
    case Flat = "Flat"
    case FlatUp = "FlatUp"
    case FlatDown = "FlatDown"
    case QuarterSharp = "QuarterSharp"
    case QuarterSharpUp = "QuarterSharpUp"
    case QuarterSharpDown = "QuarterSharpDown"
    case QuarterFlat = "QuarterFlat"
    case QuarterFlatUp = "QuarterFlatUp"
    case QuarterFlatDown = "QuarterFlatDown"
    
    public var description: String { get { return rawValue } }
}

public func AccidentalTypeMake(coarse coarse: Float, fine: Float) -> AccidentalType? {
    switch (coarse, fine) {
    case (+0.0, +0.00): return .Natural
    case (+0.0, +0.25): return .NaturalUp
    case (+0.0, -0.25): return .NaturalDown
    case (+1.0, +0.00): return .Sharp
    case (+1.0, +0.25): return .SharpUp
    case (+1.0, -0.25): return .SharpDown
    case (-1.0, +0.00): return .Flat
    case (-1.0, +0.25): return .FlatUp
    case (-1.0, -0.25): return .FlatDown
    case (+0.5, +0.00): return .QuarterSharp
    case (+0.5, +0.25): return .QuarterSharpUp
    case (+0.5, -0.25): return .QuarterSharpDown
    case (-0.5, +0.00): return .QuarterFlat
    case (-0.5, +0.25): return .QuarterFlatUp
    case (-0.5, -0.25): return .QuarterFlatDown
    default: return nil
    }
}