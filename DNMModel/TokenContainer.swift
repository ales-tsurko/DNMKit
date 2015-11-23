//
//  TokenBranch.swift
//  Tokenizer3
//
//  Created by James Bean on 11/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
TokenContainer is an hierarchical structure containing 0...n tokens 
(which may be TokenContainers, themselves)
*/
public class TokenContainer: Token {

    /// String representation of TokenContainer
    public var description: String { return getDescription() }
    
    /// Identifier of TokenContainer
    public var identifier: String
    
    /// String value that opens the scope of a command (e.g., "p" for Pitch value)
    public var openingValue: String
    
    /// All of the Tokens contained by this TokenContainer (may be TokenContainers, themselves)
    public var tokens: [Token] = []
    
    // MARK: Syntax highlighting
    
    /// Index in the source file where this Token starts (used for syntax highlighting)
    public var startIndex: Int
    
    /// Index in the source file where this Token stops (used for syntax highlighting)
    public var stopIndex: Int = -1 // to be calculated with contents
    
    /**
    Create a TokenContainer with an identifier, opening value, and start index
    
    - parameter identifier:   String that is used by syntax highlighter to identify Tokens
    - parameter openingValue: String value that opens scope of a command
    - parameter startIndex:   Index in the source file where this Token starts
    
    - returns: TokenContainer
    */
    public init(identifier: String, openingValue: String = "", startIndex: Int) {
        self.identifier = identifier
        self.openingValue = openingValue
        self.startIndex = startIndex
        self.stopIndex = startIndex + openingValue.characters.count - 1
    }
    
    /**
    Add Token to contained Tokens

    - parameter token: Token
    */
    public func addToken(token: Token) {
        tokens.append(token)
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
        return description
    }
}