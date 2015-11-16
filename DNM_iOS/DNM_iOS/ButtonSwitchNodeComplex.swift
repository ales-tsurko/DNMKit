//
//  ButtonSwitchNodeComplex.swift
//  ComponentSelectorTest
//
//  Created by James Bean on 10/7/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// TODO: add ButtonSwitchNodes directly to this view as subview, though organized by ID
//
public class ButtonSwitchNodeComplex: UIView {
    
    public var x: CGFloat = 0
    public var y: CGFloat = 0
    
    public var primaryGroupID: String?
    
    public var buttonSwitchNodes: [ButtonSwitchNode] = []

    // perhaps these are deprecatable
    //public var buttonSwitchNodesByID: [String : [ButtonSwitchNode]] = [:]
    public var buttonSwitchNodeGroupByID: [String : ButtonSwitchNodeGroup] = [:]
    
    // hmmm, eh
    public var stateByIDByGroupID: [String : [String : ButtonSwitchNodeState]] = [:]
    
    private let buttonSwitchNode_width: CGFloat = 75
    
    // test
    public var systemView: SystemView?
    public var componentTypesShownByID: [String : [String]] {
        get {
            var componentTypesShownByID: [String: [String]] = [:]
            for (groupID, stateByID) in stateByIDByGroupID {
                for (id, state) in stateByID {
                    switch state {
                    case .On:
                        if componentTypesShownByID[groupID] == nil {
                            componentTypesShownByID[groupID] = []
                        }
                        componentTypesShownByID[groupID]!.append(id)
                    default: break
                    }
                }
            }
            return componentTypesShownByID
        }
    }
    
    public init(x: CGFloat, y: CGFloat, primaryGroupID: String? = nil) {
        self.x = x
        self.y = y
        self.primaryGroupID = primaryGroupID
        
        super.init(frame: CGRectZero)
        
        /*
        // add middle circle
        let middleButtonSwitchNode_width: CGFloat = 50
        let middleButtonSwitchNode = ButtonSwitchNode(
            x: 0.5 * middleButtonSwitchNode_width,
            y: 0.5 * middleButtonSwitchNode_width,
            width: middleButtonSwitchNode_width,
            switch_state: .On ,
            text: "",
            id: "main"
        )
        middleButtonSwitchNode.switchOn()
        middleButtonSwitchNode.layer.opacity = 0.25
        //addSubview(middleButtonSwitchNode)
        layer.borderColor = UIColor.purpleColor().CGColor
        layer.borderWidth = 1
        */
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    
    public func addButtonSwitchToGroupID(groupID: String,
        withText text: String, andID buttonSwitchNodeID: String, isLeader: Bool = false
    )
    {
        let buttonSwitchNode: ButtonSwitchNode
        switch isLeader {
        case true:
            buttonSwitchNode = ButtonSwitchNodeLeader(
                width: buttonSwitchNode_width,
                text: text,
                id: buttonSwitchNodeID
            )
            buttonSwitchNode.addTarget(self,
                action: "stateHasChangedFromLeaderButtonSwitchNode:",
                forControlEvents: UIControlEvents.TouchUpInside
            )
        case false:
            buttonSwitchNode = ButtonSwitchNode(
                width: buttonSwitchNode_width,
                text: text,
                id: buttonSwitchNodeID
            )
            buttonSwitchNode.addTarget(self,
                action: "stateHasChangedFromFollowerButtonSwitchNode:",
                forControlEvents: UIControlEvents.TouchUpInside
            )
        }
        addButtonSwitchNode(buttonSwitchNode, withGroupID: groupID)
    }

    public func addButtonSwitchNode(buttonSwitchNode: ButtonSwitchNode, withGroupID id: String) {
        ensureButtonSwitchNodeGroupWithID(id)
        buttonSwitchNodeGroupByID[id]!.addButtonSwitchNode(buttonSwitchNode)
        addSubview(buttonSwitchNode)
    }
    
    private func setColorHueForButtonSwitchNodeGroup(group: ButtonSwitchNodeGroup) {
        if let primaryGroupID = primaryGroupID where primaryGroupID == group.id {
            group.colorHue = 0
        }
        else { group.colorHue = 214 }
    }
    
    private func ensureButtonSwitchNodeGroupWithID(id: String) {
        if buttonSwitchNodeGroupByID[id] == nil {
            let group = ButtonSwitchNodeGroup(id: id)
            setColorHueForButtonSwitchNodeGroup(group)
            buttonSwitchNodeGroupByID[id] = group
        }
    }
    
    public func getButtonSwitchNodeGroupContainingButtonSwitchNode(
        buttonSwitchNode: ButtonSwitchNode
    ) -> ButtonSwitchNodeGroup?
    {
        for (id, buttonSwitchNodeGroup) in buttonSwitchNodeGroupByID {
            if buttonSwitchNodeGroup.buttonSwitchNodes.containsObject(buttonSwitchNode) {
                return buttonSwitchNodeGroup
            }
        }
        return nil
    }
    
    public func stateHasChangedFromFollowerButtonSwitchNode(follower: ButtonSwitchNode) {
        if let group = getButtonSwitchNodeGroupContainingButtonSwitchNode(follower) {
            if let leader = group.leaderButtonSwitchNode {
                switch (leader.switch_state, follower.switch_state) {
                case (.Off, .On): follower.switchOff() // shouldn't happen
                case (.Off, .Off): follower.switchMuted()
                case (.Off, .Muted): follower.switchOff()
                case (.On, .On): follower.switchOff()
                case (.On, .Off): follower.switchOn()
                case (.On, .Muted): follower.switchOn()
                default: break
                }
            }
            else { follower.switchState() }
        }
        else { follower.switchState() }
        updateStateByID()
        systemView?.stateHasChangedFromButtonSwitchNodeComplex(self)
    }
    
    public func stateHasChangedFromLeaderButtonSwitchNode(leader: ButtonSwitchNodeLeader) {
        leader.switchState()
        if let group = getButtonSwitchNodeGroupContainingButtonSwitchNode(leader) {
            for buttonSwitchNode in group.buttonSwitchNodes where buttonSwitchNode != leader {
                switch (leader.switch_state, buttonSwitchNode.switch_state) {
                case (.Off, .On): buttonSwitchNode.switchMuted()
                case (.On, .Muted): buttonSwitchNode.switchOn()
                default: break
                }
            }
        }
        updateStateByID()
        systemView?.stateHasChangedFromButtonSwitchNodeComplex(self)
    }
    
    public func updateStateByID() {
        for (id, group) in buttonSwitchNodeGroupByID {
            group.updateStateByID()
            stateByIDByGroupID[id] = group.stateByID
        }
    }
    
    public func addButtonSwitchNodeGroupWithID(groupID: String,
        buttonSwitchNodeValueSets: [(String, String, Bool)]
    )
    {
        ensureButtonSwitchNodeGroupWithID(groupID)
        for buttonSwitchNodeValueSet in buttonSwitchNodeValueSets {
            let (text, id, isLeader) = buttonSwitchNodeValueSet
            addButtonSwitchToGroupID(groupID, withText: text, andID: id, isLeader: isLeader)
        }

    }
    
    public func layoutButtonSwitchNodes() {
        
        // make an alternate ButtonSwitchLayout()
        // performLayout()?
        
        var left: CGFloat = 0
        for (id, group) in buttonSwitchNodeGroupByID {
            var top: CGFloat = 0
            for node in group.buttonSwitchNodes {
                node.layer.position.x = left + 0.5 * node.frame.width
                node.layer.position.y = top + 0.5 * node.frame.height
                top += node.frame.width
            }
            left += 100
        }
        /*
        print("complex: amount groups: \(buttonSwitchNodeGroupByID.count)")
        
        // get initial angle
        let angle_initial: Float = (Float(buttonSwitchNodeGroupByID.count) * 30) / 2
        
        var angle: Float = angle_initial
        for (id, buttonSwitchNodeGroup) in buttonSwitchNodeGroupByID {
            let distance_initial = 2.25 * buttonSwitchNode_width
            var delta_y_initial = sin(CGFloat(DEGREES_TO_RADIANS(angle))) * distance_initial
            var delta_x_initial = sqrt(pow(distance_initial, 2) - pow(delta_y_initial, 2))
            delta_x_initial *= -1
            
            if angle > 90 { delta_x_initial *= -1 }
            let distance_betweenEach = 1.25 * buttonSwitchNode_width
            var delta_y_betweenEach = sin(CGFloat(DEGREES_TO_RADIANS(angle))) * distance_betweenEach
            var delta_x_betweenEach = sqrt(pow(distance_betweenEach, 2) - pow(delta_y_betweenEach, 2))
            delta_x_betweenEach *= -1
            //if angle > 90 { delta_x_betweenEach *= -1 }
            var delta_y: CGFloat = delta_y_initial
            var delta_x: CGFloat = delta_x_initial
            for buttonSwitchNode in buttonSwitchNodeGroup.buttonSwitchNodes {
                let length = 1.25 * buttonSwitchNode_width
                buttonSwitchNode.layer.position.x = delta_x
                buttonSwitchNode.layer.position.y = delta_y
                delta_x += delta_x_betweenEach
                delta_y += delta_y_betweenEach
            }
            angle -= 30
        }
        */
        setFrame()
        setDefaultStatesForAllGroups()
    }
    
    private func setDefaultStatesForAllGroups() {
        for (id, group) in buttonSwitchNodeGroupByID {
            if let primaryGroupID = primaryGroupID where primaryGroupID == id {
                for node in group.buttonSwitchNodes { node.switchOn() }
            }
            else {
                for node in group.buttonSwitchNodes { node.switchMuted() }
                if let leader = group.leaderButtonSwitchNode { leader.switchOff() }
            }
        }
        updateStateByID()
    }
    
    public func setFrame() {
        var minX: CGFloat?
        var maxX: CGFloat?
        var minY: CGFloat?
        var maxY: CGFloat?

        if buttonSwitchNodeGroupByID.count > 0 {
            for (id, group) in buttonSwitchNodeGroupByID {
                for buttonSwitchNode in group.buttonSwitchNodes {
                    if minX == nil { minX = buttonSwitchNode.frame.minX }
                    if maxX == nil { maxX = buttonSwitchNode.frame.maxX }
                    if minY == nil { minY = buttonSwitchNode.frame.minY }
                    if maxY == nil { maxY = buttonSwitchNode.frame.maxY }
                    if buttonSwitchNode.frame.minX < minX { minX = buttonSwitchNode.frame.minX }
                    if buttonSwitchNode.frame.maxX > maxX { maxX = buttonSwitchNode.frame.maxX }
                    if buttonSwitchNode.frame.minY < minY { minY = buttonSwitchNode.frame.minY }
                    if buttonSwitchNode.frame.maxY > maxY { maxY = buttonSwitchNode.frame.maxY }
                }
            }
            
            let width = maxX! - minX!
            let height = maxY! - minY!
            
            frame = CGRectMake(0, 0, width, height)
            
            for (id, group) in buttonSwitchNodeGroupByID {
                for buttonSwitchNode in group.buttonSwitchNodes {
                    buttonSwitchNode.layer.position.y += (height - maxY!)
                    buttonSwitchNode.layer.position.x += (width - maxX!)
                }
                
                if let primaryGroupID = primaryGroupID where primaryGroupID == id {
                    group.colorHue = 0
                }
                
                if group.buttonSwitchNodes.count > 1 {
                    let line = CAShapeLayer()
                    let line_path = UIBezierPath()
                    line_path.moveToPoint(group.buttonSwitchNodes.first!.layer.position)
                    line_path.addLineToPoint(group.buttonSwitchNodes.last!.layer.position)
                    line.path = line_path.CGPath
                    
                    if let primaryGroupID = primaryGroupID where primaryGroupID == id {
                        line.strokeColor = UIColor.colorWithHue(0,
                            andDepthOfField: .Foreground, inColorMode: DNMColorManager.colorMode
                        ).CGColor
                        line.lineWidth = 4
                    }
                    else {
                        line.strokeColor = UIColor.colorWithHue(214,
                            andDepthOfField: .Background, inColorMode: DNMColorManager.colorMode
                        ).CGColor
                        line.lineWidth = 2
                    }
                    layer.insertSublayer(line, atIndex: 0)
                }
            }
        }
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            let touchedView = hitTest(point, withEvent: nil)
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            let touchedView = hitTest(point, withEvent: nil)
        }
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        // something
    }
}