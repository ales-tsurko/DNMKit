//
//  TextLayerContstrainedByHeight.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

public class TextLayerConstrainedByHeight: CATextLayer, BuildPattern {
    
    public var x: CGFloat = 0
    public var top: CGFloat = 0
    public var height: CGFloat = 0
    public var fontName: String = ""
    public var alignment: PositionAbsolute = .Left
    
    public var left: CGFloat { get { return getLeft() } }
    public var width: CGFloat { get { return getWidth() } }
    
    public var hasBeenBuilt: Bool = false
    
    public init(
        text: String,
        x: CGFloat,
        top: CGFloat,
        height: CGFloat,
        alignment: PositionAbsolute,
        fontName: String = "AvenirNext-Medium"
    )
    {
            super.init()
            self.string = text
            self.x = x
            self.top = top
            self.height = height
            self.fontName = fontName
            self.font = UIFont(name: fontName, size: getFontSize())
            self.fontSize = getFontSize()
            self.alignment = alignment
            self.foregroundColor = UIColor.blackColor().CGColor
            setFrame()
            contentsScale = UIScreen.mainScreen().scale
    }
    
    public override init() { super.init() }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func build() {
        borderWidth = 1
        borderColor = UIColor.redColor().CGColor
        contentsScale = UIScreen.mainScreen().scale
        hasBeenBuilt = true
    }
    
    private func setFont() {
        //self.font = UIFont(name: fontName, size: size)
        self.font = UIFont(name: fontName, size: 12)
        print("font: \(font)", terminator: "")
    }
    
    private func setFrame() {
        let t = top + (font!.capHeight - font!.ascender)
        let h = fontSize - font!.descender
        frame = CGRectMake(left, t, width, h)
    }
    
    private func getLeft() -> CGFloat {
        switch alignment {
        case .Left:
            self.alignmentMode = kCAAlignmentLeft
            return x
        case .Center:
            self.alignmentMode = kCAAlignmentCenter
            return x - 0.5 * width
        case .Right:
            self.alignmentMode = kCAAlignmentRight
            return x - width
        default: break
        }
        return x
    }
    
    private func getWidth() -> CGFloat {
        let w: CGFloat = string!.sizeWithAttributes([NSFontAttributeName: font!]).width
        return w
    }
    
    private func getFontSize() -> CGFloat {
        let scale = (
            UIFont(name: fontName, size: 24)!.capHeight -
                UIFont(name: fontName, size: 12)!.capHeight
            ) / 12.0
        return height / scale
    }
    
}
