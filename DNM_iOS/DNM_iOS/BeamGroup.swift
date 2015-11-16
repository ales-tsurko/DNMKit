//
//  BeamGroup.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore
import DNMModel

// TO-DO: Conform to Guido
public class BeamGroup: ViewNode, BuildPattern {
    
    public var hasBeenBuilt: Bool = false
    
    public var id: String? // FOR TESTING ONLY! will be on Component-level only later
    
    public var g: CGFloat = 12
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }
    public var beatWidth: CGFloat = 0
    
    public var stemDirection: StemDirection = .Down {
        willSet {
            layoutAccumulation_vertical = stemDirection == .Down ? .Top : .Bottom
        }
    }
    
    public var durationNode: DurationNode?
    
    public var bgStratum: BGStratum?
    public var bgEvents: [BGEvent] { get { return getBGEvents() } }
    public var bgContainers: [BGContainer] = []
    
    public var tbGroupAtDepth: [Int : TBGroup] = [:]
    public var beamsLayerGroupAtDepth: [Int : BeamsLayerGroup] = [:]
    public var tbLigaturesAtDepth: [Int : [TBLigature]] = [:]

    // THIS IS BEING REFACTORED OUT
    //public var mgNodeAtDepth: [Int : MGNode] = [:]
    
    public var beamsLayerGroup: BeamsLayerGroup?
    public var tupletBracketGroup = TBGroup()
    
    public var augmentationDots: [AugmentationDot] = []
    
    public var isMetrical: Bool = true
    public var isNumerical: Bool = true
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init() {
        super.init()
    }
    
    public init(durationNode: DurationNode, left: CGFloat = 0) {
        super.init()
        self.durationNode = durationNode
        self.left = left
        self.isMetrical = durationNode.isMetrical
        self.isNumerical = durationNode.isNumerical
    }
    
    public init(
        durationNode: DurationNode,
        stemDirection: StemDirection,
        g: CGFloat,
        beatWidth: CGFloat
    )
    {
        self.durationNode = durationNode
        self.id = durationNode.id
        self.stemDirection = stemDirection
        self.g = g
        self.beatWidth = beatWidth // proxy
        super.init()
        self.layoutAccumulation_vertical = stemDirection == .Down ? .Top : .Bottom
        build()
    }
    
    public init(
        durationNode: DurationNode,
        top: CGFloat,
        left: CGFloat,
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
        self.s = scale
        self.beatWidth = beatWidth
        self.stemDirection = stemDirection
        self.isMetrical = isMetrical
        self.isNumerical = isNumerical
        super.init()
        self.top = top
        self.left = left
        self.layoutAccumulation_vertical = stemDirection == .Down ? .Top : .Bottom
        build()
    }
    
    public func build() {
        var x: CGFloat = 0
        descendToBuildWithDurationNode(durationNode!, context: self, x: &x)
        commitTupletBracketGroups() // add in build()
        addNode(beamsLayerGroup!)
        layout()
        
        // HACK: encapsulate, get rid of hard-coded values
        // add slash if !isMetrical
        if !isMetrical {
            let slash = CAShapeLayer()
            let slash_path = UIBezierPath()
            
            let point0: CGPoint
            let point1: CGPoint
            if stemDirection == .Down {
                point0 = CGPointMake(-10, 10)
                point1 = CGPointMake(10, -10)
            }
            else {
                point0 = CGPointMake(-10, -10)
                point1 = CGPointMake(10, 10)
            }
            slash_path.moveToPoint(point0)
            slash_path.addLineToPoint(point1)
            slash.path = slash_path.CGPath
            slash.strokeColor = UIColor.grayColor().CGColor // hack
            slash.lineWidth = 1.5 // hack
            
            slash.position.x += 3
            slash.position.y += 3
            beamsLayerGroup?.addSublayer(slash)
        }
        
        hasBeenBuilt = true
    }
    
    private func buildWithDurationNode(durationNode: DurationNode) {
        var x: CGFloat = 0
        descendToBuildWithDurationNode(durationNode, context: self, x: &x)
    }
    
    private func descendToBuildWithDurationNode(
        durationNode: DurationNode,
        context: CALayer,
        inout x: CGFloat
    )
    {
        if durationNode.isContainer {
            let bgContainer = BGContainer(
                durationNode: durationNode,
                left: x,
                top: 0,
                g: g,
                scale: s,
                beatWidth: beatWidth,
                stemDirection: stemDirection,
                isMetrical: isMetrical,
                isNumerical: isNumerical
            )
            addBGContainer(bgContainer, toContext: context)
            var x: CGFloat = 0
            for child in durationNode.children as! [DurationNode] {
                descendToBuildWithDurationNode(child, context: bgContainer, x: &x)
                adjustX(&x, forChildNode: child)
            }
        }
        else {
            let bgEvent = BGEvent(durationNode: durationNode, x: x)
            addBGEvent(bgEvent, toContext: context)
        }
    }

    private func adjustX(inout x: CGFloat, forChildNode node: DurationNode) {
        //let w: CGFloat = graphicalWidth(duration: node.duration, beatWidth: beatWidth)
        let w = node.width(beatWidth: beatWidth)
        x = node !== node.parent!.children.last! ? x + w : 0
    }
    
    private func addBGEvent(bgEvent: BGEvent, toContext context: CALayer) {
        if let bgContainer = context as? BGContainer { bgContainer.addBGEvent(bgEvent) }
    }
    
    private func addBGContainer(bgContainer: BGContainer, toContext context: CALayer) {
        if let parentContainer = context as? BGContainer {
            parentContainer.addBGContainer(bgContainer)
        }
        else if let beamGroup = context as? BeamGroup { beamGroup.addBGContainer(bgContainer) }
        
        bgContainer.beamGroup = self
        // make helper function
        
        let hue = HueByTupletDepth[bgContainer.depth]
        bgContainer.beamsLayer.color = UIColor.colorWithHue(hue,
            andDepthOfField: .MostForeground
        ).CGColor
        
        augmentationDots.appendContentsOf(bgContainer.augmentationDots)
        addBeamsLayer(bgContainer.beamsLayer)
        if bgContainer.tupletBracket != nil {
            addTupletBracket(bgContainer.tupletBracket!, atDepth: bgContainer.depth)
            
            if tbLigaturesAtDepth[bgContainer.depth] == nil {
                tbLigaturesAtDepth[bgContainer.depth] = bgContainer.tbLigatures
                for tbLigature in bgContainer.tbLigatures {
                    tbLigature.position.x += bgContainer.frame.minX
                }
            }
            else {
                tbLigaturesAtDepth[bgContainer.depth]?.appendContentsOf(bgContainer.tbLigatures)
                for tbLigature in bgContainer.tbLigatures {
                    tbLigature.position.x += bgContainer.frame.minX
                }
            }
        }
        
        // THIS IS BEING REFACTORED OUT
        //addMGNode(bgContainer.mgNode!, atDepth: bgContainer.depth)
    }
    
    public func addBGContainer(bgContainer: BGContainer) {
        bgContainers.append(bgContainer)
    }
    
    private func addTupletBracket(tupletBracket: TupletBracket, atDepth depth: Int) {
        ensureTupletBracketGroupAtDepth(depth)
        tbGroupAtDepth[depth]?.addNode(tupletBracket)
    }
    
    private func ensureTupletBracketGroupAtDepth(depth: Int) {
        if tbGroupAtDepth[depth] == nil {
            tbGroupAtDepth[depth] = TBGroup() // as! TBGroup
            tbGroupAtDepth[depth]!.depth = depth
        }
    }
    
    private func addBeamsLayer(beamsLayer: BeamsLayer) {
        if beamsLayerGroup == nil {
            beamsLayerGroup = BeamsLayerGroup(stemDirection: stemDirection)
        }
        beamsLayer.layout()
        beamsLayerGroup!.addNode(beamsLayer)
    }
    
    private func getBGEvents() -> [BGEvent] {
        var bgEvents: [BGEvent] = []
        //for bgContainer in bgContainers { bgEvents.extend(bgContainer.bgEvents) }
        traverseToGetBGEvents(bgContainers.first!, bgEvents: &bgEvents)
        for bgEvent in bgEvents { bgEvent.beamGroup = self }
        bgEvents.sortInPlace { $0.x < $1.x }
        return bgEvents
    }
    
    private func traverseToGetBGEvents(bgContainer: BGContainer, inout bgEvents: [BGEvent]) {
        if bgContainer.bgContainers.count > 0 {
            for bgc in bgContainer.bgContainers {
                traverseToGetBGEvents(bgc, bgEvents: &bgEvents)
            }
        }
        for bge in bgContainer.bgEvents { bgEvents.append(bge) }
    }
    
    private func commitTupletBracketGroups() {
        let tbGroupsSorted: [TBGroup] = makeSortedTBGroups()
        if isNumerical {
            for tbGroup in tbGroupsSorted { addNode(tbGroup) }
        }
        
    }
    
    private func makeSortedTBGroups() -> [TBGroup] {
        var tbgs: [TBGroup] = []
        var tbgsByDepth: [(Int, TBGroup)] = []
        for (depth, tbg) in tbGroupAtDepth { tbgsByDepth.append((depth, tbg)) }
        tbgsByDepth.sortInPlace { $0.0 < $1.0 }
        for tbg in tbgsByDepth { tbgs.append(tbg.1) }
        return tbgs
    }
    
    public func addTestStems() {
        for event in bgEvents {
            let x = event.x + event.bgContainer!.left
            let stem = Stem(x: x, beamEndY: beamsLayerGroup!.frame.minY, infoEndY: 100)
            stem.lineWidth = 0.0618 * g
            stem.color = UIColor.colorWithHue(HueByTupletDepth[event.bgContainer!.depth],
                andDepthOfField: .MostForeground
                ).CGColor
            
            /*
            stem.strokeColor = JBColor.colorWithHue(HueByTupletDepth[event.bgContainer!.depth],
                andDepthOfField: .MostForeground
            ).CGColor
            */
            
            
            //stem.strokeColor = colors[event.bgContainer!.depth].CGColor
            addSublayer(stem)
        }
    }
    
    override func setWidthWithContents() {
        if durationNode == nil { super.setWidthWithContents() }
        else {
            let width = durationNode!.width(beatWidth: beatWidth)
            //let width = graphicalWidth(duration: durationNode!.duration, beatWidth: beatWidth)
            frame = CGRectMake(frame.minX, frame.minY, width, frame.height)
        }
    }
    
    // THIS IS BEING REFACTORED OUT --------------------------------------------------------->
    /*
    private func addMGNode(mgNode: MGNode, atDepth depth: Int) {
    ensureMGLayerAtDepth(depth)
    mgNode.depth = depth
    mgNodeAtDepth[depth]?.addNode(mgNode)
    }
    */
    
    
    /*
    private func ensureMGLayerAtDepth(depth: Int) {
    if mgNodeAtDepth[depth] == nil {
    mgNodeAtDepth[depth] = MGNode() //  as! MGGroup
    mgNodeAtDepth[depth]!.depth = depth
    }
    }
    */
    // <---------------------------------------------------------------------------------------
    
    // THESE ARE BEING REFACTORED OUT ------------------------------------------------------->
    /*
    private func commitMGNodes() {
    let mgNodesSorted: [MGNode] = makeSortedMGNodes()
    for mgNode in mgNodesSorted {
    mgNode.layout()
    addNode(mgNode)
    }
    }
    */
    
    /*
    private func makeSortedMGNodes() -> [MGNode] {
    var mgns: [MGNode] = []
    var mgnsByDepth: [(Int, MGNode)] = []
    for (depth, mgn) in mgNodeAtDepth { mgnsByDepth.append((depth, mgn)) }
    mgnsByDepth.sortInPlace { $0.0 < $1.0 }
    for mgn in mgnsByDepth { mgns.append(mgn.1) }
    return mgns
    }
    */
    // -------------------------------------------------------------------------------------->
    
}


