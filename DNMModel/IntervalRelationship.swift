//
//  IntervalRelationship.swift
//  DNMModel
//
//  Created by James Bean on 11/27/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

// Implementation of Allen's interval algebra calculus
public struct IntervalRelationship: OptionSetType {

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static var Equal = IntervalRelationship(rawValue: 1)
    public static var TakesPlaceBefore = IntervalRelationship(rawValue: 2)
    public static var TakesPlaceAfter = IntervalRelationship(rawValue: 4)
    public static var Meets = IntervalRelationship(rawValue: 8)
    public static var Overlaps = IntervalRelationship(rawValue: 16)
    public static var During = IntervalRelationship(rawValue: 32)
    public static var Starts = IntervalRelationship(rawValue: 64)
    public static var Finishes = IntervalRelationship(rawValue: 128)
}