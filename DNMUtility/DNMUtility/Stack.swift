//
//  Stack.swift
//  DNMUtility
//
//  Created by James Bean on 11/9/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct Stack<Element> {
    
    var items: [Element] = []
    
    mutating func push(item: Element) {
        items.append(item)
    }
    
    mutating func pop(item: Element) -> Element? {
        if items.count == 0 { return nil }
        return items.removeLast()
    }
}