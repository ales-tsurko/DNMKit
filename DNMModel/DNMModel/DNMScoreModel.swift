//
//  DNMScoreModel.swift
//  DNMModel
//
//  Created by James Bean on 11/1/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
The model of an entire DNMScore. This will contain:
    * InstrumentIDs and InstrumentTypes (ordered) organized by PerformerID
    * DurationNodes
    * Measures
    * TempoMarkings
    * RehearsalMarkings

This model will continue expanding as feature set increases
*/
public struct DNMScoreModel {
    
    /// Title of Work
    public var title: String = ""
    
    /// Name of Composer -- make space for multiples, colabs, etc.
    public var composer: String = ""
    
    /// All InstrumentIDs and InstrumentTypes (ordered), organized by PerformerIDs in the piece
    public var iIDsAndInstrumentTypesByPID: [[String: [(String, InstrumentType)]]] = []
    
     /// All DurationNodes in the piece
    public var durationNodes: [DurationNode] = []
    
    /// All Measures in the piece
    public var measures: [Measure] = []
    
    /// All TempoMarkings in the piece
    public var tempoMarkings: [TempoMarking] = []
    
    /// All RehearsalMarkings in the piece
    public var rehearsalMarkings: [RehearsalMarking] = []
    
    public init() { }
    
    /*
    /**
    Create a DENMScoreModel
    
    - parameter iIDsAndInstrumentTypesByPID: iIDsAndInstrumentTypesByPID
    - parameter durationNodes:               DurationNodes
    - parameter measures:                    Measures
    - parameter tempoMarkings:               TempoMarkings
    - parameter rehearsalMarkings:           RehearsalMarking
    
    - returns: DENMScoreModel
    */
    public init(
        iIDsAndInstrumentTypesByPID: [[String: [(String,InstrumentType)]]] = [],
        durationNodes: [DurationNode] = [],
        measures: [Measure] = [],
        tempoMarkings: [TempoMarking] = [],
        rehearsalMarkings: [RehearsalMarking] = []
    )
    {
        self.iIDsAndInstrumentTypesByPID = iIDsAndInstrumentTypesByPID
        self.durationNodes = durationNodes
        self.measures = measures
        self.tempoMarkings = tempoMarkings
        self.rehearsalMarkings = rehearsalMarkings
    }
    */
}