//
//  Arithmetic.swift
//  denm_utility
//
//  Created by James Bean on 8/12/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public protocol Arithmetic {
    static func add(lhs: Self, _ rhs: Self) -> Self
    static func subtract(lhs: Self, _ rhs: Self) -> Self
    static func multiply(lhs: Self, _ rhs: Self) -> Self
    static func divide(lhs: Self, _ rhs: Self) -> Self
    static func modulo(lhs: Self, _ rhs: Self) -> Self
    static func isEven(val: Self) -> Bool
    static func zero() -> Self
}

extension Int: Arithmetic {
    public static func add(lhs: Int, _ rhs: Int) -> Int {
        return lhs + rhs
    }
    
    public static func subtract(lhs: Int, _ rhs: Int) -> Int {
        return lhs - rhs
    }
    
    public static func multiply(lhs: Int, _ rhs: Int) -> Int {
        return lhs * rhs
    }
    
    public static func divide(lhs: Int, _ rhs: Int) -> Int {
        return lhs / rhs
    }
    
    public static func modulo(lhs: Int, _ rhs: Int) -> Int {
        let result = lhs % rhs
        return result < 0 ? result + rhs : result
    }
    
    public static func isEven(val: Int) -> Bool {
        return val % 2 == 0
    }
    
    public static func zero() -> Int {
        return 0
    }
    
    public func format(f: String) -> String {
        return NSString(format: "%\(f)d", self) as String
    }
}

extension Float: Arithmetic {
    public static func add(lhs: Float, _ rhs: Float) -> Float {
        return lhs + rhs
    }
    
    public static func subtract(lhs: Float, _ rhs: Float) -> Float {
        return lhs - rhs
    }
    
    public static func multiply(lhs: Float, _ rhs: Float) -> Float {
        return lhs * rhs
    }
    
    public static func divide(lhs: Float, _ rhs: Float) -> Float {
        return lhs / rhs
    }
    
    public static func modulo(lhs: Float, _ rhs: Float) -> Float {
        let result = lhs % rhs
        return result < 0 ? result + rhs : result
    }
    
    public static func isEven(val: Float) -> Bool {
        return val % 2.0 == 0.0
    }
    
    public static func zero() -> Float {
        return 0.0
    }
    
    public func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

extension Double: Arithmetic {
    public static func add(lhs: Double, _ rhs: Double) -> Double {
        return lhs + rhs
    }
    
    public static func subtract(lhs: Double, _ rhs: Double) -> Double{
        return lhs - rhs
    }
    
    public static func multiply(lhs: Double, _ rhs: Double) -> Double {
        return lhs * rhs
    }
    
    public static func divide(lhs: Double, _ rhs: Double) -> Double {
        return lhs / rhs
    }
    
    public static func modulo(lhs: Double, _ rhs: Double) -> Double {
        let result = lhs % rhs
        return result < 0 ? result + rhs : result
    }
    
    public static func isEven(val: Double) -> Bool {
        return val % 2.0 == 0.0
    }
    
    public static func zero() -> Double {
        return 0.0
    }
    
    public func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

// MAKE GENERIC
public func DEGREES_TO_RADIANS(degrees: Float) -> Float {
    return degrees / 180.0 * Float(M_PI)
}

public func RADIANS_TO_DEGREES(radians: Float) -> Float {
    return radians * (180.0 / Float(M_PI))
}

public func DEGREES_TO_RADIANS(degrees: CGFloat) -> CGFloat {
    return degrees / 180.0 * CGFloat(M_PI)
}

public func RADIANS_TO_DEGREES(radians: CGFloat) -> CGFloat {
    return radians * (180.0 / CGFloat(M_PI))
}

/*
/** Degrees to Radian **/
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )
*/