//
//  Component.swift
//  denm_model
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class Component: CustomStringConvertible {
    
    public var description: String { return getDescription() }
    
    public var identifier: String { return "Abstract Component" }
    public var performerID: String
    public var instrumentID: String
    
    // override in subclasses
    public var isGraphBearing: Bool { return getIsGraphBearing() }
    
    public init(
        performerID: String,
        instrumentID: String
    )
    {
        self.performerID = performerID
        self.instrumentID = instrumentID
    }
    
    private func getIsGraphBearing() -> Bool {
        return false
    }
    
    private func getDescription() -> String {
        return identifier
    }
}

public class ComponentRest: Component {
    
    public override var identifier: String { return "Rest" }
    
    private override func getIsGraphBearing() -> Bool {
        return true
    }
}

public class ComponentPitch: Component {
    
    public override var identifier: String { return "Pitch" }
    
    public var values: [Float]
    
    public init(performerID: String, instrumentID: String, values: [Float]) {
        self.values = values
        super.init(performerID: performerID, instrumentID: instrumentID)
    }
    
    private override func getIsGraphBearing() -> Bool {
        return true
    }
    
    private override func getDescription() -> String {
        var description = identifier
        if values.count == 1 {
            description += ": \(values.first!)"
        }
        else if values.count > 1 {
            description += ": { "
            for (v, value) in values.enumerate() {
                if v > 0 { description += ", " }
                description += "\(value)"
            }
            description += " }"
        }
        return description
    }
}

public class ComponentDynamicMarking: Component {
    
    public override var identifier: String { return "DynamicMarking" }
    
    public var value: String
    
    public init(performerID: String, instrumentID: String, value: String) {
        self.value = value
        super.init(performerID: performerID, instrumentID: instrumentID)
    }
    
    private override func getDescription() -> String {
        return identifier + ": \(value)"
    }
}

public class ComponentDynamicMarkingSpanner: Component {
    
    // something
}

public class ComponentDynamicMarkingSpannerStart: ComponentDynamicMarkingSpanner {
    
    // for now, no variables
    
    public override var identifier: String { return "DynamicMarkingSpannerStart" }
}

public class ComponentDynamicMarkingSpannerStop: ComponentDynamicMarkingSpanner {
    
    public override var identifier: String { return "DynamicMarkingSpannerStop" }
}

public class ComponentSlurStart: Component {
    
    public override var identifier: String { return "SlurStart" }
}

public class ComponentSlurStop: Component {
    
    public override var identifier: String { return "SlurStop" }
}

public class ComponentArticulation: Component {
    
    public override var identifier: String { return "Articulation" }
    
    public var values: [String] = []
    
    public init(performerID: String, instrumentID: String, values: [String]) {
        self.values = values
        super.init(performerID: performerID, instrumentID: instrumentID)
    }
    
    private override func getDescription() -> String {
        var description: String = identifier
        if values.count == 1 {
            description += ": \(values.first!)"
        }
        else if values.count > 1 {
            description += ": { "
            for (v, value) in values.enumerate() {
                if v > 0 { description += ", " }
                description += "\(value)"
            }
            description += " }"
        }
        return description
    }
}

public class ComponentExtensionStart: Component {
    
    public override var identifier: String { return "ExtensionStart" }
}

public class ComponentExtensionStop: Component {
    
    public override var identifier: String { return "ExtensionStop" }
}

public class ComponentGraphNode: Component {
    
    public override var identifier: String { return "GraphNode" }
    
    public var value: Float
    
    public init(performerID: String, instrumentID: String, value: Float) {
        self.value = value
        super.init(performerID: performerID, instrumentID: instrumentID)
    }
    
    private override func getIsGraphBearing() -> Bool {
        return true
    }
    
    private override func getDescription() -> String {
        return identifier + ": \(value)"
    }
}

public class ComponentGraphEdgeStart: Component {
    
    public override var identifier: String { return "GraphEdgeStart" }
    
    // TODO
    public var spannerValues: Int = 0
    
    private override func getIsGraphBearing() -> Bool {
        return true
    }
}

public class ComponentGraphEdgeStop: Component {
    
    public override var identifier: String { return "GraphEdgeStop" }
    
    private override func getIsGraphBearing() -> Bool {
        return true
    }
}

public class ComponentStringArtificialHarmonic: Component {
    
    public override var identifier: String { return "StringArtificialHarmonic" }
    
    public var value: Float
    
    public init(performerID: String, instrumentID: String, value: Float) {
        self.value = value
        super.init(performerID: performerID, instrumentID: instrumentID)
    }
    
    private override func getIsGraphBearing() -> Bool {
        return true
    }
}

public class ComponentWaveform: Component {
    
    public override var identifier: String { return "Waveform" }
    
    private override func getIsGraphBearing() -> Bool {
        return true
    }
}