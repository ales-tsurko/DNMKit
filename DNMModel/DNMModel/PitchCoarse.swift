//
//  PitchCoarse.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public enum PitchCoarse: String, CustomStringConvertible {
    
    case Natural = "Natural"
    case Sharp = "Sharp"
    case QuarterSharp = "QuarterSharp"
    case Flat = "Flat"
    case QuarterFlat = "QuarterFlat"
    
    public var description: String { get { return self.rawValue } }
}