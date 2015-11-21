//
//  DNMColorManager.swift
//  DNMView
//
//  Created by James Bean on 10/31/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class DNMColorManager {
    
    public static var colorMode: ColorMode = .Dark
    
    public static var backgroundColor: UIColor {
        get {
            switch colorMode {
            case .Light: return UIColor.whiteColor()
            case .Dark: return UIColor.blackColor()
            }
        }
    }
}

