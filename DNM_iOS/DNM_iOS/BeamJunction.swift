//
//  BeamJunction.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public class BeamJunction: CustomStringConvertible {
    
    public var description: String { get { return getDescription() } }
    
    public var x: CGFloat = 0
    
    public var beamsLayer: BeamsLayer?
    
    // perhaps not necessary, dealt with abo
    public var junctionLeft: BeamJunction? { get { return getJunctionLeft() } }
    public var juntionRight: BeamJunction? { get { return getJunctionRight() } }
    
    public var positionInTree: NodePositionTree
    public var positionInContainer: NodePositionContainer
    public var currentSubdivisionLevel: Int
    public var previousSubdivisionLevel: Int?
    public var nextSubdivisionLevel: Int?
    public var beamletDirection: Direction = .West // default?
    
    public var componentsOnLevel: [Int : BeamJunctionComponent] = [:]
    
    init(
        positionInTree: NodePositionTree,
        positionInContainer: NodePositionContainer,
        currentSubdivisionLevel: Int,
        previousSubdivisionLevel: Int?,
        nextSubdivisionLevel: Int?
        )
    {
        self.positionInTree = positionInTree
        self.positionInContainer = positionInContainer
        self.currentSubdivisionLevel = currentSubdivisionLevel
        self.previousSubdivisionLevel = previousSubdivisionLevel
        self.nextSubdivisionLevel = nextSubdivisionLevel
        makeDefaultComponentsOnLevel()
        setDefaultBeamletDirection()
    }
    
    public func setComponent(component: BeamJunctionComponent, forLevel level: Int) {
        componentsOnLevel[level] = component
    }
    
    public func setComponent(component: BeamJunctionComponent, forLevelRange range: [Int]) {
        for level in range[0]...range[1] { componentsOnLevel[level] = component }
    }
    
    internal func makeDefaultComponentsOnLevel() {
        let c: Int = currentSubdivisionLevel - 1
        if c < 0 { return }
        let n: Int? = nextSubdivisionLevel != nil ? nextSubdivisionLevel! - 1 : nil
        let p: Int? = previousSubdivisionLevel != nil ? previousSubdivisionLevel! - 1 : nil
        var cOnL: [Int : BeamJunctionComponent] = [:]
        switch positionInTree {
        case .SingleInTree:
            for level in 0...c { cOnL[level] = .Beamlet }
        case .FirstInTree:
            switch positionInContainer {
            case .SingleInContainer:
                for level in 0...c { cOnL[level] = .Beamlet }
                break
            default:
                for level in 0...c { cOnL[level] = .Start }
                if c > n! { for level in n! + 1...c { cOnL[level] = .Beamlet } }
                break
            }
        case .MiddleInTree:
            switch positionInContainer {
            case .SingleInContainer:
                for level in 0...c { cOnL[level] = .Beamlet }
            case .FirstInContainer:
                for level in 0...c { cOnL[level] = .Start }
                if c > n! { for level in n! + 1...c { cOnL[level] = .Beamlet } }
            case .MiddleInContainer:
                if c == p! && c > n! {  for level in n! + 1...c { cOnL[level] = .Stop } }
                else if c > p! {
                    if c <= n! { for level in p! + 1...c { cOnL[level] = .Start } }
                    else if c > n! {
                        if n! > p! {
                            for level in p! + 1...n! { cOnL[level] = .Start }
                            for level in n! + 1...c { cOnL[level] = .Beamlet }
                        }
                        else if n! == p! {
                            for level in p! + 1...c { cOnL[level] = .Beamlet }
                        }
                        else if n! < p! {
                            for level in n! + 1...p! { cOnL[level] = .Stop }
                            for level in p! + 1...c { cOnL[level] = .Beamlet }
                        }
                    }
                }
                else if c < p! && c > n! { for level in n! + 1...c { cOnL[level] = .Stop } }
            case .LastInContainer:
                for level in 0...c { cOnL[level] = .Stop }
                if c > p! { for level in p! + 1...c { cOnL[level] = .Beamlet } }
                break
            }
        case .LastInTree:
            switch positionInContainer {
            case .SingleInContainer:
                for level in 0...c { cOnL[level] = .Beamlet }
                break
            default:
                for level in 0...c { cOnL[level] = .Stop }
                if c > p! { for level in p! + 1...c { cOnL[level] = .Beamlet } }
                break
            }
            
            break
        }
        componentsOnLevel = cOnL
    }
    
    private func getJunctionLeft() -> BeamJunction? {
        if beamsLayer == nil { return nil }
        let index: Int? = beamsLayer!.beamJunctions.indexOfObject(self)
        if index == nil || index == 0 { return nil }
        return beamsLayer!.beamJunctions[index! - 1]
    }
    
    private func getJunctionRight() -> BeamJunction? {
        if beamsLayer == nil { return nil }
        let index: Int? = beamsLayer!.beamJunctions.indexOfObject(self)
        if index == nil || index == beamsLayer!.beamJunctions.count - 1 { return nil }
        return beamsLayer!.beamJunctions[index! + 1]
    }
    
    internal func setDefaultBeamletDirection() {
        if positionInContainer == .SingleInContainer { beamletDirection = .East }
        else if positionInContainer == .FirstInContainer { beamletDirection = .East }
        else if positionInContainer == .LastInContainer { beamletDirection = .West }
        else {
            beamletDirection = previousSubdivisionLevel! > nextSubdivisionLevel ? .West : .East
        }
    }
    
    internal func getDescription() -> String {
        var description: String = "BeamJunction: "
        description += "\(positionInTree), \(positionInContainer); "
        description += "cur: \(currentSubdivisionLevel)"
        if previousSubdivisionLevel != nil {
            description += "; prev: \(previousSubdivisionLevel!)"
        }
        if nextSubdivisionLevel != nil { description += "; next: \(nextSubdivisionLevel!)"  }
        return description
    }
}

public func BeamJunctionMake(durationNode: DurationNode) -> BeamJunction {
    assert(durationNode.isLeaf, "durationNode must be leaf to create beamJunction")
    let positionInTree = durationNode.positionInTree!
    let positionInContainer = durationNode.positionInContainer!
    let cur = durationNode.duration.subdivisionLevel!
    let prev: Int? = (durationNode.leafLeft as? DurationNode)?.duration.subdivisionLevel
    let next: Int? = (durationNode.leafRight as? DurationNode)?.duration.subdivisionLevel
    let beamJunction = BeamJunction(
        positionInTree: positionInTree,
        positionInContainer: positionInContainer,
        currentSubdivisionLevel: cur,
        previousSubdivisionLevel: prev,
        nextSubdivisionLevel: next
    )
    return beamJunction
}

public enum BeamJunctionComponent {
    case Start, Stop, Beamlet, Extended
}
