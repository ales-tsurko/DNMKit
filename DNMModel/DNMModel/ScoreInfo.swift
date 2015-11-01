//
//  ScoreInfo.swift
//  denm_model
//
//  Created by James Bean on 10/18/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation


public struct ScoreInfo {
    public var iIDsAndInstrumentTypesByPID: [[String: [(String, InstrumentType)]]]
    public var measures: [Measure]
    public var tempoMarkings: [TempoMarking]
    public var durationNodes: [DurationNode]
    public var rehearsalMarkings: [RehearsalMarking]
    
    public init(
        iIDsAndInstrumentTypesByPID: [[String: [(String,InstrumentType)]]],
        measures: [Measure],
        tempoMarkings: [TempoMarking],
        durationNodes: [DurationNode],
        rehearsalMarkings: [RehearsalMarking]
    )
    {
        self.iIDsAndInstrumentTypesByPID = iIDsAndInstrumentTypesByPID
        self.measures = measures
        self.tempoMarkings = tempoMarkings
        self.durationNodes = durationNodes
        self.rehearsalMarkings = rehearsalMarkings
    }
}
