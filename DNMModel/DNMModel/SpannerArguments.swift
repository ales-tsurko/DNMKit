//
//  SpannerArguments.swift
//  DNMModel
//
//  Created by James Bean on 11/6/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct SpannerArguments {
    public var exponent: Float = 1
    
    // is there a memory advantage to using []? rather than [] ... ?
    
    public var widthArgs: [Float] = []
    public var dashArgs: [Float] = []
    public var colorArgs: [(Float, Float, Float)] = []
    public var zigZagArgs: [Float] = []
    public var waveArgs: [Float] = []
    public var controlPointArgs: [Float] = []
    
    public init() { }
}