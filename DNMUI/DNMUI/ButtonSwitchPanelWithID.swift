//
//  ButtonSwitchPanelWithID.swift
//  denm_view
//
//  Created by James Bean on 9/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMView

// DEPRECATE
public class ButtonSwitchPanelWithID: ButtonSwitchPanel {
    
    public var id: String = ""
    public var idLabel: TextLayerConstrainedByHeight?
    
    public init(
        left: CGFloat,
        top: CGFloat,
        id: String,
        target: AnyObject? = nil,
        titles: [String] = []
    )
    {
        self.id = id
        super.init(left: left, top: top, target: target, titles: titles)

    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func stateHasChangedFromSender(sender: ButtonSwitch) {
        statesByText[sender.text] = sender.isOn
    }
    
    public override func addButtonSwitchWithTitle(title: String) {
        let buttonSwitch = ButtonSwitch(text: title, id: id)
        addButtonSwitch(buttonSwitch)
    }
    
    private func addIDLabel() {
        let label_h: CGFloat = 0.25 * frame.height
        idLabel = TextLayerConstrainedByHeight(
            text: id,
            x: pad,
            top: 0.5 * frame.height - 0.5 * label_h,
            height: label_h, alignment: .Left
        )
        layer.addSublayer(idLabel!)
    }
    
    public override func layout() {
        for (b, buttonSwitch) in buttonSwitches.enumerate() {
            buttonSwitch.layer.position.y = pad + 0.5 * buttonSwitch.frame.height
            if b == 0 {
                let buttonSwitch_left = pad + idLabel!.frame.maxX
                buttonSwitch.layer.position.x = buttonSwitch_left + 0.5 * buttonSwitch.frame.width
            }
            else {
                let buttonSwitch_left = pad + buttonSwitches[b-1].frame.maxX
                buttonSwitch.layer.position.x = buttonSwitch_left + 0.5 * buttonSwitch.frame.width
            }
            self.frame = CGRectMake(left, top, buttonSwitches.last!.frame.maxX + pad, 40 + 10)
            addSubview(buttonSwitch)
            
            buttonSwitch.addTarget(self,
                action: "stateHasChangedFromSender:", forControlEvents: .TouchUpInside
            )
        }

    }
    
    public override func build() {
        addIDLabel()
        layout()
        setFrame()
        setInitialStatesByTextByID()
    }
    
    internal override func setRememberedStates() {
        for (text, state) in statesByText {
            if text != self.id { rememberedStatesByText[text] = state }
        }
    }
}