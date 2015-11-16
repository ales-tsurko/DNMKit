//
//  PitchFine.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public enum PitchFine: String, CustomStringConvertible {
    
    case None = ""
    case Up = "Up"
    case Down = "Down"
    
    public var description: String { get { return self.rawValue } }
}
