//
//  PitchClass.swift
//  DNMModel
//
//  Created by James Bean on 11/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class PitchClass: Pitch {
    
    public init(pitch: Pitch) {
        let midi = pitch.midi.value % 12.0
        super.init(midi: MIDI(midi))
    }
}