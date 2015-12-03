//
//  PageLayer.swift
//  denm_view
//
//  Created by James Bean on 8/24/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class PageLayer: ViewNode, BuildPattern {
    
    /// Identifier of PerformerView viewing this PageLayer
    //public var viewerID: String?
    
    // All SystemLayers in this PageLayer -- laid out automatically
    public var systemLayers: [SystemLayer] = []
    
    /// If this PageLayer has been built yet
    public var hasBeenBuilt: Bool = false
    
    /**
    Create a PageLayer with SystemLayers

    - parameter systemLayers: All SystemLayers to be contained by this PageLayer

    - returns: PageLayer
    */
    public init(systemLayers: [SystemLayer]) {
        super.init()
        layoutAccumulation_vertical = .Top
        setSystemLayersWithSystemLayerss(systemLayers)
        build()
    }
    
    public override init() {
        super.init()
        layoutAccumulation_vertical = .Top
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }

    public func setSystemLayersWithSystemLayerss(systemLayers: [SystemLayer]) {
        for systemLayer in systemLayers { addSystemLayer(systemLayer) }
    }
    
    public func addSystemLayer(systemLayer: SystemLayer) {
        systemLayer.page = self
        systemLayers.append(systemLayer)
        addNode(systemLayer)
    }
    
    public func build() {
        //buildSystems()
        layout()
        hasBeenBuilt = true
    }
    
    private func buildSystems() {
        for systemLayer in systemLayers {
            if !systemLayer.hasBeenBuilt { systemLayer.build() }
        }
    }
}

