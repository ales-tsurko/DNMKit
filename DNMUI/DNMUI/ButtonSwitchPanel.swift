//
//  ButtonSwitchPanel.swift
//  denm_view
//
//  Created by James Bean on 9/25/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMView

public class ButtonSwitchPanel: UIView {
    
    internal let pad: CGFloat = 0
    public var buttonSwitches: [ButtonSwitch] = []
    
    public var left: CGFloat = 0
    public var top: CGFloat = 0
    
    public var target: AnyObject?
    
    // this should be extended in subclass!
    public var title: String = ""
    public var titleLabel: TextLayerConstrainedByHeight?
    
    public var statesByText: [String : Bool] = [:]
    public var rememberedStatesByText: [String : Bool] = [:]
    
    public var buttonSwitchByID: [String : ButtonSwitch] = [:]
    
    public init(left: CGFloat, top: CGFloat, target: AnyObject? = nil, titles: [String] = []) {
        self.left = left
        self.top = top
        self.target = target
        super.init(frame: CGRectMake(left, top, 0, 40 + 10))
        addButtonSwitchesWithTitles(titles)
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func stateHasChangedFromSender(sender: ButtonSwitch) {
        statesByText[sender.id] = sender.isOn
    }
    
    public func addButtonSwitch(buttonSwitch: ButtonSwitch) {
        buttonSwitches.append(buttonSwitch)
        buttonSwitchByID[buttonSwitch.text] = buttonSwitch
    }
    
    public func addButtonSwitchesWithTitles(titles: [String]) {
        for title in titles {
            addButtonSwitchWithTitle(title)
        }
    }
    
    public func insertButtonSwitchWithTitle(title: String, atIndex index: Int) {
        let buttonSwitch = ButtonSwitch(width: 100, height: 25, text: title, id: title)
        insertButtonSwitch(buttonSwitch, atIndex: index)
    }
    
    public func insertButtonSwitch(buttonSwitch: ButtonSwitch, atIndex index: Int) {
        buttonSwitches.insert(buttonSwitch, atIndex: index)
        buttonSwitchByID[buttonSwitch.id] = buttonSwitch
    }
    
    public func addButtonSwitchWithTitle(title: String) {
        let buttonSwitch = ButtonSwitch(width: 100, height: 25, text: title, id: title)
        addButtonSwitch(buttonSwitch)
        //buttonSwitchByID[buttonSwitch.text] = buttonSwitch
    }
    
    public func layout() {
        for (b, buttonSwitch) in buttonSwitches.enumerate() {
            buttonSwitch.layer.position.y = 0.5 * buttonSwitch.frame.height
            if b == 0 {
                buttonSwitch.layer.position.x = 0.5 * buttonSwitch.frame.width
            }
            else {
                let buttonSwitch_left = pad + buttonSwitches[b-1].frame.maxX
                buttonSwitch.layer.position.x = buttonSwitch_left + 0.5 * buttonSwitch.frame.width
            }
            addSubview(buttonSwitch)
        }
    }
    
    public func build() {
        layout()
        setFrame()
        setInitialStatesByTextByID()
    }
    
    
    internal func setInitialStatesByTextByID() {
        for buttonSwitch in buttonSwitches { statesByText[buttonSwitch.id] = buttonSwitch.isOn }
        setRememberedStates()
    }
    
    internal func setRememberedStates() {
        for (id, state) in statesByText { rememberedStatesByText[id] = state }
    }
    
    internal func setFrame() {
        self.frame = CGRectMake(
            left, top, buttonSwitches.last!.frame.maxX, buttonSwitches.first!.frame.height
        )
    }
}
