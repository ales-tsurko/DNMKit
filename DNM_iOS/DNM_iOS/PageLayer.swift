//
//  PageLayer.swift
//  denm_view
//
//  Created by James Bean on 8/24/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class PageLayer: ViewNode, BuildPattern {
    
    public var viewerID: String?
    
    public var systems: [SystemLayer] = []
    
    // not in here...
    public var maximumHeight: CGFloat { get { return getMaximumHeight() } }
    public var maximumWidth: CGFloat { get { return getMaximumWidth() } }
    
    public var hasBeenBuilt: Bool = false
    
    public init(systems: [SystemLayer]) {
        super.init()
        layoutAccumulation_vertical = .Top
        setSystemsWithSystems(systems)
    }
    
    public override init() {
        super.init()
        layoutAccumulation_vertical = .Top
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }

    public func setSystemsWithSystems(systems: [SystemLayer]) {
        self.systems = systems
        for system in systems {
            system.page = self
            addNode(system)
        }
    }
    
    public func addSystem(system: SystemLayer) {
        system.page = self
        systems.append(system)
        addNode(system)
    }
    
    public func build() {
        buildSystems()
        layout()
        hasBeenBuilt = true
    }
    
    private func buildSystems() {
        for system in systems { if !system.hasBeenBuilt { system.build() } }
    }
    
    public func getBounds() -> CGRect {
        return UIScreen.mainScreen().bounds
    }
    
    private func getMaximumHeight() -> CGFloat {
        return UIScreen.mainScreen().bounds.height // - pad
    }
    
    private func getMaximumWidth() -> CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
}

