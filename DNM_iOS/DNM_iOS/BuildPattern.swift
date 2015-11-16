//
//  BuildPattern.swift
//  denm_view
//
//  Created by James Bean on 8/17/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public protocol BuildPattern {
    
    func build()
    var hasBeenBuilt: Bool { get }
    
    //optional func addComponents()
    //optional func commitComponents()
    //optional func setVisualAttributes()
    //optional func setFrame()
    
}