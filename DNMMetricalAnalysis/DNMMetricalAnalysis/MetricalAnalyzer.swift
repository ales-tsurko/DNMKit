//
//  MetricalAnalyzer.swift
//  denm_model
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

/**
Analyzes a rhythmic material, or measure containing materal for the best way(s) to subdivide.

NYI: Single-event
*/
public class MetricalAnalyzer {
    
    /// The DurationNode to be analyzed (the rhythmical material)
    public var refNode: DurationNode
    
    private static var prototypesBySum: [Int : [[Int]]] = [
        2: [[2]],
        3: [[3]],
        4: [[2,2]],
        5: [[3,2],[2,3]],
        6: [[2,2,2],[3,3]],
        7: [[2,2,3],[3,2,2],[2,3,2]],
        8: [[4,4],[3,3,2],[2,3,3],[3,2,3]],
        9: [[3,3,3],[4,5],[5,4]]
    ]
    
    /**
    Create a MetricalAnalyzer with reference DurationNode
    
    - parameter refNode: The DurationNode that is to be analyzed.
    This DurationNode may be either a rhythmic material itself, or a measure containing
    DurationNodes
    
    - returns: Initialized MetricalAnalyzer object
    */
    public init(refNode: DurationNode) {
        assert(refNode.isContainer, "cannot do Metrical Analysis of leaf DurationNode")
        self.refNode = refNode.copy()
    }
    
    /**
    Creates an MANode with a hierarchically organized beat-structure underlying ref node.
    
    - returns: MANode object with underlying beat structure of provided DurationNode
    */
    public func makeMANode() -> MANode {
        refNode.matchDurationsOfChildren()
        let beats: Int = refNode.relativeDurationsOfChildren!.sum()
        let subdivsion: Int = refNode.subdivisionOfChildren!.value
        let rootMANode = MANode(duration: Duration(beats, subdivsion))
        let scale: Float = refNode.scaleOfChildren!
        let durationNodes: [DurationNode] = refNode.children as! [DurationNode]
        recurseToMakeMANode(durationNodes: durationNodes, maNode: rootMANode)
        rootMANode.scaleDurationsOfTree(scale: scale)
        return rootMANode
    }
    
    private func recurseToMakeMANode(durationNodes durationNodes: [DurationNode], maNode: MANode) {
        let sum: Int = getSumOfDurationNodes(durationNodes)
        let subdivision: Int = refNode.duration.subdivision!.value
        switch sum {
        case 1:
            for _ in 0..<1 {
                maNode.addChild(MANode(duration: Duration(1, subdivision * 2)))
            }
            //maNode.addChild(MANode(duration: Duration(2,subdivision * 2)))
            // what to do here? this really shouldn't happen…
            // but, create node with twice the subdivision
            break
        case 2...7:
            let bestFit: [Int] = getBestPrototypeForDurations(durationNodes)
            addLeavesToMANode(maNode, withPrototype: bestFit)
        case 8...9:
            let bestFit: [Int] = getBestPrototypeForDurations(durationNodes)
            
            // if 8 or 9 really necessitates compound prototype
            if bestFit.containsElementsWithValuesGreaterThanValue(3) {
                let partitions = partitionDurations(durationNodes, widths: bestFit)
                for partition in partitions {
                    let partitionSum: Int = getSumOfDurationNodes(partition)
                    let child = MANode(duration: Duration(partitionSum, subdivision))
                    recurseToMakeMANode(durationNodes: partition, maNode: child)
                    maNode.addChild(child)
                }
            }
            else { addLeavesToMANode(maNode, withPrototype: bestFit) }
        default:
            // if greater than prototype range, split into partitions
            let bestFit: [Int] = getBestCompoundPrototypeForDurations(durationNodes)
            let partitions = partitionDurations(durationNodes, widths: bestFit)
            for partition in partitions {
                let partitionSum: Int = getSumOfDurationNodes(partition)
                let child = MANode(duration: Duration(partitionSum, subdivision))
                recurseToMakeMANode(durationNodes: partition, maNode: child)
                maNode.addChild(child)
            }
        }
    }
    
    private func getBestCompoundPrototypeForDurations(durationNodes: [DurationNode]) -> [Int] {
        let sum: Int = getSumOfDurationNodes(durationNodes)
        var prototypes: [MAPrototype] = makeMAPrototypes(makeCombinatorialArray(sum))
        setSyncopationOfPrototypes(prototypes, durationNodes: durationNodes)
        filterPrototypesForLeastSyncopation(prototypes: &prototypes)
        filterPrototypesForMostEvenness(prototypes: &prototypes)
        filterPrototypesForLeastVariance(prototypes: &prototypes)
        filterPrototypesForShortestLength(prototypes: &prototypes)
        return prototypes.first!.sequence
    }
    
    private func getBestPrototypeForDurations(durationNodes: [DurationNode]) -> [Int] {
        let sum: Int = getSumOfDurationNodes(durationNodes)
        var prototypes: [MAPrototype] = getPrototypesBySum(sum)
        if prototypes.count > 1 {
            setSyncopationOfPrototypes(prototypes, durationNodes: durationNodes)
            filterPrototypesForLeastSyncopation(prototypes: &prototypes)
            filterPrototypesForHighestPriority(prototypes: &prototypes)
        }
        return prototypes.first!.sequence
    }
    
    private func addLeavesToMANode(maNode: MANode, withPrototype prototype: [Int]) {
        for beats in prototype {
            let child = MANode(duration: Duration(beats, refNode.duration.subdivision!.value))
            maNode.addChild(child)
        }
    }
    
    private func partitionDurations(durations: [DurationNode], widths: [Int]) -> [[DurationNode]] {
        let partitionPoints = makePartitionPointsWithPartitionWidths(widths)
        var partitions: [[DurationNode]] = [[]]
        var partitionToAppendTo: Int = 0
        var accum: Int = 0
        for node in durations {
            let point: Int = partitionPoints[partitionToAppendTo]
            accum += node.duration.beats!.amount
            if accum < point { partitions[partitionToAppendTo].append(node) }
            else if accum == point {
                partitions[partitionToAppendTo].append(node)
                if node !== durations.last! {
                    partitions.append([])
                    partitionToAppendTo++
                }
            }
            else if accum > point {
                let newBeats: Int = accum - point
                let oldBeats: Int = node.duration.beats!.amount - newBeats
                let subdivision: Int = node.duration.subdivision!.value
                let oldNode = DurationNode(duration: Duration(oldBeats, subdivision))
                let newNode = DurationNode(duration: Duration(newBeats, subdivision))
                partitions[partitionToAppendTo].append(oldNode)
                partitions.append([])
                partitionToAppendTo++
                partitions[partitionToAppendTo].append(newNode)
            }
        }
        return partitions
    }
    
    private func makePartitionPointsWithPartitionWidths(partitionWidths: [Int]) -> [Int] {
        var partitionPoints: [Int] = []
        var accum: Int = 0
        for width in partitionWidths {
            accum += width
            partitionPoints.append(accum)
        }
        return partitionPoints
    }
    
    private func filterPrototypesForShortestLength(inout prototypes prototypes: [MAPrototype]) {
        prototypes.sortInPlace { $0.sequence.count < $1.sequence.count }
        let shortestLength: Int = prototypes[0].sequence.count
        prototypes = prototypes.filter { $0.sequence.count == shortestLength }
    }
    
    private func filterPrototypesForLeastSyncopation(inout prototypes prototypes: [MAPrototype]) {
        prototypes.sortInPlace { $0.syncopation! < $1.syncopation! }
        let leastSyncopation: Float = prototypes[0].syncopation!
        prototypes = prototypes.filter { $0.syncopation! == leastSyncopation }
    }
    
    private func filterPrototypesForHighestPriority(inout prototypes prototypes: [MAPrototype]) {
        prototypes.sortInPlace { $0.priority! < $1.priority! }
        let highestPriority: Int = prototypes[0].priority!
        prototypes = prototypes.filter { $0.priority! == highestPriority }
    }
    
    private func filterPrototypesForLeastVariance(inout prototypes prototypes: [MAPrototype]) {
        prototypes.sortInPlace { $0.variance < $1.variance }
        let leastVariance: Float = prototypes[0].variance
        prototypes = prototypes.filter { $0.variance == leastVariance }
    }
    
    private func filterPrototypesForMostEvenness(inout prototypes prototypes: [MAPrototype]) {
        prototypes.sortInPlace { $0.evenness > $1.evenness }
        let mostEvenness: Float = prototypes[0].evenness
        prototypes = prototypes.filter { $0.evenness == mostEvenness }
    }
    
    private func setSyncopationOfPrototypes(
        prototypes: [MAPrototype], durationNodes: [DurationNode]
        )
    {
        for prototype in prototypes {
            prototype.setSyncopationWithDurationNodes(durationNodes)
        }
    }
    
    private func makeCombinatorialArray(sum: Int) -> [[Int]] {
        let sum = sum
        let combo: [Int] = []
        var allCombos: [[Int]] = []
        recurseToMakeCombinatorialArray(sum: sum, combo: combo, allCombos: &allCombos)
        return allCombos
    }
    
    private func recurseToMakeCombinatorialArray(
        sum sum: Int, combo: [Int], inout allCombos: [[Int]]
        )
    {
        var num: Int = sum - combo.sum() >= 9 ? 9 : sum - combo.sum()
        while num >= 4 {
            var localCombo: [Int] = combo
            localCombo.append(num)
            let accum: Int = localCombo.sum()
            if accum == sum { allCombos.append(localCombo) }
            else if accum < sum {
                if accum + 3 < sum {
                    recurseToMakeCombinatorialArray(
                        sum: sum, combo: localCombo, allCombos: &allCombos
                    )
                }
            }
            num--
        }
    }
    
    private func getPrototypesBySum(sum: Int) -> [MAPrototype] {
        var maPrototypes: [MAPrototype] = []
        for (priority, sequence) in (MetricalAnalyzer.prototypesBySum[sum]!).enumerate() {
            let maPrototype = MAPrototype(sequence: sequence)
            maPrototype.setPriority(priority)
            maPrototypes.append(maPrototype)
        }
        return maPrototypes
    }
    
    private func makeMAPrototypes(sequences: [[Int]]) -> [MAPrototype] {
        var prototypes: [MAPrototype] = []
        for sequence in sequences { prototypes.append(MAPrototype(sequence: sequence)) }
        return prototypes
    }
    
    private func getSumOfDurationNodes(durationNodes: [DurationNode]) -> Int {
        var sum: Int = 0
        for node in durationNodes { sum += node.duration.beats!.amount }
        return sum
    }
}

public class MANode: DurationNode {
    
    // perhaps only method is to verify that sum of all children == parent beats
    public override func descendToScaleDurationsOfChildren(
        inout node: DurationNode, inout scale: Float
        ) {
            node.duration.setScale(scale)
            if node.isContainer {
                for child in node.children as! [DurationNode] {
                    var child = child
                    descendToScaleDurationsOfChildren(&child, scale: &scale)
                }
            }
    }
    
    /*
    public func play(tempo tempo: Tempo, timer: Timer) {
        print("duration: \(duration); ms: \(duration.getDurationInMilliseconds(tempo: tempo)); samples: \(duration.getDurationInSamples(tempo: tempo, samplingRate: 44100))")
    }
    */
}

public class MAPrototype: CustomStringConvertible {
    
    // MARK: String Representation
    
    /// Printed Description of an MAPrototype (MetricalAnalysisPrototype)
    public var description: String { get { return "" } }
    
    // MARK: Attributes
    
    /// Sequence of integers with relative beat values
    public var sequence: [Int]
    
    /// Syncopation of MAPrototype against DurationNodes
    public var syncopation: Float?
    
    /**
    Priority of MAPrototype. Lower number is better. Should this be inverted? Probably..
    */
    public var priority: Int?
    
    // MARK: Analyze an MAPrototype
    public var variance: Float { get { return getVariance() } }
    
    public var evenness: Float { get { return getEvenness() } }
    
    // MARK: Create an MAPrototype
    
    /**
    Create an MAPrototype with sequence of integers representing relative beat amounts
    
    - parameter sequence: Sequence of integers representing relative beat amounts
    
    - returns: Initialized MAPrototype
    */
    public init(sequence: [Int]) {
        self.sequence = sequence
    }
    
    // MARK: Set attributes of MAPrototype
    
    /**
    Set priority of MAPrototype
    
    - parameter priority: Priority of MAPrototype
    
    - returns: MAPrototype object
    */
    public func setPriority(priority: Int) -> MAPrototype {
        self.priority = priority
        return self
    }
    
    /**
    Set the syncopation of MAPrototype against a sequence of DurationNodes
    
    - parameter durationNodes: DurationNodes (children of DurationNode that is a container)
    
    - returns: MAPrototype object
    */
    public func setSyncopationWithDurationNodes(durationNodes: [DurationNode]) -> MAPrototype {
        // If only one value: break out with syncopation of 0.0
        if durationNodes.count == 1 { self.syncopation = 0.0; return self }
        // DurationNodes
        var d: [(node: DurationNode, position: Int)] = cumulative(durationNodes)
        // Prototype
        var p: [(value: Int, position: Int)] = cumulative(sequence)
        // Syncopation
        var s: Float = 0
        while d.count > 0 && p.count > 0 {
            // If Duration is synchronous with Prototype
            if d.first!.position == p.first!.position { d.removeFirst(); p.removeFirst() }
                // If accumulated Duration is before current prototype value
            else if d.first!.position < p.first!.position {
                // If the next DurationNode is synchronous with the current prototype
                if d.count > 1 && p.count > 1 && d.second!.position <= p.first!.position {
                    d.removeFirst()
                }
                else {
                    // search for delayed Duration match with next prototype
                    var delayedMatch: Bool = false
                    var peek: Int = 0
                    while peek < d.count - 1 {
                        if d[peek].position == p.first!.position { delayedMatch = true; break }
                        else { peek++ }
                    }
                    addPenaltyForPrototypeValue(p.first!.value, syncopation: &s)
                    if delayedMatch {
                        d.removeFirst(peek)
                        p = p.filter { $0.position < d.first!.position }
                    }
                    else { d.removeFirst(); p.removeFirst() }
                }
            }
                // If accumulated Durations have past current prototype
            else if d.first!.position > p.first!.position {
                // If the next DurationNode is synchronous with the current prototype
                if d.count > 1 && d.first!.position == p.first!.position {
                    d.removeFirst(); p.removeFirst()
                }
                else {
                    // search for delayed prototype match with next Duration
                    var delayedMatch = false
                    var peek: Int = 0
                    while peek < p.count {
                        if p[peek].position == d.first!.position { delayedMatch = true; break }
                        else { peek++ }
                    }
                    if delayedMatch {
                        d.removeFirst()
                        if d.count > 0 { p = p.filter { $0.position >= d.first!.position } }
                    }
                    else {
                        p.removeFirst()
                        addPenaltyForPrototypeValue(p.first!.value, syncopation: &s)
                        d = d.filter { $0.position >= p.first!.position }
                    }
                }
            }
        }
        self.syncopation = s
        return self
    }
    
    private func addPenaltyForPrototypeValue(value: Int, inout syncopation: Float) {
        syncopation = value % 2 == 0 ? syncopation + (1/3) : syncopation + (2/3)
    }
    
    
    private func getVariance() -> Float {
        let variance: Float = sequence.map { Float($0) }.variance()
        return variance
    }
    
    private func getEvenness() -> Float {
        return Float(sequence.filter { $0 % 2 == 0 }.count) / Float(sequence.count)
    }
}

public func cumulative(array: [Int]) -> [(value: Int, position: Int)] {
    var cumulative: [(value: Int, position: Int)] = []
    var p: Int = 0
    for v in array {
        p += v
        let pair: (value: Int, position: Int) = (value: v, position: p)
        cumulative.append(pair)
    }
    return cumulative
}

public func cumulative(array: [DurationNode]) -> [(node: DurationNode, position: Int)] {
    var cumulative: [(node: DurationNode, position: Int)] = []
    var p: Int = 0
    for n in array {
        p += n.duration.beats!.amount
        let pair = (node: n, position: p)
        cumulative.append(pair)
    }
    return cumulative
}