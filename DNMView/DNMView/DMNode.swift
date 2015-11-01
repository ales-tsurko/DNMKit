//
//  DMNode.swift
//  denm_view
//
//  Created by James Bean on 9/10/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class DMNode: ViewNode {
    
    public var height: CGFloat = 0
    public var ligatureHeight: CGFloat { get { return 0.382 * height } }
    
    // setPads()
    
    //public override var pad_above: CGFloat { get { return 0.236 * frame.height } }
    //public override var pad_below: CGFloat { get { return 0.236 * frame.height } }
    
    public var dynamicMarkings: [DynamicMarking] = []
    public var ligatures: [DMLigature] = []
    
    public var dynamicMarkingsWithLigatureType: [(DynamicMarking, Float)] = []
    
    public init(height: CGFloat) {
        self.height = height
        super.init()
        layoutFlow_vertical = .Top
        //setsHeightWithContents = false
        // encapsulate somewhere...
        //frame = CGRectMake(frame.minX, frame.minY, frame.width, height)
    }
    
    // stratum of DynamicMarkings, with interpolations
    public override init() {
        super.init()
        layoutFlow_vertical = .Top
        //setsHeightWithContents = false
        // encapsulate somewhere...
        //frame = CGRectMake(frame.minX, frame.minY, frame.width, height)
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }

    public func build() {
        commitLigatures()
        layout()
    }
    
    public func getDynamicMarkingAtX(x: CGFloat) -> DynamicMarking? {
        for dynamicMarking in dynamicMarkings {
            if dynamicMarking.x == x {
                return dynamicMarking
            }
        }
        return nil
    }
    
    public func addDynamicMarkingsWithString(string: String,
        withLigatureType ligatureType: Float = 0, atX x: CGFloat
    )
    {
        let dynamicMarking = DynamicMarking(string: string, x: x, top: 0, height: height)
        addDynamicMarking(dynamicMarking)
        dynamicMarkingsWithLigatureType.append((dynamicMarking, ligatureType))
    }
    
    public func addSegmentToCurrentLigatureFromLeft(
        left: CGFloat,
        toRight right: CGFloat,
        percentageLeft: CGFloat,
        percentageRight: CGFloat,
        lineStyle: DMLigatureSegmentStyle = .Solid
    )
    {
        // to-do
    }
    
    private func addLigatures() {
        dynamicMarkingsWithLigatureType.sortInPlace({$0.0.position.x < $1.0.position.x})
    }
    
    override func setHeightWithContents() {
        if dynamicMarkings.count > 0 { super.setHeightWithContents() }
        else {
            if ligatures.count > 0 {
                frame = CGRectMake(frame.minX, frame.minY, frame.width, height)
            }
        }
    }
    
    /*
    public func addLigatureWithDirection(
        direction: DMLigatureDirection,
        fromLeft left: CGFloat,
        toRight right: CGFloat
    )
    {
        let ligature = DMLigature(left: left, height: ligatureHeight)
        
        //let ligature = DMLigature(left: left, height: height, direction: direction)
        
        let percentageLeft: CGFloat
        let percentageRight: CGFloat
        switch direction {
        case .Decrescendo:
            percentageLeft = 1
            percentageRight = 0
        case .Crescendo:
            percentageLeft = 0
            percentageRight = 1
            break
        case .Static:
            percentageLeft = 0.5
            percentageRight = 0.5
        }
        
        ligature.addSegmentFromLeft(0,
            toRight: right, percentageLeft: percentageLeft, percentageRight: percentageRight
        )
        ligature.build()
        addLigature(ligature)
    }
    */
    
    public func startLigatureAtX(x: CGFloat, withDynamicMarkingIntValue intValue: Int?) {
        let ligature = DMLigature(
            left: x, height: ligatureHeight, initialDynamicMarkingIntValue: intValue
        )
        addLigature(ligature)
    }
    
    /*
    public func startLigatureWithDirection(direction: DMLigatureDirection, atX x: CGFloat) {
        let ligature = DMLigature(left: x, height: ligatureHeight, direction: direction)
        addLigature(ligature)
    }
    */
    
    public func stopCurrentLigatureAtX(x: CGFloat, withDynamicMarkingIntValue intValue: Int?) {
        if ligatures.count > 0 {
            ligatures.last!.completeToX(x, withDynamicMarkingIntValue: intValue)
            ligatures.last!.build()
        }
        else {
            let ligature = DMLigature(
                right: x, height: ligatureHeight, finalDynamicMarkingIntValue: intValue
            )
            addLigature(ligature)
        }
    }
    
    // private?
    public func addDynamicMarking(dynamicMarking: DynamicMarking) {
        dynamicMarkings.append(dynamicMarking)
        addNode(dynamicMarking)
    }
    
    // private?
    public func addLigature(ligature: DMLigature) {
        ligatures.append(ligature)
    }
    
    private func commitLigatures() {
        for ligature in ligatures {
            //assert(ligature.hasBeenBuilt, "ligature must be built for it to be committed!")
            addSublayer(ligature)
            ligature.position.y = 0.5 * frame.height
        }
    }
}