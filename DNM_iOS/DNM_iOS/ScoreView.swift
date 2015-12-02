//
//  ScoreView.swift
//  DNM_iOS
//
//  Created by James Bean on 11/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// TODO: THIS WILL BE THE NEW SCOREVIEW, being refactored from _ScoreView.swift (2015-12-01)
public class ScoreView: UIView {

    public var viewerID: String!
    public var peerIDs: [String] = []
    public var scoreModel: DNMScoreModel!
    
    // MARK: - PageViews
    
    /// All PageViews
    public var pageViews: [PageView] = []
    
    /// Current PageView
    public var currentPageView: PageView?

    /// Index of current PageView
    public var currentPageIndex: Int? { return getCurrentPageIndex() }
    
    // HACKS ----------------------------------------------------------------------------------
    let g: CGFloat = 10
    let beatWidth: CGFloat = 110
    // KILL PLEASE ----------------------------------------------------------------------------
    
    /**
    Create a ScoreView with an identifier and scoreModel

    - parameter identifier: String with identifier of Performer ViewerID
    - parameter scoreModel: DNMScoreModel

    - returns: _ScoreView
    */
    public init(
        scoreModel: DNMScoreModel,
        viewerID: String,
        peerIDs: [String] = [] // not optimal
    ) {
        super.init(frame: UIScreen.mainScreen().bounds) // reset frame to size of screen
        self.scoreModel = scoreModel
        self.viewerID = viewerID
        self.peerIDs = peerIDs
        build()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        let systems = makeSystems()
        let systemLayers = makeSystemLayersWithSystems(systems)
        self.pageViews = makePageViewsWithSystemLayers(systemLayers)
        goToFirstPage()
    }
    
    // can this be encapsulated in a class (or event a class func)
    private func makePageViewsWithSystemLayers(systemLayers: [SystemLayer]) -> [PageView] {
        print("make page views with system layers")
        // deal with maximum height
        var pageViews: [PageView] = []
        
        // hack
        let margin: CGFloat = 25
        let maximumHeight = UIScreen.mainScreen().bounds.height - 2 * margin
        var systemIndex: Int = 0
        while systemIndex < systemLayers.count {
            do {
                let systemLayerRange = try SystemLayer.rangeFromSystemLayers(systemLayers,
                    startingAtIndex: systemIndex,
                    constrainedByMaximumTotalHeight: maximumHeight
                )
                
                print("PAGE -----------------------------------------------------------------")
                
                // preliminary systemLayerBuild: wrap up
                //for systemLayer in systemLayerRange { systemLayer.build() }

                let pageLayer = PageLayer(systemLayers: systemLayerRange)
                let pageView = PageView(frame: frame)
                
                // adjust view.frame: wrap in method
                pageView.layer.position.y += 25
                pageView.layer.position.x += 50
                
                pageViews.append(pageView)
                
                // add in after bg color test
                pageView.layer.addSublayer(pageLayer)
                systemIndex += systemLayerRange.count
            }
            catch {
                print("could not create systemRange: \(error)")
            }
        }
        return pageViews
    }
    
    // TODO: IN PROCESS: 2015-12-01
    private func makeSystemLayersWithSystems(systems: [System]) -> [SystemLayer] {
        
        var systemLayers: [SystemLayer] = []
        for system in systems {
            let systemLayer = SystemLayer(
                system: system, g: g, beatWidth: beatWidth, viewerID: viewerID
            )
            systemLayers.append(systemLayer)
        }
        
        // preliminary build
        for systemLayer in systemLayers { systemLayer.build() }
        
        // manage spanners
        manageDMLigaturesForSystemLayers(systemLayers)
        
        // complete build
        for systemLayer in systemLayers {

            // setDefaultComponentTypesShown
            if viewerID != "omni" {
                // wipe out all of the component types shown
                for id in peerIDs {
                    systemLayer.componentTypesShownByID[id] = []
                }
            }

            systemLayer.arrangeNodesWithComponentTypesPresent()
            
            // probably not the best place for this
            systemLayer.createStems()
            
            //systemLayer.layout()
            //manageTempoMarkingsForSystem(systemLayer)
            //manageRehearsalMarkingsForSystem(systemLayer)
        }
        return systemLayers
    }
    
    // refactor out of here
    // ----------------------------------------------------------------------------------------   
    // make DMLigature (DynamicMarkingSpanner at some point) Manager class, this is out of hand
    public func manageDMLigaturesForSystemLayers(systems: [SystemLayer]) {
        
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
        
        var dmLigatureSpansByID: [String : [DMLigatureSpan]] = [:]
        
        for (s, system) in systems.enumerate() {
            for (id, dmNode) in system.dmNodeByID {
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
        
        // encapsulate: now add ligature components to dmNode
        
        for (id, dmLigatureSpans) in dmLigatureSpansByID {
            for dmLigatureSpan in dmLigatureSpans {
                
                let startSystem = systems[dmLigatureSpan.systemStartIndex!]
                let stopIntValue = dmLigatureSpan.stopIntValue!
                let lastDMNode = startSystem.dmNodeByID[id]!
                let lastLigature = lastDMNode.ligatures.last!
                if lastLigature.finalDynamicMarkingIntValue == nil {
                    let x = startSystem.frame.width + 20
                    lastLigature.completeHalfOpenToX(x, withDynamicMarkingIntValue: stopIntValue)
                    lastLigature.position.y = 0.5 * lastDMNode.frame.height
                }
                
                let stopSystem = systems[dmLigatureSpan.systemStopIndex!]
                let startIntValue = dmLigatureSpan.startIntValue!
                let firstDMNode = stopSystem.dmNodeByID[id]!
                let firstLigature = firstDMNode.ligatures.first!
                if firstLigature.initialDynamicMarkingIntValue == nil {
                    firstLigature.completeHalfOpenFromLeftWithDynamicMarkingIntValue(startIntValue)
                    firstLigature.position.y = 0.5 * firstDMNode.frame.height
                }
                
                for s in dmLigatureSpan.systemStartIndex! + 1..<dmLigatureSpan.systemStopIndex! {
                    
                    if systems[s].dmNodeByID[id] == nil {
                        // create dmNode
                        let dmNode = DMNode(height: 2.5 * g) // hack
                        dmNode.startLigatureAtX(0, withDynamicMarkingIntValue: startIntValue)
                        dmNode.ligatures.last!.completeHalfOpenToX(systems[s].frame.width + 20,
                            withDynamicMarkingIntValue: stopIntValue
                        )
                        dmNode.ligatures.last!.position.y = 0.5 * dmNode.frame.height
                        
                        dmNode.build()
                        systems[s].dmNodeByID[id] = dmNode
                        
                        // hail mary
                        systems[s].eventsNode.insertNode(dmNode,
                            afterNode: systems[s].performerByID[id]!
                        )
                    }
                }
            }
        }
    }
    // ----------------------------------------------------------------------------------------
    
    // Enscpsulate in class: SystemFactory
    private func makeSystems() -> [System] {
        let margin: CGFloat = 25
        let maximumWidth = frame.width - 2 * margin
        let beatWidth: CGFloat = 110 // hack, make not static
        let systems = System.rangeWithScoreModel(scoreModel,
            beatWidth: beatWidth,
            maximumWidth: maximumWidth
        )
        return systems
    }
    
    // throws error?
    public func goToPageAtIndex(index: Int) {
        if index >= 0 && index < pageViews.count {
            removeCurrentPageView()
            let pageView = pageViews[index]
            insertSubview(pageView, atIndex: 0)
        }
    }
    
    public func goToPreviousPage() {
        // TODO
    }
    
    public func goToNextPage() {
        // TODO
    }

    public func goToFirstPage() {
        goToPageAtIndex(0)
    }
    
    public func goToLastPage() {
        goToPageAtIndex(pageViews.count - 1)
    }
    
    private func removeCurrentPageView() {
        if let currentPageView = currentPageView { currentPageView.removeFromSuperview() }
    }
    
    private func getCurrentPageIndex() -> Int? {
        if let currentPageView = currentPageView { return pageViews.indexOf(currentPageView) }
        return nil
    }
}
