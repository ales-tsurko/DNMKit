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
    * InstrumentTypes organized by InstrumentIDs (ordered), organized by PerformerID (ordered)
    * DurationNodes
    * Measures
    * TempoMarkings
    * RehearsalMarkings

This model will continue expanding as feature set increases
*/
public struct DNMScoreModel: CustomStringConvertible {
    
    /// String representation of DNMScoreModel
    public var description: String { return getDescription() }
    
    /// Title of Work
    public var title: String = ""
    
    /// Name of Composer -- make space for multiples, colabs, etc.
    public var composer: String = ""
    
    
    
    /**
    Collection of InstrumentIDsWithInstrumentType, organized by PerformerID.
    These values ensure Performer order and Instrument order,
    while making it still possible to call for this information by key identifiers.
    */
    public var instrumentIDsAndInstrumentTypesByPerformerID = OrderedDictionary<
        String, OrderedDictionary<String, InstrumentType>
    >()
    
    /// All DurationNodes in the piece
    public var durationNodes: [DurationNode] = []
    
    /// All Measures in the piece
    public var measures: [Measure] = []
    
    /// All TempoMarkings in the piece
    public var tempoMarkings: [TempoMarking] = []
    
    /// All RehearsalMarkings in the piece
    public var rehearsalMarkings: [RehearsalMarking] = []
    
    public init() { }
    
    private func getDescription() -> String {
        var description: String = "DNMScoreModel: \(title)"
        description += "; amountMeasures: \(measures.count)"
        description += "; amountDurationNodes: \(durationNodes.count)"
        description += "; IIDsAndInstrumentTypesByPID: \(instrumentIDsAndInstrumentTypesByPerformerID)"
        return description
    }
}