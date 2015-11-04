//
//  PageControlButtonPrevious.swift
//  DNMUI
//
//  Created by James Bean on 11/4/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class PageControlButtonPrevious: PageControlButton {
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        setTitle("<", forState: UIControlState.Normal)
        setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        setTitleColor(UIColor.redColor(), forState: .Highlighted)
    }

    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    
}
