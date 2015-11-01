//
//  ButtonSwitch.swift
//  ComponentSelectorTest
//
//  Created by James Bean on 10/7/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMView

public class ButtonSwitchNode: UIButton {
    
    public var id: String = ""
    public var text: String = ""
    
    public var switch_state: ButtonSwitchNodeState = ButtonSwitchNodeState.Off

    public var colorForState: [ButtonSwitchNodeState : UIColor] = [:]
    
    public var x: CGFloat = 0
    public var y: CGFloat = 0
    public var width: CGFloat = 0
    
    public var colorHue: CGFloat = 214 { didSet { setDefaultColorForState() } }
    
    public init(
        x: CGFloat = 0,
        y: CGFloat = 0,
        width: CGFloat = 0,
        switch_state: ButtonSwitchNodeState = .Off,
        text: String = "",
        id: String = ""
    )
    {
        super.init(frame: CGRectMake(x - 0.5 * width, y - 0.5 * width, width, width))
        self.x = x
        self.y = y
        self.width = width
        self.switch_state = switch_state
        self.text = text
        self.id = id
        setVisualAttributes()
        switchOff()
        setTitle(text, forState: UIControlState.Normal)

    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func switchState() {
        switch switch_state {
        case .On: switchOff()
        case .Off, .Muted: switchOn()
        }
    }
    
    public func switchOn() {
        switch_state = .On
        layer.backgroundColor = colorForState[.On]?.CGColor
        layer.borderWidth = 0
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    public func switchOff() {
        switch_state = .Off
        layer.backgroundColor = DNMColorManager.backgroundColor.CGColor
        layer.borderColor = colorForState[.Off]?.CGColor
        layer.borderWidth = 1
        setTitleColor(colorForState[.Off], forState: .Normal)
    }
    
    public func switchMuted() {
        switch_state = .Muted
        layer.backgroundColor = colorForState[.Muted]?.CGColor
        layer.borderWidth = 0
        setTitleColor(UIColor.grayscaleColorWithDepthOfField(DepthOfField.MiddleBackground, inColorMode: DNMColorManager.colorMode), forState: .Normal)
    }
    
    public func setColor(color: UIColor, forState state: ButtonSwitchNodeState) {
        colorForState[state] = color
    }
    
    public func setVisualAttributes() {
        layer.cornerRadius = width / 2
        layer.backgroundColor = UIColor.grayColor().CGColor
        layer.borderWidth = 1
        setDefaultColorForState()
    }
    
    internal func setDefaultColorForState() {
        colorForState = [
            ButtonSwitchNodeState.On : UIColor.colorWithHue(colorHue,
                andDepthOfField: .Middleground, inColorMode: DNMColorManager.colorMode
            ),
            
            ButtonSwitchNodeState.Off : UIColor.colorWithHue(colorHue,
                andDepthOfField: .Middleground, inColorMode: DNMColorManager.colorMode
            ),
            
            ButtonSwitchNodeState.Muted : UIColor.colorWithHue(colorHue,
                andDepthOfField: .Background, inColorMode: DNMColorManager.colorMode
            )
        ]
    }
}
