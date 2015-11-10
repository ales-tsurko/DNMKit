// From: 
// https://github.com/lithium3141/SwiftDataStructures/blob/master/SwiftDataStructures/OrderedDictionary.swift
//
//  OrderedDictionary.swift
//  DNMUtility
//
//  Created by James Bean on 11/9/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public struct OrderedDictionary<Tk: Hashable, Tv>: CustomStringConvertible {
    
    public var description: String { return getDescription() }

    var keys: [Tk] = []
    var values: [Tk : Tv] = [:]
    
    public init() { }
    
    subscript(key: Tk) -> Tv? {
        
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
        var result = "{\n"
        for i in 0..<keys.count {
            let key = keys[i]
            result += "[\(i): \(key) => \(self[key])\n"
        }
        result += "}"
        return result
    }
}