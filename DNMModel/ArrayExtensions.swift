//
//  ArrayExtensions.swift
//  denm_utility
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public extension Array {
    
    var second: Element? { get { return self[1] as Element } }
    
    func sum<T: Arithmetic>() -> T {
        return self.map { $0 as! T }.reduce(T.zero()) { T.add($0, $1) }
    }
    
    func containsElementsWithValuesGreaterThanValue<T: Comparable>(value: T) -> Bool {
        for el in self { if el as! T > value { return true } }
        return false
    }
    
    // find more elegant solution
    func mean<T: Arithmetic>() -> T {
        if self[0] is Int {
            let sum: Int = self.sum()
            let count: Int = self.count
            return T.divide(sum as! T, count as! T)
        }
        else if self[0] is Float {
            let sumAsFloat: Float = self.sum()
            let countAsFloat = Float(self.count)
            return T.divide(sumAsFloat as! T, countAsFloat as! T)
        }
        else if self[0] is Double {
            let sumAsDouble: Double = self.sum()
            let countAsDouble = Double(self.count)
            return T.divide(sumAsDouble as! T, countAsDouble as! T)
        }
        return T.zero()
    }
    
    func variance<T: Arithmetic>() -> T {
        var distancesSquared: [T] = []
        let mean: T = self.mean()
        for el in self {
            let distance: T = T.subtract(el as! T, mean)
            distancesSquared.append(T.multiply(distance, distance))
        }
        return distancesSquared.mean()
    }
    
    func evenness<T: Arithmetic>() -> T {
        var amountEven: Float = 0
        var amountOdd: Float = 0
        for el in self {
            if T.isEven(el as! T) { amountEven++ }
            else { amountOdd++ }
        }
        return T.zero()
    }
    
    func cumulative<T: Arithmetic>() -> [(value: T, position: T)] {
        let typedSelf: [T] = self.map { $0 as! T }
        var newSelf: [(value: T, position: T)] = []
        var cumulative: T = T.zero()
        for val in typedSelf {
            cumulative = T.add(cumulative, val)
            let pair: (value: T, position: T) = (value: val, position: cumulative)
            newSelf.append(pair)
        }
        return newSelf
    }
    
    func indexOf<T: Equatable>(value: T) -> Int? {
        for (index, el) in self.enumerate() {
            if el as! T == value { return index }
        }
        return nil
    }
    
    func indexOfObject(object: AnyObject) -> Int? {
        for (index, el) in self.enumerate() {
            if el as? AnyObject === object { return index }
        }
        return nil
    }
    
    func unique<T: Equatable>() -> [T] {
        var buffer: [T] = []
        var added: [T] = []
        for el in self {
            if !added.contains(el as! T) {
                buffer.append(el as! T)
                added.append(el as! T)
            }
        }
        return buffer
    }
    
    func random<T: Equatable>() -> T {
        let randomIndex: Int = Int(arc4random_uniform(UInt32(self.count)))
        return self[randomIndex] as! T
    }
    
    mutating func removeFirst() {
        assert(self.count > 0, "can't remove the first if there is nothing there")
        self.removeAtIndex(0)
    }
    
    mutating func removeFirst(amount amount: Int) {
        assert(self.count >= amount, "can't remove more than what's there")
        for _ in 0..<amount { self.removeAtIndex(0) }
    }
    
    mutating func removeLast(amount amount: Int) {
        assert(self.count >= amount, "can't remove more than what's there")
        for _ in 0..<amount { self.removeLast() }
    }
    
    mutating func remove<T: Equatable>(element: T) {
        let index: Int? = indexOf(element)
        if index != nil { removeAtIndex(index!) }
    }
    
    mutating func removeObject(object: AnyObject) {
        let index: Int? = indexOfObject(object)
        if index != nil { removeAtIndex(index!) }
    }
    
    func containsObject(object: AnyObject) -> Bool {
        if let _ = indexOfObject(object) { return true }
        return false
    }
}

public func ==<T: Equatable, U: Equatable> (tuple1:(T,U),tuple2:(T,U)) -> Bool {
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}

public func intersection<T: Equatable>(array0: [T], array1: [T]) -> [T] {
    let intersection = array0.filter { array1.contains($0) }
    return intersection
}

public func closest(array: [Float], val: Float) -> Float {
    var cur: Float = array[0]
    var diff: Float = abs(val - cur)
    for i in array {
        let newDiff = abs(val - i)
        if newDiff < diff { diff = newDiff; cur = i }
    }
    return cur
}

public func gcd(array: [Int]) -> Int {
    var x: Float = abs(Float(array[0]))
    for el in array {
        var y: Float = abs(Float(el))
        while (x > 0 && y > 0) { if x > y { x %= y } else { y %= x } }
        x += y
    }
    return Int(x)
}

public func getClosestPowerOfTwo(multiplier multiplier: Int, value: Int) -> Int {
    var potential: [Float] = []
    for exponent in -4..<4 {
        potential.append(Float(multiplier) * pow(2.0, Float(exponent)))
    }
    var closestVal: Float = closest(potential, val: Float(value))
    var newValue = value
    while closestVal % 1.0 != 0 { closestVal *= 2.0; newValue *= 2 }
    return Int(closestVal)
}