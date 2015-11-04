//
//  PageView.swift
//  denm_view
//
//  Created by James Bean on 10/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMView

public class PageView: UIView {
    
    public var page: Page!
    public var performerView: PerformerView!
    public var systemViews: [SystemView] = []
    
    public init(page: Page, performerView: PerformerView) {
        self.page = page
        self.performerView = performerView
        
        // hack
        super.init(frame: UIScreen.mainScreen().bounds)
        
        layer.addSublayer(page)
        //addSystemViews()
        
        //layer.borderColor = UIColor.blueColor().CGColor
        //rlayer.borderWidth = 1
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addSystemViews() {
        for system in page.systems {
            let systemView = SystemView(system: system, pageView: self)
            systemViews.append(systemView)
            addSubview(systemView)
        }
    }
    
    public func systemsNeedReflowing() {
        performerView.systemsNeedReflowing()
    }
}
