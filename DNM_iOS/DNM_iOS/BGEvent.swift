//
//  BGEvent.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

/// Graphical representation of DurationNode leaf
public class BGEvent {
    
    // model
    public var durationNode: DurationNode
    
    // view organization
    public var bgStratum: BGStratum?
    public var beamGroup: BeamGroup?
    public var bgContainer: BGContainer?

    public var stem: Stem?
    public var beamJunction: BeamJunction?

    public var next: BGEvent? { return nil }
    public var previous: BGEvent? { return nil }
    
    public var isRest: Bool { return getIsRest() }
    
    public var stemArticulationTypes: [ArticulationType] = []
    
    public var hasAugmentationDot: Bool { return getHasAugmentationDot() }
    public var augmentationDot: AugmentationDot?
    
    public var startsExtension: Bool { return getStartsExentsion() }
    public var stopsExtension: Bool { return getStopsExtension() }
    
    public var x: CGFloat = 0
    
    // check this for recursive placement within BGContainer(s)
    // objective currently works to depth = 2 ?
    public var x_inBGContainer: CGFloat? { get { return getX_inBGContainer() } }
    public var x_inBeamGroup: CGFloat? { get { return getX_inBeamGroup() } }
    public var x_inBGStratum: CGFloat? { get { return getX_inBGStratum() } }
    public var x_objective: CGFloat? { get { return getX_objective() } }
    
    public var depth: Int?
    
    public init(durationNode: DurationNode, x: CGFloat) {
        self.x = x
        self.durationNode = durationNode
        self.depth = durationNode.depth
        self.beamJunction = BeamJunctionMake(durationNode)
    }
    
    public func addStemArticulationType(type: ArticulationType) {
        stemArticulationTypes.append(type)
    }
    
    private func getHasAugmentationDot() -> Bool {
        if let beamGroup = beamGroup {
            return beamGroup.isMetrical && durationNode.duration.beats!.amount % 3 == 0
        } else { return durationNode.duration.beats!.amount % 3 == 0 }
    }
    
    private func getIsRest() -> Bool {
        for component in durationNode.components {
            if component is ComponentRest { return true }
        }
        return false
    }
    
    private func getStopsExtension() -> Bool {
        for component in durationNode.components {
            if component is ComponentExtensionStop { return true }
        }
        return false
    }
    
    private func getStartsExentsion() -> Bool {
        for component in durationNode.components {
            if component is ComponentExtensionStart { return true }
        }
        return false
    }
    
    private func getNext() -> BGEvent? {
        if let bgStratum = bgStratum {
            if let index = bgStratum.bgEvents.indexOfObject(self) {
                if index < bgStratum.bgEvents.count - 1 {
                    return bgStratum.bgEvents[index + 1]
                }
            }
        }
        else if let beamGroup = beamGroup {
            if let index = beamGroup.bgEvents.indexOfObject(self) {
                if index < beamGroup.bgEvents.count - 1 {
                    return beamGroup.bgEvents[index + 1]
                }
            }
        }
        else if let bgContainer = bgContainer {
            if let index = bgContainer.bgEvents.indexOfObject(self) {
                if index < bgContainer.bgEvents.count - 1 {
                    return bgContainer.bgEvents[index + 1]
                }
            }
        }
        return nil
    }
    
    private func getPrevious() -> BGEvent? {
        if let bgStratum = bgStratum {
            if let index = bgStratum.bgEvents.indexOfObject(self) {
                if index > 0 {
                    return bgStratum.bgEvents[index - 1]
                }
            }
        }
        else if let beamGroup = beamGroup {
            if let index = beamGroup.bgEvents.indexOfObject(self) {
                if index > 0 {
                    return beamGroup.bgEvents[index - 1]
                }
            }
        }
        else if let bgContainer = bgContainer {
            if let index = bgContainer.bgEvents.indexOfObject(self) {
                if index > 0 {
                    return bgContainer.bgEvents[index - 1]
                }
            }
        }
        return nil
    }

    private func getX_inBGContainer() -> CGFloat? {
        return x
    }
    
    private func getX_inBeamGroup() -> CGFloat? {
        if bgContainer == nil { return nil }
        return x + bgContainer!.left
    }
    
    private func getX_inBGStratum() -> CGFloat? {
        if bgContainer == nil || beamGroup == nil { return nil }
        return x_inBeamGroup! + beamGroup!.left
    }
    
    private func getX_objective() -> CGFloat? {
        if bgContainer == nil || beamGroup == nil || bgStratum == nil { return nil }
        return x_inBGStratum! + bgStratum!.left
    }
}