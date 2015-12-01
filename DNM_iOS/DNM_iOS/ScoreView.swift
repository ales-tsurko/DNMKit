//
//  ScoreView.swift
//  DNM_iOS
//
//  Created by James Bean on 11/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// TODO: THIS WILL BE THE NEW SCOREVIEW, being refactored from _ScoreView.swift (2015-11-30)
public class ScoreView: UIView {

    public var viewerID: String?
    public var scoreModel: DNMScoreModel!
    
    // MARK: - PageViews
    
    /// All PageViews
    public var pageViews: [PageView] = []
    
    /// Current PageView
    public var currentPageView: PageView?

    /// Index of current PageView
    public var currentPageIndex: Int? { return getCurrentPageIndex() }
    
    // HACKS
    let g: CGFloat = 10 // hack
    let beatWidth: CGFloat = 110 // hack
    
    /**
    Create a ScoreView with an identifier and scoreModel

    - parameter identifier: String with identifier of Performer ViewerID
    - parameter scoreModel: DNMScoreModel

    - returns: _ScoreView
    */
    public init(scoreModel: DNMScoreModel, viewerID: String? = nil) {
        super.init(frame: UIScreen.mainScreen().bounds) // reset frame to size of screen
        self.scoreModel = scoreModel
        self.viewerID = viewerID
        build()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        let systems = makeSystems()
        let systemLayers = makeSystemLayersWithSystems(systems)
        print("systemLayers: \(systemLayers)")
        
        //
    }
    
    private func makeSystemLayersWithSystems(systems: [System]) -> [SystemLayer] {
        return systems.map {
            SystemLayer(system: $0, g: g, beatWidth: beatWidth, viewerID: viewerID)
        }
    }
    
    // Enscpsulate in class: SystemFactory
    private func makeSystems() -> [System] {
        let page_pad: CGFloat = 25
        let maximumWidth = frame.width - 2 * page_pad
        let beatWidth: CGFloat = 110 // hack, make not static
        let systems = System.rangeWithScoreModel(scoreModel,
            beatWidth: beatWidth, maximumWidth: maximumWidth
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
        // TODO
    }
    
    public func goToLastPage() {
        // TODO
    }
    
    private func removeCurrentPageView() {
        if let currentPageView = currentPageView { currentPageView.removeFromSuperview() }
    }
    
    private func getCurrentPageIndex() -> Int? {
        if let currentPageView = currentPageView { return pageViews.indexOf(currentPageView) }
        return nil
    }
}
