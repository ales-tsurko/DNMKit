//
//  BGStratumFactory.swift
//  DNM_iOS
//
//  Created by James Bean on 11/27/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

public class BGStratumFactory {
    
    // system: System?
    
    public init(durationNodeStrata: [DurationNodeStratum]) {
        var bgStrata: [BGStratum] = []
        
        // get this outta here...
        for durationNodeStratum in durationNodeStrata {
            let performerIDs = performerIDsInStratum(durationNodeStratum)
            
            // for now, only one pID possible per DurationNode; bail if no pIDs present
            guard let firstValue = performerIDs.first else { continue }
            //var hasSinglePerformerID: Bool = performerIDs.unique().count == 1
            
            let bgStratum = BGStratum()
            // todo
        }
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

