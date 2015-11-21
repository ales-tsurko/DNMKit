//
//  RadioGroupPanelVertical.swift
//  denm_view
//
//  Created by James Bean on 10/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class RadioGroupPanelVertical: RadioGroupPanel {
    
    public init(
        left: CGFloat = 0,
        top: CGFloat = 0,
        width: CGFloat = 40,
        target: AnyObject? = nil,
        titles: [String] = []
    )
    {
        super.init(frame: CGRectMake(left, top, 40 + 10, 0)) // height to be set later
        self.target = target
        addButtonSwitchesWithTitles(titles)

        for buttonSwitch in buttonSwitches { buttonSwitch.switchOff() }
           
        for buttonSwitch in buttonSwitches {
            buttonSwitch.addTarget(self,
                action: "stateHasChangedFromSender:", forControlEvents: UIControlEvents.TouchUpInside
            )
        }
        
        //layer.borderWidth = 1
        //layer.borderColor = UIColor.lightGrayColor().CGColor
    }

    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func layout() {
        for (b, buttonSwitch) in buttonSwitches.enumerate() {
            buttonSwitch.layer.position.x = 0.5 * buttonSwitch.frame.width
            if b == 0 {
                buttonSwitch.layer.position.y = 0.5 * buttonSwitch.layer.frame.height
            }
            else {
                let buttonSwitch_y = buttonSwitches[b-1].frame.maxY
                buttonSwitch.layer.position.y = buttonSwitch_y + 0.5 * buttonSwitch.frame.height
            }
            addSubview(buttonSwitch)
        }
    }
    
    internal override func setFrame() {
        frame = CGRect(
            x: left,
            y: top,
            width: buttonSwitches.first!.frame.width,
            height: buttonSwitches.last!.frame.maxY + pad
        )

        /*
        self.frame = CGRectMake(left, top, buttonSwitches.first!.frame.width, buttonSwitches.last!.frame.maxY + pad)
        */
    }
}
