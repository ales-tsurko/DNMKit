//
//  SystemModel.swift
//  DNM_iOS
//
//  Created by James Bean on 11/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

// add tests for this, add doc comments
public struct SystemModel {
    
    public var durationInterval: DurationInterval
    public var measures: [Measure]
    public var durationNodes: [DurationNode]
    public var tempoMarkings: [TempoMarking]
    public var rehearsalMarkings: [RehearsalMarking]
    
    // throws?, options: defined by measures or duration nodes?
    public static func rangeWithScoreModel(scoreModel: DNMScoreModel,
        beatWidth: CGFloat, maximumWidth: CGFloat
    ) -> [SystemModel]
    {
        let maximumDuration = maximumWidth.durationWithBeatWidth(beatWidth)
        var systems: [SystemModel] = []
        var systemStartDuration: Duration = DurationZero
        var measureIndex: Int = 0
        while measureIndex < scoreModel.measures.count {
            
            // create the maximum duration interval for the next System
            let maximumDurationInterval = DurationInterval(
                startDuration: systemStartDuration,
                stopDuration: systemStartDuration + maximumDuration
            )
            
            // attempt to get range of measures within maximum duration interval for System
            do {
                let measureRange = try Measure.rangeFromArray(scoreModel.measures,
                    withinDurationInterval: maximumDurationInterval
                )
                
                // create actual duration interval for System, based on Measures present
                let systemDurationInterval = DurationInterval.unionWithDurationIntervals(
                    measureRange.map { $0.durationInterval}
                )
                
                // attempt to get range of duration nodes within duration interval for System
                do {
                    let durationNodeRange = try DurationNode.rangeFromArray(
                        scoreModel.durationNodes,
                        withinDurationInterval: systemDurationInterval
                    )
                    
                    // create System
                    let system = SystemModel(
                        durationInterval: systemDurationInterval,
                        measures: measureRange,
                        durationNodes: durationNodeRange,
                        tempoMarkings: [],
                        rehearsalMarkings: []
                    )
                    systems.append(system)
                    
                    // advance accumDuration
                    systemStartDuration = systemDurationInterval.stopDuration
                    
                    // advance measure index
                    measureIndex += measureRange.count
                }
                catch {
                    print("could not find duration nodes in range: \(error)")
                }
            }
            catch {
                print("could not find measures in range: \(error)")
            }
        }
        return systems
    }
    
    public init(
        durationInterval: DurationInterval,
        measures: [Measure],
        durationNodes: [DurationNode],
        tempoMarkings: [TempoMarking],
        rehearsalMarkings: [RehearsalMarking]
    )
    {
        self.durationInterval = durationInterval
        self.measures = measures
        self.durationNodes = durationNodes
        self.tempoMarkings = tempoMarkings
        self.rehearsalMarkings = rehearsalMarkings
    }
}