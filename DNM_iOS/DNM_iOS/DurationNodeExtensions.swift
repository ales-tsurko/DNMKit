//
//  DurationNodeExtensions.swift
//  DNMView
//
//  Created by James Bean on 11/1/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public extension DurationNode {
    
    public func getGraphicalWidthWithBeatWidth(beatWidth: CGFloat) -> CGFloat {
        return CGFloat(duration.floatValue!) * 8.0 * beatWidth
    }
    
    public func width(beatWidth beatWidth: CGFloat) -> CGFloat {
        return getGraphicalWidthWithBeatWidth(beatWidth)
    }
}
