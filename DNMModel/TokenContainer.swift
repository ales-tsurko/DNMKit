//
//  TokenBranch.swift
//  Tokenizer3
//
//  Created by James Bean on 11/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class TokenContainer: Token {
    
    public var identifier: String
    
    public var description: String { return getDescription() }
    
    public var openingValue: String
    
    public var argumentMatches: [String] = []
    
    public var tokens: [Token] = []
    
    public var startIndex: Int
    public var stopIndex: Int = -1 // to be calculated with contents
    
    public var indentationLevel: Int?
    
    public init(identifier: String, openingValue: String = "", startIndex: Int) {
        self.identifier = identifier
        self.openingValue = openingValue
        self.startIndex = startIndex
        self.stopIndex = startIndex + openingValue.characters.count
    }
    
    public func addToken(token: Token) {
        tokens.append(token)
        //if token.stopIndex > stopIndex { stopIndex = token.stopIndex }
    }
    
    private func getDescription() -> String {
        var description: String = "\(identifier)"
        if openingValue != "" { description += ": \(openingValue)" }
        description += "; from \(startIndex) to \(stopIndex)"
        for token in tokens {
            if token is TokenContainer {
                description += "\n\(token)"
            } else {
                description += "\n-- \(token)"
            }
        }
        
        // for token in tokens { description += "\n---- \(token)" }
        return description
    }
}