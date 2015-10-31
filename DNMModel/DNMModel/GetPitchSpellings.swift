//
//  GetPitchSpellings.swift
//  denm_pitch
//
//  Created by James Bean on 8/13/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/// DEPRECATED

/*
public class GetPitchSpellings {
    
    public class func forPitch(pitch: Pitch) -> [PitchSpelling] {
        /**
        Dictionary with keys of MIDI values 0.0-11.75, and values of tuples in the format of
        (letterName, coarse, fine).
        */
        var spellingsByMIDI: [Float : [(PitchLetterName, Float, Float)]] = [:]
        
        // C
        spellingsByMIDI[00.00] = [(.C, +0.0, +0.00)]
        spellingsByMIDI[00.25] = [(.C, +0.0, +0.25),(.C, +0.5, -0.25)]
        spellingsByMIDI[00.50] = [(.C, +0.5, +0.00)]
        spellingsByMIDI[00.75] = [(.C, +0.5, +0.25),(.C, +1.0, -0.25),(.D, -1.0, -0.25)]
        spellingsByMIDI[01.00] = [(.C, +1.0, +0.00),(.D, -1.0, +0.00)]
        spellingsByMIDI[01.25] = [(.C, +1.0, +0.25),(.D, -1.0, +0.25),(.D, -0.5, -0.25)]
        spellingsByMIDI[01.50] = [(.D, -0.5, +0.00)]
        spellingsByMIDI[01.75] = [(.D, -0.5, +0.25),(.D, +0.0, -0.25)]
        
        // D
        spellingsByMIDI[02.00] = [(.D, +0.0, +0.00)]
        spellingsByMIDI[02.25] = [(.D, +0.0, +0.25),(.D, +0.5, -0.25)]
        spellingsByMIDI[02.50] = [(.D, +0.5, +0.00)]
        spellingsByMIDI[02.75] = [(.D, +0.5, +0.25),(.D, +1.0, -0.25),(.E, -1.0, -0.25)]
        spellingsByMIDI[03.00] = [(.D, +1.0, +0.00),(.E, -1.0, +0.00)]
        spellingsByMIDI[03.25] = [(.D, +1.0, +0.25),(.E, -1.0, +0.25),(.E, -0.5, -0.25)]
        spellingsByMIDI[03.50] = [(.E, -0.5, +0.00)]
        spellingsByMIDI[03.75] = [(.E, -0.5, +0.25),(.E, +0.0, -0.25)]
        
        // E
        spellingsByMIDI[04.00] = [(.E, +0.0, +0.00)]
        spellingsByMIDI[04.25] = [(.E, +0.0, +0.25),(.E, +0.5, -0.25),(.F, -0.5, -0.25)]
        spellingsByMIDI[04.50] = [(.E, +0.5, +0.00),(.F, -0.5, +0.00)]
        spellingsByMIDI[04.75] = [(.E, +0.5, +0.25),(.F, -0.5, +0.25),(.F, +0.0, -0.25)]
        
        // F
        spellingsByMIDI[05.00] = [(.F, +0.0, +0.00)]
        spellingsByMIDI[05.25] = [(.F, +0.0, +0.25),(.F, +0.5, -0.25)]
        spellingsByMIDI[05.50] = [(.F, +0.5, +0.00)]
        spellingsByMIDI[05.75] = [(.F, +0.5, +0.25),(.F, +1.0, -0.25),(.G, -1.0, -0.25)]
        spellingsByMIDI[06.00] = [(.F, +1.0, +0.00),(.G, -1.0, +0.00)]
        spellingsByMIDI[06.25] = [(.F, +1.0, +0.25),(.G, -1.0, +0.25),(.G, -0.5, -0.25)]
        spellingsByMIDI[06.50] = [(.G, -0.5, +0.00)]
        spellingsByMIDI[06.75] = [(.G, -0.5, +0.25),(.G, +0.0, -0.25)]
        
        // G
        spellingsByMIDI[07.00] = [(.G, +0.0, +0.00)]
        spellingsByMIDI[07.25] = [(.G, +0.0, +0.25),(.G, +0.5, -0.25)]
        spellingsByMIDI[07.50] = [(.G, +0.5, +0.00)]
        spellingsByMIDI[07.75] = [(.G, +0.5, +0.25),(.G, +1.0, -0.25),(.A, -1.0, -0.25)]
        spellingsByMIDI[08.00] = [(.G, +1.0, +0.00),(.A, -1.0, +0.00)]
        spellingsByMIDI[08.25] = [(.G, +1.0, +0.25),(.A, -1.0, +0.25),(.A, -0.5, -0.25)]
        spellingsByMIDI[08.50] = [(.A, -0.5, +0.00)]
        spellingsByMIDI[08.75] = [(.A, -0.5, +0.25),(.A, +0.0, -0.25)]
        
        // A
        spellingsByMIDI[09.00] = [(.A, +0.0, +0.00)]
        spellingsByMIDI[09.25] = [(.A, +0.0, +0.25),(.A, +0.5, -0.25)]
        spellingsByMIDI[09.50] = [(.A, +0.5, +0.00)]
        spellingsByMIDI[09.75] = [(.A, +0.5, +0.25),(.A, +1.0, -0.25),(.B, -1.0, -0.25)]
        spellingsByMIDI[10.00] = [(.A, +1.0, +0.00),(.B, -1.0, +0.00)]
        spellingsByMIDI[10.25] = [(.A, +1.0, +0.25),(.B, -1.0, +0.25),(.B, -0.5, -0.25)]
        spellingsByMIDI[10.50] = [(.B, -0.5, +0.00)]
        spellingsByMIDI[10.75] = [(.B, -0.5, +0.25),(.B, +0.0, -0.25)]
        
        // B
        spellingsByMIDI[11.00] = [(.B, +0.0, +0.00)]
        spellingsByMIDI[11.25] = [(.B, +0.0, +0.25),(.B, +0.5, -0.25),(.C, -0.5, -0.25)]
        spellingsByMIDI[11.50] = [(.B, +0.5, +0.00),(.C, -0.5, +0.00)]
        spellingsByMIDI[11.75] = [(.B, +0.5, +0.25),(.C, -0.5, +0.25),(.C, +0.0, -0.25)]
        
        let spellings: [(PitchLetterName, Float, Float)] = spellingsByMIDI[
            pitch.pitchClass.midi.value
        ]!
        
        var pitchSpellings: [PitchSpelling] = []
        for (l, c, f) in spellings {
            
            var o: Int = pitch.octave
            if l == .C && c == 0 && f == -0.25 { o += 1 }
            if l == .C && c == -0.5 { o += 1 }
            let ps = PitchSpelling(pitch: pitch, coarse: c, fine: f, letterName: l, octave: o)
            pitchSpellings.append(ps)
        }
        return pitchSpellings
    }
}
*/