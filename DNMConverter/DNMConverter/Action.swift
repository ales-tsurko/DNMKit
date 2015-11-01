//
//  Actions.swift
//  denm_parser
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public enum Action {
    //case IIDsAndInstrumentTypesByPID(instrumentTypeByIIDByPID: [String : [String : String]])
    case IIDsAndInstrumentTypesByPID(instrumentTypeAndIIDByPID: [ [String : [(String, String)]] ] )
    case DurationAccumulationMode(mode: String)
    
    case PID(string: String)
    case IID(string: String)
    
    // deprecate
    case ID(string: String) // extend
    
    case Measure
    case RehearsalMarking(type: String) // a: alphabetical or numerical
    case SlurStart(id: String) // workaround for weird Swift error: remove ID
    case SlurStop(id: String) // workaround for weird Swift error: remove ID
    case DurationNodeRoot(duration: (Int, Int))
    case DurationNodeInternal(beats: Int, depth: Int)
    case DurationNodeLeaf(beats: Int, depth: Int)
    case Pitch([Float])
    case Dynamic(marking: String)
    case Articulation(markings: [String])
    case Rest // workaround
    case ExtensionStart(id: String) // workaround
    case ExtensionStop(id: String) // workaround
    case DMLigatureStart(id: String) // workaround?
    case DMLigatureStop(id: String) // workaround
    case NonNumerical(id: String) // workaround ... to be deprecated
    case NonMetrical(id: String) // workaround ... to be deprecated
    case Tremolo(id: String) // workaround
    
    case Node(value: Float)
    case NodeStop(id: String) // workaround
    case EdgeStart(hasDashes: Bool) // workaround
    case EdgeStop(id: String) // workaround
    
    case HideTimeSignature(id: String) // workaround
    case Wave(id: String) // workaround
    case Tempo(value: Int, subdivisionLevel: Int)
    case Label(value: String)
    case StringArtificialHarmonic(pitch: Float)
    case StringBowDirection(value: String) // Up, Down
    case StringNumber(value: String) // I, II, III, IV
    case GlissandoStart(id: String) // workaround
    case GlissandoStop(id: String) // workaround
}