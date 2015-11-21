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
    
    public func graphicalWidthWithBeatWidth(beatWidth: CGFloat) -> CGFloat {
        guard let floatValue = floatValue else { return 0 }
        return CGFloat(floatValue) * 8.0 * beatWidth
    }
    
    // Wrapper for more verbose method
    public func width(beatWidth beatWidth: CGFloat) -> CGFloat {
        return graphicalWidthWithBeatWidth(beatWidth)
    }
}

public extension CGFloat {
    
    public func durationWithBeatWidth(beatWidth: CGFloat) -> Duration {

        let floatValue = self / beatWidth
        //print("float value: \(floatValue)")
        let duration = Duration(floatValue: Float(floatValue))
        //print("duration: \(duration)")
        return duration
    }
}
