//
//  PerformerView.swift
//  denm_view
//
//  Created by James Bean on 10/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMView

public class PerformerView: UIView {

    public var id: String = ""
    public var pages: [Page] = []
    public var currentPage: Page?
    public var currentPageIndex: Int?
    
    public var pageViews: [PageView] = []
    public var currentPageView: PageView?
    
    public var systems: [System] = []

    public init(id: String, systems: [System]) {
        super.init(frame: UIScreen.mainScreen().bounds)
        self.id = id
        self.systems = systems
        build()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        createPages()
        goToFirstPage()
        setFrame()
        
        // encapsulate
        for pageView in pageViews {
            for systemView in pageView.systemViews {
                systemView.setFrame()
            }
        }
    }
    
    public func rebuild() {

        //createPages()
        //goToFirstPage()
        //setFrame()
    }
    
    public func createPages() {
        let before = CFAbsoluteTimeGetCurrent()
        
        // clean this up, please
        let page_pad: CGFloat = 25
        var maximumHeight = UIScreen.mainScreen().bounds.height - 2 * page_pad
        
        subviews.map { $0.removeFromSuperview() }
        var pages: [Page] = []
        var systemIndex: Int = 0
        while systemIndex < systems.count {
            let systemRange = System.rangeFromSystems(systems,
                startingAtIndex: systemIndex, constrainedByMaximumTotalHeight: maximumHeight
            )
            
            // clean up initialization
            let page = Page(systems: systemRange)
            page.build()
            

            let pageView = PageView(page: page, performerView: self)
            pageViews.append(pageView)
            
            // make contingency for too-big-a-system
            let lastSystemIndex = systems.indexOfObject(page.systems.last!)!
            systemIndex = lastSystemIndex + 1
            pages.append(page)
        }
        
        self.pages = pages
    }
    
    public func addSystemViews() {
        if let currentPage = currentPage {
            for system in currentPage.systems {
                let systemView = SystemView(system: system, pageView: currentPageView!)
                addSubview(systemView)
            }
        }
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
        if let currentPageView = currentPageView {
            frame = CGRectMake(
                25, 0.618 * 25, currentPageView.frame.width, currentPageView.frame.height
            )
        }
        
        if let currentPage = currentPage {
            frame = CGRectMake(25, 0.618 * 25, currentPage.frame.width, currentPage.frame.height)
        }
    }
}
