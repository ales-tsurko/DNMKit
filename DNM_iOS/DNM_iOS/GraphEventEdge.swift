//
//  GraphEventEdge.swift
//  denm_view
//
//  Created by James Bean on 9/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public class GraphEventEdge: CAShapeLayer {
    
    public var graph: Graph?
    
    public var point1: CGPoint?
    public var point2: CGPoint?
    
    
    public var spannerArguments: SpannerArguments!

    // scale the spannerArguments (width values are relative, etc)
    // need to get scaling information from parent graph, prolly from "g", yikes
    
    // add graph
    public init(
        point1: CGPoint? = nil,
        point2: CGPoint? = nil,
        spannerArguments: SpannerArguments,
        graph: Graph? = nil
    )
    {
        super.init()
        self.point1 = point1
        self.point2 = point2
        self.spannerArguments = spannerArguments
        self.graph = graph
        build()
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        path = makePath()
        setVisualAttributes()
    }
    
    public func makePath() -> CGPath {
        if let point1 = point1, point2 = point2 {

            
            let curve = BezierCurveLinear(point1: point1, point2: point2)
            var styledCurve: StyledBezierCurve = ConcreteStyledBezierCurve(carrierCurve: curve)
            
            switch spannerArguments.widthArgs.count {
            case 0:
                styledCurve = BezierCurveStylerWidth(styledBezierCurve: styledCurve, width: 1)
            case 1:
                let width = CGFloat(spannerArguments.widthArgs[0])
                styledCurve = BezierCurveStylerWidth(
                    styledBezierCurve: styledCurve, width: width
                )
            case 2:
                let widthAtBeginning = CGFloat(spannerArguments.widthArgs[0])
                let widthAtEnd = CGFloat(spannerArguments.widthArgs[1])
                styledCurve = BezierCurveStyleWidthVariable(
                    styledBezierCurve: styledCurve,
                    widthAtBeginning: widthAtBeginning,
                    widthAtEnd: widthAtEnd
                )
            case 3:
                let widthAtBeginning = CGFloat(spannerArguments.widthArgs[0])
                let widthAtEnd = CGFloat(spannerArguments.widthArgs[1])
                let exponent = CGFloat(spannerArguments.widthArgs[2])
                styledCurve = BezierCurveStyleWidthVariable(styledBezierCurve: styledCurve,
                    widthAtBeginning: widthAtBeginning,
                    widthAtEnd: widthAtEnd,
                    exponent: exponent
                )
            default:
                print("too many args for graph event edge")
            }
            
            // manage Spanner Arguments
            
            return styledCurve.uiBezierPath.CGPath
            
            /*
            if hasDashes {
                var styledCurve: StyledBezierCurve = ConcreteStyledBezierCurve(carrierCurve: curve)
                styledCurve = BezierCurveStylerDashes(styledBezierCurve: styledCurve)
                return styledCurve.uiBezierPath.CGPath
            }
            else {
                var styledCurve: StyledBezierCurve = ConcreteStyledBezierCurve(carrierCurve: curve)
                styledCurve = BezierCurveStylerWidth(styledBezierCurve: styledCurve, width: 1)
                return styledCurve.uiBezierPath.CGPath
            }
            */

        }
        // otherwise, return empty path
        return UIBezierPath().CGPath
    }
    
    public func setVisualAttributes() {
        fillColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
    }
}
