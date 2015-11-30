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

    public var identifier: String!
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
    public init(identifier: String, scoreModel: DNMScoreModel) {
        super.init(frame: UIScreen.mainScreen().bounds) // reset frame to size of screen
        self.identifier = identifier
        self.scoreModel = scoreModel
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func createSystems() {
        // TODO
        // get maximumWidth
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
