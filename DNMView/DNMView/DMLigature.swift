//
//  DMLigature.swift
//  denm_view
//
//  Created by James Bean on 9/10/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class DMLigature: CALayer {
    
    public var initialDynamicMarkingIntValue: Int?
    public var finalDynamicMarkingIntValue: Int?
    
    public var height: CGFloat = 0
    public var direction: DMLigatureDirection = .Static // hmmmm
    public var segments: [DMLigatureSegment] = []
    public var left: CGFloat = 0 // ?
    public var right: CGFloat = 0 // ?
    
    public var hasBeenBuilt: Bool = false
    
    public init(height: CGFloat) {
        super.init()
        self.height = height
    }
    
    public init(right: CGFloat, height: CGFloat, finalDynamicMarkingIntValue: Int?) {
        super.init()
        self.right = right
        self.height = height
        self.finalDynamicMarkingIntValue = finalDynamicMarkingIntValue
    }
    
    public init(left: CGFloat, height: CGFloat, initialDynamicMarkingIntValue: Int?) {
        super.init()
        self.left = left
        self.height = height
        self.initialDynamicMarkingIntValue = initialDynamicMarkingIntValue
    }
    
    public init(left: CGFloat, height: CGFloat) {
        super.init()
        self.left = left
        self.height = height
    }
    
    public init(right: CGFloat, height: CGFloat) {
        super.init()
        self.right = right
        self.height = height
    }
    
    public init(left: CGFloat, height: CGFloat, direction: DMLigatureDirection) {
        super.init()
        self.left = left
        self.height = height
        self.direction = direction
    }
    
    public init(left: CGFloat, right: CGFloat, height: CGFloat, direction: DMLigatureDirection) {
        super.init()
        self.left = left
        self.right = right
        self.height = height
        self.direction = direction

        let (percentage_left, percentage_right) = getPercentagesLeftAndRightFromDirection(direction)
        addSegmentFromLeft(0,
            toRight: right - left,
            percentageLeft: percentage_left,
            percentageRight: percentage_right
        )
        build()
    }
    
    private func getPercentagesLeftAndRightFromIntValues() -> (CGFloat, CGFloat) {
        assert(
            initialDynamicMarkingIntValue != nil && finalDynamicMarkingIntValue != nil,
            "dynamicMarkingIntValues not set!!"
        )
        if initialDynamicMarkingIntValue > finalDynamicMarkingIntValue { return (1,0) }
        else if initialDynamicMarkingIntValue < finalDynamicMarkingIntValue { return (0,1) }
        else { return (0,0) }
    }
    
    private func getPercentagesLeftAndRightFromDirection(direction: DMLigatureDirection)
        -> (CGFloat, CGFloat)
    {
        let percentage_left: CGFloat
        let percentage_right: CGFloat
        switch direction {
        case .Crescendo:
            percentage_left = 0
            percentage_right = 1
        case .Decrescendo:
            percentage_left = 1
            percentage_right = 0
        case .Static:
            percentage_left = 0
            percentage_right = 0
        }
        return (percentage_left, percentage_right)
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    public func addSegmentsWithPattern(
        pattern: [(
            x0: CGFloat,
            x1: CGFloat,
            percentage0: CGFloat,
            percentage1: CGFloat,
            lineStyle: DMLigatureSegmentStyle
        )]
    )
    {
        for (x0, x1, percentage0, percentage1, lineStyle) in pattern {
            addSegmentFromLeft(x0,
                toRight: x1,
                percentageLeft: percentage0,
                percentageRight:
                percentage1,
                lineStyle: lineStyle
            )
        }
    }
    
    public func completeFromZeroWithDynamicMarkingIntValue(intValue: Int?) {
        assert(right != 0, "right must be set for this to be valid")
        initialDynamicMarkingIntValue = intValue
        
        left = -10
        let (percentage_left, percentage_right) = getPercentagesLeftAndRightFromIntValues()
        addSegmentFromLeft(0,
            toRight: right,
            percentageLeft: percentage_left,
            percentageRight: percentage_right
        )
        build()
    }
    
    public func completeHalfOpenFromLeftWithDynamicMarkingIntValue(intValue: Int?) {
        initialDynamicMarkingIntValue = intValue
        left = -10
        let (_, percentage_right) = getPercentagesLeftAndRightFromIntValues()
        let percentage_left: CGFloat = 0.5
        addSegmentFromLeft(0,
            toRight: right, percentageLeft: percentage_left, percentageRight: percentage_right
        )
        build()
    }
    
    public func completeHalfOpenToX(x: CGFloat, withDynamicMarkingIntValue intValue: Int?) {
        finalDynamicMarkingIntValue = intValue
        right = x - left
        let (percentage_left, _) = getPercentagesLeftAndRightFromIntValues()
        let percentage_right: CGFloat = 0.5
        addSegmentFromLeft(0,
            toRight: right, percentageLeft: percentage_left, percentageRight: percentage_right
        )
        build()
    }
    
    public func completeToX(x: CGFloat, withDynamicMarkingIntValue intValue: Int?) {
        finalDynamicMarkingIntValue = intValue
        right = x - left

        let (percentage_left, percentage_right) = getPercentagesLeftAndRightFromIntValues()
        addSegmentFromLeft(0,
            toRight: right,
            percentageLeft: percentage_left,
            percentageRight: percentage_right
        )
        build()
    }
    
    public func addSegmentFromLeft(
        left: CGFloat,
        toRight right: CGFloat,
        percentageLeft: CGFloat,
        percentageRight: CGFloat,
        lineStyle: DMLigatureSegmentStyle = .Solid
    )
    {
        let segment = DMLigatureSegment(
            height: height,
            left: left,
            right: right,
            percentageLeft: percentageLeft,
            percentageRight: percentageRight,
            lineStyle: lineStyle
        )
        addSegment(segment)
    }
    
    public func addSegment(segment: DMLigatureSegment) {
        segments.append(segment)
    }
    
    public func build() {
        setFrame()
        for segment in segments { addSublayer(segment) }
        hasBeenBuilt = true
    }
    
    // setFrame?
    private func setFrame() {
        let maxX = segments.count == 0 ? 0 : segments.sort({$0.right > $1.right}).first!.right
        frame = CGRectMake(left, 0, maxX, height)
    }
}


/*
public class DMLigature: LigatureHorizontal {
    
    // hairpin, but generalized:
    // - ord cresc, decresc
    // - static
    // - exponential / log bezier types
    
    public var height: CGFloat = 0.0
    public var direction: DMLigatureDirection = .Crescendo
    public var exponent: Float = 1.0
    
    public var hasBeenBuilt: Bool = false
    
    public init(
        height: CGFloat,
        left: CGFloat,
        direction: DMLigatureDirection,
        exponent: Float = 1.0
    )
    {
        self.height = height
        self.direction = direction
        self.exponent = exponent
        super.init()
        self.left = left
        // unbuilt!
    }
    
    public init(
        height: CGFloat,
        y: CGFloat,
        left: CGFloat,
        right: CGFloat,
        direction: DMLigatureDirection,
        exponent: Float = 1.0
    )
    {
        self.height = height
        self.direction = direction

        //super.init(y: y, left: left, right: right)
        super.init()
        self.left = left
        self.right = right
        build()
    }
    
    public init(height: CGFloat, y: CGFloat, left: CGFloat, direction: DMLigatureDirection) {
        self.height = height
        self.direction = direction
        //super.init(y: y, left: left, right: left) // for now make it infinitessimally thin
        super.init()
        self.left = left
        self.right = right
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        path = makePath()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    private func makePath() -> CGPath {
        // something
        let path = UIBezierPath()
        
        switch direction {
        case .Crescendo:
            // if exponent != 1, etc...
            
            path.moveToPoint(CGPointMake(right, y - 0.5 * height))
            path.addLineToPoint(CGPointMake(left, y))
            path.addLineToPoint(CGPointMake(right, y + 0.5 * height))
        case .Decrescendo:
            path.moveToPoint(CGPointMake(left, y - 0.5 * height))
            path.addLineToPoint(CGPointMake(right, y))
            path.addLineToPoint(CGPointMake(left, y + 0.5 * height))
        case .Static:
            path.moveToPoint(CGPointMake(left, y))
            path.addLineToPoint(CGPointMake(right, y))
        }
        
        // TO-DO: EXPONENTIAL: switch Exponent
        
        return path.CGPath
    }
    
    private func setVisualAttributes() {
        strokeColor = UIColor.grayColor().CGColor
        fillColor = UIColor.whiteColor().CGColor
        lineJoin = kCALineJoinBevel
        lineWidth = 0.1236 * height
        //lineDashPattern = [2]
    }
}
*/

public enum DMLigatureDirection {
    case Crescendo, Decrescendo, Static
}