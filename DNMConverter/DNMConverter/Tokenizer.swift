//
//  Tokenizer.swift
//  denm_parser
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

internal class Tokenizer {
    
    internal var items: [Item]
    
    internal init(items: [Item]) {
        self.items = items
    }
    
    internal func getTokens() -> [Token] {
    
        var inBlockComment: Bool = false
        //var inLineComment: Bool = false
        
        var tokens: [Token] = []
        var lineCount: Int = 0
        var indentationLevel: Int = 0
        var index: Int = 0
        while index < items.count {
            let item: Item = items[index]
            switch item {
            case .NewLine:
                
                if !inBlockComment {
                    switch items[index + 1] {
                    case .Indent: break
                    default: indentationLevel = 0
                    }
                    lineCount++
                }
            case .Indent:
                if !inBlockComment { indentationLevel = getIndentationLevel(&index) }
            case .Character:
                if !inBlockComment {
                    addTokenForCharacterBegunAtIndex(&index,
                        lineCount: lineCount,
                        indentationLevel: indentationLevel,
                        tokens: &tokens
                    )
                }
            case .BlockCommentStart:
                inBlockComment = true
            case .BlockCommentStop:
                inBlockComment = false
            case .LineCommentStart:
                //inLineComment = true
                break
            default: break
            }
            index++
        }
        return tokens
    }
    
    private func addTokenForCharacterBegunAtIndex(
        inout index: Int,
        lineCount: Int,
        indentationLevel: Int,
        inout tokens: [Token]
    )
    {
        let item = items[index]
        switch item {
        case .Character(let value):
            switch value {
            case "0"..."9":
                let number = getNumberBegunAtIndex(&index)
                let token = Token.Number(
                    value: number,
                    indentationLevel: indentationLevel,
                    lineCount: lineCount
                )
                tokens.append(token)
            case ",", "/", ":":
                // something else, perhaps case specific
                break
            default:
                // all other symbols
                let symbol = getSymbolBegunAtIndex(&index)
                let token = Token.Symbol(
                    value: symbol,
                    indentationLevel: indentationLevel,
                    lineCount: lineCount
                )
                tokens.append(token)
            }
        default: break
        }
    }
    
    private func getSymbolBegunAtIndex(inout index: Int) -> String {
        var symbolAsString: String = ""
        while index < items.count {
            switch items[index] {
            case .Character(let value):
                symbolAsString += value
                index++
            default:
                // overshot, compensate, return
                index--
                return symbolAsString
            }
        }
        // overshot, compensate, return
        index--
        return symbolAsString
    }
    
    private func getNumberBegunAtIndex(inout index: Int) -> String {
        var numberAsString: String = ""
        while index < items.count {
            switch items[index] {
            case .Character(let value):
                if value.isDigitOrDecimalPoint() {
                    numberAsString += value
                    index++
                }
                else {
                    // overshot, compensate, return
                    index--
                    return numberAsString
                }
            default:
                // overshot, compensate, return
                index--
                return numberAsString
            }
        }
        // overshot, compensate, return
        index--
        return numberAsString
    }
    
    private func getIndentationLevel(inout index: Int) -> Int {
        var indentationLevel: Int = 0
        while index < items.count {
            switch items[index] {
            case .Indent:
                indentationLevel++
                index++
            default:
                // overshot, compensate, return
                index--
                return indentationLevel
            }
        }
        return 0
    }
}

extension String {
    func isDigitOrDecimalPoint() -> Bool {
        switch self {
        case "0"..."9", ".": return true
        default: return false
        }
    }
}