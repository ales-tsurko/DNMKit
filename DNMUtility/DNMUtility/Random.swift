//
//  Random.swift
//  denm
//
//  Created by James Bean on 4/8/15.
//  Copyright (c) 2015 James Bean. All rights reserved.
//

import Foundation

public func randomFloat(max: Float) -> Float {
    return (Float(UInt32(arc4random())) / Float(UINT32_MAX)) * max
}

public func randomFloat(min min: Float, max: Float, resolution: Float) -> Float {
    return round(randomFloat(min: min, max: max) / resolution) * resolution
}

public func randomFloat(max max: Float, resolution: Float) -> Float {
    return round(randomFloat(max) / resolution) * resolution
}

public func randomFloat(min min: Float, max: Float) -> Float {
    return randomFloat(max - min) + min
}

public func randomInt(max: Int) -> Int {
    return Int(arc4random_uniform(UInt32(max)))
}

public func randomInt(min: Int, max: Int) -> Int {
    return randomInt(max - min) + min
}