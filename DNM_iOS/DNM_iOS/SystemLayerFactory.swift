//
//  SystemLayerCoordinator.swift
//  DNM_iOS
//
//  Created by James Bean on 12/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public class SystemLayerFactory {

    private var systems: [System]
    private var g: CGFloat
    private var beatWidth: CGFloat
    private var viewerID: String

    public init(systems: [System], g: CGFloat, beatWidth: CGFloat, viewerID: String) {
        self.systems = systems
        self.g = g
        self.beatWidth = beatWidth
        self.viewerID = viewerID
    }
    
    public func makeSystemLayers() -> [SystemLayer] {
        var systemLayers: [SystemLayer] = []
        for system in systems {
            let systemLayer = SystemLayer(
                system: system, g: g, beatWidth: beatWidth, viewerID: viewerID
            )
            systemLayer.build()
            systemLayers.append(systemLayer)
        }
        manageDMLigaturesForSystemLayers(systemLayers)
        arrangeNodesInSystemLayers(systemLayers)
        createStemsInSystemLayers(systemLayers)
        return systemLayers
    }
    
    // manage tempo / rehearsal markings
    
    private func createStemsInSystemLayers(systemLayers: [SystemLayer]) {
        for systemLayer in systemLayers { systemLayer.createStems() }
    }
    
    private func arrangeNodesInSystemLayers(systemLayers: [SystemLayer]) {
        for systemLayer in systemLayers { systemLayer.arrangeNodesWithComponentTypesPresent() }
    }
    
    private func manageDMLigaturesForSystemLayers(systemLayers: [SystemLayer]) {
        let dmLigatureCoordinator = DMLigatureCoordinator(systemLayers: systemLayers, g: g)
        dmLigatureCoordinator.coordinateDMLigatures()
    }
    
    private func buildSystemLayers(systemLayers: [SystemLayer]) {
        for systemLayer in systemLayers {
            if !systemLayer.hasBeenBuilt { systemLayer.build() }
        }
    }
}

