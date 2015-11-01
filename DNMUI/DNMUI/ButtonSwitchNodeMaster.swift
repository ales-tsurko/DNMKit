//
//  ButtonSwitchNodeMaster.swift
//  ComponentSelectorTest
//
//  Created by James Bean on 10/7/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMView

public class ButtonSwitchNodeLeader: ButtonSwitchNode {
    
    public override init(
        x: CGFloat = 0,
        y: CGFloat = 0,
        width: CGFloat = 0,
        switch_state: ButtonSwitchNodeState = .Off,
        text: String = "",
        id: String = ""
    )
    {
        super.init(x: x, y: y, width: width, switch_state: switch_state, text: text, id: id)
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func switchOn() {
        switch_state = .On
        layer.backgroundColor = colorForState[.On]?.CGColor
        layer.borderWidth = 0
        setTitleColor(DNMColorManager.backgroundColor, forState: .Normal)
    }
    
    public override func switchOff() {
        switch_state = .Off
        layer.backgroundColor = DNMColorManager.backgroundColor.CGColor
        layer.borderColor = colorForState[.Off]?.CGColor
        layer.borderWidth = 1
        setTitleColor(colorForState[.Off], forState: .Normal)
    }
    
    public override func setVisualAttributes() {
        super.setVisualAttributes()
        layer.opacity = 1
        setDefaultColorForState()
    }
    
    internal override func setDefaultColorForState() {
        colorForState = [
            ButtonSwitchNodeState.On : UIColor.colorWithHue(colorHue,
                andDepthOfField: .MostForeground, inColorMode: DNMColorManager.colorMode
            ),
            
            ButtonSwitchNodeState.Off : UIColor.colorWithHue(colorHue,
                andDepthOfField: .MostForeground, inColorMode: DNMColorManager.colorMode
            ),
            
            ButtonSwitchNodeState.Muted : UIColor.colorWithHue(colorHue,
                andDepthOfField: .Middleground, inColorMode: DNMColorManager.colorMode
            )
        ]
    }
}
