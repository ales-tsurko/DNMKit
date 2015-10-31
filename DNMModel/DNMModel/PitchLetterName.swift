//
//  PitchLetterName.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public enum PitchLetterName: Float/*, CustomStringConvertible*/ {
    
    case C = 0.0
    case D = 0.5
    case E = 1.0
    case F = 1.5
    case G = 2.0
    case A = 2.5
    case B = 3.0
    
    public static func pitchLetterNameWithString(string string: String) -> PitchLetterName? {
        switch string {
        case "c", "C": return .C
        case "d", "D": return .D
        case "e", "E": return .E
        case "f", "F": return .F
        case "g", "G": return .G
        case "a", "A": return .A
        case "b", "B": return .B
        default: return nil
        }
    }
    
    public var staffSpaces: Float { get { return rawValue } }
    
    public var description: String {
        get {
            switch self {
            case .C: return "C"
            case .D: return "D"
            case .E: return "E"
            case .F: return "F"
            case .G: return "G"
            case .A: return "A"
            case .B: return "B"
            }
        }
    }
}

public func ==(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public func >(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

public func <(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func >=(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

public func <=(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}