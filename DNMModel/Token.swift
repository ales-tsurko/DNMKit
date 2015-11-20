//
//  Token.swift
//  Tokenizer3
//
//  Created by James Bean on 11/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//


import Foundation

// TODO: get rid of indentation level as a property -- instead, this will be its own Token
public protocol Token: CustomStringConvertible {
    
    // lets?
    var identifier: String { get set }
    var startIndex: Int { get set }
    var stopIndex: Int { get set }
    //var indentationLevel: Int? { get set }
}

public struct TokenLineComment: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    
    public init(startIndex: Int, stopIndex: Int) {
        self.identifier = "LineComment"
        self.startIndex = startIndex
        self.stopIndex = stopIndex
    }
    
    private func getDescription() -> String {
        return "\(identifier) from \(startIndex) to \(stopIndex)"
    }
}

// make TokenContainer?
public struct TokenBlockCommentStart: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    
    public init(startIndex: Int) {
        self.identifier = "BlockCommentStart"
        self.startIndex = startIndex
        self.stopIndex = startIndex + 1
    }
    
    private func getDescription() -> String {
        return "\(identifier) from \(startIndex) to \(stopIndex)"
    }
}

public struct TokenBlockCommentStop: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    
    public init(startIndex: Int) {
        self.identifier = "BlockCommentStop"
        self.startIndex = startIndex
        self.stopIndex = startIndex + 1
    }
    
    private func getDescription() -> String {
        return "\(identifier) from \(startIndex) to \(stopIndex)"
    }
}

public struct TokenIndent: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    
    public init(startIndex: Int, stopIndex: Int) {
        self.identifier = "Indentation"
        self.startIndex = startIndex
        self.stopIndex = stopIndex
    }
    
    private func getDescription() -> String {
        return "\(identifier) from \(startIndex) to \(stopIndex)"
    }
}

public struct TokenString: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    public var indentationLevel: Int?
    
    public var value: String
    
    // use length fo string to determine stop index
    
    public init(
        identifier: String,
        value: String,
        startIndex: Int,
        indentationLevel: Int? = nil
    )
    {
        self.identifier = identifier
        self.value = value
        self.startIndex = startIndex
        self.stopIndex = startIndex + value.characters.count
        self.indentationLevel = indentationLevel
    }
    
    private func getDescription() -> String {
        return "\(identifier): \(value); from \(startIndex) to \(stopIndex)"
    }
}

public struct TokenInt: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    public var indentationLevel: Int?
    
    public var value: Int
    
    public init(
        identifier: String,
        value: Int,
        startIndex: Int,
        stopIndex: Int,
        indentationLevel: Int? = nil
    )
    {
        self.identifier = identifier
        self.value = value
        self.startIndex = startIndex
        self.stopIndex = stopIndex
        self.indentationLevel = indentationLevel
    }

    private func getDescription() -> String {
        return "\(identifier): \(value); from \(startIndex) to \(stopIndex)"
    }
}

public struct TokenFloat: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    public var indentationLevel: Int?
    
    public var value: Float
    
    public init(
        identifier: String,
        value: Float,
        startIndex: Int,
        stopIndex: Int,
        indentationLevel: Int? = nil
    )
    {
        self.identifier = identifier
        self.value = value
        self.startIndex = startIndex
        self.stopIndex = stopIndex
        self.indentationLevel = indentationLevel
    }
    
    private func getDescription() -> String {
        return "\(identifier): \(value); from \(startIndex) to \(stopIndex)"
    }
}

public struct TokenDuration: Token {
    
    public var description: String { return getDescription() }
    
    public var identifier: String
    public var startIndex: Int
    public var stopIndex: Int
    public var indentationLevel: Int?
    
    // (beats, subdivisionValue)
    public var value: (Int, Int)
    
    public init(
        identifier: String,
        value: (Int, Int),
        startIndex: Int,
        stopIndex: Int,
        indentationLevel: Int? = nil
    )
    {
        self.identifier = identifier
        self.value = value
        self.startIndex = startIndex
        self.stopIndex = stopIndex
        self.indentationLevel = indentationLevel
    }
    
    private func getDescription() -> String {
        return "\(identifier): \(value); from \(startIndex) to \(stopIndex)"
    }
}