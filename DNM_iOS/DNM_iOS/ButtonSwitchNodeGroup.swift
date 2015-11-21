//
//  ButtonSwitchNodeGroup.swift
//  ComponentSelectorTest
//
//  Created by James Bean on 10/8/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class ButtonSwitchNodeGroup {
    
    public var id: String = ""
    public var buttonSwitchNodes: [ButtonSwitchNode] = []
    public var buttonSwitchNodeByID: [String : ButtonSwitchNode] = [:]
    public var leaderButtonSwitchNode: ButtonSwitchNodeLeader?
    public var stateByID: [String : ButtonSwitchNodeState] = [:]
    
    public var line = CAShapeLayer() // refine
    
    // view
    public var colorHue: CGFloat = 214 {
        didSet {
            for buttonSwitchNode in buttonSwitchNodes { buttonSwitchNode.colorHue = colorHue }
        }
    }
    
    public init(id: String) {
        self.id = id
    }
    
    public func updateStateByID() {
        for buttonSwitchNode in buttonSwitchNodes {
            if buttonSwitchNode.text == id {
                stateByID["performer"] = buttonSwitchNode.switch_state
            }
            else {
                stateByID[buttonSwitchNode.text] = buttonSwitchNode.switch_state
            }
        }
    }
    
    public func addButtonSwitchNode(buttonSwitchNode: ButtonSwitchNode) {
        if let leader = buttonSwitchNode as? ButtonSwitchNodeLeader {
            buttonSwitchNodes.insert(buttonSwitchNode, atIndex: 0)
            leaderButtonSwitchNode = leader
        }
        else { buttonSwitchNodes.append(buttonSwitchNode) }
        buttonSwitchNodeByID[buttonSwitchNode.id] = buttonSwitchNode
    }
    
    public func buttonSwitchNodeWithID(id: String, andText text: String, isLeader: Bool = false) {
        
        // TODO: non-hack width
        
        let buttonSwitchNode: ButtonSwitchNode
        switch isLeader {
        case true:
            buttonSwitchNode = ButtonSwitchNodeLeader(width: 50, text: text, id: id)
        case false:
            buttonSwitchNode = ButtonSwitchNode(width: 50, text: text, id: id)
        }
        addButtonSwitchNode(buttonSwitchNode)
    }
    
    public func stateHasChangedFromLeaderButtonSwitchNode(
        leaderButtonSwitchNode: ButtonSwitchNodeLeader
    )
    {
        // something
    }
    
    public func stateHasChangedFromFollowerButtonSwitchNode(
        followerButtonSwitchNode: ButtonSwitchNode
    )
    {
        // something
    }
}
