//
//  _ScoreView.swift
//  DNM_iOS
//
//  Created by James Bean on 11/30/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// TODO: THIS WILL BE THE NEW SCOREVIEW, being refactored from ScoreView.swift (2015-11-30)
public class _ScoreView: UIView {

    public var viewerID: String?
    public var scoreModel: DNMScoreModel!
    
    // MARK: - PageViews
    
    /// All PageViews
    public var pageViews: [PageView] = []
    
    /// Current PageView
    public var currentPageView: PageView?

    /// Index of current PageView
    public var currentPageIndex: Int? { return getCurrentPageIndex() }
    
    /**
    Create a ScoreView with an identifier and scoreModel

    - parameter identifier: String with identifier of Performer ViewerID
    - parameter scoreModel: DNMScoreModel

    - returns: ScoreView
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
        print("build")
        createSystems()
    }
    
    // Enscpsulate in class: SystemFactory
    public func createSystems() {
        
        print("create systems")
        
        // hacks
        let page_pad: CGFloat = 25
        let beatWidth: CGFloat = 110
        //let g: CGFloat = 10
        
        let maximumWidth = frame.width - 2 * page_pad
        let maximumDuration = maximumWidth.durationWithBeatWidth(beatWidth)
        
        print("maximum width: \(maximumWidth)")
        print("maximum duration: \(maximumDuration)")
        print("measures.count: \(scoreModel.measures)")
        
        let systems = SystemModel.rangeWithScoreModel(scoreModel,
            beatWidth: beatWidth, maximumWidth: maximumWidth
        )
        
        /*
        // System (MODEL)
        var systems: [SystemModel] = []
        var systemStartDuration: Duration = DurationZero
        var measureIndex: Int = 0
        while measureIndex < scoreModel.measures.count {
            
            // create the maximum duration interval for the next System
            let maximumDurationInterval = DurationInterval(
                startDuration: systemStartDuration,
                stopDuration: systemStartDuration + maximumDuration
            )

            do {
                let measureRange = try Measure.rangeFromArray(scoreModel.measures,
                    withinDurationInterval: maximumDurationInterval
                )
                
                // create actual duration interval for System
                let systemDurationInterval = DurationInterval.unionWithDurationIntervals(
                    measureRange.map { $0.durationInterval}
                )
                
                print("system duration interval: \(systemDurationInterval)")
                
                // get durationNodes in range
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
                }
                catch {
                    print("couldn't find duration nodes in range")
                }
                
                // advance accumDuration
                systemStartDuration = systemDurationInterval.stopDuration
                
                // advance measure index
                measureIndex += measureRange.count
                
            }
            catch {
                print("could not create measure range: \(error)")
            }
        }
        */
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
