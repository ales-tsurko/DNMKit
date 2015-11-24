//
//  DurationNode.swift
//  denm_model
//
//  Created by James Bean on 8/11/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
DurationNode is a hierarchical structure with an accompanying datum of Duration. NYI: Partition
*/
public class DurationNode: Node {
    
    // deprecate
    public var id: String?
    
    // MARK: Attributes
    
    /// Duration of DurationNode
    public var duration: Duration
    public var offsetDuration: Duration = DurationZero
    
    public var durationSpan: DurationSpan { get { return getDurationSpan() } }
    
    public var components: [Component] = []
    
    public var isRest: Bool { return getIsRest() }
    
    /// All Instrument ID values organized by Performer ID keys
    public var instrumentIDsByPerformerID: [String : [String]] { get { return getIIDsByPID() } }
    
    /// If this DurationNode is a continuation from another ("tied")
    public var hasExtensionStart: Bool = false
    
    /// If this DurationNode continues into another ("tied")
    public var hasExtensionStop: Bool = false
    
    /// If this DurationNode shall be represented with metrical beaming
    public var isMetrical: Bool = true
    
    /** 
    If this DurationNode is either [1] subdividable (non-tuplet), or [2] should not be
    represented with tuplet bracket(s).
    */
    public var isNumerical: Bool = true
    
    
    // FIXME
    /// If this DurationNode has only Extension Components (ties) (not a rest, but no info).
    public var hasOnlyExtensionComponents: Bool {
        for component in components {
            if !(component is ComponentExtensionStart) && !(component is ComponentExtensionStop) {
                return false
            }
        }
        return true
    }
    
    /*
    public func distanceFromDurationNode(durationNode: DurationNode) -> Duration? {
        // TODO
        return nil
    }
    
    public func distanceFromDuration(duration: Duration) -> Duration? {
        // TODO
        return nil
    }
    */
    
    // MARK: Analyze DurationNode
    
    /// Array of integers with reduced relative durations of children
    public var relativeDurationsOfChildren: [Int]? {
        get { return getRelativeDurationsOfChildren() }
    }
    
    /// The reduced, leveled Subdivision of children
    public var subdivisionOfChildren: Subdivision? {
        get { return getSubdivisionOfChildren() }
    }
    
    /// Scale of children DurationNodes
    public var scaleOfChildren: Float? { get { return getScaleOfChildren() } }
    
    /// If DurationNode is subdividable (non-tuplet)
    public var isSubdividable: Bool { get { return getIsSubdividable() } }
    
    /*
    // implement
    public class func rangeFromDurationNodes(durationNodes: [DurationNode],
        inDurationSpan durationSpan: DurationSpan
    ) -> [DurationNode]
    {
        return []
    }
    */
    

    /// From an array of DurationNodes, choose those that fit within the given DurationSpan
    public class func rangeFromDurationNodes(
        durationNodes: [DurationNode],
        afterDuration start: Duration,
        untilDuration stop: Duration
    ) -> [DurationNode]
    {
        var durationNodeRange: [DurationNode] = []
        for durationNode in durationNodes {
            if (
                durationNode.offsetDuration >= start &&
                durationNode.offsetDuration + durationNode.duration <= stop
            )
            {
                durationNodeRange.append(durationNode)
            }
        }
        // make nil returnable if count == 0
        return durationNodeRange
    }
    
    public class func random() -> DurationNode {
        
        let amountBeats = randomInt(3, max: 9)
        let duration = Duration(amountBeats,16)
        let amountEvents = randomInt(4, max: 9)
        var sequence: [Int] = []
        for _ in 0..<amountEvents {
            let duration: Int = [1,1,1,2,2,3].random()
            sequence.append(duration)
        }
        let durationNode = DurationNode(duration: duration, sequence: sequence)
        return durationNode
    }
    
    public class func getMaximumSubdivisionOfSequence(sequence: [DurationNode]) -> Subdivision? {
        var maxSubdivision: Subdivision?
        for child in sequence {
            if maxSubdivision == nil || child.duration.subdivision! > maxSubdivision! {
                maxSubdivision = child.duration.subdivision!
            }
        }
        return maxSubdivision
    }
    
    public class func getMinimumSubdivisionOfSequence(sequence: [DurationNode]) -> Subdivision? {
        var minSubdivision: Subdivision?
        for child in sequence {
            if minSubdivision == nil || child.duration.subdivision! < minSubdivision! {
                minSubdivision = child.duration.subdivision!
            }
        }
        return minSubdivision
    }
    
    public class func matchDurationsOfSequence(sequence: [DurationNode]) {
        DurationNode.levelDurationsOfSequence(sequence)
        DurationNode.reduceDurationsOfSequence(sequence)
    }
    
    public class func levelDurationsOfSequence(sequence: [DurationNode]) {
        let maxSubdivision: Subdivision = getMaximumSubdivisionOfSequence(sequence)!
        for child in sequence {
            child.duration.respellAccordingToSubdivision(maxSubdivision)
        }
    }
    
    public class func reduceDurationsOfSequence(sequence: [DurationNode]) {
        
        if !DurationNode.allSubdivisionsOfSequenceAreEquivalent(sequence) {
            DurationNode.levelDurationsOfSequence(sequence)
        }
        
        let relativeDurationsOfSequence = getRelativeDurationsOfSequence(sequence)
        let durationGCD: Int = gcd(relativeDurationsOfSequence)
        for node in sequence {
            let newBeats = node.duration.beats! / durationGCD
            node.duration.respellAccordingToBeats(newBeats)
        }
        /*
        levelDurationsOfChildren()
        let durationGCD: Int = gcd(relativeDurationsOfChildren!)
        for child in children as! [DurationNode] {
        
        let newBeats = child.duration.beats! / durationGCD
        child.duration.respellAccordingToBeats(newBeats)
        //child.duration.beats! /= durationGCD
        }
        */
    }
    
    public class func allSubdivisionsOfSequenceAreEquivalent(sequence: [DurationNode]) -> Bool {
        if sequence.count == 0 { return false }
        let refSubdivision = sequence.first!.duration.subdivision!
        for i in 1..<sequence.count {
            if sequence[i].duration.subdivision! != refSubdivision { return false }
        }
        return true
    }
    
    public class func getRelativeDurationsOfSequence(sequence: [DurationNode]) -> [Int] {
        // make copy of sequence, to not change current values of DurationNode sequence
        var sequence_copy: [DurationNode] = []
        for node in sequence { sequence_copy.append(node.copy()) }
        
        if !DurationNode.allSubdivisionsOfSequenceAreEquivalent(sequence_copy) {
            DurationNode.levelDurationsOfSequence(sequence_copy)
        }
        //DurationNode.reduceDurationsOfSequence(sequence_copy) // make this an option?
        
        var relativeDurations: [Int] = []
        for node in sequence_copy { relativeDurations.append(node.duration.beats!.amount) }
        return relativeDurations
    }
    
    /**
    Create a DurationNode with Duration
    
    - parameter duration: Duration
    
    - returns: Initialized DurationNode
    */
    public init(duration: Duration) {
        self.duration = duration
    }
    
    /*
    public init(duration: Duration, sequence: NSArray) {
        self.duration = duration
        super.init()
        addChildrenWithSequence(sequence)
    }
    */
    
    /**
    Create a DurationNode with a Duration and a sequence of relative durations.
    
    - parameter duration: Duration
    - parameter sequence: Sequence of relative durations of child nodes
    
    - returns: Initialized DurationNode object
    */
    public init(duration: Duration, offsetDuration: Duration = DurationZero, sequence: NSArray) {
        self.duration = duration
        self.offsetDuration = offsetDuration
        super.init()
        addChildrenWithSequence(sequence)
    }
    
    /**
    Create a DurationNode with a Duration as an array of two integers: [beats, subdivision] and
    a sequence of relative durations.
    
    - parameter duration: Duration as an array of two integers: [beats, subdivision]
    - parameter sequence: Sequence of relative durations of child nodes
    
    - returns: Initialized DurationNode object
    */
    public init(duration: (Int, Int), offsetDuration: (Int, Int) = (0,8), sequence: NSArray) {
        self.duration = Duration(duration.0, duration.1)
        self.offsetDuration = Duration(offsetDuration.0, offsetDuration.1)
        super.init()
        addChildrenWithSequence(sequence)
    }
    
    /*
    public override func addChild(node: Node) -> Self {
    super.addChild(node)
    matchDurationsOfTree()
    return self
    }
    */
    
    /*
    public func addRandomComponentsToLeavesWithPID(pID: String, andIID iID: String) {
        for leaf in leaves as! [DurationNode] {
            leaf.addComponent(
                ComponentPitch(
                    pID: pID, iID: iID, pitches: [
                        randomFloat(min: 60, max: 84, resolution: 0.25)
                    ]
                )
            )
            leaf.addComponent(ComponentArticulation(pID: pID, iID: iID, markings: ["."]))
            //leaf.addComponent(ComponentDynamic(pID: pID, iID: iID, marking: "fff"))
        }
    }
    */
    
    public func addChildWithBeats(beats: Int) -> DurationNode {
        let child = DurationNode(duration: Duration(beats, duration.subdivision!.value))
        // perhaps do some calculation here...to figure out proper
        addChild(child)
        return child
        
        //println("children: \(children)")
        
        //(root as! DurationNode).matchDurationsOfTree()
        
        //println("children after match durations of tree (destructive): \(children))")
        
        //(root as! DurationNode).scaleDurationsOfChildren()
        
        //println("children after scale durations of children: \(children)")
    }

    /**
    Set Duration of DurationNode
    
    - parameter duration: Duration of DurationNode
    
    - returns: DurationNode object
    */
    public func setDuration(duration: Duration) -> DurationNode {
        self.duration = duration
        return self
    }
    
    /**
    Add child nodes with relative durations in sequence.
    
    - parameter sequence: Sequence of relative durations of child nodes
    
    - returns: DurationNode object
    */
    public func addChildrenWithSequence(sequence: NSArray) -> DurationNode {
        traverseToAddChildrenWithSequence(sequence, parent: self)
        (root as! DurationNode).matchDurationsOfTree()
        (root as! DurationNode).scaleDurationsOfChildren()

        // weird, encapsulate
        if sequence.count == 1 {
            (children.first! as! DurationNode).duration.setSubdivision(duration.subdivision!)
        }
        setOffsetDurationOfChildren()
        return self
    }
    
    public func addComponent(component: Component) {
        components.append(component)
    }
    
    public func clearComponents() {
        components = []
    }
    
    public func setOffsetDurationOfChildren() {
        var offsetDuration = self.offsetDuration
        traverseToSetOffsetDurationOfChildrenOfDurationNode(self,
            andOffsetDuration: &offsetDuration
        )
    }
    
    private func traverseToSetOffsetDurationOfChildrenOfDurationNode(durationNode: DurationNode,
        inout andOffsetDuration offsetDuration: Duration
    )
    {
        durationNode.offsetDuration = offsetDuration
        // must incorporate SCALE into here...
        for child in durationNode.children as! [DurationNode] {
            
            var newOffsetDuration = offsetDuration
            
            if child.isContainer {
                print("child is container: scale of child.children: \(child.scaleOfChildren)")
                traverseToSetOffsetDurationOfChildrenOfDurationNode(child,
                    andOffsetDuration: &newOffsetDuration
                )
            }
            // LEAF
            else { child.offsetDuration = offsetDuration }
            offsetDuration += child.duration
            
            // have to do that thing where it resets the duration back to what it was
        }
    }
    
    // could this be done with [AnyObject]? ...then do the type cast check?
    // for testing only, i'd assume; rather not dip into NSArray…
    private func traverseToAddChildrenWithSequence(sequence: NSArray, parent: DurationNode) {
        for el in sequence {
            if let leafBeats = el as? Int {
                let leafNode = DurationNode(
                    duration: Duration(abs(leafBeats), duration.subdivision!.value)
                )
                parent.addChild(leafNode)
            }
            else if let container = el as? NSArray {
                var node: DurationNode?
                if let beats = container[0] as? Int {
                    node = DurationNode(duration: Duration(beats, duration.subdivision!.value))
                    parent.addChild(node!)
                }
                if let seq = container[1] as? NSArray {
                    traverseToAddChildrenWithSequence(seq, parent: node!)
                }
            }
        }
    }
    
    /**
    Set if DurationNode is extended at the beginning
    
    - parameter hasExtensionBegin: If DurationNode is extended at the beginning
    
    - returns: DurationNode object
    */
    public func setHasExtensionStart(hasExtensionStart: Bool) -> DurationNode {
        self.hasExtensionStart = hasExtensionStart
        return self
    }
    
    /**
    Set if DurationNode extends into the next
    
    - parameter hasExtensionEnd: If DurationNode extends into the next
    
    - returns: DurationNode object
    */
    public func setHasExtensionStop(hasExtensionStop: Bool) -> DurationNode {
        self.hasExtensionStop = hasExtensionStop
        return self
    }
    
    // MARK: Operations
    
    /**
    Deep copy of DurationNode. A new DurationNode is created with all attributes equivalant
    to original.
    When comparing a Node that has been copied from another,"===" will return false,
    while "==" will return true (NYI).
    
    - returns: DurationNode object
    */
    public override func copy() -> DurationNode {
        var node: Node = self
        descendToCopy(&node)
        return node as! DurationNode
    }
    
    
    /**
    This is the recursive counterpart to copy(). This method copies the Duration of each
    child and descends to each child, if applicable.
    
    - parameter node: Node
    */
    public override func descendToCopy(inout node: Node) {
        let newParent: DurationNode = DurationNode(duration: (node as! DurationNode).duration)
        if node.isContainer {
            for child in node.children {
                var newChild: Node = child
                descendToCopy(&newChild)
                newParent.addChild(newChild)
            }
        }
        node = newParent
    }
    
    
    public func matchDurationsOfTree() {
        var node = self
        traverseToMatchDurationsOfTree(&node)
    }
    
    private func traverseToMatchDurationsOfTree(inout node: DurationNode) {
        if node.isContainer {
            node.matchDurationToChildren_destructive()
            for child in node.children as! [DurationNode] {
                var child = child
                traverseToMatchDurationsOfTree(&child)
            }
        }
    }
    
    public func scaleDurationsOfTree(scale scale: Float) -> DurationNode {
        duration.setScale(scale)
        scaleDurationsOfChildren()
        return self
    }
    
    /**
    Recursively scales the Durations of all Nodes in a DurationNode tree. This scale is used
    when calculating the graphical widths and temporal lengths of (embedded-)tuplet rhythms.
    */
    public func scaleDurationsOfChildren() {
        var node: DurationNode = self
        var scale: Float = duration.scale
        descendToScaleDurationsOfChildren(&node, scale: &scale)
    }
    
    /**
    This is the recursive counterpart to scaleDurationsOfChildren(). This method sets the
    inheritedScale of the Duration of each Node in a DurationNode tree.
    
    - parameter node:  DurationNode to be scaled
    - parameter scale: Amount by which to scale Duration of DurationNode
    */
    public func descendToScaleDurationsOfChildren(
        inout node: DurationNode, inout scale: Float
    )
    {
        node.duration.setScale(scale)
        if node.isContainer {
            let beats: Float = Float(node.duration.beats!.amount)
            let sumAsInt: Int = node.relativeDurationsOfChildren!.sum()
            let sum: Float = Float(sumAsInt)
            var newScale = scale * (beats / sum)
            for child in node.children as! [DurationNode] {
                var child = child
                descendToScaleDurationsOfChildren(&child, scale: &newScale)
            }
        }
    }
    
    // make this private, can only happen on INIT_WITH_SEQ() !!!!
    private func matchDurationToChildren_destructive() {
        
        //print("matchDurationToChildren_destructive")
        
        for child in children as! [DurationNode] {
            child.duration.respellAccordingToSubdivision(duration.subdivision!)
        }
        let beats: Int = duration.beats!.amount
        
        var reduced: [Int] = []
        let relDurs = relativeDurationsOfChildren!
        let relDursGCD = gcd(relDurs)
        for d in relDurs { reduced.append(d / relDursGCD) }
        
        //print("reduced: \(reduced)")
        
        let sum: Int = reduced.sum()
        
        //print("beats: \(beats); sum: \(sum); relativeDurations: \(reduced)")
        
        if sum < beats {
            //let closestPowerOfTwo = getClosestPowerOfTwo(multiplier: sum, value: beats)
            //print("closestPowerOfTwo: \(closestPowerOfTwo)")
            
            //let scale: Int = closestPowerOfTwo / sum
            //print("scale: \(scale)")

            for c in 0..<children.count {
                let child = children[c] as! DurationNode
                child.duration.respellAccordingToBeats(reduced[c])
            }
            
            /*
            for child in children as! [DurationNode] {
            child.duration *= scale
            }
            */
 
            
        }
        else if sum > beats {
            
            //print("parent duration: \(duration)")
            
            //print("sum: \(sum) > beats: \(beats)")
            
            let closestPowerOfTwo = getClosestPowerOfTwo(multiplier: beats, value: sum)
            
            //print("closestPowerOfTwo: \(closestPowerOfTwo)")
            
            let scale: Int = closestPowerOfTwo / beats
            
            //print("scale: \(scale)")
            
            let newBeats = duration.beats!.amount * scale
            
            //print("children before: \(children)")
            
            //print("parent dur before: \(duration)")
            duration.respellAccordingToBeats(newBeats)
            //print("parent dur after: \(duration)")
            
            // only being respelled to 4 not 8? why!??!??!
            
            for child in children as! [DurationNode] {
                
                // something has to happen in here!!!!
                
                child.duration.setSubdivision(duration.subdivision!)
            }
            
            //print("reduced beats: \(reduced)")
            //print("children after: \(children)")
        }
        
        for c in 0..<children.count {
            let child = children[c] as! DurationNode
            child.duration.setBeats(reduced[c])
        }
        
        // encapsulate
        // reduce if there's all evens
        var beatsWithChildBeats: [Int] = [duration.beats!.amount]
        for child in children as! [DurationNode] {
            beatsWithChildBeats.append(child.duration.beats!.amount)
        }
        let allDursGCD = gcd(beatsWithChildBeats)
        //print("all durs GCD: \(allDursGCD)")
        if allDursGCD > 1 {
            // deal with cur node
            //let newBeats: Int = duration.beats!.amount / allDursGCD
            //duration.respellAccordingToBeats(newBeats)
            // deal with children
            
            /*
            for child in children as! [DurationNode] {
            //let newBeats: Int = child.duration.beats!.amount / allDursGCD
            //child.duration.respellAccordingToBeats(newBeats)
            }
            */
        }
        //reduceDurationsOfChildren()
    }
    
    public func matchDurationToChildren_nonDestructive() {
        // respelling only
    }
    
    /**
    Ensures that the Duration of this DurationNode is appropriate considering the context of
    the Durations of its children.
    
    In many cases, this means that the Duration of this DurationNode is respelled according to
    the amount of beats that most closely matches the sum of the leveled and reduced children
    Durations (e.g. original DurationNode.duration = (2,16), and original
    DurationNode.relativeDurationsOfChildren.sum() = 13; new DurationNode.duration = (16,128)).
    
    In other cases, this means that the Durations of the children DurationNodes are respelled
    such that their sum matches the most-reduced form the Duration of this DurationNode (e.g.
    original DurationNode.duration = (7,32), and the amounts of beats for the children are
    [1,2,1]; the new amounts of beats for the children are [2,4,2], with a sum of 8).
    */
    public func matchDurationToChildren() {
        
        
        // currently does nothing
        
        /*
        for child in children as! [DurationNode] {
        child.duration.respellAccordingToSubdivision(duration.subdivision!)
        }
        
        levelDurationsOfChildren()
        reduceDurationsOfChildren()
        
        let beats: Int = duration.beats!.amount
        let sum: Int = relativeDurationsOfChildren!.sum()
        
        
        
        println("matchDurationToChildren BEFORE: beats: \(beats) / sum: \(sum)")
        
        /*
        // first, set the subdivisions to match!
        for child in children as! [DurationNode] {
        child.duration.setSubdivision(duration.subdivision!)
        }
        */
        
        // e.g.: 7:13
        if sum < beats {
        
        println("sum: \(sum) < beats: \(beats)")
        
        /*
        for b in 0..<relativeDurationsOfChildren!.count {
        var beats = relativeDurationsOfChildren![b]
        var child = (children as! [DurationNode])[b]
        child.duration.respellAccordingToBeats(b)
        }
        */
        
        
        for child in children as! [DurationNode] {
        child.duration.respellAccordingToSubdivision(duration.subdivision!)
        }
        
        
        // is parent changed?
        /*
        let closestPowerOfTwo = getClosestPowerOfTwo(multiplier: sum, value: beats)
        let scale: Float = Float(closestPowerOfTwo) / Float(sum)
        for child in children as! [DurationNode] {
        
        // why can't i just respell according to parent.subdivision?
        // -- see above
        // are there cases where this won't work
        
        let newBeats = child.duration.beats! * Int(scale)
        child.duration.respellAccordingToBeats(newBeats)
        }
        */
        }
        
        else if sum > beats {
        
        println("sum: \(sum) > beats: \(beats)")
        
        let closestPowerOfTwo = getClosestPowerOfTwo(multiplier: beats, value: sum)
        duration.respellAccordingToBeats(closestPowerOfTwo)
        for child in children as! [DurationNode] {
        child.duration.setSubdivision(duration.subdivision!)
        }
        
        }
        */
        
        /*
        if beats > sum {
        let closestPowerOfTwo = getClosestPowerOfTwo(multiplier: sum, value: beats)
        let scale: Float = Float(closestPowerOfTwo) / Float(sum)
        for child in children as! [DurationNode] {
        child.duration.beats! *= Int(scale)
        }
        }
        else if beats < sum {
        let closestPowerOfTwo = getClosestPowerOfTwo(multiplier: beats, value: sum)
        duration.respellAccordingToBeats(Beats(amount: closestPowerOfTwo))
        for child in children as! [DurationNode] {
        //child.duration.setSubdivision(duration.subdivision!)
        child.duration.respellAccordingToSubdivision(duration.subdivision!)
        }
        }
        */
    }
    
    /**
    Levels and Reduces the Durations of all of the children of this DurationNode, if present.
    */
    public func matchDurationsOfChildren() {
        reduceDurationsOfChildren()
    }
    
    /**
    Ensures that the Durations of each child of this DurationNode have the same Subdivision.
    */
    public func levelDurationsOfChildren() {
        if !isContainer { return }
        DurationNode.levelDurationsOfSequence(children as! [DurationNode])
    }
    
    /**
    Ensures that the Durations of each child, once leveled, are reduced to the greatest degree.
    */
    public func reduceDurationsOfChildren() {
        if !isContainer { return }
        DurationNode.levelDurationsOfSequence(children as! [DurationNode])
        DurationNode.reduceDurationsOfSequence(children as! [DurationNode])
    }
    
    /**
    Partitions this DurationNode at the desired Subdivision.
    
    NYI: Less friendly partition-points. Arbitrary arrays of partition widths ([3,5,3]).
    
    - parameter newSubdivision: The Subdivision at which to partition DurationNode
    
    - returns: An array of DurationNodes, partitioned at the desired Subdivision
    */
    public func partitionAtSubdivision(newSubdivision: Subdivision) -> [DurationNode] {
        matchDurationToChildren()
        assert(newSubdivision >= subdivisionOfChildren!, "can't divide by bigger subdivision")
        let ratio: Int = newSubdivision.value / subdivisionOfChildren!.value
        var multiplied: [DurationNode] = makeChildrenWithDurationsScaledByRatio(ratio)
        var compound: [[DurationNode]] = [[]]
        let sum: Int = getSumOfDurationNodes(children as! [DurationNode])
        recurseToPartitionAtSubdivision(&multiplied, compound: &compound, sum: sum)
        
        // encapsulate ----------------------------------------------------------------------->
        var partitioned: [DurationNode] = []
        for beat in compound {
            let newParent = DurationNode(duration: Duration(subdivision: newSubdivision))
            for child in beat { newParent.addChild(child) }
            newParent.matchDurationToChildren()
            partitioned.append(newParent)
        }
        // <----------------------------------------------------------------------- encapsulate
        
        return partitioned
    }
    
    /**
    This is the recursive counterpart to partitionAtSubdivision().
    
    - parameter array:    Array of DurationNodes
    - parameter compound: Array of Arrays of Durations, with a width prescribed by the Subdivision
    - parameter sum:      Width of each Partition
    */
    public func recurseToPartitionAtSubdivision(
        inout array: [DurationNode],
        inout compound: [[DurationNode]],
        sum: Int
    ) {
            let curBeats: Int = array[0].duration.beats!.amount
            var accumulated: Int = 0
            if compound.last!.last == nil { accumulated = curBeats }
            else {
                for dur in compound.last! { accumulated += dur.duration.beats!.amount }
                accumulated += curBeats
            }
            
            if accumulated < sum {
                var newLast: [DurationNode] = compound.last!
                newLast.append(array[0])
                compound.removeLast()
                compound.append(newLast)
                array.removeAtIndex(0)
                if array.count > 0 {
                    recurseToPartitionAtSubdivision(&array, compound: &compound, sum: sum)
                }
            }
            else if accumulated == sum {
                var newLast: [DurationNode] = compound.last!
                newLast.append(array[0])
                compound.removeLast()
                compound.append(newLast)
                array.removeAtIndex(0)
                if array.count > 0 {
                    compound.append([])
                    recurseToPartitionAtSubdivision(&array, compound: &compound, sum: sum)
                }
            }
            else {
                var newLast: [DurationNode] = compound.last!
                let endNode: DurationNode = array[0].copy()
                endNode.duration.beats!.setAmount(sum - (accumulated - curBeats))
                endNode.setHasExtensionStart(true)
                newLast.append(endNode)
                compound.removeLast()
                compound.append(newLast)
                var beginBeats = array[0].duration.beats!.amount - endNode.duration.beats!.amount
                if curBeats > sum {
                    while beginBeats > sum {
                        let newNode: DurationNode = array[0].copy()
                        newNode.duration.beats!.setAmount(sum)
                        newNode.setHasExtensionStop(true)
                        newNode.setHasExtensionStart(true)
                        compound.append([newNode])
                        beginBeats -= sum
                    }
                }
                if beginBeats > 0 {
                    let newNode: DurationNode = array[0].copy()
                    newNode.duration.beats!.setAmount(beginBeats)
                    newNode.setHasExtensionStop(true)
                    compound.append([newNode])
                }
                array.removeAtIndex(0)
                if array.count > 0 {
                    recurseToPartitionAtSubdivision(&array, compound: &compound, sum: sum)
                }
            }
    }
    
    /**
    - parameter ratio: Amount by which to scale the Durations of the children of this DurationNode
    
    - returns: An array of DurationNodes with Durations scaled by ratio
    */
    public func makeChildrenWithDurationsScaledByRatio(ratio: Int) -> [DurationNode] {
        var multiplied: [DurationNode] = []
        for child in children as! [DurationNode] {
            let newChild: DurationNode = child.copy()
            let newBeats = newChild.duration.beats! * ratio * duration.beats!.amount
            newChild.duration.setBeats(newBeats)
            newChild.duration.subdivision! *= getClosestPowerOfTwo(
                multiplier: 2, value: newChild.duration.beats!.amount
            ) * ratio
            multiplied.append(newChild)
        }
        return multiplied
    }
    
    /**
    - returns: Maximum Subdivision of children of this DurationNode, if present.
    */
    public func getMaximumSubdivisionOfChildren() -> Subdivision? {
        if isContainer {
            var maxSubdivision: Subdivision?
            for child in children {
                let durNodeChild = child as! DurationNode
                if (
                    maxSubdivision == nil ||
                        durNodeChild.duration.subdivision! > maxSubdivision!
                    )
                {
                    maxSubdivision = durNodeChild.duration.subdivision!
                }
            }
            return maxSubdivision
        }
        else { return nil }
    }
    
    /**
    - returns: An array of integers of relative amounts of Beats in the Durations of children.
    */
    public func getRelativeDurationsOfChildren() -> [Int]? {
        if !isContainer { return nil }
        var relativeDurations: [Int] = []
        for child in children as! [DurationNode] {
            let child_copy = child.copy()
            child_copy.duration.respellAccordingToSubdivision(duration.subdivision!)
            relativeDurations.append(child_copy.duration.beats!.amount)
        }
        
        return relativeDurations
    }
    
    /**
    Checks if the sum of the Durations of all children DurationNodes are equivelant to the
    amount of Beats in this DurationNode. Otherwise, this DurationNode is a tuplet.
    
    - returns: If this DurationNode is subdividable
    */
    public func getIsSubdividable() -> Bool {
        matchDurationToChildren()
        let sum: Int = relativeDurationsOfChildren!.sum()
        let beats: Int = duration.beats!.amount
        return sum == beats
    }
    
    
    private func getIsRest() -> Bool {
        if !isLeaf { return false }
        for component in components { if !(component is ComponentRest) { return false } }
        return true
    }
    
    /**
    - returns: Subdivision of children, if present.
    */
    public func getSubdivisionOfChildren() -> Subdivision? {
        if !isContainer { return nil }
        // match (level, reduce) children to parent
        return (children[0] as! DurationNode).duration.subdivision!
        
        /*
        // ensure that all subdivisions are ==
        if isContainer {
        return (children[0] as! DurationNode).duration.subdivision!
        }
        else { return nil }
        */
    }
    
    private func getScaleOfChildren() -> Float {
        return (children as! [DurationNode]).first!.duration.scale
    }
    
    /**
    - parameter durationNodes: Array of DurationNodes
    
    - returns: Sum of the Beats in the Durations of each DurationNode in array.
    */
    public func getSumOfDurationNodes(durationNodes: [DurationNode]) -> Int {
        var sum: Int = 0
        for child in durationNodes { sum += child.duration.beats!.amount }
        return sum
    }
    
    private func getIIDsByPID() -> [String : [String]] {
        var iIDsByPID: [String : [String]] = [:]
        let durationNode = self
        descendToGetIIDsByPID(durationNode: durationNode, iIDsByPID: &iIDsByPID)
        return iIDsByPID
    }
    
    // FIXME
    private func descendToGetIIDsByPID(
        durationNode durationNode: DurationNode,
        inout iIDsByPID: [String : [String]]
    )
    {
        func addInstrumentID(
            iID: String,
            andPerformerID pID: String,
            inout toIIDsByPID iIDsByPID: [String : [String]]
        )
        {
            if iIDsByPID[pID] == nil { iIDsByPID[pID] = [iID] }
            else if !iIDsByPID[pID]!.contains(iID) { iIDsByPID[pID]!.append(iID) }
        }
        
        
        for component in durationNode.components {
            addInstrumentID(component.instrumentID,
                andPerformerID: component.performerID,
                toIIDsByPID: &iIDsByPID
            )
        }
        if durationNode.isContainer {
            for child in durationNode.children as! [DurationNode] {
                descendToGetIIDsByPID(durationNode: child, iIDsByPID: &iIDsByPID)
            }
        }
    }
    
    private func getDurationSpan() -> DurationSpan {
        return DurationSpan(duration: duration, startDuration: offsetDuration)
    }
    
    public override func getDescription() -> String {
        var description: String = "DurationNode"
        if isRoot { description += " (root)" }
        else if isLeaf { description = "leaf" }
        else { description = "internal" }
        
        // add duration info : make this DurationSpan
        description += ": \(duration), offset: \(offsetDuration)"
        
        if isRest { description += " (rest)" }
        // add component info
        if components.count > 0 {
            description += ": "
            for (c, component) in components.enumerate() {
                if c > 0 { description += ", " }
                description += "\(component)"
            }
            description += ";"
        }
        
        // traverse children
        if isContainer {
            for child in children {
                description += "\n"
                for _ in 0..<child.depth { description += "\t" }
                description += "\(child)"
            }
        }
        return description
    }
}

// MAKE EXTENSION -- add to DurationNode as class func
public func makeDurationSpanWithDurationNodes(durationNodes: [DurationNode]) -> DurationSpan {
    if durationNodes.count == 0 { return DurationSpan() }
    else {
        let nds = durationNodes
        let startDuration = nds.sort({
            $0.durationSpan.startDuration < $1.durationSpan.startDuration
        }).first!.durationSpan.startDuration
        let stopDuration = nds.sort({
            $0.durationSpan.stopDuration > $1.durationSpan.stopDuration
        }).first!.durationSpan.stopDuration
        return DurationSpan(startDuration: startDuration, stopDuration: stopDuration)
    }
}