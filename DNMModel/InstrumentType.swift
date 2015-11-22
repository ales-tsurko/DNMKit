//
//  InstrumentType.swift
//  denm_model
//
//  Created by James Bean on 10/10/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class InstrumentFamily {
    
    internal static var members: [InstrumentType] { get { return getMembers() } }
    internal static var subfamilies: [InstrumentFamily.Type] { get { return getSubfamilies() } }
    
    // make a clean, fast wrapper:
    public static func has(instrumentType: InstrumentType) -> Bool {
        return self.containsInstrumentType(instrumentType)
    }
    
    public static func containsInstrumentType(instrumentType: InstrumentType) -> Bool {
        for family in subfamilies {
            if family.containsInstrumentType(instrumentType) { return true }
        }
        return members.contains(instrumentType)
    }
    
    // override in subclasses as appropriate
    internal class func getMembers() -> [InstrumentType] {
        return []
    }
    
    // override in subclasses as appropriate
    internal class func getSubfamilies() -> [InstrumentFamily.Type] {
        return []
    }
    
    // Nested Subclasses ----------------------------------------------------------------------
    public class Strings: InstrumentFamily {
        public static let Violin: InstrumentType = .Violin
        public static let Viola: InstrumentType = .Viola
        public static let Violoncello: InstrumentType = .Violoncello
        public static let Guitar: InstrumentType = .Guitar
        
        internal override class func getMembers() -> [InstrumentType] {
            return [Violin, Viola, Violoncello, Guitar]
        }
    }
    
    public class Woodwinds: InstrumentFamily {
        public class Flutes: InstrumentFamily {
            public static let Piccolo: InstrumentType = .Flute_Piccolo
            public static let C: InstrumentType = .Flute_C
            public static let Alto: InstrumentType = .Flute_Alto
            public static let Bass: InstrumentType = .Flute_Bass
            public static let Contrabass: InstrumentType = .Flute_Contrabass
            
            internal override class func getMembers() -> [InstrumentType] {
                return [Piccolo, C, Alto, Bass, Contrabass]
            }
        }
        
        public class Clarinets: InstrumentFamily {
            public static let Bflat: InstrumentType = .Clarinet_Bflat
            public static let A: InstrumentType = .Clarinet_A
            public static let Bass: InstrumentType = .Clarinet_Bass
            public static let Contrabass: InstrumentType = .Clarinet_Contrabass
            
            internal override class func getMembers() -> [InstrumentType] {
                return [Bflat, A, Bass, Contrabass]
            }
        }
        
        public class DoubleReeds: InstrumentFamily {
            public static let Oboe: InstrumentType = .Oboe
            public static let Oboe_dArmore: InstrumentType = .Oboe_dAmore
            public static let English_Horn: InstrumentType = .English_Horn
            public static let Bassoon: InstrumentType = .Bassoon
            
            // HECKELFON?, etc
            
            internal override class func getMembers() -> [InstrumentType] {
                return [Oboe, Oboe_dArmore, English_Horn, Bassoon]
            }
        }
        
        public class Saxophones: InstrumentFamily {
            public static let Sopranino: InstrumentType = .Saxophone_Sopranino
            public static let Soprano: InstrumentType = .Saxophone_Soprano
            public static let Alto: InstrumentType = .Saxophone_Alto
            public static let Baritone: InstrumentType = .Saxophone_Baritone
            public static let Bass: InstrumentType = .Saxophone_Bass
            public static let Contrabass: InstrumentType = .Saxophone_Contrabass
            
            internal override class func getMembers() -> [InstrumentType] {
                return [Sopranino, Soprano, Alto, Baritone, Bass, Contrabass]
            }
        }
        
        internal override class func getSubfamilies() -> [InstrumentFamily.Type] {
            return [
                Flutes.self,
                Clarinets.self,
                DoubleReeds.self,
                Saxophones.self,
                // brass
            ]
        }
    }
    
    public class Brass: InstrumentFamily {
        
        public class Trumpets: InstrumentFamily {
            public static let Bflat: InstrumentType = .Trumpet_Bflat
            public static let C: InstrumentType = .Trumpet_C
            
            internal override class func getMembers() -> [InstrumentType] {
                return [Bflat, C]
            }
        }
        
        /*
        public class Trombones: InstrumentFamily {
        
        }
        
        public class Horns: InstrumentFamily {
        
        }
        
        public class Tubas: InstrumentFamily {
        
        }
        */
        
        internal override class func getSubfamilies() -> [InstrumentFamily.Type] {
            return [Trumpets.self]
        }
    }
}

public let InstrumentFamilies: [InstrumentFamily.Type] = InstrumentFamily.subfamilies

// Woodwinds
public typealias Woodwinds = InstrumentFamily.Woodwinds
public typealias Flute = Woodwinds.Flutes
public typealias Clarinet = Woodwinds.Clarinets
public typealias DoubleReed = Woodwinds.DoubleReeds
public typealias Saxophone = Woodwinds.Saxophones

// Brass
public typealias Brass = InstrumentFamily.Brass
public typealias Trumpet = Brass.Trumpets

// Strings
public typealias Strings = InstrumentFamily.Strings

// Percussion

// Keyboards

public enum InstrumentType: String {
    
    case Violin
    case Viola
    case Violoncello
    case Guitar
    
    case Flute_Piccolo
    case Flute_C
    case Flute_Alto
    case Flute_Bass
    case Flute_Contrabass
    
    case Clarinet_Bflat
    case Clarinet_A
    case Clarinet_Bass
    case Clarinet_Contrabass
    
    case Oboe
    case Oboe_dAmore
    case English_Horn
    case Bassoon
    
    case Saxophone_Sopranino
    case Saxophone_Soprano
    case Saxophone_Alto
    case Saxophone_Tenor
    case Saxophone_Baritone
    case Saxophone_Bass
    case Saxophone_Contrabass
    
    case Trumpet_Bflat
    case Trumpet_C
    case Trombone_Bflat
    case Trombone_F
    case Horn // different keys
    case Euphonium // different keys
    case Tuba
    
    case Percussion_Skin // enum
    case Percussion_Metal // enum
    case Percussion_Wood // enum
    
    case Keyboard_Piano
    
    case ContinuousController
    case BinarySwitch
    case MultiStateSwitch
    case Trigger
    
    case Waveform
    
    public func isInInstrumentFamily(instrumentFamily: InstrumentFamily.Type) -> Bool {
        return instrumentFamily.containsInstrumentType(self)
    }
    
    // return 3-tuple of clef, transposition amount, if transposition is shown
    public var preferredClefsAndTransposition: [(String, Int, Bool)] {
        // retrieve values from nested JSON Singleton
        let values = PreferredClefsAndTranspositionByInstrumentType.sharedInstance[self.rawValue]
        var tuples: [(String, Int, Bool)] = []
        for (_, value) in values {
            let clef: String = value["clef"].stringValue
            let transpsosition: Int
            let isShown: Bool
            
            if let t: Int = value["transposition"].int { transpsosition = t }
            else { transpsosition = 0 }
            
            if transpsosition != 0 {
                if let iS: Bool = value["transposition_shown"].bool where iS { isShown = true }
                else { isShown = false }
            }
            else { isShown = false }
            
            let tuple = (clef, transpsosition, isShown)
            tuples.append(tuple)
        }
        return tuples
    }
    
    private class PreferredClefsAndTranspositionByInstrumentType {
        class var sharedInstance : JSON {
            struct Static {
                static let instance: JSON = Static.getInstance()
                static func getInstance() -> JSON {
                    let bundle = NSBundle(forClass: InstrumentFamily.self)
                    let filePath = bundle.pathForResource(
                        "PreferredClefsAndTranspositionByInstrumentType", ofType: "json"
                    )!
                    let jsonData = NSData(contentsOfFile: filePath)!
                    let jsonObj: JSON = JSON(data: jsonData)
                    return jsonObj
                }
            }
            return Static.instance
        }
    }
}
