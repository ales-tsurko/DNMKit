//
//  System.swift
//  DNM_iOS
//
//  Created by James Bean on 11/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

// add tests for this, add doc comments
public struct System {
    
    /// DurationInterval for this System
    public var durationInterval: DurationInterval
    
    /// Model of musical information for this System
    public var scoreModel: DNMScoreModel
    
    // throws?, options: defined by measures or duration nodes?
    public static func rangeWithScoreModel(scoreModel: DNMScoreModel,
        beatWidth: CGFloat, maximumWidth: CGFloat
    ) -> [System]
    {
        let maximumDuration = maximumWidth.durationWithBeatWidth(beatWidth)
        var systems: [System] = []
        var systemStartDuration: Duration = DurationZero
        var measureIndex: Int = 0
        while measureIndex < scoreModel.measures.count {
            
            // create the maximum duration interval for the next SystemLayer
            let maximumDurationInterval = DurationInterval(
                startDuration: systemStartDuration,
                stopDuration: systemStartDuration + maximumDuration
            )
            
            // attempt to get range of measures within maximum duration interval for System
            do {
                let measureRange = try Measure.rangeFromArray(scoreModel.measures,
                    withinDurationInterval: maximumDurationInterval
                )
                
                // create actual duration interval for SystemLayer, based on Measures present
                let systemDurationInterval = DurationInterval.unionWithDurationIntervals(
                    measureRange.map { $0.durationInterval}
                )
                
                // attempt to get range of duration nodes within duration interval for System
                do {
                    let durationNodeRange = try DurationNode.rangeFromArray(
                        scoreModel.durationNodes,
                        withinDurationInterval: systemDurationInterval
                    )
                    
                    var systemScoreModel = DNMScoreModel()
                    systemScoreModel.instrumentIDsAndInstrumentTypesByPerformerID = scoreModel.instrumentIDsAndInstrumentTypesByPerformerID
                    systemScoreModel.measures = measureRange
                    systemScoreModel.durationNodes = durationNodeRange
                    
                    // manage tempo markings, rehearsal markings, and anything later here
                    
                    let system = System(
                        durationInterval: systemDurationInterval,
                        scoreModel: systemScoreModel
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
    
    public init(durationInterval: DurationInterval, scoreModel: DNMScoreModel) {
        self.durationInterval = durationInterval
        self.scoreModel = scoreModel
    }
}