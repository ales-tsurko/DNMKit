//
//  ScoreView.swift
//  DNM_iOS
//
//  Created by James Bean on 11/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

public class ScoreView: UIView {

    /// The PerformerID of the Performer viewing the current Score
    public var viewerID: String!
    
    /// The PerformerIDs of all colleagues in an ensemble, excluding the viewer's PerformerID
    public var peerIDs: [PerformerID] = []
    
    /// The model of the entire piece being rendered
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

    - parameter identifier: String with identifier of PerformerView ViewerID
    - parameter scoreModel: DNMScoreModel

    - returns: ScoreView
    */
    public init(
        scoreModel: DNMScoreModel,
        viewerID: PerformerID,
        peerIDs: [PerformerID] = []
    ) {
        super.init(frame: UIScreen.mainScreen().bounds)
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
            
            //manageTempoMarkingsForSystem(systemLayer)
            //manageRehearsalMarkingsForSystem(systemLayer)
        }
        return systemLayers
    }

    // consider how this is to be generalized for all spanners
    private func manageDMLigaturesForSystemLayers(systemLayers: [SystemLayer]) {
        let dmLigatureCoordinator = DMLigatureCoordinator(systemLayers: systemLayers, g: g)
        dmLigatureCoordinator.coordinateDMLigatures()
    }
    
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
    
    // MARK: - Page Navigation
    
    public func goToPageAtIndex(index: Int) {
        if index >= 0 && index < pageViews.count {
            removeCurrentPageView()
            let pageView = pageViews[index]
            currentPageView = pageView
            insertSubview(pageView, atIndex: 0)
        }
    }
    
    public func goToPreviousPage() {
        if let currentPageIndex = currentPageIndex { goToPageAtIndex(currentPageIndex - 1) }
    }
    
    public func goToNextPage() {
        if let currentPageIndex = currentPageIndex { goToPageAtIndex(currentPageIndex + 1) }
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
