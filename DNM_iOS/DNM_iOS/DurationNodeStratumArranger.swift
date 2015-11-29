//
//  DurationNodeStratumArranger.swift
//  DNM_iOS
//
//  Created by James Bean on 11/27/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

/// Organizes DurationNodes into collections based on Performer Identifiers
public class DurationNodeStratumArranger {
    
    public var durationNodes: [DurationNode]
    
    public init(durationNodes: [DurationNode]) {
        self.durationNodes = durationNodes
    }
    
    public func makeDurationNodeStrata() -> [DurationNodeStratum] {
        let durationNodeStratumClusters = makeDurationNodeStratumClusters()
        let durationNodeStrata = recombineStratumClusters(durationNodeStratumClusters)
        return durationNodeStrata
    }

    private func recombineStratumClusters(var stratumClusters: [DurationNodeStratum])
        -> [DurationNodeStratum]
    {
        var s_index0: Int = 0
        while s_index0 < stratumClusters.count {
            var s_index1: Int = 0
            while s_index1 < stratumClusters.count {
                let s0 = stratumClusters[s_index0]
                let s1 = stratumClusters[s_index1]
                if !stratum(s0, overlapsWithStratum: s1) {
                    let s0_pids: [String] = performerIDsInStratum(s0).unique()
                    let s1_pids: [String] = performerIDsInStratum(s1).unique()
                    if s0_pids == s1_pids {
                        let concatenated = s0 + s1
                        stratumClusters.removeAtIndex(s_index0)
                        stratumClusters.removeAtIndex(s_index1 - 1) // compensate for above
                        stratumClusters.insert(concatenated, atIndex: 0)
                        s_index0 = 0
                        s_index1 = 0
                    }
                    else { s_index1++ } // how do i clump these together?
                }
                else { s_index1++ } // see above!
            }
            s_index0++
        }
        return stratumClusters
    }
    
    private func makeDurationNodeStratumClusters() -> [DurationNodeStratum] {
        
        // First pass: get initial stratum clumps
        var stratumClumps: [DurationNodeStratum] = []
        durationNodeLoop: for durationNode in durationNodes {
            
            // Create initial stratum if none yet
            if stratumClumps.count == 0 {
                stratumClumps = [[durationNode]]
                continue durationNodeLoop
            }
            
            // Find if we can clump the remaining durationNodes onto a stratum
            var matchFound: Bool = false
            stratumLoop: for s in 0..<stratumClumps.count {
                
                let durationIntervals = stratumClumps[s].map { $0.durationInterval }
                
                let stratum_durationInterval = DurationInterval.unionWithDurationIntervals(
                    durationIntervals
                )
                
                let relationship: IntervalRelationship = durationNode.durationInterval.relationshipToDurationInterval(stratum_durationInterval)
                
                // find if DurationNodeStrata are adjactent and can be rejoined
                if relationship == .Meets {
                    var stratum = stratumClumps[s]
                    let stratum_pids = performerIDsInStratum(stratum)
                    let dn_pids = performerIDsInDurationNode(durationNode)
                    for pid in dn_pids {
                        if stratum_pids.contains(pid) {
                            stratumClumps.removeAtIndex(s)
                            stratum.append(durationNode)
                            stratumClumps.insert(stratum, atIndex: s)
                            matchFound = true
                            break stratumLoop
                        }
                    }
                }
            }
            if !matchFound { stratumClumps.append([durationNode]) }
        }
        return stratumClumps
    }
    
    private func stratum(stratum: DurationNodeStratum,
        overlapsWithStratum otherStratum: DurationNodeStratum
    ) -> Bool
    {
        var overlaps: Bool = false
        for dn0 in stratum {
            for dn1 in otherStratum {
                let dyad = DurationNodeDyad(durationNode0: dn0, durationNode1: dn1)
                if dyad.relationship == .Overlapping { overlaps = true }
            }
        }
        return overlaps
    }

    private func performerIDsInStratum(stratum: DurationNodeStratum) -> [String] {
        var performerIDs: [String] = []
        for dn in stratum { performerIDs += performerIDsInDurationNode(dn) }
        return performerIDs
    }
    
    private func performerIDsInDurationNode(durationNode: DurationNode) -> [String] {
        return Array<String>(durationNode.instrumentIDsByPerformerID.keys)
    }
}

