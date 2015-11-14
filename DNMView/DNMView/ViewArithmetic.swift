//
//  ViewArithmetic.swift
//  DNMView
//
//  Created by James Bean on 11/14/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation


public func DEGREES_TO_RADIANS(degrees: CGFloat) -> CGFloat {
    return degrees / 180.0 * CGFloat(M_PI)
}

public func RADIANS_TO_DEGREES(radians: CGFloat) -> CGFloat {
    return radians * (180.0 / CGFloat(M_PI))
}