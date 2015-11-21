//
//  DepthOfField.swift
//  denm_view
//
//  Created by James Bean on 10/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public enum DepthOfField: Int {
    case MostBackground = 0
    case Background
    case MiddleBackground
    case Middleground
    case MiddleForeground
    case Foreground
    case MostForeground
}