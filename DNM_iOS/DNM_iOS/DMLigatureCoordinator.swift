//
//  DMLigatureCoordinator.swift
//  DNM_iOS
//
//  Created by James Bean on 12/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class DMLigatureCoordinator {
    
    // encapsulate: create ligature spans
    struct DMLigatureSpan {
        var systemStartIndex: Int?
        var systemStopIndex: Int?
        var startIntValue: Int?
        var stopIntValue: Int?
        
        init(systemStartIndex: Int, startIntValue: Int) {
            self.systemStartIndex = systemStartIndex
            self.startIntValue = startIntValue
        }
        
        init(systemStopIndex: Int, stopIntValue: Int) {
            self.systemStartIndex = systemStopIndex
            self.stopIntValue = stopIntValue
        }
        
        mutating func setSystemStopIndex(systemStopIndex: Int, stopIntValue: Int) {
            self.systemStopIndex = systemStopIndex
            self.stopIntValue = stopIntValue
        }
        
        mutating func setSystemStartIndex(systemStartIndex: Int, startIntValue: Int) {
            self.systemStartIndex = systemStartIndex
            self.startIntValue = startIntValue
        }
    }

    private var dmLigatureSpansByID: [String: [DMLigatureSpan]] = [:]
    private var systemLayers: [SystemLayer] = []
    private var g: CGFloat = 0
    
    public init(systemLayers: [SystemLayer], g: CGFloat = 10) {
        self.systemLayers = systemLayers
        self.g = g
    }
    
    public func coordinateDMLigatures() {
        createLigatureSpans()
        addLigatureComponentsToDMNodes()
    }
    
    // this just sucks so much
    private func createLigatureSpans() {
        
        for (s, systemLayer) in systemLayers.enumerate() {
            for (id, dmNode) in systemLayer.dmNodeByID {
                for ligature in dmNode.ligatures {
                    if ligature.hasBeenBuilt { continue }
                    if ligature.initialDynamicMarkingIntValue == nil {
                        if let finalIntValue = ligature.finalDynamicMarkingIntValue {
                            if dmLigatureSpansByID[id] == nil {
                                
                                let dmLigatureSpan = DMLigatureSpan(
                                    systemStopIndex: s,
                                    stopIntValue: finalIntValue
                                )
                                
                                dmLigatureSpansByID[id] = [dmLigatureSpan]
                            }
                            else {
                                for (d, var dmLigatureSpan) in dmLigatureSpansByID[id]!.enumerate() {
                                    if dmLigatureSpan.stopIntValue == nil {
                                        dmLigatureSpan.setSystemStopIndex(s, stopIntValue: finalIntValue)
                                        dmLigatureSpansByID[id]!.removeAtIndex(d)
                                        dmLigatureSpansByID[id]!.insert(dmLigatureSpan, atIndex: d)
                                        break
                                    }
                                }
                            }
                        }
                    }
                    else {
                        if let initialValue = ligature.initialDynamicMarkingIntValue {
                            if dmLigatureSpansByID[id] == nil {
                                // create
                                let dmLigatureSpan = DMLigatureSpan(
                                    systemStartIndex: s, startIntValue: initialValue
                                )
                                dmLigatureSpansByID[id] = [dmLigatureSpan]
                            }
                            else {
                                // find and append
                                for (d, var dmLigatureSpan) in dmLigatureSpansByID[id]!.enumerate() {
                                    if dmLigatureSpan.startIntValue == nil {
                                        dmLigatureSpan.setSystemStartIndex(s, startIntValue: initialValue)
                                        dmLigatureSpansByID[id]!.removeAtIndex(d)
                                        dmLigatureSpansByID[id]!.insert(dmLigatureSpan, atIndex: d)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addLigatureComponentsToDMNodes() {
        for (id, dmLigatureSpans) in dmLigatureSpansByID {
            for dmLigatureSpan in dmLigatureSpans {
                
                let startSystem = systemLayers[dmLigatureSpan.systemStartIndex!]
                let stopIntValue = dmLigatureSpan.stopIntValue!
                let lastDMNode = startSystem.dmNodeByID[id]!
                let lastLigature = lastDMNode.ligatures.last!
                if lastLigature.finalDynamicMarkingIntValue == nil {
                    let x = startSystem.frame.width + 20
                    lastLigature.completeHalfOpenToX(x, withDynamicMarkingIntValue: stopIntValue)
                    lastLigature.position.y = 0.5 * lastDMNode.frame.height
                }
                
                let stopSystem = systemLayers[dmLigatureSpan.systemStopIndex!]
                let startIntValue = dmLigatureSpan.startIntValue!
                let firstDMNode = stopSystem.dmNodeByID[id]!
                let firstLigature = firstDMNode.ligatures.first!
                if firstLigature.initialDynamicMarkingIntValue == nil {
                    firstLigature.completeHalfOpenFromLeftWithDynamicMarkingIntValue(startIntValue)
                    firstLigature.position.y = 0.5 * firstDMNode.frame.height
                }
                
                for s in dmLigatureSpan.systemStartIndex! + 1..<dmLigatureSpan.systemStopIndex! {
                    
                    if systemLayers[s].dmNodeByID[id] == nil {
                        // create dmNode
                        let dmNode = DMNode(height: 2.5 * g) // hack
                        dmNode.startLigatureAtX(0, withDynamicMarkingIntValue: startIntValue)
                        dmNode.ligatures.last!.completeHalfOpenToX(systemLayers[s].frame.width + 20,
                            withDynamicMarkingIntValue: stopIntValue
                        )
                        dmNode.ligatures.last!.position.y = 0.5 * dmNode.frame.height
                        
                        dmNode.build()
                        systemLayers[s].dmNodeByID[id] = dmNode
                        
                        // hail mary
                        systemLayers[s].eventsNode.insertNode(dmNode,
                            afterNode: systemLayers[s].performerByID[id]!
                        )
                    }
                }
            }
        }
    }
}