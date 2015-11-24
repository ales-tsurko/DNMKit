//
//  PitchLetterName.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

// TODO: change this away from being : Float, and instead : String
public enum PitchLetterName: String, Comparable {
    
    case C// = 0.0
    case D// = 0.5
    case E// = 1.0
    case F// = 1.5
    case G// = 2.0
    case A// = 2.5
    case B// = 3.0
    
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
    
    public var distanceFromC: Float {
        switch self {
        case .C: return 0.0
        case .D: return 2.0
        case .E: return 4.0
        case .F: return 5.0
        case .G: return 7.0
        case .A: return 9.0
        case .B: return 11.0
        }
    }
    
    public var staffSpaces: Float {
        switch self {
        case .C: return 0.0
        case .D: return 0.5
        case .E: return 1.0
        case .F: return 1.5
        case .G: return 2.0
        case .A: return 2.5
        case .B: return 3.0
        }
    }
}

public func ==(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.staffSpaces == rhs.staffSpaces
}

public func >(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.staffSpaces > rhs.staffSpaces
}

public func <(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.staffSpaces < rhs.staffSpaces
}

public func >=(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.staffSpaces >= rhs.staffSpaces
}

public func <=(lhs: PitchLetterName, rhs: PitchLetterName) -> Bool {
    return lhs.staffSpaces <= rhs.staffSpaces
}