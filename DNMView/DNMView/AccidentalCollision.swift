//
//  AccidentalCollision.swift
//  denm_view
//
//  Created by James Bean on 8/18/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

// TODO: Break this out into multiple files
public class AccidentalDyad: CustomStringConvertible {
    
    public var description: String { get { return "\(accidental0); \(accidental1)" } }
    
    public var accidental0: Accidental
    public var accidental1: Accidental
    
    public init(accidental0: Accidental, accidental1: Accidental) {
        var accidentals: [Accidental] = [accidental0, accidental1]
        accidentals.sortInPlace { $0.point.y > $1.point.y }
        self.accidental0 = accidentals[0]
        self.accidental1 = accidentals[1]
    }
}

public class AccidentalDyadMover {
    
    public var dyad: AccidentalDyad
    
    public var staffEvent: StaffEvent? // deprecate!
    
    public var g: CGFloat = 0
    public var pad: CGFloat { get { return 0.0618 * g } }
    
    public var hasCollision: Bool { get { return getHasCollision() } }
    public var collisions: [AccidentalComponentDyad] { get { return getCollisions() } }
    public var canBeSpelledWithoutMovement: Bool {
        get { return getCanBeSpelledWithoutMovement() }
    }
    
    public init(dyad: AccidentalDyad, g: CGFloat) {
        self.dyad = dyad
        self.g = g
    }
    
    public init(dyad: AccidentalDyad) {
        self.dyad = dyad
    }
    
    public init(dyad: AccidentalDyad, staffEvent: StaffEvent?) {
        self.dyad = dyad
        self.staffEvent = staffEvent
    }
    
    public func moveLowerAccidental() {
        dyad.accidental0.position.x -= dyad.accidental1.body!.collisionFrame.width + 1.5 * pad
    }
    
    public func adjust() {
        
        let b0 = dyad.accidental0.body!
        let b1 = dyad.accidental1.body!
        let b0_poly = getContextualPolygonForComponent(b0)
        let b1_poly = getContextualPolygonForComponent(b1)
        
        for collision in collisions {
            /*
            if let a0 = collision.component0 as? AccidentalComponentArrow {
            if let a1 = collision.component1 as? AccidentalComponentArrow {
            // c0, c1
            }
            }
            */
            if let a0 = collision.component0 as? AccidentalComponentArrow {
                if let b1 = collision.component1 as? AccidentalComponentBody {
                    var amount: CGFloat = 0
                    var isStillColliding: Bool = true
                    while isStillColliding {
                        a0.contractByStep()
                        let a0_poly = getContextualPolygonForComponent(a0)
                        let a0_x = a0_poly.midX!
                        let a0_y = a0_poly.minY!
                        let b1_y = b1_poly.getYValueAtX(a0_x, fromDirection: .South)
                        if a0_y > b1_y { isStillColliding = false }
                        else { amount += a0.contractionStepSize }
                    }
                    a0.column?.contractByAmount(amount)
                    
                    let a0_poly = getContextualPolygonForComponent(a0)
                    let c1 = getColumnThatConflictsWithArrow(a0)
                    let c1_len = a0_poly.minY! - b1.accidental!.point.y
                    c1?.contractToLength(c1_len - pad)
                }
            }
            if let b0 = collision.component0 as? AccidentalComponentBody {
                if let a1 = collision.component1 as? AccidentalComponentArrow {
                    var amount: CGFloat = 0
                    var isStillColliding: Bool = true
                    while isStillColliding {
                        a1.contractByStep()
                        let a1_poly = getContextualPolygonForComponent(a1)
                        let a1_x = a1_poly.midX!
                        let a1_y = a1_poly.maxY!
                        let b0_y = b0_poly.getYValueAtX(a1_x, fromDirection: .North)
                        if a1_y < b0_y { isStillColliding = false }
                        else { amount += a1.contractionStepSize }
                    }
                    a1.column?.contractByAmount(amount)
                    
                    let a1_poly = getContextualPolygonForComponent(a1)
                    let c0 = getColumnThatConflictsWithArrow(a1)
                    let c0_len = b0.accidental!.point.y - a1_poly.maxY!
                    c0?.contractToLength(c0_len - pad)
                }
            }
            
            if let a0 = collision.component0 as? AccidentalComponentArrow {
                if let c1 = collision.component1 as? AccidentalComponentColumn {
                    if a0.direction != c1.direction {
                        if !a0.hasBeenContracted {
                            a0.contractByStep()
                            a0.column?.contractByAmount(a0.contractionStepSize)
                        }
                        let a0_poly = getContextualPolygonForComponent(a0)
                        let c1_poly = getContextualPolygonForComponent(c1)
                        let c1_x = c1_poly.midX!
                        let a0_x = a0_poly.midX!
                        if c1_x == a0_x {
                            let c1_len = a0_poly.minY! - c1.accidental!.point.y
                            c1.contractToLength(c1_len - pad)
                        }
                        else {
                            let c1_len = a0_poly.midY! - c1.accidental!.point.y
                            c1.contractToLength(c1_len)
                        }
                    }
                }
            }
            
            if let c0 = collision.component0 as? AccidentalComponentColumn {
                if let a1 = collision.component1 as? AccidentalComponentArrow {
                    if c0.direction != a1.direction {
                        if !a1.hasBeenContracted {
                            a1.contractByStep()
                            a1.column?.contractByAmount(a1.contractionStepSize)
                        }
                        let a1_poly = getContextualPolygonForComponent(a1)
                        let c0_poly = getContextualPolygonForComponent(c0)
                        let c0_x = c0_poly.midX!
                        let a1_x = a1_poly.midX!
                        if a1_x == c0_x {
                            let c0_len = c0.accidental!.point.y - a1_poly.maxY!
                            c0.contractToLength(c0_len - pad)
                        }
                        else {
                            let c0_len = c0.accidental!.point.y - a1_poly.midY!
                            c0.contractToLength(c0_len)
                        }
                    }
                }
            }
            
            if let c0 = collision.component0 as? AccidentalComponentColumn {
                if let b1 = collision.component1 as? AccidentalComponentBody {
                    let c0_poly = getContextualPolygonForComponent(c0)
                    let c0_x = c0_poly.midX!
                    let b1_y = b1_poly.getYValueAtX(c0_x, fromDirection: .South)
                    let c0_len = c0.accidental!.point.y - b1_y
                    c0.contractToLength(c0_len - 2 * pad)
                }
            }
            
            if let b0 = collision.component0 as? AccidentalComponentBody {
                if let c1 = collision.component1 as? AccidentalComponentColumn {
                    let c1_poly = getContextualPolygonForComponent(c1)
                    let c1_x = c1_poly.midX!
                    let b0_y = b0_poly.getYValueAtX(c1_x, fromDirection: .North)
                    let c1_len = b0_y - c1.accidental!.point.y
                    c1.contractToLength(c1_len - 2 * pad)
                }
            }
            
            if let c0 = collision.component0 as? AccidentalComponentColumn {
                if let c1 = collision.component1 as? AccidentalComponentColumn {
                    if c0.direction != c1.direction {
                        let c0_poly = getContextualPolygonForComponent(c0)
                        let c1_poly = getContextualPolygonForComponent(c1)
                        let x = c0_poly.midX!
                        let b0_y = b0_poly.getYValueAtX(x, fromDirection: .North)
                        let b1_y = b1_poly.getYValueAtX(x, fromDirection: .South)
                        let distance = b0_y - b1_y
                        if distance > 0.382 * c0.gS {
                            let c0_len = (c0.accidental!.point.y - b0_y) + 0.618 * distance
                            let c1_len = (b1_y - c1.accidental!.point.y) + 0.382 * distance
                            c0.contractToLength(c0_len - pad)
                            c1.contractToLength(c1_len - pad)
                        }
                        else {
                            if !c0.canContract {
                                let c1_len = b0_y - c1.accidental!.point.y
                                c1.contractToLength(c1_len - pad)
                            }
                            else {
                                c1.contractToMinimumDistance()
                                let c0_len = c0.accidental!.point.y - b1_y
                                c0.contractToLength(c0_len - pad)
                            }
                        }
                    }
                }
            }
        }
    }
    
    internal func getContextualPolygonForComponent(component: AccidentalComponent) -> Polygon {
        return staffEvent!.convertPolygon(component.polygon, fromLayer: component)
    }
    
    internal func getColumnThatConflictsWithArrow(arrow: AccidentalComponentArrow) -> AccidentalComponentColumn?
    {
        let otherAccidental: Accidental = arrow.accidental! === dyad.accidental0
            ? dyad.accidental1
            : dyad.accidental0
        var c: AccidentalComponentColumn?
        for component in otherAccidental.components {
            if let _c = component as? AccidentalComponentColumn {
                if arrow.alignment == _c.alignment && arrow.direction != _c.direction {
                    c = _c
                    break
                }
            }
        }
        return c
    }
    
    internal func getHasCollision() -> Bool {
        for c0 in dyad.accidental0.components {
            let c0_poly = staffEvent!.convertPolygon(c0.polygon, fromLayer: c0)
            for c1 in dyad.accidental1.components {
                let c1_poly = staffEvent!.convertPolygon(c1.polygon, fromLayer: c1)
                if c0_poly.collidesWithPolygon(c1_poly) { return true }
            }
        }
        return false
    }
    
    internal func getCollisions() -> [AccidentalComponentDyad] {
        var collisions: [AccidentalComponentDyad] = []
        for c0 in dyad.accidental0.components {
            let c0_poly = staffEvent!.convertPolygon(c0.polygon, fromLayer: c0)
            for c1 in dyad.accidental1.components {
                let c1_poly = staffEvent!.convertPolygon(c1.polygon, fromLayer: c1)
                if c0_poly.collidesWithPolygon(c1_poly) {
                    let collision = AccidentalComponentDyad(component0: c0, component1: c1)
                    collisions.append(collision)
                }
            }
        }
        sortCollisionsByType(&collisions)
        return collisions
    }
    
    internal func sortCollisionsByType(inout collisions: [AccidentalComponentDyad]) {
        //  a = arrow; b = body; c = column
        var c_c: [AccidentalComponentDyad] = []
        var c_a: [AccidentalComponentDyad] = []
        var c_b: [AccidentalComponentDyad] = []
        var a_c: [AccidentalComponentDyad] = []
        var a_a: [AccidentalComponentDyad] = []
        var a_b: [AccidentalComponentDyad] = []
        var b_a: [AccidentalComponentDyad] = []
        var b_c: [AccidentalComponentDyad] = []
        var b_b: [AccidentalComponentDyad] = []
        
        for collision in collisions {
            let component0 = collision.component0
            let component1 = collision.component1
            
            typealias A = AccidentalComponentArrow
            typealias B = AccidentalComponentBody
            typealias C = AccidentalComponentColumn
            
            if component0 is A && component1 is A { a_a.append(collision) }
            else if component0 is A && component1 is B { a_b.append(collision) }
            else if component0 is A && component1 is C { a_c.append(collision) }
            else if component0 is B && component1 is A { b_a.append(collision) }
            else if component0 is B && component1 is B { b_b.append(collision) }
            else if component0 is B && component1 is C { b_c.append(collision) }
            else if component0 is C && component1 is A { c_a.append(collision) }
            else if component0 is C && component1 is B { c_b.append(collision) }
            else if component0 is C && component1 is C { c_c.append(collision) }
        }
        
        var newCollisions: [AccidentalComponentDyad] = []
        for collisionType in [a_a, a_b, b_a, a_c, c_a, c_c, c_b, b_c, b_b] {
            for collision in collisionType { newCollisions.append(collision) }
        }
        collisions = newCollisions
    }
    
    // clean up!
    internal func getCanBeSpelledWithoutMovement() -> Bool {
        if !hasCollision { return true }
        if bodiesCollide() { return false }
        
        if dyad.accidental1.arrow != nil && dyad.accidental1.arrow!.direction == .South {
            
            let arrow1 = dyad.accidental1.arrow!
            let arrow1_poly = staffEvent!.convertPolygon(arrow1.polygon, fromLayer: arrow1)
            let body0 = dyad.accidental0.body!
            let body0_poly = staffEvent!.convertPolygon(body0.polygon, fromLayer: body0)
            
            // encapsulate
            let body0_y = body0_poly.getYValueAtX(arrow1_poly.midX!, fromDirection: .North)
            //if body0_y == nil { body0_y = body0_poly.minY! }
            
            
            let arrow1_minY = arrow1.accidental!.point.y + arrow1.minimumDistance! + 0.5 * arrow1.height
            
            if arrow1_minY + pad > body0_y { return false }
        }
        
        if dyad.accidental0.arrow != nil && dyad.accidental0.arrow!.direction == .North {
            let arrow0 = dyad.accidental0.arrow!
            let arrow0_poly = staffEvent!.convertPolygon(arrow0.polygon, fromLayer: arrow0)
            let body1 = dyad.accidental1.body!
            let body1_poly = staffEvent!.convertPolygon(body1.polygon, fromLayer: body1)
            let body1_y = body1_poly.getYValueAtX(arrow0_poly.midX!, fromDirection: .South)
            
            let arrow0_maxY = arrow0.accidental!.point.y - arrow0.minimumDistance! - 0.5 * arrow0.height
            
            if arrow0_maxY - pad < body1_y { return false }
        }
        
        // make more subtle
        return true
    }
    
    internal func bodiesCollide() -> Bool {
        let body0 = dyad.accidental0.body!
        let body1 = dyad.accidental1.body!
        let body0_poly = staffEvent!.convertPolygon(body0.polygon, fromLayer: body0)
        let body1_poly = staffEvent!.convertPolygon(body1.polygon, fromLayer: body1)
        return body0_poly.collidesWithPolygon(body1_poly)
    }
}

public class AccidentalVerticality {
    
    public var accidentals: [Accidental] = []
    public var dyads: [AccidentalDyad]? { get { return getDyads() } }
    
    public init(accidentals: [Accidental]) {
        let sortedAccidentals = accidentals
        //sortedAccidentals.sort { $0.point.y < $1.point.y }
        self.accidentals = sortedAccidentals
    }
    
    internal func getDyads() -> [AccidentalDyad]? {
        if accidentals.count < 2 { return nil }
        let reversedAccidentals: [Accidental] = Array(accidentals.reverse())
        var dyads: [AccidentalDyad] = []
        var index0: Int = 0
        while index0 < accidentals.count {
            var index1: Int = index0 + 1
            while index1 < accidentals.count {
                let dyad = AccidentalDyad(
                    accidental0: reversedAccidentals[index0],
                    accidental1: reversedAccidentals[index1]
                )
                dyads.append(dyad)
                index1++
            }
            index0++
        }
        return dyads
    }
}

public class AccidentalVerticalityMover {
    
    public var staffEvent: StaffEvent?
    public var pad: CGFloat { get { return 0.236 * staffEvent!.g } }
    
    public var verticality: AccidentalVerticality
    
    public var columns: [Int : AccidentalColumn] = [:]
    
    public var initialOffset: CGFloat = 0
    
    public init(verticality: AccidentalVerticality) {
        self.verticality = verticality
    }
    
    public init(verticality: AccidentalVerticality, staffEvent: StaffEvent, initialOffset: CGFloat = 0) {
        self.verticality = verticality
        self.staffEvent = staffEvent
        self.initialOffset = initialOffset
    }

    public func move() {
        
        addColumnAtIndex(0)
        columns[0]?.accidentals = verticality.accidentals
        columns[0]?.right = initialOffset
        
        // set all accidentals initially to zero
        for accidental in columns[0]!.accidentals { accidental.column = 0 }
        
        if verticality.dyads == nil {
            columns[0]?.right = -(initialOffset + pad)
            columns[0]?.alignAccidentals()
            return
        }
        
        // or while :
        // -- only do one column at a time
        
        var col: Int = 0
        while true {
            if columns[col]!.dyads == nil { break }
            for dyad in columns[col]!.dyads! {
                //let mover = AccidentalDyadMover(dyad: dyad, staffEvent: staffEvent)
                
                //let mover = AccidentalDyadMover(dyad: dyad, g: g)
                let mover = AccidentalDyadMover(dyad: dyad, staffEvent: staffEvent)
                if mover.hasCollision && !mover.canBeSpelledWithoutMovement {
                    if dyad.accidental0 is AccidentalQuarterFlatUp {
                        if dyad.accidental0.column! == col && dyad.accidental1.column! == col {
                            moveAccidental(dyad.accidental1)
                        }
                    }
                    else {
                        if dyad.accidental0.column! == col && dyad.accidental1.column! == col {
                            moveAccidental(dyad.accidental0)
                        }
                    }
                }
            }
            if columns[col + 1] == nil { break }
            else { col++ }
        }
        
        
        // encapsulate / clean up!
        var sortedColumns: [(index: Int, column: AccidentalColumn)] = []
        for (index, column) in columns {
            sortedColumns.append((index: index, column: column))
        }
        
        sortedColumns.sortInPlace { $0.index < $1.index }
        
        var columnsOrdered: [AccidentalColumn] = []
        for (_, column) in sortedColumns { columnsOrdered.append(column) }
        
        // encapsulate
        
        
        var accumWidth: CGFloat = initialOffset
        for column in columnsOrdered {
            column.right = -(accumWidth + pad)  // + 0.5 * width padding (rel)
            column.alignAccidentals()
            accumWidth += column.width + pad
        }
        
        for (_, column) in columns {
            if column.accidentals.count >= 2 {
                for dyad in column.dyads! {
                    //let mover = AccidentalDyadMover(dyad: dyad)
                    let mover = AccidentalDyadMover(dyad: dyad, staffEvent: staffEvent)
                    //mover.staffEvent = staffEvent
                    //let mover = AccidentalDyadMover(dyad: dyad, g: g)
                    if mover.hasCollision && mover.canBeSpelledWithoutMovement {
                        mover.adjust()
                    }
                }
            }
        }
    }
    
    internal func addColumnAtIndex(index: Int) {
        columns[index] = AccidentalColumn()
    }
    
    internal func moveAccidental(accidental: Accidental) {
        let curColumn: Int = accidental.column!
        let nextColumn: Int = curColumn + 1
        if columns[nextColumn] == nil { addColumnAtIndex(nextColumn) }
        columns[nextColumn]?.addAccidental(accidental)
        columns[curColumn]?.removeAccidental(accidental)
        accidental.column = nextColumn
    }
}

public class AccidentalColumn: AccidentalVerticality {
    
    public var columnToTheRight: AccidentalColumn?
    public var columnToTheLeft: AccidentalColumn?
    
    public var right: CGFloat = 0
    public var x: CGFloat { get { return right - 0.5 * width } }
    public var width: CGFloat { get { return getWidth() } }
    
    public var index: Int?
    
    init() {
        super.init(accidentals: [])
    }
    
    public func addAccidental(accidental: Accidental) {
        accidentals.append(accidental)
        alignAccidentals()
    }
    
    public func removeAccidental(accidental: Accidental) {
        accidentals.removeObject(accidental)
        //accidentals.remove(accidental)
        alignAccidentals()
    }
    
    public func alignAccidentals() {
        for accidental in accidentals {
            accidental.position.x = x
        }
    }
    
    internal func getWidth() -> CGFloat {
        var maxWidth: CGFloat = 0
        for accidental in accidentals {
            if maxWidth == 0 { maxWidth = accidental.boundingWidth! }
            else if accidental.boundingWidth! > maxWidth {
                maxWidth = accidental.boundingWidth!
            }
        }
        return maxWidth
    }
}