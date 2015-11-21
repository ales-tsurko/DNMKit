//
//  UIColorExtensions.swift
//  DNMView
//
//  Created by James Bean on 10/31/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public extension UIColor {
    
    // blue, orange, purple,
    public class func grayscaleColorWithDepthOfField(depthOfField: DepthOfField,
        inColorMode colorMode: ColorMode
        ) -> UIColor
    {
        let b = getGrayscaleBrightnessWithDepthOfField(depthOfField, inColorMode: colorMode)
        return UIColor(hue: 0, saturation: 0, brightness: b, alpha: 1)
    }
    
    public class func grayscaleColorWithDepthOfField(depthOfField: DepthOfField) -> UIColor {
        let b = getGrayscaleBrightnessWithDepthOfField(depthOfField,
            inColorMode: DNMColorManager.colorMode
        )
        return UIColor(hue: 0, saturation: 0, brightness: b, alpha: 1)
    }
    
    public class func colorWithHue(hue: CGFloat, andDepthOfField depthOfField: DepthOfField
        ) -> UIColor
    {
        let (s, b) = getSaturationAndBrightnessWithDepthOfField(depthOfField,
            inColorMode: DNMColorManager.colorMode
        )
        return UIColor(hue: hue / 360, saturation: s, brightness: b, alpha: 1)
    }
    
    public class func colorWithHue(hue: CGFloat,
        andDepthOfField depthOfField: DepthOfField, inColorMode colorMode: ColorMode
        ) -> UIColor
    {
        let (s, b) = getSaturationAndBrightnessWithDepthOfField(depthOfField,
            inColorMode: colorMode
        )
        return UIColor(hue: hue / 360, saturation: s, brightness: b, alpha: 1)
    }
    
    private static func getSaturationAndBrightnessWithDepthOfField(depthOfField: DepthOfField,
        inColorMode colorMode: ColorMode
        ) -> (CGFloat, CGFloat)
    {
        switch colorMode {
        case .Dark:
            switch depthOfField {
            case .MostBackground: return (0.6,0.1)
            case .Background: return (0.6,0.2)
            case .MiddleBackground: return (0.6,0.3)
            case .Middleground: return (0.6,0.4)
            case .MiddleForeground: return (0.6,0.5)
            case .Foreground: return (0.6,0.6)
            case .MostForeground: return (0.6,0.7)
            }
        case .Light:
            switch depthOfField {
            case .MostBackground: return (0.10,1.0)
            case .Background: return (0.25,0.95)
            case .MiddleBackground: return (0.32,0.88)
            case .Middleground: return (0.39,0.81)
            case .MiddleForeground: return (0.46,0.74)
            case .Foreground: return (0.53,0.67)
            case .MostForeground: return (0.60,0.60)
            }
        }
    }
    
    private static func getGrayscaleBrightnessWithDepthOfField(depthOfField: DepthOfField,
        inColorMode colorMode: ColorMode
        ) -> CGFloat {
            
            switch colorMode {
            case .Dark:
                switch depthOfField {
                case .MostBackground: return 0
                case .Background: return 0.17
                case .MiddleBackground: return 0.35
                case .Middleground: return 0.52
                case .MiddleForeground: return 0.79
                case .Foreground: return 0.9
                case .MostForeground: return 1.0
                }
            case .Light:
                switch depthOfField {
                case .MostBackground: return 1.0
                case .Background: return 0.9
                case .MiddleBackground: return 0.79
                case .Middleground: return 0.52
                case .MiddleForeground: return 0.35
                case .Foreground: return 0.17
                case .MostForeground: return 0.0
                }
            }
    }

}
