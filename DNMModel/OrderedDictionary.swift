// From: 
// https://github.com/lithium3141/SwiftDataStructures/blob/master/SwiftDataStructures/OrderedDictionary.swift
// and
// http://nshipster.com/swift-collection-protocols/
//
//  OrderedDictionary.swift
//  DNMUtility
//
//  Created by James Bean on 11/9/15.
//  Copyright © 2015 James Bean. All rights reserved.
//


import Foundation

public struct OrderedDictionary<Tk: Hashable, Tv: Equatable where Tk: Comparable>: Equatable, CustomStringConvertible
{
    
    public var description: String { return getDescription() }

    public var keys: [Tk] = []
    public var values: [Tk : Tv] = [:]
    
    public var count: Int { return keys.count }
    
    public init() { }
    
    public mutating func appendContentsOfOrderedDictionary(
        orderedDictionary: OrderedDictionary<Tk, Tv>
    )
    {
        keys.appendContentsOf(orderedDictionary.keys)
        for key in orderedDictionary.keys {
            values.updateValue(orderedDictionary[key]!, forKey: key)
        }
    }
    
    public subscript(key: Tk) -> Tv? {
        
        get {
            return values[key]
        }
        
        set(newValue) {
            if newValue == nil {
                values.removeValueForKey(key)
                keys = keys.filter { $0 != key }
                return
            }
            
            let oldValue = values.updateValue(newValue!, forKey: key)
            if oldValue == nil {
                keys.append(key)
            }
        }
    }
    
    private func getDescription() -> String {
        var description: String = "Ordered Dictionary: [\n"
        for i in 0..<keys.count {
            let key = keys[i]
            description += "\t(\(i), \(key)): \(self[key]!)\n"
        }
        description += "]"
        return description
    }
}

extension OrderedDictionary: SequenceType {
    
    public typealias Generator = AnyGenerator<(Tk, Tv)>
    
    public func generate() -> Generator {
        
        var zipped: [(Tk, Tv)] = []
        for key in keys { zipped.append((key, values[key]!)) }
        
        var index = 0
        return anyGenerator {
            if index < self.keys.count { return zipped[index++] }
            return nil
        }
    }
}

public func ==<Tk: Hashable, Tv: Equatable where Tk: Comparable>(
    lhs: OrderedDictionary<Tk, Tv>, rhs: OrderedDictionary<Tk, Tv>
) -> Bool {
    if lhs.keys != rhs.keys { return false }
    
    // for each lhs key, check if rhs has value for key, and if that value is the same
    for key in lhs.keys {
        if rhs.values[key] == nil || rhs.values[key]! != lhs.values[key]! {
            return false
        }
    }
    return true
}