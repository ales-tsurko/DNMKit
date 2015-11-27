//
//  IntervalRelationship.swift
//  DNMModel
//
//  Created by James Bean on 11/27/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct IntervalRelationship: OptionSetType {

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    static var Equal = IntervalRelationship(rawValue: 1)
    static var TakesPlaceBefore = IntervalRelationship(rawValue: 2)
    static var TakesPlaceAfter = IntervalRelationship(rawValue: 4)
    static var Meets = IntervalRelationship(rawValue: 8)
    static var Overlaps = IntervalRelationship(rawValue: 16)
    static var During = IntervalRelationship(rawValue: 32)
    static var Starts = IntervalRelationship(rawValue: 64)
    static var Finishes = IntervalRelationship(rawValue: 128)
}