//
//  PageView.swift
//  denm_view
//
//  Created by James Bean on 10/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class PageView: UIView {
    
    public var page: Page!
    public var performerView: ScoreView!
    public var systemViews: [SystemView] = []
    
    public init(page: Page, systemViews: [SystemView], performerView: ScoreView) {
        self.page = page
        self.performerView = performerView
        self.systemViews = systemViews

        super.init(frame: UIScreen.mainScreen().bounds)

        layer.addSublayer(page)
        addSystemViews()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addSystemViews() {
        
        clearSystemViews()
        for systemView in systemViews {
            systemView.pageView = self
            addSubview(systemView)
        }
    }
    
    public func clearSystemViews() {
        for systemView in systemViews { systemView.removeFromSuperview() }
    }
    
    public func systemsNeedReflowing() {
        clearSystemViews()
        performerView.systemsNeedReflowing()
    }
}
