//
//  DMCharacter.swift
//  denm_view
//
//  Created by James Bean on 9/10/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class DMCharacter: CAShapeLayer {
    
    public var x: CGFloat = 0
    public var top: CGFloat = 0
    public var width: CGFloat { get { return 0 } }
    public var height: CGFloat = 0
    
    public var italicAngle: CGFloat = 0
    public var midLine: CGFloat { get { return 0.5 * height } }
    public var xHeight: CGFloat { get { return 0.2 * height } }
    public var capHeight: CGFloat { get { return 0.0618 * height } }
    public var baseline: CGFloat { get { return 0.75 * height } }
    public var restLine: CGFloat { get { return 0.9 * height } }
    
    public class func withDMCharacterType(type: DMCharacterType, height: CGFloat)
        -> DMCharacter?
    {
        let dmCharacter: DMCharacter?
        switch type {
        case .F: dmCharacter = DMCharacter_f()
        case .P: dmCharacter = DMCharacter_p()
        case .M: dmCharacter = DMCharacter_m()
        case .O: dmCharacter = DMCharacter_o()
        case .Exclamation: return nil
        case .Paren_open: return nil
        case .Paren_close: return nil
        }
        dmCharacter!.height = height
        
        // still needs position set, and build()
        
        return dmCharacter!
    }
    
    public class func dmCharacterWithDMCharacterType(
        type: DMCharacterType,
        x: CGFloat,
        height: CGFloat
        ) -> DMCharacter?
    {
        let dmCharacter: DMCharacter?
        switch type {
        case .F: dmCharacter = DMCharacter_f()
        case .P: dmCharacter = DMCharacter_p()
        default: return nil
        }
        dmCharacter!.x = x
        dmCharacter!.height = height
        dmCharacter!.build()
        return dmCharacter!
    }
    
    internal func build() {
        path = makePath()
        setFrame()
        setVisualAttributes()
    }
    
    private func setFrame() {
        // get bounding box?, then -0.5 * width
        frame = CGRectMake(x - 0.5 * width, top, width, height)
    }
    
    private func makePath() -> CGPath {
        // make path, override in subclassesq
        return UIBezierPath().CGPath
    }
    
    private func setVisualAttributes() {
        strokeColor = UIColor.grayscaleColorWithDepthOfField(.MostForeground).CGColor
        fillColor = UIColor.clearColor().CGColor
        lineJoin = kCALineJoinBevel
        lineWidth = 0.0618 * height
    }
}

public class DMCharacter_f: DMCharacter {
    
    public override var width: CGFloat { get { return baseline - xHeight } }
    private var crossStroke_length: CGFloat { get { return 0.5 * width } }
    
    override func makePath() -> CGPath {
        let path = UIBezierPath()
        addDownStrokeToPath(path)
        addCrossStrokeToPath(path)
        return path.CGPath
    }
    
    private func addDownStrokeToPath(path: UIBezierPath) {
        let downStroke = UIBezierPath()
        downStroke.moveToPoint(CGPointMake(0, restLine))
        downStroke.addLineToPoint(CGPointMake(0.236 * width, height))
        downStroke.addLineToPoint(CGPointMake(0.618 * width, xHeight))
        downStroke.addCurveToPoint(
            CGPointMake(width, capHeight),
            controlPoint1: CGPointMake(0.825 * width, -0.1236 * height),
            controlPoint2: CGPointMake(width, capHeight)
        )
        path.appendPath(downStroke)
    }
    
    private func addCrossStrokeToPath(path: UIBezierPath) {
        let crossStroke = UIBezierPath()
        crossStroke.moveToPoint(
            CGPointMake(0.618 * width - 0.5 * crossStroke_length, xHeight)
        )
        crossStroke.addLineToPoint(
            CGPointMake(0.618 * width + 0.5 * crossStroke_length, xHeight)
        )
        path.appendPath(crossStroke)
    }
}


public class DMCharacter_p: DMCharacter {
    
    public override var width: CGFloat { get { return baseline - xHeight } }
    public var serif_length: CGFloat { get { return 0.382 * width } }
    
    override func makePath() -> CGPath {
        let path = UIBezierPath()
        addStemStrokeToPath(path)
        addBowlStrokeToPath(path)
        addSerifStrokeToPath(path)
        return path.CGPath
    }
    
    private func addStemStrokeToPath(path: UIBezierPath) {
        let stemStroke = UIBezierPath()
        stemStroke.moveToPoint(CGPointMake(0.5 * serif_length, restLine))
        stemStroke.addLineToPoint(CGPointMake(0.618 * width, xHeight))
        stemStroke.addLineToPoint(CGPointMake(0.33 * width, xHeight + 0.0618 * height))
        path.appendPath(stemStroke)
    }
    
    private func addBowlStrokeToPath(path: UIBezierPath) {
        let bowlStroke = UIBezierPath(
            ovalInRect: CGRectMake(
                0.5 * width, midLine - 0.25 * width, 0.5 * width, 0.5 * width
            )
        )
        path.appendPath(bowlStroke)
    }
    
    private func addSerifStrokeToPath(path: UIBezierPath) {
        let serifStroke = UIBezierPath()
        serifStroke.moveToPoint(CGPointMake(0, restLine))
        serifStroke.addLineToPoint(CGPointMake(serif_length, restLine))
        path.appendPath(serifStroke)
    }
    
    override func setVisualAttributes() {
        super.setVisualAttributes()
        fillColor = DNMColorManager.backgroundColor.CGColor
    }
}

public class DMCharacter_o: DMCharacter {
    
    public override var width: CGFloat { get { return 0.618 * (baseline - xHeight) } }
    
    override func makePath() -> CGPath {
        let path = UIBezierPath(ovalInRect: CGRectMake(0, midLine - 0.5 * width, width, width))
        return path.CGPath
    }
    
    override func setVisualAttributes() {
        super.setVisualAttributes()
        fillColor = DNMColorManager.backgroundColor.CGColor
    }
}

public class DMCharacter_m: DMCharacter {
    
    public override var width: CGFloat { get { return baseline - xHeight } }
    
    override func makePath() -> CGPath {
        // something
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, baseline))
        path.addLineToPoint(CGPointMake(0, xHeight))
        path.addLineToPoint(CGPointMake(0.5 * width, xHeight + 0.5 * (baseline - xHeight)))
        path.addLineToPoint(CGPointMake(width, xHeight))
        path.addLineToPoint(CGPointMake(width, baseline))
        return path.CGPath
    }
}

public enum DMCharacterType {
    case F, P, M, O, Exclamation, Paren_open, Paren_close
}