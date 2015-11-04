//
//  SystemView.swift
//  denm_view
//
//  Created by James Bean on 10/2/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMUtility
import DNMModel
import DNMView

public class SystemView: UIView {
    
    public var system: System!
    public var pageView: PageView!
    public var isShowingComponentSelector: Bool = false
    
    public var componentSelector: ButtonSwitchNodeComplex!
    
    // test, change name to ComponentSelector
    //public var buttonSwitchNodeComplex: ButtonSwitchNodeComplex!
    
    public var selectionRectangle: SelectionRectangle?
    public var durationSelected_start: Duration?
    public var durationSelected_stop: Duration?
    
    public var graphEventsSelected: [GraphEvent] = []
    
    // temporary
    public var stemsSelected: [Stem] = []
    
    // takes in frame from global context
    public init(system: System, pageView: PageView) {
        self.system = system
        self.pageView = pageView
        super.init(frame: system.frame) // sketch?

        manageGestureRecognizers()
        createComponentSelector()
    }
    
    private func manageGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapSystem")
        addGestureRecognizer(tapRecognizer)
    }
    
    private func createComponentSelector() {
        func addLeaderButtonSwitchNodesForPerformers() {
            for (id, componentTypes) in system.componentTypesByID {
                for componentType in componentTypes {
                    let buttonText: String = componentType == "performer" ? id : componentType
                    let buttonID: String = componentType == "performer" ? componentType : id
                    let isLeader: Bool = componentType == "performer" ? true : false
                    componentSelector.addButtonSwitchToGroupID(id,
                        withText: buttonText, andID: buttonID, isLeader: isLeader
                    )
                }
            }
        }
        
        func setDefaultValuesIfOmniView() {
            if let viewerID = system.viewerID where viewerID == "omni" {
                for (_, group) in componentSelector.buttonSwitchNodeGroupByID {
                    for node in group.buttonSwitchNodes { node.switchOn() }
                }
                componentSelector.updateStateByID()
            }
        }
        
        componentSelector = ButtonSwitchNodeComplex(x: 0, y: 0, primaryGroupID: system.viewerID)
        componentSelector.systemView = self
        addLeaderButtonSwitchNodesForPerformers()
        componentSelector.layoutButtonSwitchNodes()
        setDefaultValuesIfOmniView()
        system.componentTypesShownByID = componentSelector.componentTypesShownByID
        system.arrangeNodesWithComponentTypesPresent()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    public func stateHasChangedFromButtonSwitchNodeComplex(complex: ButtonSwitchNodeComplex) {
        system.componentTypesShownByID = complex.componentTypesShownByID
        system.arrangeNodesWithComponentTypesPresent()
        pageView.systemsNeedReflowing()
        print("system.stateHasChangedFromButtonSwitchNodeComplex: newHeight: \(system.frame.height)")
        

        // do this within systemsNeedReflowing... up there
        // encapsulate: call from within pageView: pageView.setFramesOfAllSystemViews()
        for systemView in pageView.systemViews {
            systemView.setFrame()
        }
    }
    
    public func setFrame() {
        
        // HACK
        frame = system.frame
        if isShowingComponentSelector {
            if componentSelector.frame.maxX > frame.maxX {
                frame = CGRectMake(
                    frame.minX,
                    frame.minY,
                    componentSelector.frame.maxX,
                    frame.height
                )
            }
            if componentSelector.frame.maxY > frame.maxY {
                frame = CGRectMake(
                    componentSelector.frame.minX,
                    frame.minY,
                    frame.maxX,
                    frame.height
                )
            }
        }

        if isShowingComponentSelector {
            componentSelector.layer.position.x = 0.5 * componentSelector.frame.width
        }
    }

    
    public func switchComponentSelector() {
        isShowingComponentSelector ? hideComponentSelector() : showComponentSelector()
    }
    
    public func showComponentSelector() {
        addSubview(componentSelector)
        isShowingComponentSelector = true
        setFrame()
    }
    
    public func hideComponentSelector() {
        componentSelector.removeFromSuperview()
        isShowingComponentSelector = false
        setFrame()
    }
    
    public func didTapSystem() {
        switchComponentSelector()
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            
            // text
            for stem in system.stems { stem.deHighlight() }
            
            // create componentsShownForDurationSpan
            if stemsSelected.count > 0 { showComponentSelector() }
            
            for stem in stemsSelected {
                if let bgEvent = stem.bgEvent {
                    if let beamGroup = bgEvent.beamGroup {
                        if let beamsLayerGroup = beamGroup.beamsLayerGroup {
                            beamsLayerGroup.hidden = true
                        }
                    }
                }
            }
            selectionRectangle?.removeFromSuperlayer()
            selectionRectangle = nil
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            if let selectionRectangle = selectionRectangle {
                
                // get correct coordinates from selectRect
                selectionRectangle.scaleToPoint(point: point)
                let selRectFrame = system.eventsNode.convertRect(selectionRectangle.frame, fromLayer: system)


                // create durationSpan
                durationSelected_stop = system.getDurationAtX(point.x)
                let durationSpan = DurationSpan(
                    duration: durationSelected_start!,
                    andAnotherDuration: durationSelected_stop!
                )
                
                // get which pIDs are currently selected
                var pIDsSelected: [String] = []
                for performer in system.performers {
                    if performer.frame.intersects(selRectFrame) {
                        pIDsSelected.append(performer.id)
                    }
                }
                
                
                // find out which stems to highlight
                var stemsHighlighted: [Stem] = []
                for bgStratum in system.bgStrata {
                    for bgEvent in bgStratum.bgEvents {
                        if bgEvent.durationNode.offsetDuration.isInDurationSpan(durationSpan) {
                            for pID in pIDsSelected {
                                if bgEvent.durationNode.iIDsByPID[pID] != nil {
                                    if let stem = bgEvent.stem {
                                        stemsHighlighted.append(stem)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // temp
                stemsSelected = stemsHighlighted
                
                // highlight stems
                for stem in stemsHighlighted { stem.highlight() }
                
                // de highlight stems
                for stem in system.stems {
                    if stem.isHighlighted && !stemsHighlighted.containsObject(stem) {
                        stem.deHighlight()
                    }
                }
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            let convertedPoint = layer.convertPoint(point, fromLayer: system)
            let touchedObj = system.hitTest(convertedPoint)
            selectionRectangle = SelectionRectangle(initialPoint: point)
            durationSelected_start = system.getDurationAtX(point.x)
            layer.addSublayer(selectionRectangle!)
        }
        super.touchesBegan(touches, withEvent: event)
    }
}
