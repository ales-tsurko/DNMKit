//
//  BGContainer.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

public class BGContainer: ViewNode {
    
    // model
    public var durationNode: DurationNode?
    
    // organization
    public var beamGroup: BeamGroup?
    public var bgContainer: BGContainer?
    
    // components
    public var bgContainers: [BGContainer] = []
    public var bgEvents: [BGEvent] = []
    public var beamJunctions: [BeamJunction] = [] // just referenced by BGEvent.beamJunction
    public var augmentationDots: [AugmentationDot] = []
    public var beamsLayer = BeamsLayer()
    public var tupletBracket: TupletBracket?
    
    // THIS WILL BE REFACTORED OUT!
    //public var mgNode: MGNode?
    
    public var tbLigatures: [TBLigature] = []
    
    // attributes
    
    public var width: CGFloat = 0
    public var beatWidth: CGFloat = 0 // proxy
    public var depth: Int { get { return durationNode!.depth } }
    
    public var g: CGFloat = 0
    public var scale: CGFloat = 1
    
    public var isMetrical: Bool = true
    public var isNumerical: Bool = true
    
    //public var includesTupletBracket: Bool = true
    //public var includesMGLayer: Bool = true
    
    public var stemDirection: StemDirection = .Down
    
    public init(
        durationNode: DurationNode,
        left: CGFloat,
        top: CGFloat,
        g: CGFloat,
        scale: CGFloat,
        beatWidth: CGFloat,
        stemDirection: StemDirection,
        isMetrical: Bool = true,
        isNumerical: Bool = true
    )
    {
        self.durationNode = durationNode
        self.g = g
        self.scale = scale
        self.beatWidth = beatWidth
        //self.width = graphicalWidth(duration: durationNode.duration, beatWidth: beatWidth)
        //self.width = durationNode.duration.getGraphicalWidth(beatWidth: beatWidth)
        self.width = durationNode.width(beatWidth: beatWidth)
        self.stemDirection = stemDirection
        self.isMetrical = isMetrical
        self.isNumerical = isNumerical
        super.init()
        self.left = left
        self.top = top
        self.setsWidthWithContents = false
        self.setsHeightWithContents = true
        self.layoutAccumulation_vertical = stemDirection == .Down ? .Top : .Bottom
        
        createTupletBracket() // if necessary
        createBeamsLayer()
        
        
        // THIS SHALL BE REFACTORED OUT
        /*
        let maNode = MetricalAnalyzer(refNode: durationNode).makeMANode()
        mgNode = MGNodeMake(maNode: maNode, g: g, beatWidth: beatWidth)
        
        // pass g and scale, as well
        mgNode!.build()
        addNode(mgNode!)
        */


        layout()
        
        if tupletBracket == nil { return }
        if durationNode.children.first != nil && durationNode.children.first!.isContainer {
            return
        }

        //if durationNode.heightOfTree < 2 { return }
        //if durationNode.heightOfTree > 2 && (durationNode.depth >= durationNode.heightOfTree - 2) { return }
        
        
        if stemDirection == .Down {
            let tbl = TBLigature.ligatureWithType(.Begin,
                x: 0,
                beamEndY: beamsLayer.frame.minY,
                bracketEndY: tupletBracket!.position.y,
                g: g
            )!
            addSublayer(tbl)
            tbLigatures.append(tbl)
        }
        else {
            let tbl = TBLigature.ligatureWithType(.Begin,
                x: 0,
                beamEndY: beamsLayer.frame.maxY,
                bracketEndY: tupletBracket!.position.y,
                g: g
            )!
            addSublayer(tbl)
            tbLigatures.append(tbl)
        }
    }
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addBGContainer(bgContainer: BGContainer) {
        bgContainers.append(bgContainer)
        addSublayer(bgContainer)
        bgContainer.bgContainer = self
        bgContainer.beamGroup = beamGroup
    }
    
    public func addBGEvent(bgEvent: BGEvent) {
        bgEvents.append(bgEvent)
        bgEvent.bgContainer = self
    }
    
    internal func createTupletBracket() {
        //let color = colors[durationNode!.depth].CGColor // encapsulate
        
        let sum: Int = durationNode!.relativeDurationsOfChildren!.sum()
        
        // sum Int issue
        if isNumerical && (durationNode != nil && !durationNode!.isSubdividable) {
            tupletBracket = TupletBracket(
                left: 0,
                top: 0,
                width: width,
                height: 1.618 * g * scale,
                stemDirection: stemDirection,
                sum: sum,
                beats: durationNode!.duration.beats!.amount,
                subdivisionLevel: durationNode!.duration.subdivision!.level
            )
            addNode(tupletBracket!)
        }
    }
    
    internal func createBeamsLayer() {
        beamsLayer = BeamsLayer(
            g: g,
            scale: scale,
            start: CGPointMake(0, 0),
            stop: CGPointMake(width, 0),
            stemDirection: stemDirection,
            isMetrical: isMetrical
        )
        var x: CGFloat = 0
        for child in durationNode!.children as! [DurationNode] {
            if child.isLeaf {
                beamsLayer.addBeamJunction(BeamJunctionMake(child), atX: x)
                
                /*
                if child.duration.beats!.amount == 3 {
                    //let augDot = AugmentationDot(x: x + 0.618 * g, y: 0, width: 0.382 * g * scale)
                    // FOR TESTING
                    //beamsLayer.addSublayer(augDot)
                    //augmentationDots.append(augDot)
                }
                */
            }
            x += child.width(beatWidth: beatWidth)
            //x += graphicalWidth(duration: child.duration, beatWidth: beatWidth)
            //x += child.duration.getGraphicalWidth(beatWidth: beatWidth)
        }
        beamsLayer.addBeams()
        //beamsLayer.layout()
        addNode(beamsLayer)
    }
    
    private func setFrame() {
        frame = CGRectMake(left, top, width, 100)
    }
}
