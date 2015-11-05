//
//  ButtonSwitchPanelWithMasterButtonSwitch.swift
//  denm_view
//
//  Created by James Bean on 9/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

// DEPRECATE
/*
public class ButtonSwitchPanelWithMasterButtonSwitch: ButtonSwitchPanelWithID {
    
    public var masterButtonSwitch: ButtonSwitchMaster!
    
    public override init(
        left: CGFloat,
        top: CGFloat,
        id: String,
        target: AnyObject? = nil,
        titles: [String] = []
    )
    {
        super.init(left: left, top: top, id: id, target: target, titles: titles)
        build()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func build() {
        addMasterButtonSwitchWithID()
        commitButtonSwitches()
        addTargetsToButtonSwitches()
        layout()
        setFrame()
        setInitialStatesByTextByID()
    }
    
    public func commitButtonSwitches() {
        for buttonSwitch in buttonSwitches { addSubview(buttonSwitch) }
    }
    
    public func addTargetsToButtonSwitches() {
        for buttonSwitch in buttonSwitches {
            buttonSwitch.addTarget(self,
                action: "stateHasChangedFromSender:", forControlEvents: .TouchUpInside
            )
        }
    }
    
    public override func addButtonSwitchWithTitle(title: String) {
        let buttonSwitch = ButtonSwitch(width: 110, height: 33, text: title, id: title) // id superfluous
        buttonSwitchByID[buttonSwitch.text] = buttonSwitch
        addButtonSwitch(buttonSwitch)
    }
    
    private func addMasterButtonSwitchWithID() {
        masterButtonSwitch = ButtonSwitchMaster(width: 80, height: 33, text: id, id: "performer") // HACK
        masterButtonSwitch.addTarget(self,
            action: "stateChangedFromMasterButton:", forControlEvents: UIControlEvents.TouchUpInside
        )
        insertButtonSwitch(masterButtonSwitch, atIndex: 0)
    }
    
    public func stateChangedFromMasterButton(masterButton: ButtonSwitch) {
        
        print("state has changed from masterButton: text: \(masterButton.text); id: \(masterButton.id); masterButton.isOn: \(masterButton.isOn)")
        
        if masterButton.isOn {
            for (id, buttonSwitch) in buttonSwitchByID {
                if let rememberedState = rememberedStatesByText[buttonSwitch.text] {
                    if rememberedState {
                        buttonSwitch.switchOn()
                        statesByText[buttonSwitch.id] = true
                    }
                    else {
                        buttonSwitch.switchOff()
                        statesByText[buttonSwitch.id] = false
                    }
                }
            }
        }
        else {
            setRememberedStates()
            for buttonSwitch in buttonSwitches {
                buttonSwitch.switchOff()
                statesByText[buttonSwitch.id] = false
            } // "mute"
        }
        //statesByText["performer"] = masterButton.isOn // HACK
        
        
        print("statesByText: id \(id): \(statesByText)")
    }
    
    public override func stateHasChangedFromSender(sender: ButtonSwitch) {
        
        print("state has changed from normal button: text: \(sender.text); id: \(sender.id); isOn: \(sender.isOn)")
        
        statesByText[sender.id] = sender.isOn

        print("statesByText: id: \(id): \(statesByText)")
        
        // set value with state by text
        // -- shown, hidden
        
        if let superview = superview {
            if let componentSelector = superview as? ComponentSelector {
                componentSelector.stateHasChangedFromSender(self)
            }
        }
    }
    
    public func muteAllSwitches() {
        // call this once "muting" exists
    }
    
    public override func layout() {
        for (b, buttonSwitch) in buttonSwitches.enumerate() {
            buttonSwitch.layer.position.y = pad + 0.5 * buttonSwitch.frame.height
            if b == 0 {
                buttonSwitch.layer.position.x = pad + 0.5 * buttonSwitch.frame.width
            }
            else {
                let buttonSwitch_left = pad + buttonSwitches[b-1].frame.maxX
                buttonSwitch.layer.position.x = buttonSwitch_left + 0.5 * buttonSwitch.frame.width
            }
        }
    }
    
    public func layout_flowLeft() {
        for (b, buttonSwitch) in buttonSwitches.enumerate() {
            buttonSwitch.layer.position.y = pad + 0.5 * buttonSwitch.frame.height
            if b == 0 {
                buttonSwitch.layer.position.x = pad + 0.5 * buttonSwitch.frame.width
            }
            else {
                let buttonSwitch_left = pad + buttonSwitches[b-1].frame.maxX
                buttonSwitch.layer.position.x = buttonSwitch_left + 0.5 * buttonSwitch.frame.width
            }
        }
    }
    
    public func layout_flowRight() {
        
        for (b, buttonSwitch) in buttonSwitches.reverse().enumerate() {
            buttonSwitch.layer.position.y = pad + 0.5 * buttonSwitch.frame.height
            if b == 0 {
                buttonSwitch.layer.position.x = pad + 0.5 * buttonSwitch.frame.width
            }
            else {
                let buttonSwitch_left = pad + buttonSwitches[b-1].frame.maxX
                buttonSwitch.layer.position.x = buttonSwitch_left + 0.5 * buttonSwitch.frame.width
            }
        }
    }
    
    /*
    public override func build() {
        addMasterButtonSwitchWithID()
        layout()
        setFrame()
        setInitialStatesByTextByID()
    }
    */
}
*/