//
//  PitchPolyphony.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class PitchPolyphony {
    
    public var verticalities: [PitchVerticality] = []
    
    public init() {}
    
    public init(verticalities: [PitchVerticality]) {
        self.verticalities = verticalities
    }
    
    public func addVerticality(verticality: PitchVerticality) -> PitchPolyphony {
        verticalities.append(verticality)
        return self
    }
}