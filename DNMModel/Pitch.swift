//
//  Pitch.swift
//  denm_pitch
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Pitch
*/
public class Pitch: CustomStringConvertible, Equatable {
    
    // MARK: String Representation
    
    /// Printable description of Pitch
    public var description: String { get { return getDescription() } }
    
    // MARK: Attributes
    
    /// MIDI representation of Pitch (middle-c = 60.0, C5 = 72.0, C3 = 48.0, etc)
    public var midi: MIDI
    
    /// Frequency representation of Pitch (middle-c = 261.6)
    public var frequency: Frequency
    
    /// Modulo 12 representation of Pitch
    public var pitchClass: Pitch { get { return Pitch(midi: self.midi % 12.0) } }
    
    /// Resolution of Pitch (1.0 = chromatic, 0.5 = 1/4-tone, 0.25 = 1/8-tone)
    public var resolution: Float {
        get { return midi.value % 1 == 0 ? 1.0 : midi.value % 0.5 == 0 ? 0.5 : 0.25 }
    }
    
    public var octave: Int { get { return getOctave() } }
    
    // MARK: Spelling a Pitch
    
    /// PitchSpelling of Pitch, if it has been spelled.
    public var spelling: PitchSpelling?
    
    /// All possible PitchSpellings of Pitch
    public var possibleSpellings: [PitchSpelling] {
        get { return PitchSpelling.pitchSpellingsForPitch(pitch: self) }
    }
    
    /// Check if this Pitch has been spelled
    public var hasBeenSpelled: Bool { get { return spelling != nil } }
    
    // NYI: Create random pitch with Frequency
    
    /**
    Creates a random pitch within sensible values.
    
    - returns: Pitch with random value
    */
    public class func random() -> Pitch {
        let randomMIDI: Float = randomFloat(min: 60, max: 79, resolution: 0.25)
        //assert(randomMIDI > 60, "random MIDI not in range")
        return Pitch(midi: MIDI(randomMIDI))
    }
    
    /**
    Creates a pitch within range and with resolution decided by user
    
    - parameter min:        Minimum MIDI value
    - parameter max:        Maximum MIDI value
    - parameter resolution: Resolution of Pitch (1.0: Half-tone, 0.5: Quarter-tone, 0.25: Eighth-tone)
    
    - returns: Pitch within range and resolution decided by user
    */
    public class func random(min: Float, max: Float, resolution: Float) -> Pitch {
        let randomMIDI: Float = randomFloat(min: min, max: max, resolution: resolution)
        return Pitch(midi: MIDI(randomMIDI))
    }
    
    /**
    Creates an array of pitches with random values
    
    - parameter amount: Amount of pitches desired
    
    - returns: Array of pitches with random values
    */
    public class func random(amount: Int) -> [Pitch] {
        var pitches: [Pitch] = []
        for _ in 0..<amount { pitches.append(Pitch.random()) }
        return pitches
    }
    
    public class func random(amount: Int, min: Float, max: Float, resolution: Float)
        -> [Pitch]
    {
        var pitches: [Pitch] = []
        for _ in 0..<amount {
            pitches.append(Pitch.random(min, max: max, resolution: resolution))
        }
        return pitches
    }
    
    public static func middleC() -> Pitch {
        return Pitch(midi: MIDI(60))
    }
    
    // MARK: Create a Pitch
    
    /**
    Create a Pitch with MIDI value and optional resolution.
    
    - parameter midi:       MIDI representation of Pitch (middle-c = 60.0, C5 = 72.0, C3 = 48.0)
    - parameter resolution: Resolution of returned MIDI. Default is nil (objective resolution).
    (1 = chromatic, 0.5 = 1/4-tone resolution, 0.25 = 1/8-tone resolution)
    
    - returns: Initialized Pitch object
    */
    public init(midi: MIDI, resolution: Float? = nil) {
        // add resolution functionality
        self.midi = MIDI(value: midi.value, resolution: resolution)
        self.frequency = Frequency(midi: midi)
    }
    
    /**
    Create a Pitch with Frequency and optional resolution
    
    - parameter frequency:  Frequency representation of Pitch
    - parameter resolution: Resolution of returned MIDI. Default is nil (objective resolution).
    (1 = chromatic, 0.5 = 1/4-tone resolution, 0.25 = 1/8-tone resolution)
    
    - returns: Initialized Pitch object
    */
    public init(frequency: Frequency, resolution: Float? = nil) {
        var m = MIDI(frequency: frequency)
        if let resolution = resolution { m.quantizeToResolution(resolution) }
        self.midi = m
        self.frequency = Frequency(midi: m)
    }
    
    /**
    Create a Pitch with String. This string can be of a format "C#" which will create a C#
    above middle-c, or of a format "Eb5" which will create an Eb a minor 10th above middle-c.
    At this point, the actual pitch spelling prescribed by you here is ignored. Further
    down the line, perhaps the pitch spelling will be enforced here.
    
    - parameter string: String representation of Pitch
    
    - returns: Initialized Pitch object if you didn't fuck up the formatting of the String.
    */
    public convenience init(var string: String) throws {

        enum StringInitError: ErrorType {
            case InvalidString
            case InvalidLetterName
            case InvalidEighthToneIndicator
            case InvalidQuarterToneIndicator
            case InvalidHalfToneIndicator
            case InvalidOctave
        }

        // throw error if empty string
        if string == "" { throw StringInitError.InvalidString }
        
        let firstChar = String(string.characters.first!)
        if let letterName = PitchLetterName.pitchLetterNameWithString(string: firstChar) {
            
            // trim off first char
            string = string[1...string.characters.count - 1]
            
            let scanner = NSScanner(string: string)
            scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "_")
            scanner.caseSensitive = true
            var str: NSString?
            
            // quarter tone
            var quarterTone: Float = 1
            if scanner.scanString("q", intoString: &str) { quarterTone = 0.5 }
            
            // half tone
            let halfToneCharSet = NSCharacterSet(charactersInString: "s#")
            var halfTone: Float = 0
            if scanner.scanString("b", intoString: &str) { halfTone = -1 }
            else if scanner.scanCharactersFromSet(halfToneCharSet, intoString: &str) {
                halfTone = 1
            }
            
            var eighthTone: Float = 0
            if scanner.scanString("up", intoString: &str) { eighthTone = 0.25 }
            else if scanner.scanString("down", intoString: &str) { eighthTone = -0.25 }
            
            var octave: Float = 4 // default to octave starting at middle c
            var floatValue: Float = 0.0
            if scanner.scanFloat(&floatValue) { octave = floatValue }
            
            let midi: Float = (
                (octave + 1) * 12
                    + letterName.rawValue
                    + quarterTone * halfTone
                    + eighthTone
            )
            self.init(midi: MIDI(midi))
            
        } else {
            throw StringInitError.InvalidLetterName
        }
    }
    
    // MARK: Set attributes of a Pitch
    
    /**
    Set MIDI value of Pitch
    
    - parameter midi: MIDI value (middle-c = 60.0, C5 = 72.0, C3 = 48.0)
    
    - returns: Pitch object
    */
    public func setMIDI(midi: MIDI) -> Pitch {
        self.midi = midi
        self.frequency = Frequency(midi: midi)
        return self
    }
    
    /**
    Set frequency of Pitch
    
    - parameter frequency: Frequency of Pitch
    
    - returns: Pitch object
    */
    public func setFrequency(frequency: Frequency) -> Pitch {
        self.frequency = frequency
        self.midi = MIDI(frequency: frequency)
        return self
    }
    
    /**
    Set PitchSpelling of Pitch
    
    - parameter pitchSpelling: PitchSpelling
    
    - returns: Pitch object
    */
    public func setPitchSpelling(pitchSpelling: PitchSpelling) -> Pitch {
        self.spelling = pitchSpelling
        return self
    }
    
    public func clearPitchSpelling() {
        self.spelling = nil
    }
    
    // MARK: Operations
    
    /**
    Make a copy of Pitch without spelling
    
    - returns: Copy of Pitch without PitchSpelling
    */
    public func copy() -> Pitch {
        return Pitch(midi: midi)
    }
    
    // transposeByInterval()
    
    // invertAroundPitch
    
    // MARK: Get information of partials of Pitch
    
    /**
    Get MIDI representation of partial of Pitch
    
    - parameter partial:    Desired partial
    - parameter resolution: Resolution of returned MIDI. Default is nil (objective resolution).
    (1 = chromatic, 0.5 = 1/4-tone resolution, 0.25 = 1/8-tone resolution)
    
    - returns: MIDI representation of partial
    */
    public func getMIDIOfPartial(partial: Int, resolution: Float? = nil) -> MIDI {
        return MIDI(frequency: frequency * Float(partial))
    }
    
    /**
    Get Frequency representation of partial of Pitch
    
    - parameter partial:    Desired partial
    - parameter resolution: Resolution of returned MIDI. Default is nil (objective resolution).
    (1 = chromatic, 0.5 = 1/4-tone resolution, 0.25 = 1/8-tone resolution)
    
    - returns: Frequency representation of partial
    */
    public func frequencyOfPartial(partial: Int, resolution: Float? = nil) -> Frequency {
        return frequency * Float(partial)
    }
    
    internal func getOctave() -> Int {
        var octave = Int(floor(midi.value / 12)) - 1
        if spelling != nil {
            if spelling!.letterName == .C && spelling!.coarse == 0 && spelling!.fine == -0.25 {
                octave += 1
            }
            else if spelling!.letterName == .C && spelling!.coarse == -0.5 { octave += 1 }
        }
        return octave
    }
    
    internal func getDescription() -> String {
        var description: String = "Pitch: \(midi.value)"
        if hasBeenSpelled { description += "; \(spelling!)" }
        return description
    }
}

public func ==(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs.midi.value == rhs.midi.value
}

public func <(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs.midi.value < rhs.midi.value
}

public func >(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs.midi.value > rhs.midi.value
}

public func <=(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs.midi.value <= rhs.midi.value
}

public func >=(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs.midi.value >= rhs.midi.value
}

// TODO: +, +=, -, -=, *, *=, /, /=