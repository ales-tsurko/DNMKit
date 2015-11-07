//
//  Component.swift
//  denm_model
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public enum ComponentProperty {
    case SlurStart
    case SlurStop
    case Dynamic(marking: String)
    case DMLigatureStart(type: Float)
    case DMLigatureStop
    case Articulation(markings: [String])
    case Pitch(pitches: [Float])
    case Rest
    case ExtensionStart
    case ExtensionStop
    case Node(value: Float)
    
    case EdgeStart(spannerArguments: SpannerArguments)
    
    
    case EdgeStop
    case Wave
    case TempoMarking(value: Int, subdivisionValue: Int)
    case Label(value: String)
    case StringArtificialHarmonic(pitch: Float)
    case StringNumber(romanNumeral: String)
    case StringBowDirection(direction: String)
    case GlissandoStart
    case GlissandoStop
}

// component should just be a class:
// -- inherit pID, iID, name: String, isGraphBearing: default false

public protocol Component {
    var pID: String { get set }
    var iID: String { get set }
    var property: ComponentProperty { get set }
    var isGraphBearing: Bool { get set }
    var name: String { get set }
}

public struct ComponentPitch: Component {
    public var name = "pitch"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = true
    
    public init(pID: String, iID: String, pitches: [Float]) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.Pitch(pitches: pitches)
    }
}

public struct ComponentGlissandoStart: Component {
    public var name = "glissando"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.GlissandoStart
    }
}

public struct ComponentGlissandoStop: Component {
    public var name = "glissando"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.GlissandoStop
    }
}

public struct ComponentArticulation: Component {
    public var name = "articulation"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String, markings: [String]) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.Articulation(markings: markings)
    }
}

public struct ComponentDynamic: Component {
    public var name = "dynamic"
    public var id: String
    //public var ligatureType: Float = 0 // 0 == none, 1 = <, -1 = >; 2.0 = -<, -2.0 = >-
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(id: String, pID: String, iID: String, marking: String) {
        self.id = id
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.Dynamic(marking: marking)
    }
}

public protocol ComponentDMLigature: Component {

    var id: String { get set }
}

public struct ComponentDMLigatureStart: ComponentDMLigature {
    public var name = "dynamic"
    public var id: String
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(id: String, pID: String, iID: String, type: Float) {
        self.id = id
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.DMLigatureStart(type: type)
    }
}

public struct ComponentDMLigatureStop: ComponentDMLigature {
    public var name = "dynamic"
    public var id: String
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(id: String, pID: String, iID: String) {
        self.id = id
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.DMLigatureStop
    }
}

public protocol ComponentSlur: Component {
    var id: String { get set }
}

public struct ComponentSlurStart: ComponentSlur {
    public var name = "slur"
    public var id: String
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(id: String, pID: String, iID: String) {
        self.id = id
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.SlurStart
    }
}

public struct ComponentSlurStop: ComponentSlur {
    public var name = "slur"
    public var id: String
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(id: String, pID: String, iID: String) {
        self.id = id
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.SlurStop
    }
}

public struct ComponentRest: Component {
    public var name = "rest"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = true
    
    public init(pID: String, iID: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.Rest
    }
}

public struct ComponentExtensionStart: Component {
    public var name = "extension"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.ExtensionStart
    }
}

public struct ComponentExtensionStop: Component {
    public var name = "extension"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.ExtensionStop
    }
}

public struct ComponentNode: Component {
    public var name = "node"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = true
    
    public init(pID: String, iID: String, value: Float) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.Node(value: value)
    }
}

public struct ComponentEdgeStart: Component {
    public var name = "edge_start"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = true
    
    public init(pID: String, iID: String, spannerArguments: SpannerArguments) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.EdgeStart(spannerArguments: spannerArguments)
    }
}

public struct ComponentEdgeStop: Component {
    public var name = "edge_stop"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = true
    
    public init(pID: String, iID: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.EdgeStop
    }
}

public struct ComponentWave: Component {
    public var name = "wave"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = true
    
    public init(pID: String, iID: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.Wave
    }
}

public struct ComponentLabel: Component {
    public var name = "label"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String, value: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.Label(value: value)
    }
}

public struct ComponentStringArtificialHarmonic: Component {
    public var name = "string_artificial_harmonic"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = true
    
    public init(pID: String, iID: String, pitch: Float) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.StringArtificialHarmonic(pitch: pitch)
    }
}

public struct ComponentStringNumber: Component {
    public var name = "string_string_number"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String, romanNumeral: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.StringNumber(romanNumeral: romanNumeral)
    }
}

public struct ComponentStringBowDirection: Component {
    public var name = "string_string_bow_direction"
    public var pID: String
    public var iID: String
    public var property: ComponentProperty
    public var isGraphBearing: Bool = false
    
    public init(pID: String, iID: String, bowDirection: String) {
        self.pID = pID
        self.iID = iID
        self.property = ComponentProperty.StringBowDirection(direction: bowDirection)
    }
}

