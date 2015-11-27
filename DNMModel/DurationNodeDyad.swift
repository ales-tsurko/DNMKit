//
//  DurationNodeDyad.swift
//  denm_model
//
//  Created by James Bean on 8/28/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class DurationNodeDyad: DurationSpanning {
    
    public var durationNode0: DurationNode
    public var durationNode1: DurationNode

    // clean up
    public var durationInterval: DurationInterval {
        return durationNode0.durationInterval.makeUnionWithDurationInterval(
            durationNode0.durationInterval
        )
    }
    
    /*
    public var durationSpan: DurationSpan {
        get {
            let startDuration = [
                durationNode0.durationSpan.startDuration,
                durationNode1.durationSpan.startDuration
            ].sort(<).first!
            let stopDuration = [
                durationNode0.durationSpan.stopDuration,
                durationNode1.durationSpan.stopDuration
            ].sort(<).last!
            return DurationSpan(startDuration: startDuration, stopDuration: stopDuration)
        }
    }
    */

    
    // this is a sloppy adapter
    // change to IntervalRelationship
    public var relationship: DurationNodeDyadRelationship {
        let r = durationNode0.durationInterval.relationshipToDurationInterval(durationNode1.durationInterval)
        
        let none: [IntervalRelationship] = [.TakesPlaceBefore, .TakesPlaceAfter]
        let adjacent: [IntervalRelationship] = [.Starts, .Finishes]
        
        if none.contains(r) {
            return .None
        }
        else if adjacent.contains(r) {
            return .Adjacent
        }
        else {
            return .Overlapping
        }
    }

    
    public var hasMatchingPIDs: Bool { get { return getHasMatchingPIDs() } }
    
    private func getHasMatchingPIDs() -> Bool {
        let dn0_pIDs = durationNode0.instrumentIDsByPerformerID.map({$0.0})
        let dn1_pIDs = durationNode1.instrumentIDsByPerformerID.map({$0.0})
        return dn0_pIDs == dn1_pIDs
    }
    
    public init(durationNode0: DurationNode, durationNode1: DurationNode) {
        if durationNode0.offsetDuration < durationNode1.offsetDuration {
            self.durationNode0 = durationNode0
            self.durationNode1 = durationNode1
        }
        else {
            self.durationNode0 = durationNode1
            self.durationNode1 = durationNode0
        }
    }
    
    // abstract this to compare to compount dyad (stratum)
    private func getRelationship() -> DurationNodeDyadRelationship {
        let dn0_start = durationNode0.offsetDuration
        let dn0_stop = durationNode0.offsetDuration + durationNode0.duration
        let dn1_start = durationNode1.offsetDuration
        let dn1_stop = durationNode1.offsetDuration + durationNode1.duration
        
        // does not need to check which is first! that is taken care of
        if dn0_start < dn1_start { if dn0_stop < dn1_start { return .None }
            else if dn0_stop > dn1_start { return .Overlapping }
            else { return .Adjacent }
        }
        else if dn1_start < dn0_start { if dn1_stop < dn0_start { return .None }
            else if dn1_stop > dn0_start { return .Overlapping }
            else { return .Adjacent }
        }
        else { return .Overlapping }
    }
    
    private func getIsOverlapping() -> Bool {
        let dn0_endDuration = durationNode0.offsetDuration + durationNode0.duration
        let dn1_endDuration = durationNode1.offsetDuration + durationNode1.duration
        if durationNode0.offsetDuration < durationNode1.offsetDuration {
            if dn0_endDuration <= durationNode1.offsetDuration { return false }
            else { return true }
        }
        else {
            if dn1_endDuration <= durationNode0.offsetDuration { return false }
            else { return true }
        }
    }
}

public enum DurationNodeDyadRelationship {
    case None, Adjacent, Overlapping
}