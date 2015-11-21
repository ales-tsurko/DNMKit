//
//  Stack.swift
//  DNMUtility
//
//  Created by James Bean on 11/9/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct Stack<Element> {
    
    private var items: [Element] = []
    
    public var top: Element? { return items.last }
    
    public init() { }
    
    public init(items: [Element]) {
        self.items = items
    }
    
    public mutating func push(item: Element) {
        items.append(item)
    }
    
    public mutating func pop() -> Element? {
        if items.count == 0 { return nil }
        return items.removeLast()
    }
    
    public mutating func pop(amount amount: Int) -> [Element] {
        if items.count < amount { return [] }
        var poppedItems: [Element] = []
        for _ in 0..<amount { poppedItems.append(pop()!) }
        return poppedItems
    }
}