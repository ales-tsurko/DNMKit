//
//  Parser.swift
//  DNMConverter
//
//  Created by James Bean on 11/9/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

public class Parser {
    
    private var durationNodeStackMode: DurationNodeStackMode = .Measure
    
    public init() { }
    
    public func parseTokenContainer(tokenContainer: TokenContainer) ->  DNMScoreModel {
        
        
        return DNMScoreModel()
    }
}

private enum DurationNodeStackMode: String {
    case Measure = "|"
    case Increment = "+"
    case Decrement = "-"
}