//
//  BGStratum.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

// TO-DO: PADS AT INIT!
public class BGStratum: ViewNode, BuildPattern {
    
    public override var description: String { get { return getDescription() } }
    
    private func getDescription() -> String {
        var description: String = "BGStratum"
        description += ": StemDirection: \(stemDirection)"
        return description
    }
    
    // this is temporary!!
    public var id: String? {
        get { if iIDsByPID.count == 1 { return iIDsByPID.first!.0 }; return nil }
    }
    
    public var system: System? // temp
    
    public var g: CGFloat = 12
    public var s: CGFloat = 1
    public var gS: CGFloat { get { return g * s } }
    public var stemDirection: StemDirection = .Down
    public var beatWidth: CGFloat = 0
    
    public var isMetrical: Bool?
    public var isNumerical: Bool?
    
    public var beamEndY: CGFloat { get { return getBeamEndY() } }

    public var hasBeenBuilt: Bool = false
    
    public var beamGroups: [BeamGroup] = []
    public var bgEvents: [BGEvent] { get { return getBGEvents() } }
    
    public var deNode: DENode?
    public var saNodeByType: [ArticulationType : SANode] = [:]
    public var beamsLayerGroup: BeamsLayerGroup?
    public var tbGroupAtDepth: [Int : TBGroup] = [:]
    public var tbLigaturesAtDepth: [Int : [TBLigature]] = [:]
    public var augmentationDots: [AugmentationDot] = []
    
    public var iIDsByPID: [String: [String]] { get { return getIIDsByPID() } }

    
    // THIS IS BEING REFACTORED OUT
    //public var mgNodeAtDepth: [Int : MGNode] = [:]

    public init(stemDirection: StemDirection = .Down, g: CGFloat = 12, s: CGFloat = 1) {
        super.init()
        self.stemDirection = stemDirection
        self.g = g
        self.s = s
        layoutAccumulation_vertical = stemDirection == .Down ? .Top : .Bottom
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func showTBGroupAtDepth(depth: Int) {
        // something
    }
    
    public func hideTBGRoupAtDepth(depth: Int) {
        
    }
    
    public func commitDENode() {
        
        if deNode != nil {
            addNode(deNode!)
            deNode!.layout()
        }
    }
    
    private func createSANodes() {

        
    }
    
    private func createDENode() {
        // encapsulate: ensureDENode()
        if deNode == nil {
            deNode = DENode(left: 0, top: 0, height: 0.5 * beamGroups.first!.g)
            deNode!.pad_bottom = 0.5 * g
            deNode!.pad_top = 0.5 * g
        } // hack
        for e in 0..<bgEvents.count {
            let bgEvent = bgEvents[e]
            let dePad = 0.618 * g
            let x: CGFloat = bgEvent.x_inBGStratum!
            let pad: CGFloat = g

            let hasAugDot: Bool = bgEvent.beamGroup!.isMetrical &&
                bgEvent.durationNode.duration.beats!.amount % 3 == 0
                ? true : false
            
            let augDotPad = hasAugDot ? 0.75 * g : 0
            if hasAugDot { deNode!.addAugmentationDotAtX(x + augDotPad) }
            
            if e == 0 {
                // first event
                let start: CGFloat = -10
                let stop = x - pad
                for component in bgEvent.durationNode.components {
                    switch component {
                    case is ComponentExtensionStop:
                        deNode!.addDurationalExtensionFromLeft(start, toRight: stop)
                    default: break
                    }
                    
                    /*
                    switch component.property {
                    case .ExtensionStop: break
                        
                    default: break
                    }
                    */
                }
            }
            else if e < bgEvents.count - 1 {
                // middle event
                let nextEvent = bgEvents[e + 1]
                let start: CGFloat = x + augDotPad + dePad
                let stop: CGFloat = nextEvent.x_inBGStratum! - dePad
                for component in bgEvent.durationNode.components {
                    switch component {
                    case is ComponentExtensionStart:
                        deNode!.addDurationalExtensionFromLeft(start, toRight: stop)
                    default: break
                    }
                    
                    /*
                    switch component.property {
                    case .ExtensionStart:
                        deNode!.addDurationalExtensionFromLeft(start, toRight: stop)
                    default: break
                    }
                    */
                }
            }
            else {

                // last event
                let start: CGFloat = x + augDotPad + dePad
                //let stop: CGFloat = frame.width
                
                let stop: CGFloat
                if let system = system { stop = system.frame.width + 20 }
                else { stop = UIScreen.mainScreen().bounds.width }
                
                for component in bgEvent.durationNode.components {
                    switch component {
                    case is ComponentExtensionStart:
                        deNode!.addDurationalExtensionFromLeft(start, toRight: stop)
                    default: break
                    }
                    
                    /*
                    switch component.property {
                    case .ExtensionStart:
                        deNode!.addDurationalExtensionFromLeft(start, toRight: stop)
                    default: break
                    }
                    */
                }
            }
        }
        commitDENode()
        layout() // perhaps not necessary?
    }
    
    public override func layout() {
        super.layout()
        
        // manage LIGATURES
        /*
        for (level, tbLigatures) in tbLigaturesAtDepth {
        let beamEndY = stemDirection == .Down
        ? beamsLayerGroup!.frame.minY
        : beamsLayerGroup!.frame.maxY
        
        let bracketEndY = tbGroupAtDepth[level]!.position.y
        
        for tbLigature in tbLigatures {
        addSublayer(tbLigature)
        tbLigature.setBeamEndY(beamEndY, andBracketEndY: bracketEndY)
        }
        }
        */
        //uiView?.setFrame()
    }
    
    public func addBeamGroupWithDurationNode(durationNode: DurationNode, atX x: CGFloat) {
        let beamGroup = BeamGroup(durationNode: durationNode, left: x)
        beamGroup.beatWidth = beatWidth
        beamGroups.append(beamGroup)
    }
    
    // make private
    public func buildBeamGroups() {
        for beamGroup in beamGroups {
            beamGroup.g = g
            beamGroup.s = s
            beamGroup.stemDirection = stemDirection
            if !beamGroup.hasBeenBuilt { beamGroup.build() }
        }
    }
    
    // make private
    public func commitBeamGroups() {
        buildBeamGroups()
        handOffBeamGroups()
    }
    
    private func handOffBeamGroups() {
        for beamGroup in beamGroups { handOffBeamGroup(beamGroup) }
    }
    
    public func handOffBeamGroup(beamGroup: BeamGroup) {
        assert(beamGroup.hasBeenBuilt, "beamGroup must be built to be handed off")
        
        // clean up in here
        
        // handoff TB, encaps
        for (depth, tbGroup) in beamGroup.tbGroupAtDepth { addTBGroup(tbGroup, atDepth: depth) }
        
        // handoff BEAMS, encaps
        ensureBeamsLayerGroup()
        beamGroup.beamsLayerGroup!.layout()
        beamsLayerGroup!.addNode(beamGroup.beamsLayerGroup!)
        
        // ligatures, encaps
        
        beamGroup.bgStratum = self
    }
    
    // THIS IS BEING REFACTORED OUT
    /*
    private func addMGNode(mgNode: MGNode, atDepth depth: Int) {
        ensuremgNodeAtDepth(depth)
        mgNodeAtDepth[depth]?.addNode(mgNode)
    }
    */
    
    private func ensureBeamsLayerGroup() {
        if beamsLayerGroup == nil {
            beamsLayerGroup = BeamsLayerGroup(stemDirection: stemDirection)
            beamsLayerGroup!.pad_bottom = 6 // hack
            beamsLayerGroup!.pad_top = 6 // hack
        }
    }
    
    private func commitTBGroups() {
        let tbGroupsSorted: [TBGroup] = makeSortedTBGroups()
        for tbGroup in tbGroupsSorted { addNode(tbGroup) }
    }
    
    private func commitBeamsLayerGroup() {
        addNode(beamsLayerGroup!)
    }
    
    public func build() {
        // encapsulate
        buildBeamGroups()
        commitBeamGroups()
        commitTBGroups()
        commitBeamsLayerGroup()
        createDENode()
        createSANodes()
        layout()

        hasBeenBuilt = true
    }
    
    
    // THESE ARE BEING REFACTORED OUT ------------------------------------------------------->
    /*
    private func makeSortedMGNodes() -> [MGNode] {
        var mggs: [MGNode] = []
        var mggsByDepth: [(Int, MGNode)] = []
        for (depth, mgg) in mgNodeAtDepth {
            mggsByDepth.append((depth, mgg))
        }
        mggsByDepth.sortInPlace { $0.0 < $1.0 }
        for mgg in mggsByDepth { mggs.append(mgg.1) }
        return mggs
    }
    */
    
    
    public func addTestStems() {
        for event in bgEvents {
            let x = event.x + event.bgContainer!.left + event.bgContainer!.beamGroup!.left
            let stem = Stem(x: x, beamEndY: beamsLayerGroup!.frame.minY, infoEndY: 100) // hack
            stem.lineWidth = 0.0618 * beamGroups.first!.g // hack
            let hue = HueByTupletDepth[event.bgContainer!.depth]
            stem.strokeColor = UIColor.colorWithHue(hue, andDepthOfField: .Foreground).CGColor
            addSublayer(stem)
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
    
    private func addTBGroup(tbGroup: TBGroup, atDepth depth: Int ) {
        ensureTupletBracketGroupAtDepth(depth)
        tbGroupAtDepth[depth]?.addNode(tbGroup)
    }
    
    // THIS IS BEING REFACTORED OUT --------------------------------------------------------->
    /*
    private func ensuremgNodeAtDepth(depth: Int) {
        if mgNodeAtDepth[depth] == nil {
            mgNodeAtDepth[depth] = MGNode()
            mgNodeAtDepth[depth]!.depth = depth
            
            // TO-DO: PAD
            //mgNodeAtDepth[depth]!.pad.bottom = 5
        }
    }
    */
    
    private func ensureTupletBracketGroupAtDepth(depth: Int) {
        if tbGroupAtDepth[depth] == nil {
            tbGroupAtDepth[depth] = TBGroup()
            tbGroupAtDepth[depth]!.pad_bottom = 3 // hack
            tbGroupAtDepth[depth]!.pad_top = 3 // hack
            tbGroupAtDepth[depth]!.depth = depth

            tbGroupAtDepth[depth]!.bgStratum = self
        }
    }
    
    private func getBGEvents() -> [BGEvent] {
        var bgEvents: [BGEvent] = []
        for beamGroup in beamGroups {
            bgEvents.appendContentsOf(beamGroup.bgEvents)
        }
        for bgEvent in bgEvents { bgEvent.bgStratum = self }
        bgEvents.sortInPlace { $0.x_inBGStratum! < $1.x_inBGStratum! }
        return bgEvents
    }
    
    private func getPad_below() -> CGFloat {
        // refine
        return stemDirection == .Down ? 0.0618 * frame.height : 0.0618 * frame.height
    }
    
    private func getPad_above() -> CGFloat {
        // refine
        return stemDirection == .Down ? 0.0618 * frame.height : 0.0618 * frame.height
    }
    
    
    private func getBeamEndY() -> CGFloat {
        if beamsLayerGroup != nil {
            return stemDirection == .Up ? beamsLayerGroup!.frame.height : 0
        }
        else { return 0 }
    }
    
    private func getIIDsByPID() -> [String : [String]] {
        var iIDsByPID: [String : [String]] = [:]
        for beamGroup in beamGroups {
            if let durationNode = beamGroup.durationNode {
                let bg_iIDsByPID = durationNode.iIDsByPID
                for (pid, iids) in bg_iIDsByPID {
                    if iIDsByPID[pid] == nil {
                        iIDsByPID[pid] = iids
                    }
                    else {
                        iIDsByPID[pid]!.appendContentsOf(iids)
                        iIDsByPID[pid] = iIDsByPID[pid]!.unique()
                    }
                }
            }
        }
        return iIDsByPID
    }
    
    
    // THESE ARE BEING REFACTORED OUT ------------------------------------------------------->
    /*
    public func switchMGNodeAtDepth(depth: Int) {
    if !hasNode(mgNodeAtDepth[depth]!) { showMGNodeAtDepth(depth) }
    else { hideMGNodeAtDepth(depth) }
    }
    */
    
    /*
    public func showMGNodeAtDepth(depth: Int) {
    let mgNode = mgNodeAtDepth[depth]
    if mgNode == nil { return }
    let tbGroup = tbGroupAtDepth[depth]
    if tbGroup == nil { return }
    if !hasNode(mgNode!) { insertNode(mgNode!, afterNode: tbGroup!) }
    //layout()
    
    //container?.layout()
    print("showMGNodeAtDepth")
    print("bgStratum.container: \(container)")
    }
    
    public func hideMGNodeAtDepth(depth: Int) {
    let mgNode = mgNodeAtDepth[depth]
    if mgNode == nil { return }
    removeNode(mgNode!)
    //layout()
    //container?.layout()
    }
    */
    // <--------------------------------------------------------------------------------------
    
    
}
