//
//  GraphEventEdgeHandler.swift
//  denm_view
//
//  Created by James Bean on 10/29/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

// Handler superclass?!?! obj 1, obj 2, do shit?, adjust?, act as a delegate? object has moved?
public class GraphEventEdgeHandler {
    
    public var graphEvent0: GraphEvent?
    public var graphEvent1: GraphEvent?
    
    public var hasDashes: Bool = false
    
    public init(
        graphEvent0: GraphEvent? = nil,
        graphEvent1: GraphEvent? = nil,
        hasDashes: Bool = false
    )
    {
        self.graphEvent0 = graphEvent0
        self.graphEvent1 = graphEvent1
        self.hasDashes = hasDashes
    }
    
}
