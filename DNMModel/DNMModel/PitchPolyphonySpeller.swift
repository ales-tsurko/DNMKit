//
//  PitchPolyphonySpeller.swift
//  denm_pitch
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation


/*
public class PitchPolyphonySpeller {
    
    public var polyphony: PitchPolyphony
    
    public init(polyphony: PitchPolyphony) {
        self.polyphony = polyphony
    }
    
    public func spell() {
        
        // if only one verticality: spell
        
        // if > 1 verticality:
        
        // -- shifting window size technique
        
        // agglomerate (n,n+1) into a single PitchVerticality for a PitchVerticalitySpeller
        
        switch polyphony.verticalities.count {
        case 0:
            assertionFailure("There must be more than 0 verticalities in order to spell")
        case 1:
            print("single verticality: spell by itself")
            let speller = PitchVerticalitySpeller(verticality: polyphony.verticalities.first!)
            speller.spell()
        default:
            print("more than one verticality: shifting window size technique")
            print("polyphony.verticalities.count: \(polyphony.verticalities.count)")
            var composites: [PitchVerticality] = []
            for i in 0..<polyphony.verticalities.count - 1 {
                var v0_pitches: [Pitch] = []
                for pitch in polyphony.verticalities[i].pitches {
                    v0_pitches.append(pitch.copy())
                }
                var v1_pitches: [Pitch] = []
                for pitch in polyphony.verticalities[i+1].pitches {
                    v1_pitches.append(pitch.copy())
                }
                let v0 = PitchVerticality(pitches: v0_pitches)
                let v1 = PitchVerticality(pitches: v1_pitches)
                
                let composite = PitchVerticality(verticality0: v0, verticality1: v1)
                print("composite: \(composite)")
                let speller = PitchVerticalitySpeller(verticality: composite)
                speller.spell()
                for pitch in composite.pitches {
                    print(pitch)
                }
                composites.append(composite)
            }
            
            for c in 0..<composites.count - 1 {
                print("COMPOSITE:")
                let cur = composites[c]
                let next = composites[c+1]
                for p_cur in cur.pitches {
                    for p_next in next.pitches {
                        print("cur: \(p_cur); next: \(p_next)")
                        if p_cur == p_next {
                            if p_cur.spelling != p_next.spelling {
                                print("Different Spellings")
                                print("p_cur sharpness: \(p_cur.spelling!.sharpness)")
                                print("p_next sharpness: \(p_next.spelling!.sharpness)")
                                
                                var spellings = [p_cur.spelling!, p_next.spelling!]
                                spellings.sortInPlace { abs($0.sharpness) < abs($1.sharpness) }
                                
                                print("least sharp: \(spellings.first!)")
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        /*
        for v in 0..<polyphony.verticalities.count - 1 {
        let v0 = polyphony.verticalities[v]
        let v1 = polyphony.verticalities[v+1]
        //let allTheSame: Bool = true
        
        /*
        for p0 in v0.pitches {
        for p1 in v1.pitches {
        print("p0: \(p0); p1: \(p1); same: \(p0 == p1)")
        }
        }
        */
        
        }
        */
    }
}
*/