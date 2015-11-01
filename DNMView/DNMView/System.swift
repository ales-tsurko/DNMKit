//
//  System.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMUtility
import DNMModel

public class System: ViewNode, BuildPattern {
    
    // DESTROY --------------------------------------------------------------------------------
    public var rhythmCueGraphByID: [String : RhythmCueGraph] = [:]
    // DESTROY --------------------------------------------------------------------------------
    
    /// String representation of System
    public override var description: String { get { return getDescription() } }
    
    
    public var viewerID: String?
    
    /// Page containing this System
    public var page: Page?
    
    /// If this System has been built yet
    public var hasBeenBuilt: Bool = false
    
    /// All GraphEvents contained within this System
    public var graphEvents: [GraphEvent] { return getGraphEvents() }

    /// All InstrumentIDs and InstrumentTypes, organized by PerformerID
    public var iIDsAndInstrumentTypesByPID: [[String : [(String, InstrumentType)]]] = []
    

    
    // this should go...
    // make private getter
    public var instrumentTypeByIIDByPID: [String : [String : InstrumentType]] {
        return getInstrumentTypeAndIIDByPID()
    }

    /** 
    All component types (as `String`) by ID.
    Currently, this is a PerformerID, however, 
    this is to be extended to be more generalized at flexibility increases with identifiers.
    Examples of these component types are: "dynamics", "articulations", "pitch", etc..
    */
    public var componentTypesByID: [String : [String]] = [:]
    
    
    /// Component types currently shown
    public var componentTypesShownByID: [String : [String]] = [:]
    
    
    /// Identifiers organizaed by component type (as `String`)
    private var idsByComponentType: [String : [String]] = [:]
    
    /// Identifiers that are currently showing a given component type (as `String`)
    private var idsShownByComponentType: [String : [String]] = [:]
    
    /// Identifiers that are currently not showing a given component type (as `String`)
    private var idsHiddenByComponentType: [String : [String]] = [:]
    
    // DESTROY
    public var bgStratumByID: [String : BGStratum] = [:]
    public var bgStrataByID: [String : [BGStratum]] = [:]
    
    /// DynamicMarkingNodes organized by identifier `String`
    public var dmNodeByID: [String : DMNode] = [:]
    
    /// Performers organized by identifier `String`
    public var performerByID: [String: Performer] = [:]
    
    /// SlurHandlers organizaed by identifier `String`
    public var slurHandlersByID: [String : [SlurHandler]] = [:]

    /// All InstrumentEventHandlers in this System
    public var instrumentEventHandlers: [InstrumentEventHandler] = []
    
    /** TemporalInfoNode of this System. Contains:
        - TimeSignatureNode
        - MeasureNumberNode
        - TempoMarkingsNode
    */
    public var temporalInfoNode = TemporalInfoNode(height: 75)
    
    /** 
    EventsNode of System. Stacked after the `temporalInfoNode`.
    Contains all non-temporal musical information (`Performers`, `BGStrata`, `DMNodes`, etc).
    */
    public var eventsNode = ViewNode(accumulateVerticallyFrom: .Top)
    
    /// Layer for Barlines. First (most background) layer of EventsNode
    public let barlinesLayer = CALayer()
    
    /// All MeasureViews contained in this System
    public var measures: [MeasureView] = []
    
    /// All DurationNodes contained in this System
    public var durationNodes: [DurationNode] = []
    
    public var measureNumberNode: ViewNode? // make specific
    public var timeSignatureNode: ViewNode? // make specific
    
    public var g: CGFloat = 0
    public var beatWidth: CGFloat = 0 // proxy
    public var infoStartX: CGFloat = 50 // proxy
    
    // DEPRECATE
    public var offsetDuration: Duration = DurationZero
    public var totalDuration: Duration = DurationZero
    
    public var durationSpan: DurationSpan { get { return DurationSpan() } }
    
    public var nextSystem: System? { get { return getNextSystem() } }
   
    // move down
    private func getNextSystem() -> System? {
        if page == nil { return nil }
        if let index = page!.systems.indexOfObject(self) {
            if index < page!.systems.count - 1 { return page!.systems[index + 1] }
        }
        return nil
    }
    
    public var previousSystem: System? { get { return getPreviousSystem() } }
    
    // move down
    private func getPreviousSystem() -> System? {
        if page == nil { return nil }
        if let index = page?.systems.indexOfObject(self) {
            if index > 0 { return page!.systems[index - 1] }
        }
        return nil
    }

    public var bgStrata: [BGStratum] = []
    public var performers: [Performer] = []
    public var stems: [Stem] = []

    public var barlines: [Barline] = []
    //public var mgRects: [MetronomeGridRect] = []
    
    public var minPerformersTop: CGFloat? { get { return getMinPerformersTop() } }
    public var maxPerformersBottom: CGFloat? { get { return getMaxPerformersBottom() } }
    
    public class func rangeFromSystems(
        systems: [System],
        startingAtIndex index: Int,
        constrainedByMaximumTotalHeight maximumHeight: CGFloat
    ) -> [System]
    {
        var systemRange: [System] = []
        var s: Int = index
        var accumHeight: CGFloat = 0
        while s < systems.count && accumHeight < maximumHeight {
            if accumHeight + systems[s].frame.height <= maximumHeight {
                systemRange.append(systems[s])
                accumHeight += systems[s].frame.height + systems[s].pad_bottom
                s++
            }
            else { break }
        }
        return systemRange
    }
    
    public override init() {
        super.init()
        layoutAccumulation_vertical = .Top
        setsWidthWithContents = true
        pad_bottom = 2 * g
    }
    
    public init(
        g: CGFloat,
        beatWidth: CGFloat,
        viewerID: String? = nil
    ) {
        self.g = g
        self.beatWidth = beatWidth
        self.viewerID = viewerID
        super.init()
        layoutAccumulation_vertical = .Top
        setsWidthWithContents = true
        pad_bottom = 2 * g
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func getDurationAtX(x: CGFloat) -> Duration {
        if x <= infoStartX { return DurationZero }
        let infoX = round(((x - infoStartX) / beatWidth) * 16) / 16
        let floatValue = Float(infoX)
        let duration = Duration(floatValue: floatValue) + offsetDuration
        return duration
    }

    public func addTempoMarkingWithValue(value: Int,
        andSubdivisionLevel subdivisionLevel: Int, atX x: CGFloat
    )
    {
        temporalInfoNode.addTempoMarkingWithValue(value, andSubdivisionLevel: subdivisionLevel, atX: x)
    }
    
    public func addRehearsalMarkingWithIndex(index: Int, type: RehearsalMarkingType, atX x: CGFloat) {
        print("system add rehearsal marking")
        temporalInfoNode.addRehearsalMarkingWithIndex(index, type: type, atX: x)
    }
    
    // NOTE: The use of BGStratumByID[id] is temporary, and must be dealt with over time as necessary!
    // -- in future: use getBGStratumRepresentation....
    
    // TODO: rhythmCueGraph still unstable
    // -- is maintained when there are no perfs, dmNode OR bgStratum
    public func arrangeNodesWithComponentTypesPresent() {
        
        organizeIDsByComponentType()
        
        func addPerformersShown() {
            
            // eek, redo completely
            if let performersIDsShown = idsShownByComponentType["pitches"] {
                for performerIDShown in performersIDsShown {
                    if let performer = performerByID[performerIDShown] {
                        
                        // clean up rhythm cue graph shit // clean this up
                        if let rhythmCueGraphWithID = rhythmCueGraphByID[performerIDShown] {
                            if eventsNode.hasNode(rhythmCueGraphWithID) {
                                eventsNode.removeNode(rhythmCueGraphWithID)
                            }
                        }
                        
                        // anyway, just add the fucking normal thing
                        eventsNode.addNode(performer)
                    }
                }
            }
        }
        
        func removeComponentsAsNecessary() {
            
            for (componentTypeHidden, ids) in idsHiddenByComponentType {
                for id in ids {
                    switch componentTypeHidden {
                    case "performer":
                        if let performer = performerByID[id] where eventsNode.hasNode(performer) {
                            eventsNode.removeNode(performer)
                        }
                    case "pitches":
                        if let performer = performerByID[id] where eventsNode.hasNode(performer) {
                            if let instrument = performer.instrumentByID[id] {
                                if let staff = instrument.graphByID["staff"]
                                    where instrument.hasNode(staff)
                                {
                                    let rhythmCueGraph: RhythmCueGraph
                                    if let rCG = rhythmCueGraphByID[id] {
                                        rhythmCueGraph = rCG
                                    }
                                    else {
                                        let rCG = RhythmCueGraph(height: 20, g: g)
                                        rCG.addClefAtX(15) // hack
                                        rhythmCueGraphByID[id] = rCG
                                        rhythmCueGraph = rCG
                                        
                                        // add new stems
                                        if let bgStratum = bgStratumByID[id]
                                            where eventsNode.hasNode(bgStratum)
                                        {
                                            // right now this creates WAY too many bgEvents
                                            for _ in bgStratum.bgEvents {
                                                //let x = bgEvent.x_objective!
                                                //let graphEvent = rhythmCueGraph.startEventAtX(x)
                                                
                                                
                                                /*
                                                let eventHandler = EventHandler(
                                                    bgEvent: bgEvent, graphEvent: graphEvent, system: self
                                                )
                                                */
                                                //print("making rhythm cue graph stem:")
                                                //let stem = eventHandler.makeStemInContext(eventsNode)
                                                
                                                // encapsulate within init
                                                //var stem_width: CGFloat = 0.0618 * g
                                                //stem.lineWidth = stem_width
                                                
                                                // this will be changed
                                                //stem.strokeColor = colors[eventHandler.bgEvent!.depth! - 1].CGColor
                                                
                                                //eventHandlers.append(eventHandler)
                                            }
                                        }
                                    }
                                    rhythmCueGraph.instrument = instrument
                                    instrument.replaceNode(staff, withNode: rhythmCueGraph)
                                }
                            }
                        }
                    case "rhythm":
                        // temp usage of bgStrataByID[id]
                        if let bgStrata = bgStrataByID[id] {
                            for bgStratum in bgStrata {
                                if eventsNode.hasNode(bgStratum) {
                                    eventsNode.removeNode(bgStratum)
                                }
                            }
                        }
                    case "dynamics":
                        if let dmNode = dmNodeByID[id] {
                            if eventsNode.hasNode(dmNode) {
                                eventsNode.removeNode(dmNode, andLayout: false)
                            }
                        }
                    case "articulations":
                        if let performer = performerByID[id] {
                            if eventsNode.hasNode(performer) {
                                for instrument in performer.instruments {
                                    for graph in instrument.graphs {
                                        for event in graph.events {
                                            event.hideArticulations()
                                        }
                                    }
                                }
                            }
                        }
                    case "slurs":
                        if let slurHandlers = slurHandlersByID[id] {
                            for slurHandler in slurHandlers {
                                if let slur = slurHandler.slur {
                                    slur.removeFromSuperlayer()
                                }
                            }
                        }
                    default: break
                    }
                }
            }
        }
        
        func addComponentsAsNecessary() {
            for (componentTypeShown, ids) in idsShownByComponentType {
                for id in ids {
                    switch componentTypeShown {
                    case "performer":
                        if let performer = performerByID[id] where !eventsNode.hasNode(performer) {
                            eventsNode.addNode(performer)
                        }
                    case "pitches":
                        if let performer = performerByID[id] where eventsNode.hasNode(performer) {
                            if let instrument = performer.instruments.first { // hack
                                if let rhythmCueGraph = rhythmCueGraphByID[id] {
                                    if instrument.hasNode(rhythmCueGraph) {
                                        if let staff = instrument.graphByID["staff"] {
                                            instrument.replaceNode(rhythmCueGraph, withNode: staff)
                                        }
                                    }
                                }
                            }
                        }
                    case "rhythm":
                        if let bgStrata = bgStrataByID[id] {
                            for bgStratum in bgStrata {
                                if !eventsNode.hasNode(bgStratum) {
                                    eventsNode.addNode(bgStratum, andLayout: false)
                                }
                            }
                        }
                    case "dynamics":
                        if let dmNode = dmNodeByID[id] {
                            if !eventsNode.hasNode(dmNode) {
                                eventsNode.addNode(dmNode, andLayout: false)
                            }
                        }
                    case "articulations":
                        if let performer = performerByID[id] {
                            if eventsNode.hasNode(performer) {
                                for instrument in performer.instruments {
                                    for graph in instrument.graphs {
                                        for event in graph.events {
                                            event.showArticulations()
                                        }
                                    }
                                }
                            }
                        }
                    case "slurs":
                        if let slurHandlers = slurHandlersByID[id] {
                            for slurHandler in slurHandlers {
                                if let slur = slurHandler.slur { eventsNode.addSublayer(slur) }
                            }
                        }
                    default: break
                    }
                }
            }
        }
    
        func sortComponents() {

            // encapsulate makeSortedPIDs() -> [String]
            var sortedPIDs: [String] = []
            for pID_dict in iIDsAndInstrumentTypesByPID {
                for (pID, _) in pID_dict { sortedPIDs.append(pID) }
            }

            var sortedPerformers = sortedPIDs
            if let viewerID = viewerID where viewerID != "omni" {
                sortedPerformers.remove(viewerID)
                sortedPerformers.append(viewerID)
            }
            
            var index: Int = 0
            for id in sortedPIDs {

                // ASSUMING STEM DIRECTION IS DESIRED AS IT IS CURRENTLY SET
                if id == viewerID {
                    if let performer = performerByID[id] where eventsNode.hasNode(performer) {
                        eventsNode.removeNode(performer)
                        eventsNode.insertNode(performer, atIndex: index, andLayout: false)
                        index++
                    }
                    if let rhythmCueGraph = rhythmCueGraphByID[id] where eventsNode.hasNode(rhythmCueGraph)
                    {
                        eventsNode.removeNode(rhythmCueGraph, andLayout: false)
                        eventsNode.insertNode(rhythmCueGraph, atIndex: index, andLayout: false)
                        index++
                    }
                    
                    if let bgStrata = bgStrataByID[id] {
                        for bgStratum in bgStrata {
                            if eventsNode.hasNode(bgStratum) {
                                eventsNode.removeNode(bgStratum, andLayout: false)
                                eventsNode.insertNode(bgStratum, atIndex: index, andLayout: false)
                                index++
                            }
                        }
                    }
                
                    if let dmNode = dmNodeByID[id] where eventsNode.hasNode(dmNode) {
                        eventsNode.removeNode(dmNode, andLayout: false)
                        eventsNode.insertNode(dmNode, atIndex: index, andLayout: false)
                        index++
                    }

                }
                // ASSUMING STEM DIRECTION IS DESIRED AS IT IS CURRENTLY SET
                else {
                    
                    if let bgStrata = bgStrataByID[id] {
                        for bgStratum in bgStrata {
                            if eventsNode.hasNode(bgStratum) {
                                eventsNode.removeNode(bgStratum, andLayout: false)
                                eventsNode.insertNode(bgStratum, atIndex: index, andLayout: false)
                                index++
                            }
                        }
                    }
                    if let performer = performerByID[id] where eventsNode.hasNode(performer) {
                        eventsNode.removeNode(performer)
                        eventsNode.insertNode(performer, atIndex: index, andLayout: false)
                        index++
                    }
                    if let rhythmCueGraph = rhythmCueGraphByID[id] where eventsNode.hasNode(rhythmCueGraph)
                    {
                        eventsNode.removeNode(rhythmCueGraph, andLayout: false)
                        eventsNode.insertNode(rhythmCueGraph, atIndex: index, andLayout: false)
                        index++
                    }
                    if let dmNode = dmNodeByID[id] where eventsNode.hasNode(dmNode) {
                        eventsNode.removeNode(dmNode, andLayout: false)
                        eventsNode.insertNode(dmNode, atIndex: index, andLayout: false)
                        index++
                    }
                }
            }
            CATransaction.setDisableActions(true)
            eventsNode.layout()
            CATransaction.setDisableActions(false)
        }
        
        removeComponentsAsNecessary()
        addComponentsAsNecessary()
        sortComponents()
    }
    
    private func organizeIDsByComponentType() {
        
        // encapsulate this, put this somewhere early and smart
        for (id, componentTypes) in componentTypesByID {
            if !componentTypes.contains("performer") {
                componentTypesByID[id]!.append("performer")
            }
        }
        
        createIDsByComponentType()
        createIDsShownByComponentType()
        createIDsHiddenByComponentType()
    }
    
    private func createIDsByComponentType() {
        idsByComponentType = [:]
        for (id, componentTypes) in componentTypesByID {
            for componentType in componentTypes {
                if idsByComponentType[componentType] == nil {
                    idsByComponentType[componentType] = [id]
                }
                else { idsByComponentType[componentType]!.append(id) }
            }
        }
    }
    
    private func createIDsShownByComponentType() {
        idsShownByComponentType = [:]
        for (id, componentTypesShown) in componentTypesShownByID {
            for componentTypeShown in componentTypesShown {
                if idsShownByComponentType[componentTypeShown] == nil {
                    idsShownByComponentType[componentTypeShown] = [id]
                }
                else { idsShownByComponentType[componentTypeShown]!.append(id) }
            }
        }
    }
    
    private func createIDsHiddenByComponentType() {
        idsHiddenByComponentType = [:]
        for (componentType, ids) in idsByComponentType {
            for id in ids {
                if let idsShownWithComponentType = idsShownByComponentType[componentType] {
                    if !idsShownWithComponentType.contains(id) {
                        if idsHiddenByComponentType[componentType] == nil {
                            idsHiddenByComponentType[componentType] = [id]
                        }
                        else { idsHiddenByComponentType[componentType]!.append(id) }
                    }
                }
                else {
                    // if there isn't even idsShownWithComponentTypeAtAll!
                    if idsHiddenByComponentType[componentType] == nil {
                        idsHiddenByComponentType[componentType] = [id]
                    }
                    else { idsHiddenByComponentType[componentType]!.append(id) }
                }
            }
        }
    }

    public func makePerformerByIDWithBGStrata(bgStrata: [BGStratum]) -> [String : Performer] {
        var performerByID: [String : Performer] = [:]
        for bgStratum in bgStrata {
            for (pID, iIDs) in bgStratum.iIDsByPID {
                var idsAndInstrumentTypes: [(String, InstrumentType)] = []
                for iID in iIDs {
                    if let instrumentType = instrumentTypeByIIDByPID[pID]?[iID] {
                        idsAndInstrumentTypes.append((iID, instrumentType))
                    }
                }
                if let performer = performerByID[pID] {
                    performer.addInstrumentsWithIDsAndInstrumentTypes(idsAndInstrumentTypes)
                }
                else {
                    let performer = Performer(id: pID)
                    performer.addInstrumentsWithIDsAndInstrumentTypes(idsAndInstrumentTypes)
                    performer.pad_bottom = g // HACK
                    performerByID[pID] = performer
                    performers.append(performer)
                    eventsNode.addNode(performer)
                }
            }
        }
        return performerByID
    }
    
    private func sortIDs(ids: [String], withOrderedIDs orderedIDs: [String]) -> [String] {
        var ids_sorted: [String] = []
        for id in ids {
            if ids_sorted.count == 0 { ids_sorted = [id] }
            else {
                var id_shallBeAppended: Bool = true
                if let preferenceIndex: Int = orderedIDs.indexOf(id) {
                    for i in 0..<ids_sorted.count {
                        if i > preferenceIndex {
                            ids_sorted.insert(id, atIndex: i)
                            id_shallBeAppended = false
                            break
                        }
                    }
                }
                if id_shallBeAppended { ids_sorted.append(id) }
            }
        }
        return ids_sorted
    }

    /*
    // TODO: reimplement with InstrumentEventHandlers
    private func getBGStratumRepresentationByPerformer() -> [Performer : [BGStratum : Int]] {
        var bgStratumRepresentationByPerformer: [Performer : [BGStratum : Int]] = [:]
        for eventHandler in eventHandlers {
            if eventHandler.bgEvent == nil { continue }
            if eventHandler.graphEvent == nil { continue }
            
            let bgStratum = eventHandler.bgEvent!.bgStratum!
            let performer = eventHandler.graphEvent!.graph!.instrument!.performer!
            if bgStratumRepresentationByPerformer[performer] == nil {
                bgStratumRepresentationByPerformer[performer] = [bgStratum : 1]
            }
            else if bgStratumRepresentationByPerformer[performer]![bgStratum] == nil {
                bgStratumRepresentationByPerformer[performer]![bgStratum] = 1
            }
            else { bgStratumRepresentationByPerformer[performer]![bgStratum]!++ }
        }
        return bgStratumRepresentationByPerformer
    }
    */
    
    /*
    // TODO: reimplement: see above
    private func arrangeBGStrataAroundPerformers() {
        let bgStratumRepresentationByPerformer = getBGStratumRepresentationByPerformer()
        for (performer, representationByBGStratum) in bgStratumRepresentationByPerformer {
            let bgStrataSorted: [(BGStratum, Int)] = representationByBGStratum.sort({$0.1 > $1.1})
            for (bgStratum, representation) in Array(bgStrataSorted.reverse()) {
                eventsNode.removeNode(bgStratum)
                eventsNode.insertNode(bgStratum, beforeNode: performer)
            }
            // not sure what this is for, but i could imagine it being worthwhile?
            //let mostRepresented = bgStrataSorted.first!.0
        }
    }
    */
    
    /*
    private func getDMNodeRepresentationByPerformer() -> [Performer: [DMNode : Int]] {
        var dmNodeRepresentationByPerformer: [Performer : [DMNode : Int]] = [:]
        for eventHandler in eventHandlers {
            if eventHandler.bgEvent == nil { continue }
            if eventHandler.graphEvent == nil { continue }
            
            let performer = eventHandler.graphEvent!.graph!.instrument!.performer!
            for component in eventHandler.bgEvent!.durationNode.components {
                if let componentDynamic = component as? ComponentDynamic {
                    assert(dmNodeByID[componentDynamic.id] != nil,
                        "dmNodeByID[\(componentDynamic.id)] must exist"
                    )
                    let dmNode = dmNodeByID[componentDynamic.id]!
                    if dmNodeRepresentationByPerformer[performer] == nil {
                        dmNodeRepresentationByPerformer[performer] = [dmNode : 1]
                    }
                    else if dmNodeRepresentationByPerformer[performer]![dmNode] == nil {
                        dmNodeRepresentationByPerformer[performer]![dmNode] = 1
                    }
                    else { dmNodeRepresentationByPerformer[performer]![dmNode]!++ }
                }
            }
        }
        return dmNodeRepresentationByPerformer
    }
    */
    
    // public for now // private soon
    public func createStems() {
        
        for eventHandler in instrumentEventHandlers {
            
            let stem = eventHandler.makeStemInContext(eventsNode)
            
            let stem_width: CGFloat = 0.0618 * g
            
            // get g from either GraphEvent or BGstratum?
            stem.lineWidth = stem_width
            let hue = HueByTupletDepth[eventHandler.bgEvent!.depth! - 1]
            stem.color = UIColor.colorWithHue(hue, andDepthOfField: .MostForeground).CGColor
            eventHandler.repositionStemInContext(eventsNode)
            stems.append(stem) // addStem()
        }
        
        // deprecate
        /*
        for eventHandler in eventHandlers {
            let stem = eventHandler.makeStemInContext(eventsNode)
            
            // internalize
            var stem_width: CGFloat = 0.0618 * g
            
            // get g from either GraphEvent or BGstratum?
            stem.lineWidth = stem_width
            stem.strokeColor = UIColor.colorWithHue(HueByTupletDepth[
                eventHandler.bgEvent!.depth! - 1
                ],
                andDepthOfField: .MostForeground
            ).CGColor
            eventHandler.repositionStemInContext(eventsNode)
        }
        */
    }
    
    public func setDurationNodesWithDurationNodes(durationNodes: [DurationNode]) {
        self.durationNodes = durationNodes
        // anything else?
    }
    
    func getInfoEndYFromGraphEvent(
        graphEvent: GraphEvent,
        withStemDirection stemDirection: StemDirection
    ) -> CGFloat
    {
        let infoEndY = stemDirection == .Down
            ? convertY(graphEvent.maxInfoY, fromLayer: graphEvent)
            : convertY(graphEvent.minInfoY, fromLayer: graphEvent)
        return infoEndY
    }
    
    func getBeamEndYFromBGStratum(bgStratum: BGStratum) -> CGFloat {
        let beamEndY = bgStratum.stemDirection == .Down
            ? convertY(bgStratum.beamsLayerGroup!.frame.minY, fromLayer: bgStratum)
            : convertY(bgStratum.beamsLayerGroup!.frame.maxY, fromLayer: bgStratum)
        return beamEndY
    }
    
    private func makeDurationNodesByID(durationNodes: [DurationNode]) -> [String : [DurationNode]] {
        var durationNodesByID: [String : [DurationNode]] = [:]
        for durationNode in durationNodes {
            if let id = durationNode.id {
                if durationNodesByID[id] == nil { durationNodesByID[id] = [durationNode] }
                else { durationNodesByID[id]!.append(durationNode) }
            }
        }
        return durationNodesByID
    }
    
    private func addBeamGroupsToBGStratum(bgStratum: BGStratum,
        withDurationNodes durationNodes: [DurationNode]
    )
    {
        var accumLeft: CGFloat = infoStartX
        for durationNode in durationNodes {
            bgStratum.addBeamGroupWithDurationNode(durationNode, atX: accumLeft)
            accumLeft += durationNode.width(beatWidth: beatWidth)
            //accumLeft += graphicalWidth(duration: durationNode.duration, beatWidth: beatWidth)
        }
    }

    // in use: takes in measures that only have model data (duration, offset duration)
    // -- implant graphical info (g, beatWidth, width, etc.)
    // -- then add the graphical components of the measure: barlines, timesig, measure num
    public func setMeasuresWithMeasures(measures: [MeasureView]) {
        self.measures = measures
        var accumLeft: CGFloat = infoStartX
        var accumDur: Duration = DurationZero
        for measure in measures {
            measure.system = self
            setGraphicalAttributesOfMeasure(measure, left: accumLeft)
            handoffTimeSignatureFromMeasure(measure)
            handoffMeasureNumberFromMeasure(measure)
            
            // temp
            //handoffMGRectsFromMeasure(measure)
            
            addBarlinesForMeasure(measure)
            accumLeft += measure.frame.width
            accumDur += measure.dur!
        }
        totalDuration = accumDur
        measureNumberNode?.layout()
        timeSignatureNode?.layout()
    }
    
    override func setWidthWithContents() {
        if measures.count > 0 {
            frame = CGRectMake(frame.minX, frame.minY, measures.last!.frame.maxX, frame.height)
        }
        else {
            frame = CGRectMake(frame.minX, frame.minY, 1000, frame.height)
        }
    }
    
    private func setGraphicalAttributesOfMeasure(measure: MeasureView, left: CGFloat) {
        measure.g = g
        measure.beatWidth = beatWidth
        measure.build()
        measure.moveHorizontallyToX(left, animated: false)
    }
    
    // takes in a graphically built measure, that has been positioned within the system
    private func addBarlinesForMeasure(measure: MeasureView) {
        addBarlineLeftForMeasure(measure)
        if measure === measures.last! { addBarlineRightForMeasure(measure) }
    }
    
    private func addBarlineLeftForMeasure(measure: MeasureView) {
        let barlineLeft = Barline(x: measure.frame.minX, top: 0, bottom: frame.height)
        barlineLeft.lineWidth = 6
        barlineLeft.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Background).CGColor
        barlineLeft.opacity = 0.5
        barlines.append(barlineLeft)
        barlinesLayer.insertSublayer(barlineLeft, atIndex: 0)
    }

    private func addBarlineRightForMeasure(measure: MeasureView) {
        let barlineRight = Barline(x: measure.frame.maxX, top: 0, bottom: frame.height)
        barlineRight.lineWidth = 6
        barlineRight.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Background).CGColor
        barlineRight.opacity = 0.5
        barlines.append(barlineRight)
        barlinesLayer.insertSublayer(barlineRight, atIndex: 0)
    }
    
    private func addMGRectsForMeasure(measure: MeasureView) {
        
    }
    
    public func addMeasureComponentsFromMeasure(measure: MeasureView, atX x: CGFloat) {
        if let timeSignature = measure.timeSignature { addTimeSignature(timeSignature, atX: x) }
        if let measureNumber = measure.measureNumber { addMeasureNumber(measureNumber, atX: x) }

        // barline will become a more complex object -- barline segments, etc
        // add barlineLeft
        let barlineLeft = Barline(x: x, top: 0, bottom: frame.height)
        barlineLeft.lineWidth = 6
        barlineLeft.opacity = 0.236
        barlines.append(barlineLeft)
        insertSublayer(barlineLeft, atIndex: 0)
        
        /*
        // encapsulate
        // add metronome grid rect
        if measure.dur != nil {
        let rect_dur = Duration(1, measure.dur!.subdivision!.value)
        let rect_width = rect_dur.getGraphicalWidth(beatWidth: 120)
        var accumLeft: CGFloat = measure.left
        for r in 0..<measure.dur!.beats!.amount {
        let mgRect = MetronomeGridRect(
        rect: CGRectMake(
        accumLeft, timeSignatureNode!.frame.maxY, rect_width, frame.height
        )
        )
        //insertSublayer(mgRect, atIndex: 0)
        //addSublayer(mgRect)
        mgRects.append(mgRect)
        accumLeft += mgRect.frame.width
        }
        }
        */
    }
    
    // move to TemporalInfoNode
    public func addMeasureNumber(measureNumber: MeasureNumber, atX x: CGFloat) {
        temporalInfoNode.addMeasureNumber(measureNumber, atX: x)
    }
    
    // move to TemporalInfoNode
    public func addTimeSignature(timeSignature: TimeSignature, atX x: CGFloat) {
        temporalInfoNode.addTimeSignature(timeSignature, atX: x)
    }
    
    public func addBGStratum(bgStratum: BGStratum) {
        bgStrata.append(bgStratum)
        
        // hmmmm, check bgStrata instead
        if let id = bgStratum.id { bgStratumByID[id] = bgStratum }
        eventsNode.addNode(bgStratum)
    }
    
    public func addPerformer(performer: Performer) {
        performers.append(performer)
        performerByID[performer.id] = performer
        eventsNode.addNode(performer)
        print("performerByID after: \(performerByID)")
    }
    
    public func addBarline(barline: Barline, atX x: CGFloat) {
        barlines.append(barline)
        barline.x = x
        insertSublayer(barline, atIndex: 0)
    }
    
    public func addMeasure(measure: MeasureView) {
        addMeasureComponentsFromMeasure(measure, atX: measure.frame.minX)
    }
    
    public func addStem(stem: Stem) {
        //eventsNode.insertSublayer(stem, atIndex: 0)
        //stems.append(stem)
    }
    
    private func addStems(stems: [Stem]) {
        for stem in stems { addStem(stem) }
    }
    
    /*
    public func createTMNode() {
        tempoMarkingNode = TMNode(height: 30)
        tempoMarkingNode!.pad_bottom = 5 // HACK
        //tempoMarkingNode!.addSampleTempoMarkingAtX(50)
        insertNode(tempoMarkingNode!, atIndex: 0)
    }
    */
    
    public func build() {
        clearNodes()

        createTemporalInfoNode() // change name of this: // tempo always above?
        createEventsNode()
        createBGStrata()
        createPerformers()
        
        // deprecate
        //createEventHandlers() // NEEDS CLEANING!
        
        createInstrumentEventHandlers()
        
        decorateInstrumentEvents()
        
        // deprecate
        //decorateGraphEvents()
        
        // encapsulate
        
        
        // check out BGStrata.SANode situation
        // encapsulate
        for bgStratum in bgStrata {
            for bgEvent in bgStratum.bgEvents {
                for saType in bgEvent.stemArticulationTypes {
                    //print("STEM ARTICULATION TYPE: \(saType)")
                    if bgStratum.saNodeByType[saType] == nil {
                        //print("bgStratum.saNodeByType: \(saType) == nil: create!")
                        let saNode = SANode(left: 0, top: 0, height: 20)
                        bgStratum.saNodeByType[saType] = saNode
                    }
                    bgStratum.saNodeByType[saType]!.addTremoloAtX(bgEvent.x_inBGStratum!)
                }
            }
            for (_, saNode) in bgStratum.saNodeByType {
                saNode.layout()
                bgStratum.addNode(saNode)
            }
            

        }
        
        manageGraphLines()
        createDMNodes()
        createSlurHandlers()

        for (_, slurHandlers) in slurHandlersByID {
            for slurHandler in slurHandlers {
                if let slur = slurHandler.makeSlurInContext(eventsNode) {
                    eventsNode.addSublayer(slur)
                }
            }
        }

        // encapsulate: set initial componentTypesShownByID
        for (id, componentTypes) in componentTypesByID {
            componentTypesShownByID[id] = componentTypes
        }
        
        hasBeenBuilt = true
    }
    
    
    private func manageGraphLines() {
        for (_, performer) in performerByID {
            for (_, instrument) in performer.instrumentByID {
                for (_, graph) in instrument.graphByID {
                    if measures.count > 0 {
                        graph.stopLinesAtX(measures.last!.frame.maxX)
                    }
                    else { graph.stopLinesAtX(frame.width) }
                    graph.build()
                }
                instrument.layout()
            }
        }
    }
    
    private func decorateInstrumentEvents() {
        print("decorate instrument events: instr e handler amount: \(instrumentEventHandlers.count)")
        
        for instrumentEventHandler in instrumentEventHandlers {
            instrumentEventHandler.decorateInstrumentEvent()
        }
    }
    
    /*
    // deprecate
    private func decorateGraphEvents() {
        for eventHandler in eventHandlers { eventHandler.decorateGraphEvent() }
    }
    */
    
    private func getStemDirectionForPID(pID: String) -> StemDirection {
        return pID == viewerID ? .Up : .Down
    }
    
    private func getGForPID(pID: String) -> CGFloat {
        return pID == viewerID ? self.g : 0.75 * self.g
    }
    
    private func getStemDirectionAndGForPID(pID: String) -> (StemDirection, CGFloat) {
        let s = getStemDirectionForPID(pID)
        let g = getGForPID(pID)
        return (s, g)
    }
    
    private func createInstrumentEventHandlers() {
        
        print("create instrument event handlers")
        
        var instrumentEventHandlers: [InstrumentEventHandler] = []
        
        func addInstrumentEventHandlerWithBGEvent(bgEvent: BGEvent?,
            andInstrumentEvent instrumentEvent: InstrumentEvent?
        )
        {
            let instrumentEventHandler = InstrumentEventHandler(
                bgEvent: bgEvent,
                instrumentEvent: instrumentEvent,
                system: self
            )
            instrumentEventHandlers.append(instrumentEventHandler)
        }
        
        for bgStratum in bgStrata {
            for bgEvent in bgStratum.bgEvents {
                let durationNode = bgEvent.durationNode
                
                if durationNode.hasOnlyExtensionComponents || durationNode.components.count == 0 {
                    addInstrumentEventHandlerWithBGEvent(bgEvent, andInstrumentEvent: nil)
                    continue
                }
                
                //var instrumentEvent: InstrumentEvent?
                for component in bgEvent.durationNode.components {
                    
                    print("create instrument event handlers: component: \(component)")
                    
                    var instrumentEventHandlerSuccessfullyCreated: Bool = false
                    let pID = component.pID, iID = component.iID
                    let x: CGFloat = bgEvent.x_objective!
                    if let performer = performerByID[pID],
                        instrument = performer.instrumentByID[iID]
                    {
                        let (stemDirection, g) = getStemDirectionAndGForPID(pID)
                        if component.isGraphBearing {

                            instrument.createGraphsWithComponent(component, andG: g)
                            if let instrumentEvent = instrument.createInstrumentEventWithComponent(
                                component,
                                atX: x,
                                withStemDirection: stemDirection
                            )
                            {
                                addInstrumentEventHandlerWithBGEvent(bgEvent,
                                    andInstrumentEvent: instrumentEvent
                                )
                                // this whole thing is prolly unnecessary
                                instrumentEventHandlerSuccessfullyCreated = true
                            }
                        }
                    }
                    else { fatalError("Unable to find Performer or Instrument") }
                    
                    if !instrumentEventHandlerSuccessfullyCreated {
                        print("instrument event unsuccessfully created!")
                    }
                }
            }
        }
        self.instrumentEventHandlers = instrumentEventHandlers
    }
    
    public func createSlurHandlers() {
        
        func addSlurHandler(slurHandler: SlurHandler) {
            slurHandler.g = slurHandler.id == viewerID ? g : 0.618 * g
            if slurHandlersByID[slurHandler.id] == nil {
                slurHandlersByID[slurHandler.id] = [slurHandler]
            }
            else { slurHandlersByID[slurHandler.id]!.append(slurHandler) }
        }
        
        func getLastIncompleteSlurHandlerWithID(id: String) -> SlurHandler? {
            var lastIncomplete: SlurHandler?
            if let slurHandlersWithID = slurHandlersByID[id] {
                for slurHandler in slurHandlersWithID {
                    if slurHandler.graphEvent1 == nil {
                        lastIncomplete = slurHandler
                        break
                    }
                }
            }
            return lastIncomplete
        }
        
        for eventHandler in instrumentEventHandlers {
            if let instrumentEvent = eventHandler.instrumentEvent, bgEvent = eventHandler.bgEvent {
                for graphEvent in instrumentEvent.graphEvents {
                    for component in bgEvent.durationNode.components {
                        if let componentSlurStart = component as? ComponentSlurStart {
                            let id = componentSlurStart.id
                            let slurHandler = SlurHandler(id: id, graphEvent0: graphEvent)
                            addSlurHandler(slurHandler)
                        }
                        else if let componentSlurStop = component as? ComponentSlurStop {
                            let id = componentSlurStop.id
                            
                            if let lastIncomplete = getLastIncompleteSlurHandlerWithID(id) {
                                lastIncomplete.graphEvent1 = graphEvent
                            }
                            else {
                                let slurHandler = SlurHandler(id: id, graphEvent1: graphEvent)
                                addSlurHandler(slurHandler)
                            }
                        }
                    }
                }
            }
        }
        
        for (id, _) in slurHandlersByID {
            if componentTypesByID[id] == nil { componentTypesByID[id] = [] }
            componentTypesByID[id]!.append("slurs")
        }
    }
    
    private func createPerformers() {
        performerByID = makePerformerByIDWithBGStrata(bgStrata) // clean
    }
    
    private func createBGStrata() {
        
        // REFACTOR THIS TO BGStrataManager()
        
        func getPIDsFromStratum(stratum: [DurationNode]) -> [String] {
            var pids: [String] = []
            for dn in stratum { pids += getPIDsFromDurationNode(dn) }
            return pids
        }
        
        func getPIDsFromDurationNode(durationNode: DurationNode) -> [String] {
            var pids: [String] = []
            for (pid, _) in durationNode.iIDsByPID { pids.append(pid) }
            return pids
        }
        
        func stratum(stratum: [DurationNode],
            overlapsWithStratum otherStratum: [DurationNode]
        ) -> Bool
        {
            var overlaps: Bool = false
            for dn0 in stratum {
                for dn1 in otherStratum {
                    let relationship = dn0.durationSpan.relationShipWithDurationSpan(
                        dn1.durationSpan
                    )
                    if relationship == .Overlapping { overlaps = true }
                }
            }
            return overlaps
        }
        
        func getStratumClumps() -> [[DurationNode]] {
            // First pass: get initial stratum clumps
            var stratumClumps: [[DurationNode]] = []
            durationNodeLoop: for durationNode in durationNodes {

                var relationships: [DurationSpanRelationship] = []
                // Create initial stratum if none yet
                if stratumClumps.count == 0 {
                    stratumClumps = [[durationNode]]
                    continue durationNodeLoop
                }
                // Find if we can clump the remaining durationNodes onto a stratum
                var matchFound: Bool = false
                stratumLoop: for s in 0..<stratumClumps.count {
                    let stratum_durationSpan = makeDurationSpanWithDurationNodes(stratumClumps[s])
                    let relationship = stratum_durationSpan.relationShipWithDurationSpan(
                        durationNode.durationSpan
                    )
                    relationships.append(relationship)
                    switch relationship {
                    case .Adjacent:
                        var stratum = stratumClumps[s]
                        let stratum_pids = getPIDsFromStratum(stratum)
                        let dn_pids = getPIDsFromDurationNode(durationNode)
                        for pid in dn_pids {
                            if stratum_pids.contains(pid) {
                                stratumClumps.removeAtIndex(s)
                                stratum.append(durationNode)
                                stratumClumps.insert(stratum, atIndex: s)
                                matchFound = true
                                break stratumLoop
                            }
                        }
                    default: break
                    }
                }
                if !matchFound { stratumClumps.append([durationNode]) }
            }
            return stratumClumps
        }
        
        func makeStrataWithDisparateStratumClumps(var stratumClumps: [[DurationNode]])
            -> [[DurationNode]]
        {
            var s_index0: Int = 0
            while s_index0 < stratumClumps.count {
                var s_index1: Int = 0
                while s_index1 < stratumClumps.count {
                    let s0 = stratumClumps[s_index0]
                    let s1 = stratumClumps[s_index1]
                    if !stratum(s0, overlapsWithStratum: s1) {
                        let s0_pids: [String] = getPIDsFromStratum(s0).unique()
                        let s1_pids: [String] = getPIDsFromStratum(s1).unique()
                        if s0_pids == s1_pids {
                            let concatenated = s0 + s1
                            stratumClumps.removeAtIndex(s_index0)
                            stratumClumps.removeAtIndex(s_index1 - 1) // compensate for above
                            stratumClumps.insert(concatenated, atIndex: 0)
                            s_index0 = 0
                            s_index1 = 0
                        }
                        else { s_index1++ } // how do i clump these together?
                    }
                    else { s_index1++ } // see above!
                }
                s_index0++
            }
            return stratumClumps
        }
        
        func makeBGStrataFromDurationNodeStrata(durationNodeStrata: [[DurationNode]]) -> [BGStratum] {
            var bgStrata: [BGStratum] = []
            for stratum_model in durationNodeStrata {
                assert(stratum_model.count > 0, "must have more than one durationNode in strata")
                
                let pIDs = getPIDsFromStratum(stratum_model)
                
                // DEPRECATE!!!!
                // TEMP -----------------------------------------------------------------------
                let firstValue = pIDs.first!
                var onlyOnePID: Bool {
                    for pID in pIDs { if pID != firstValue { return false } }
                    return true
                }
                // TEMP -----------------------------------------------------------------------
                
                var stemDirection: StemDirection = .Down
                var bgStratum_g: CGFloat = g
                if onlyOnePID {
                    let (s, g) = getStemDirectionAndGForPID(firstValue)
                    stemDirection = s
                    bgStratum_g = g
                }
                
                let bgStratum = BGStratum(stemDirection: stemDirection, g: bgStratum_g)
                bgStratum.system = self
                bgStratum.beatWidth = beatWidth
                bgStratum.pad_bottom = 0.5 * g
                for durationNode in stratum_model {
                    let offset_fromSystem = durationNode.durationSpan.startDuration - offsetDuration
                    let x = infoStartX + offset_fromSystem.width(beatWidth: beatWidth)
                    bgStratum.addBeamGroupWithDurationNode(durationNode, atX: x)
                }
                if !bgStratum.hasBeenBuilt { bgStratum.build() }
                bgStrata.append(bgStratum)
            }
            return bgStrata
        }
        
        let stratumClumps = getStratumClumps()
        let strata_model = makeStrataWithDisparateStratumClumps(stratumClumps)
        let bgStrata = makeBGStrataFromDurationNodeStrata(strata_model)
        
        
        // encapsulate: set initial bgStratum "rhythm" by id
        for bgStratum in bgStrata {
            
            // HACK for now
            if bgStratum.iIDsByPID.count == 1 {
                let id = bgStratum.iIDsByPID.first!.0
                if bgStrataByID[id] == nil { bgStrataByID[id] = [bgStratum] }
                else { bgStrataByID[id]!.append(bgStratum) }
            }
        }
        addRhythmComponentTypesForBGStrata(bgStrata)
        self.bgStrata = bgStrata
    }
    
    private func addRhythmComponentTypesForBGStrata(bgStrata: [BGStratum]) {
        for bgStratum in bgStrata {
            for (pID, _) in bgStratum.iIDsByPID { addComponentType("rhythm", withID: pID) }
        }
    }
    
    private func createTemporalInfoNode() {
        temporalInfoNode.pad_bottom = 0.1236 * temporalInfoNode.frame.height
        temporalInfoNode.layout()
        addNode(temporalInfoNode)
    }
    
    private func createEventsNode() {
        addNode(eventsNode)
        eventsNode.insertSublayer(barlinesLayer, atIndex: 0)
    }
    
    public func addComponentType(type: String, withID id: String) {
        if componentTypesByID[id] == nil {
            componentTypesByID[id] = [type]
        }
        else {
            if componentTypesByID[id]!.count == 0 { componentTypesByID[id] = [type] }
            else {
                if !componentTypesByID[id]!.contains(type) {
                    componentTypesByID[id]!.append(type)
                }
            }
        }
    }
    
    // ENCAPSULATE WITH DMNodeFactory()
    private func createDMNodes() {
        
        struct DMComponentContext {
            var eventHandler: InstrumentEventHandler
            var componentDynamic: ComponentDynamic?
            var componentDMLigatures: [ComponentDMLigature] = []
            
            init(eventHandler: InstrumentEventHandler) {
                self.eventHandler = eventHandler
            }
        }
        
        struct DMComponentContextDyad {
            var dmComponentContext0: DMComponentContext?
            var dmComponentContext1: DMComponentContext?
            
            init(
                dmComponentContext0: DMComponentContext? = nil,
                dmComponentContext1: DMComponentContext? = nil
            )
            {
                self.dmComponentContext0 = dmComponentContext0
                self.dmComponentContext1 = dmComponentContext1
            }
        }
        
        func directionFromType(type: Float) -> DMLigatureDirection {
            return type == 0 ? .Static : type < 0 ? .Decrescendo : .Crescendo
        }
        
        // ---------------------------------------------------------------------------------
        // make DMNodes
        //var dmComponents: [ComponentDynamic] = []
        
        var dmNodeByID: [String : DMNode] = [:]
        
        //var dmsWithLigatureTypes: [(ComponentDynamic?, ComponentDMLigature?)] = []
        
        //var dmComponentContexts: [DMComponentContext] = []
        
        
        // deal with DYNAMIC MARKINGS
        for eventHandler in instrumentEventHandlers {
            
            // encapsulate in EVENT HANDLER?
            if eventHandler.bgEvent == nil || eventHandler.instrumentEvent == nil { continue
            }
            
            // create dmComponentContext
            var dmComponentContext = DMComponentContext(eventHandler: eventHandler)
            for component in eventHandler.bgEvent!.durationNode.components {
                if let componentDMLigature = component as? ComponentDMLigature {
                    dmComponentContext.componentDMLigatures.append(componentDMLigature)
                }
                else if let componentDynamic = component as? ComponentDynamic {
                    dmComponentContext.componentDynamic = componentDynamic
                }
            }
            
            // Create DynamicMarkings, ensuring DMNodes (no ligature consideration yet)
            if dmComponentContext.componentDynamic != nil {
                let x = eventHandler.bgEvent!.x_objective!
                let id = dmComponentContext.componentDynamic!.id // unsafe
                
                var dmNode_height: CGFloat = 2.5 * g
                
                // HACK, terrible, awful hack
                if let bgContainer = eventHandler.bgEvent!.bgContainer {
                    dmNode_height = 2.5 * bgContainer.g
                }
                
                // ensure dmNodeByID
                if dmNodeByID[id] == nil {
                    dmNodeByID[id] = DMNode(height: dmNode_height)
                    dmNodeByID[id]!.pad_bottom = 0.5 * dmNode_height
                } // hack
                
                switch dmComponentContext.componentDynamic!.property {
                case .Dynamic(let marking):
                    dmNodeByID[id]!.addDynamicMarkingsWithString(marking, atX: x)
                default: break
                }
            }
            
            // Create DMLigatures only if they are not frayed
            if dmComponentContext.componentDMLigatures.count > 0 {
                let x = eventHandler.bgEvent!.x_objective!
                
                // if there is a DynamicMarking
                if let componentDynamic = dmComponentContext.componentDynamic {
                    let id = componentDynamic.id
                    var start_intValue: Int?
                    var stop_intValue: Int?
                    let start_x: CGFloat!
                    let stop_x: CGFloat!
                    if let dynamicMarking = dmNodeByID[id]!.getDynamicMarkingAtX(x) {
                        let pad = 0.236 * dynamicMarking.height // kerning, etc: refine!
                        stop_x = dynamicMarking.frame.minX - pad
                        start_x = dynamicMarking.frame.maxX + pad
                        start_intValue = dynamicMarking.finalIntValue
                        stop_intValue = dynamicMarking.initialIntValue
                    }
                    else {
                        start_x = x
                        stop_x = x
                    }
                    
                    for componentDMLigature in dmComponentContext.componentDMLigatures {
                        switch componentDMLigature.property {
                        case .DMLigatureStart:
                            if let start_intValue = start_intValue {
                                dmNodeByID[id]!.startLigatureAtX(start_x,
                                    withDynamicMarkingIntValue: start_intValue
                                )
                            }
                        case .DMLigatureStop:
                            if let stop_intValue = stop_intValue {
                                dmNodeByID[id]!.stopCurrentLigatureAtX(stop_x,
                                    withDynamicMarkingIntValue: stop_intValue
                                )
                            }
                        default: break
                        }
                    }
                }
            }
        }

        // eek temporary // be explicit about local / semi-global declarations
        self.dmNodeByID = dmNodeByID
        
        // build DMNodes
        for (id, dmNode) in dmNodeByID {
            addComponentType("dynamics", withID: id)
            dmNode.build()
        }
    }
    
    
    
    /*
    private func handoffMGRectsFromMeasure(measure: MeasureView) {
        // hand off mg rects
        var accumLeft: CGFloat = measure.frame.minX
        for mgRect in measure.mgRects {
            mgRect.position.x = accumLeft + 0.5 * mgRect.frame.width
            mgRects.append(mgRect)
            addSublayer(mgRect)
            accumLeft += mgRect.frame.width
        }
    }
    */
    
    private func handoffTimeSignatureFromMeasure(measure: MeasureView) {
        if let timeSignature = measure.timeSignature {
            addTimeSignature(timeSignature, atX: measure.frame.minX)
        }
    }
    
    private func handoffMeasureNumberFromMeasure(measure: MeasureView) {
        if measure.measureNumber != nil {
            addMeasureNumber(measure.measureNumber!, atX: measure.frame.minX)
        }
    }
    
    public override func layout() {

        super.layout()
        
        // hack
        eventsNode.frame = CGRectMake(
            eventsNode.frame.minX,
            eventsNode.frame.minY,
            self.frame.width,
            eventsNode.frame.height
        )
        
        adjustLigatures()
    }
    
    private func adjustLigatures() {
        adjustStems()
        adjustSlurs()
        adjustBarlines()
        
        // adjustPerformerBrackets()
        // adjustMetronomeGridRects()
    }
    
    private func adjustSlurs() {
        for (_, slurHandlers) in slurHandlersByID {
            
            // this works, but jesus...clean up
            for slurHandler in slurHandlers {
                if let graphEvent0 = slurHandler.graphEvent0, graphEvent1 = slurHandler.graphEvent1 {
                    if let graph0 = graphEvent0.graph, graph1 = graphEvent1.graph {
                        if let instrument0 = graph0.instrument, instrument1 = graph1.instrument {
                            if let performer0 = instrument0.performer, performer1 = instrument1.performer {
                                if eventsNode.hasNode(performer0) && eventsNode.hasNode(performer1) && performer0.hasNode(instrument0) && performer1.hasNode(instrument1) && instrument0.hasNode(graph0) && instrument1.hasNode(graph1)
                                {
                                    if let slur = slurHandler.slur where slur.superlayer == nil {
                                        eventsNode.addSublayer(slur)
                                    }
                                }
                                else if let slur = slurHandler.slur where slur.superlayer != nil {
                                    slur.removeFromSuperlayer()
                                }
                            }
                        }
                    }
                }
                slurHandler.repositionInContext(eventsNode)
            }
        }
    }
    
    /*
    // TODO: reimplement when the time is right
    private func adjustMetronomeGridRects() {
        for mgRect in mgRects {
            let f = mgRect.frame
            let h = frame.height - timeSignatureNode!.frame.maxY
            mgRect.frame = CGRectMake(f.minX, timeSignatureNode!.frame.maxY, f.width, h)
            mgRect.path = mgRect.makePath()
        }
    }
    */
    
    private func getMinPerformersTop() -> CGFloat? {
        if performers.count == 0 { return 0 }
        var minY: CGFloat?
        for performer in performers {
            if !eventsNode.hasNode(performer) { continue }
            if let minInstrumentsTop = performer.minInstrumentsTop {
                let performerTop = eventsNode.convertY(minInstrumentsTop, fromLayer: performer)
                if minY == nil { minY = performerTop }
                else if performerTop < minY! { minY = performerTop }
            }
        }
        return minY
    }
    
    private func getMaxPerformersBottom() -> CGFloat? {
        var maxY: CGFloat?
        for performer in performers {
            if !eventsNode.hasNode(performer) { continue }
            if let maxInstrumentsBottom = performer.maxInstrumentsBottom {
                let performerBottom = eventsNode.convertY(maxInstrumentsBottom,
                    fromLayer: performer
                )
                if maxY == nil { maxY = performerBottom }
                else if performerBottom > maxY! { maxY = performerBottom }
            }
        }
        return maxY
    }
    
    private func adjustBarlines() {
        for barline in barlines {
            if let minPerformersTop = minPerformersTop, maxPerformersBottom = maxPerformersBottom {
                barline.setTop(minPerformersTop, andBottom: maxPerformersBottom)
            }
        }
    }
    
    private func adjustStems() {
        for eventHandler in instrumentEventHandlers {
            eventHandler.repositionStemInContext(eventsNode)
        }
    }
    
    private func getInfoEndYForGraphEvent(graphEvent: GraphEvent) -> CGFloat {
        return 0
    }
    
    private func getBeamEndYForBGEvent(bgEvent: BGEvent) -> CGFloat {
        return 0
    }
    
    // refine, move down
    private func getDurationSpan() -> DurationSpan {
        if measures.count == 0 { return DurationSpan() }
        let durationSpan = DurationSpan(duration: totalDuration, startDuration: offsetDuration)
        return durationSpan
    }
    
    private func getGraphEvents() -> [GraphEvent] {
        var graphEvents: [GraphEvent] = []
        for performer in performers where eventsNode.hasNode(performer) {
            for instrument in performer.instruments where performer.hasNode(instrument) {
                for graph in instrument.graphs where instrument.hasNode(graph) {
                    for event in graph.events { graphEvents.append(event) }
                }
            }
        }
        return graphEvents.sort {$0.x < $1.x }
    }
    
    private func getInstrumentTypeAndIIDByPID() -> [String : [String : InstrumentType]] {
        var instrumentTypeByIIDByPID: [String : [String : InstrumentType]] = [:]
        for dict in iIDsAndInstrumentTypesByPID {
            for (pID, arrayOfIIDsAndInstruments) in dict {
                for tuple in arrayOfIIDsAndInstruments {
                    let iID = tuple.0
                    let instrumentType = tuple.1
                    if instrumentTypeByIIDByPID[pID] == nil {
                        instrumentTypeByIIDByPID[pID] = [iID : instrumentType]
                    }
                    else { instrumentTypeByIIDByPID[pID]![iID] = instrumentType }
                }
            }
        }
        return instrumentTypeByIIDByPID
    }
    
    // ----------------------------------------------------------------------------------------- //
    
    private func getDescription() -> String {
        return "System: totalDuration: \(totalDuration), offsetDuration: \(offsetDuration)"
    }
    
    /*
    override public func hitTest(p: CGPoint) -> CALayer? {
        if containsPoint(p) { return self }
        return nil
    }
    
    override public func containsPoint(p: CGPoint) -> Bool {
        if frame.contains(p) { return true }
        return false
    }
    */
}