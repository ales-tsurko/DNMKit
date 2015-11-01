//
//  DurationExtensions.swift
//  DNMView
//
//  Created by James Bean on 11/1/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public extension Duration {
    
    public func getGraphicalWidthWithBeatWidth(beatWidth: CGFloat) -> CGFloat {
        return CGFloat(floatValue!) * 8.0 * beatWidth
    }
    
    // Wrapper for more verbose method
    public func width(beatWidth beatWidth: CGFloat) -> CGFloat {
        return getGraphicalWidthWithBeatWidth(beatWidth)
    }
}
