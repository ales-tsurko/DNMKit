//
//  RadioGroupPanel.swift
//  denm_view
//
//  Created by James Bean on 10/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class RadioGroupPanel: ButtonSwitchPanel {
    
    public var currentButtonSelectedID: String = ""
    
    public init(
        left: CGFloat = 0,
        top: CGFloat = 0,
        height: CGFloat = 25,
        target: AnyObject? = nil,
        titles: [String] = []
    )
    {
        super.init(frame: CGRectMake(left, top, 0, height))
        self.target = target
        addButtonSwitchesWithTitles(titles)
        currentButtonSelectedID = buttonSwitches.first!.text
        buttonSwitches.first!.switchOn()

        // encapsulate
        for (id, buttonSwitch) in buttonSwitchByID {
            if id != currentButtonSelectedID { buttonSwitch.switchOff() }
        }
        
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
    
    
    // this is inexcusable, but working...?
    public override func stateHasChangedFromSender(sender: ButtonSwitch) {
        
        for (id, buttonSwitch) in buttonSwitchByID {
            if id != sender.text { buttonSwitch.switchOff() }
            else {
                buttonSwitch.switchOn()
                currentButtonSelectedID = sender.text
            }
            statesByText[sender.text] = sender.isOn
        }
    
        if let environment = target as? Environment {
            environment.goToViewWithID(currentButtonSelectedID)
        }
    }
}
