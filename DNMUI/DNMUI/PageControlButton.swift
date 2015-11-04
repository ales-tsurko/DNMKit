//
//  PageControlButton.swift
//  DNMUI
//
//  Created by James Bean on 11/4/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class PageControlButton: UIButton {
    
    public class func withType(type: PageControlButtonType) -> PageControlButton? {
        switch type {
        case .Previous: return PageControlButtonPrevious()
        case .Next: return PageControlButtonNext()
        }
    }
}
