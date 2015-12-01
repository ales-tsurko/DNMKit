//
//  _ScoreView.swift
//  denm_view
//
//  Created by James Bean on 10/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

// TODO: THIS WILL BE THE OLD SCOREVIEW, being refactored into ScoreView.swift (2015-11-30)
public class _ScoreView: UIView {

    public var id: String = ""
    public var pages: [Page] = []
    public var currentPage: Page?
    public var currentPageIndex: Int?
    
    public var pageViews: [PageView] = []
    public var currentPageView: PageView?
    
    /// All Systems for a given piece of music
    public var systems: [SystemView] = []
    
    /// All SystemViews for a given piece of music
    public var systemViews: [SystemUIView] = []

    public init(id: String, systems: [SystemView]) {
        super.init(frame: UIScreen.mainScreen().bounds)
        self.id = id
        self.systems = systems // ALL SYSTEMS
        self.systemViews = makeSystemViewsForSystems(systems) // ALL SYSTEM VIEWS
        build()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        createPages()
        goToFirstPage()
        setFrame()
        
        // encapsulate: setFramesOfSystemViews()
        for pageView in pageViews {
            for systemView in pageView.systemViews {
                systemView.setFrame()
            }
        }
    }
    
    public func systemsNeedReflowing() {
        for pageView in pageViews { pageView.removeFromSuperview() }
        pages = []
        pageViews = []
        createPages()
        goToFirstPage()
        setFrame()
    }
    
    public func makeSystemViewsForSystems(systems: [SystemView]) -> [SystemUIView] {
        var systemViews: [SystemUIView] = []
        for system in systems {
            let systemView = SystemUIView(system: system)
            systemViews.append(systemView)
        }
        return systemViews
    }
    
    public func createPages() {
        
        // clean this up, please
        let page_pad: CGFloat = 25
        //let page_pad_left: CGFloat = 50
        
        // hack
        let maximumHeight = UIScreen.mainScreen().bounds.height - 2 * page_pad
        
        // remove PageViews as necessary
        for pageView in pageViews { pageView.removeFromSuperview() }

        // add systemViews
        
        var pages: [Page] = []
        var systemIndex: Int = 0
        while systemIndex < systems.count {
            let systemRange = SystemView.rangeFromSystems(systems,
                startingAtIndex: systemIndex, constrainedByMaximumTotalHeight: maximumHeight
            )

            // clean up initialization
            let page = Page(systems: systemRange)
            page.build()
            
            // make contingency for too-big-a-system
            let lastSystemIndex = systems.indexOfObject(page.systems.last!)!
            
            var systemViewsInRange: [SystemUIView] = []
            for sv in systemIndex...lastSystemIndex {
                let systemView = systemViews[sv]
                systemViewsInRange.append(systemView)
            }
            
            let pageView = PageView(page: page, systemViews: systemViewsInRange, scoreView: self)
            pageViews.append(pageView)
            
            systemIndex = lastSystemIndex + 1
            pages.append(page)
        }
        self.pages = pages
    }

    
    public func goToPageAtIndex(index: Int) {
        //print("go to page at index: \(index)")
        
        if index >= 0 && index < pages.count {
            let page = pages[index]
            let pageView = pageViews[index]
            for subview in subviews { subview.removeFromSuperview() }
            addSubview(pageView)
            currentPageView = pageView
            currentPage = page
            currentPageIndex = index
            setFrame()
        }
    }
    
    public func goToFirstPage() {
        //print("go to first page")
        
        if pages.count > 0 { goToPageAtIndex(0) }
    }
    
    public func goToLastPage() {
        if pages.count > 0 { goToPageAtIndex(pages.count - 1) }
    }
    
    public func goToNextPage() {
        if let currentPageIndex = currentPageIndex {
            if currentPageIndex < pages.count - 1 { goToPageAtIndex(currentPageIndex + 1) }
            else { print("LAST PAGE") }
        }
    }
    
    public func goToPreviousPage() {
        if let currentPageIndex = currentPageIndex {
            if currentPageIndex > 0 { goToPageAtIndex(currentPageIndex - 1) }
            else { print("FIRST PAGE") }
        }
    }
    
    public func setFrame() {
        let pad_left: CGFloat = 50
        let pad_top: CGFloat = 12
        if let currentPageView = currentPageView {
            frame = CGRectMake(
                pad_left, pad_top, currentPageView.frame.width, currentPageView.frame.height
            )
        }
        /*
        if let currentPage = currentPage {
            frame = CGRectMake(pad_left, pad_top, currentPage.frame.width, currentPage.frame.height)
        }
        */
    }
}
