//
//  BuildPattern.swift
//  denm_view
//
//  Created by James Bean on 8/17/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

@objc public protocol BuildPattern {
    
    optional func build()
    optional func addComponents()
    optional func commitComponents()
    optional func setVisualAttributes()
    optional func setFrame()
    //var hasBeenBuilt: Bool { get }
}