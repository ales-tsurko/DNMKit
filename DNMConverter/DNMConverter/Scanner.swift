//
//  Scanner.swift
//  denm_parser
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

internal class Scanner {
    
    // input
    var code: [String]
    
    internal init(code: String) {
        self.code = code.characters.map { s -> String in String(s) }
    }
    
    internal func getItems() -> [Item] {
        var items: [Item] = [.BOF]
        var index: Int = 0
        while index < code.count {
            let item: String = code[index]
            switch item {
            case " ":
                // encapsulate peek ahead for indentation
                var isIndent: Bool = true
                var peek: Int = 1
                while peek < 4 {
                    if code[index + peek] != " " {
                        items.append(.Space)
                        index += peek
                        isIndent = false
                        break
                    }
                    peek++
                }
                if isIndent {
                    items.append(.Indent)
                    index += peek
                }
            case "\n":
                items.append(.NewLine)
                index++
            case "\t":
                items.append(.Indent)
                index++
            case "/":
                if index < code.count - 1 {
                    let nextString: String = code[index + 1]
                    switch nextString {
                    case "*":
                        items.append(.BlockCommentStart)
                        index++
                    case "/":
                        items.append(Item.LineCommentStart)
                        index++
                    default: break
                    }
                    index++
                }
                else {
                    index++
                }
            case "*":
                if index < code.count - 1 && code[index + 1] == "/" {
                    items.append(Item.BlockCommentStop)
                    index += 2
                }
                else {
                    index++
                }
            default:
                items.append(.Character(value: item))
                index++
            }
        }
        items.append(.EOF)
        return items
    }
}