//
//  ComponentSelector.swift
//  denm_view
//
//  Created by James Bean on 10/3/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

// DEPRECATE
/*
public class ComponentSelector: UIView {
    
    
    // need another layer of isolation between text and id of button
    
    var target: AnyObject?
    var componentTypesByID: [String : [String]] = [:]
    var componentTypesShownByID: [String : [String]] = [:]
    var componentTypesHiddenByID: [String : [String]] = [:]
    var buttonSwitchPanelByID: [String : ButtonSwitchPanelWithMasterButtonSwitch] = [:]
    var buttonSwitchPanels: [ButtonSwitchPanelWithMasterButtonSwitch] = []
    
    public init(
        left: CGFloat = 0,
        top: CGFloat = 0,
        componentTypesByID: [String : [String]],
        target: AnyObject? = nil
    )
    {
        self.componentTypesByID = componentTypesByID
        self.target = target
        super.init(frame: CGRectMake(left, top, 0, 0))
        build()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        var buttonSwitchPanel_top: CGFloat = 0
        for (id, componentTypes) in componentTypesByID {
            let componentTypes = componentTypes.filter {$0 != "performer"}
            let buttonSwitchPanel = ButtonSwitchPanelWithMasterButtonSwitch(
                left: 0,
                top: buttonSwitchPanel_top,
                id: id,
                target: self,
                titles: componentTypes
            )
            addSubview(buttonSwitchPanel)
            buttonSwitchPanels.append(buttonSwitchPanel)
            buttonSwitchPanelByID[id] = buttonSwitchPanel
            buttonSwitchPanel_top += buttonSwitchPanel.frame.height
        }
        
        // set initial states
        for (id, componentTypes) in componentTypesByID {
            componentTypesShownByID[id] = componentTypes
        }
        setFrame()
    }
    
    public func stateHasChangedFromSender(sender: ButtonSwitchPanelWithMasterButtonSwitch) {
        
        // HIDDEN NOT NECESSARY: done within System
        
        for (text, isOn) in sender.statesByText {
            // filter out master button
            if text == sender.id {
                if isOn {
                    if var componentTypesShownWithID = componentTypesShownByID["performer"] {
                        if !componentTypesShownWithID.contains("performer") {
                            componentTypesShownWithID.append("performer")
                            componentTypesShownByID[sender.id] = componentTypesShownWithID
                        }
                    }
                    else {
                        componentTypesShownByID[sender.id] = ["performer"]
                    }
                }
                else {
                    if var componentTypesShownWithID = componentTypesShownByID["performer"] {
                        if componentTypesShownWithID.contains("performer") {
                            componentTypesShownWithID.remove("performer")
                            componentTypesShownByID[sender.id] = componentTypesShownWithID
                        }
                    }
                    else {
                        
                    }
                }
            }
            else {
                if isOn {
                    // add if necessary to components SHOWN by ID
                    if var componentTypesShownWithID = componentTypesShownByID[sender.id] {
                        if !componentTypesShownWithID.contains(text) {
                            componentTypesShownWithID.append(text)
                            componentTypesShownByID[sender.id] = componentTypesShownWithID
                        }
                    }
                    else {
                        componentTypesShownByID[sender.id] = [text]
                    }
                    // remove if necssary to components HIDDEN by ID
                    if var componentTypesHiddenWithID = componentTypesHiddenByID[sender.id] {
                        if componentTypesHiddenWithID.contains(text) {
                            componentTypesHiddenWithID.remove(text)
                            componentTypesHiddenByID[sender.id] = componentTypesHiddenWithID
                        }
                    }
                }
                else {
                    // remove if necessary from components SHOWN by ID
                    if var componentTypesShownWithID = componentTypesShownByID[sender.id] {
                        if componentTypesShownWithID.contains(text) {
                            componentTypesShownWithID.remove(text)
                            componentTypesShownByID[sender.id] = componentTypesShownWithID
                        }
                    }
                    // add if necessary to components HIDDEN by ID
                    if var componentTypesHiddenWithID = componentTypesHiddenByID[sender.id] {
                        if !componentTypesHiddenWithID.contains(text) {
                            componentTypesHiddenWithID.append(text)
                            componentTypesHiddenByID[sender.id] = componentTypesHiddenWithID
                        }
                    }
                    else { componentTypesHiddenByID[sender.id] = [text] }
                }
            }
        }
        
        //(target as? SystemView)?.stateHasChangedFromComponentSelector(self)
    }
    
    
    // WHAT IS UP WITH THIS, SHOULD WORK?
    public func layout_flowLeft() {
        
    }
    
    // WHAT IS UP WITH THIS, SHOULD WORK?
    public func layout_flowRight() {
        for panel in buttonSwitchPanels {
            panel.layout_flowRight()
            //panel.layer.position.x = frame.width - 0.5 * panel.frame.width
        }
    }
    
    public func setFrame() {
        var maxY: CGFloat = 0
        var maxX: CGFloat = 0
        for buttonSwitchPanel in buttonSwitchPanels {
            if buttonSwitchPanel.frame.maxX > maxX {
                maxX = buttonSwitchPanel.frame.maxX
            }
            if buttonSwitchPanel.frame.maxY > maxY {
                maxY = buttonSwitchPanel.frame.maxY
            }
        }
        frame = CGRectMake(frame.minX, frame.minY, maxX, maxY)
    }
}
*/