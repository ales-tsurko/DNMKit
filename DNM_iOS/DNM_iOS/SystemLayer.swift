//
//  SystemLayer.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// THIS IS BEING REFACTORED INTO SYSTEMVIEW (UIVIEW): 2015-11-30

/// A Musical SystemLayer (container of a single line's worth of music)
public class SystemLayer: ViewNode, BuildPattern, DurationSpanning {
    
    // DESTROY --------------------------------------------------------------------------------
    public var rhythmCueGraphByID: [String : RhythmCueGraph] = [:]
    // DESTROY --------------------------------------------------------------------------------
    
    /// String representation of SystemLayer
    public override var description: String { get { return getDescription() } }
    
    public var viewerID: String?
    
    /// PageLayer containing this SystemLayer
    public var page: PageLayer?
    
    public var system: System!
    
    /// If this SystemLayer has been built yet
    public var hasBeenBuilt: Bool = false
    
    /// All GraphEvents contained within this SystemLayer
    public var graphEvents: [GraphEvent] { return getGraphEvents() }
    
    /**
    Collection of InstrumentIDsWithInstrumentType, organized by PerformerID.
    These values ensure PerformerView order and InstrumentView order,
    while making it still possible to call for this information by key identifiers.
    */
    public var instrumentIDsAndInstrumentTypesByPerformerID = OrderedDictionary<
        String, OrderedDictionary<String, InstrumentType>
    >()

    /** 
    All component types (as `String`) by ID.
    Currently, this is a PerformerID, however, 
    this is to be extended to be more generalized at flexibility increases with identifiers.
    Examples of these component types are: "dynamics", "articulations", "pitch", etc..
    */
    public var componentTypesByID: [String : [String]] = [:]
    
    /// Component types currently displayed
    public var componentTypesShownByID: [String : [String]] = [:]
    
    /// Identifiers organizaed by component type (as `String`)
    private var idsByComponentType: [String : [String]] = [:]
    
    /// Identifiers that are currently showing a given component type (as `String`)
    private var idsShownByComponentType: [String : [String]] = [:]
    
    /// Identifiers that are currently not showing a given component type (as `String`)
    private var idsHiddenByComponentType: [String : [String]] = [:]
    
    /// DynamicMarkingNodes organized by identifier `String`
    public var dmNodeByID: [String : DMNode] = [:]
    
    /// All Performers in this SystemLayer.
    public var performers: [PerformerView] = []
    
    /// Performers organized by identifier `String` -- MAKE ORDERED DICTIONARY
    public var performerByID: [String: PerformerView] = [:]
    
    /// SlurHandlers organizaed by identifier `String`
    public var slurHandlersByID: [String : [SlurHandler]] = [:]

    /// All InstrumentEventHandlers in this SystemLayer
    public var instrumentEventHandlers: [InstrumentEventHandler] = []
    
    /** TemporalInfoNode of this SystemLayer. Contains:
        - TimeSignatureNode
        - MeasureNumberNode
        - TempoMarkingsNode
    */
    public var temporalInfoNode = TemporalInfoNode(height: 75)
    
    /** 
    EventsNode of SystemLayer. Stacked after the `temporalInfoNode`.
    Contains all non-temporal musical information (`Performers`, `BGStrata`, `DMNodes`, etc).
    */
    public var eventsNode = ViewNode(accumulateVerticallyFrom: .Top)
    
    /// Layer for Barlines. First (most background) layer of EventsNode
    private let barlinesLayer = CALayer()
    
    /// All Measures (model) contained in this SystemLayer
    public var measures: [Measure] = [] { didSet { setMeasuresWithMeasures(measures) } }
    
    /// All MeasureViews contained in this SystemLayer
    public var measureViews: [MeasureView] = []
    
    /// All DurationNodes contained in this SystemLayer
    public var durationNodes: [DurationNode] = []

    /// Graphical height of a single Guidonian staff space
    public var g: CGFloat = 0
    
    /// Graphical width of a single 8th-note
    public var beatWidth: CGFloat = 0
    
    /// Horiztonal starting point of musical information
    public var infoStartX: CGFloat = 50
    
    /// Duration that the beginning of this SystemLayer is offset from the beginning of the piece.
    public var offsetDuration: Duration = DurationZero
    
    /// The Duration of this SystemLayer
    public var totalDuration: Duration = DurationZero
    
    // make a better interface for this
    public var durationInterval: DurationInterval { return system.durationInterval }
    
    /* = DurationIntervalZero {
        return DurationInterval(duration: totalDuration, startDuration: offsetDuration)
    }*/
    
    /// DurationSpan of SystemLayer
    //public var durationSpan: DurationSpan { get { return DurationSpan() } }
    
    /// SystemLayer following this SystemLayer on the PageLayer containing this SystemLayer. May be `nil`.
    public var nextSystem: SystemLayer? { get { return getNextSystem() } }
   
    /// SystemLayer preceeding this SystemLayer on the PageLayer containing this SystemLayer. May be `nil`.
    public var previousSystem: SystemLayer? { get { return getPreviousSystem() } }
    
    /**
    All BGStrata organized by identifier `String`.
    This is a temporary implementation that assumes that there is only one PerformerID
    per BGStrata (and therefore BGStratum, and therefore BGEvent, etc.).
    */
    public var bgStrataByID: [String : [BGStratum]] = [:]
    
    /// All BGStrata in this SystemLayer
    public var bgStrata: [BGStratum] = []
    
    /// All Stems in this SystemLayer
    public var stems: [Stem] = []

    /// All Barlines in this SystemLayer
    private var barlines: [Barline] = []
    
    /**
    Minimum vertical value for PerformerView, for the purposes of Barline placement.
    This is the highest graphTop contained within the
    PerformerView -> InstrumentView -> Graph hierarchy.
    */
    public var minPerformersTop: CGFloat? { get { return getMinPerformersTop() } }
    
    /**
    Maximum vertical value for PerformerView, for the purposes of Barline placement.
    This is the lowest graphBottom contained within the
    PerformerView -> InstrumentView -> Graph hierarchy.
    */
    public var maxPerformersBottom: CGFloat? { get { return getMaxPerformersBottom() } }
    
    /**
    Get an array of Systems, starting at a given index, and not exceeding a given maximumHeight.
    
    TODO: throws in the case of single System too large
    
    - parameter systems:       The entire reservoir of Systems from which to choose
    - parameter index:         Index of first SystemLayer in the output range
    - parameter maximumHeight: Height which is not to be exceeded by range of Systems
    
    - returns: Array of Systems fulfilling these requirements
    */
    public class func rangeFromSystemLayers(
        systems: [SystemLayer],
        startingAtIndex index: Int,
        constrainedByMaximumTotalHeight maximumHeight: CGFloat
    ) throws -> [SystemLayer]
    {
        enum SystemRangeError: ErrorType { case Error }
        
        var systemRange: [SystemLayer] = []
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
        if systemRange.count == 0 { throw SystemRangeError.Error }
        return systemRange
    }
    
    // TODO
    public init(system: System, g: CGFloat, beatWidth: CGFloat, viewerID: String? = nil) {
        self.system = system
        
        // perhaps not necessary -- just reference self.system
        self.instrumentIDsAndInstrumentTypesByPerformerID = system.scoreModel.instrumentIDsAndInstrumentTypesByPerformerID
        self.durationNodes = system.scoreModel.durationNodes

        self.g = g
        self.beatWidth = beatWidth
        self.viewerID = viewerID
        super.init(accumulateVerticallyFrom: .Top)
        setsWidthWithContents = true
        pad_bottom = 2 * g
        
        self.setMeasuresWithMeasures(system.scoreModel.measures)
    }
    
    /**
    Create a SystemLayer.
    
    - parameter coder: NSCoder
    
    - returns: SystemLayer
    */
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /**
    Create a SystemLayer
    
    - parameter layer: AnyObject
    
    - returns: SystemLayer
    */
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    // TODO: documentation
    public func getDurationAtX(x: CGFloat) -> Duration {
        if x <= infoStartX { return DurationZero }
        let infoX = round(((x - infoStartX) / beatWidth) * 16) / 16
        let floatValue = Float(infoX)
        let duration = Duration(floatValue: floatValue) + offsetDuration
        return duration
    }
    
    /**
    Add a MeasureNumber to this SystemLayer
    
    - parameter measureNumber: MeasureNumber to be added
    - parameter x:             Horizontal placement of MeasureNumber
    */
    public func addMeasureNumber(measureNumber: MeasureNumber, atX x: CGFloat) {
        temporalInfoNode.addMeasureNumber(measureNumber, atX: x)
    }
    
    /**
    Add a TimeSignature to this SystemLayer
    
    - parameter timeSignature: TimeSignature to be added
    - parameter x:             Horizontal placement of TimeSignature
    */
    public func addTimeSignature(timeSignature: TimeSignature, atX x: CGFloat) {
        temporalInfoNode.addTimeSignature(timeSignature, atX: x)
    }
    
    /**
    Add a BeamGroupStratum to this SystemLayer
    
    - parameter bgStratum: BeamGroupStratum
    */
    public func addBGStratum(bgStratum: BGStratum) {
        bgStrata.append(bgStratum)
        eventsNode.addNode(bgStratum)
    }
    
    /**
    Add a PerformerView to this SystemLayer
    
    - parameter performer: PerformerView to be added
    */
    public func addPerformer(performer: PerformerView) {
        performers.append(performer)
        performerByID[performer.id] = performer
        eventsNode.addNode(performer)
    }
    

    public func addMeasure(measure: MeasureView) {
        addMeasureComponentsFromMeasure(measure, atX: measure.frame.minX)
    }

    /**
    Add a TempoMarking
    
    - parameter value:            Beats-per-minute value of Tempo
    - parameter subdivisionLevel: SubdivisionLevel (1: 1/16th note, etc)
    - parameter x:                Horizontal placement of TempoMarking
    */
    public func addTempoMarkingWithValue(value: Int,
        andSubdivisionValue subdivisionValue: Int, atX x: CGFloat
    )
    {
        temporalInfoNode.addTempoMarkingWithValue(value,
            andSubdivisionValue: subdivisionValue, atX: x
        )
    }
    
    /**
    Add a RehearsalMarking
    
    - parameter index: Index of the RehearsalMarking
    - parameter type:  RehearsalMarkingType (.Alphabetical, .Numerical)
    - parameter x:     Horizonatal placement of RehearsalMarking
    */
    public func addRehearsalMarkingWithIndex(index: Int,
        type: RehearsalMarkingType, atX x: CGFloat
    ) {
        temporalInfoNode.addRehearsalMarkingWithIndex(index, type: type, atX: x)
    }
    
    /**
    Set MeasureViews with MeasureViews. Manages the handing-off of Measure-related
    graphical components (Barlines, TimeSignatures, MeasureNumbers)
    
    - parameter measures: All MeasureViews in this SystemLayer
    */
    public func setMeasuresWithMeasures(measures: [Measure]) {

        // create MeasureViews with Measures
        self.measureViews = makeMeasureViewsWithMeasures(measures) // ivar necessary?
        
        // don't set
        var accumLeft: CGFloat = infoStartX
        var accumDur: Duration = DurationZero
        for measureView in measureViews {
            measureView.system = self
            setGraphicalAttributesOfMeasureView(measureView, left: accumLeft)
            handoffTimeSignatureFromMeasureView(measureView)
            handoffMeasureNumberFromMeasureView(measureView)
            addBarlinesForMeasureView(measureView)
            accumLeft += measureView.frame.width
            accumDur += measureView.dur!
        }
        totalDuration = accumDur
    }

    private func makeMeasureViewsWithMeasures(measures: [Measure]) -> [MeasureView] {
        let measureViews: [MeasureView] = measures.map { MeasureView(measure: $0) }
        return measureViews
    }
    
    /**
    Add component types (as `String`) with an identifier.
    
    - parameter type: Component type (as `String`). E.g., "dynamics", "articulations", etc.
    - parameter id:   Identifier by which this component type shall be organized
    */
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
    
    /**
    Create Stems.
    This is currently `public`, as the SystemLayer `build()` process is fragmented externally.
    As the SystemLayer `build()` process becomes clearer, this shall be made `private`,
    and called only within the SystemLayer itself.
    */
    public func createStems() {
        
        for eventHandler in instrumentEventHandlers {
            let stem = eventHandler.makeStemInContext(eventsNode)
            let stem_width: CGFloat = 0.0618 * g
            stem.lineWidth = stem_width
            let hue = HueByTupletDepth[eventHandler.bgEvent!.depth! - 1]
            stem.color = UIColor.colorWithHue(hue, andDepthOfField: .MostForeground).CGColor
            eventHandler.repositionStemInContext(eventsNode)
            stems.append(stem) // addStem()
        }
    }
    
    
    // Encapsulate into own Class
    /**
    Arrange all ViewNodes contained within this SystemLayer to show only those selected.
    */
    public func arrangeNodesWithComponentTypesPresent() {
        
        print("arrangeNodesWithComponentTypesPresent: viewerID: \(viewerID); componentTypesShownByID: \(componentTypesShownByID)")
        
        organizeIDsByComponentType()
        
        func addPerformersShown() {
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
                                        
                                        /*
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
                                        */
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

            let sortedPIDs = instrumentIDsAndInstrumentTypesByPerformerID.map { $0.0 }

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
    
    /**
    Layout this SystemLayer. Calls `ViewNode.layout()`, then adjusts Ligatures.
    */
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
    
    private func organizeIDsByComponentType() {
        addPerfomerComponentTypeToComponentTypesByID()
        createIDsByComponentType()
        createIDsShownByComponentType()
        createIDsHiddenByComponentType()
    }
    
    
    private func addPerfomerComponentTypeToComponentTypesByID() {
        for (id, componentTypes) in componentTypesByID {
            if !componentTypes.contains("performer") {
                componentTypesByID[id]!.append("performer")
            }
        }
    }
    
    // user .filter { }
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

    // use .filter { }
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
    
    // TODO: now with OrderedDictionary
    private func makePerformerByIDWithBGStrata(bgStrata: [BGStratum]) -> [String : PerformerView] {
        var performerByID: [String : PerformerView] = [:]
        for bgStratum in bgStrata {
            for (performerID, instrumentIDs) in bgStratum.iIDsByPID {
                
                var instrumentTypeByInstrumentID = OrderedDictionary<String, InstrumentType>()
                
                for instrumentID in instrumentIDs {
                    if let instrumentType = instrumentIDsAndInstrumentTypesByPerformerID[performerID]?[instrumentID]
                    {
                        instrumentTypeByInstrumentID[instrumentID] = instrumentType
                    }
                }
                
                /*
                var idsAndInstrumentTypes: [(String, InstrumentType)] = []
                for iID in instrumentIDs {
                    if let instrumentType = instrumentTypeByIIDByPID[pID]?[iID] {
                        idsAndInstrumentTypes.append((iID, instrumentType))
                    }
                }
                */
                
                if let performer = performerByID[performerID] {
                    performer.addInstrumentsWithInsturmentTypeByInstrumentID(
                        instrumentTypeByInstrumentID
                    )
                }
                else {
                    let performer = PerformerView(id: performerID)
                    performer.addInstrumentsWithInsturmentTypeByInstrumentID(
                        instrumentTypeByInstrumentID
                    )
                    performer.pad_bottom = g // HACK
                    performerByID[performerID] = performer
                    performers.append(performer)
                    eventsNode.addNode(performer)
                }
                
                /*
                if let performer = performerByID[performerID] {
                    performer.addInstrumentsWithIDsAndInstrumentTypes(idsAndInstrumentTypes)
                }
                else {
                    let performer = PerformerView(id: performerID)
                    performer.addInstrumentsWithIDsAndInstrumentTypes(idsAndInstrumentTypes)
                    performer.pad_bottom = g // HACK
                    performerByID[performerID] = performer
                    performers.append(performer)
                    eventsNode.addNode(performer)
                }
                */
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
    private func getBGStratumRepresentationByPerformer() -> [PerformerView : [BGStratum : Int]] {
        var bgStratumRepresentationByPerformer: [PerformerView : [BGStratum : Int]] = [:]
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
    private func getDMNodeRepresentationByPerformer() -> [PerformerView: [DMNode : Int]] {
        var dmNodeRepresentationByPerformer: [PerformerView : [DMNode : Int]] = [:]
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
    

    
    private func getInfoEndYFromGraphEvent(
        graphEvent: GraphEvent,
        withStemDirection stemDirection: StemDirection
    ) -> CGFloat
    {
        let infoEndY = stemDirection == .Down
            ? convertY(graphEvent.maxInfoY, fromLayer: graphEvent)
            : convertY(graphEvent.minInfoY, fromLayer: graphEvent)
        return infoEndY
    }
    
    private func getBeamEndYFromBGStratum(bgStratum: BGStratum) -> CGFloat {
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
        }
    }

    override func setWidthWithContents() {
        if measures.count > 0 {
            frame = CGRectMake(frame.minX, frame.minY, measureViews.last!.frame.maxX, frame.height)
        }
        else {
            frame = CGRectMake(frame.minX, frame.minY, 1000, frame.height)
        }
    }
    
    private func setGraphicalAttributesOfMeasureView(measureView: MeasureView, left: CGFloat) {
        measureView.g = g
        measureView.beatWidth = beatWidth
        measureView.build()
        measureView.moveHorizontallyToX(left, animated: false)
    }
    
    // takes in a graphically built measure, that has been positioned within the system
    private func addBarlinesForMeasureView(measureView: MeasureView) {
        addBarlineLeftForMeasureView(measureView)
        if measureView === measureViews.last! { addBarlineRightForMeasureView(measureView) }
    }
    
    private func addBarlineLeftForMeasureView(measureView: MeasureView) {
        let barlineLeft = Barline(x: measureView.frame.minX, top: 0, bottom: frame.height)
        barlineLeft.lineWidth = 6
        barlineLeft.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Background).CGColor
        barlineLeft.opacity = 0.5
        barlines.append(barlineLeft)
        barlinesLayer.insertSublayer(barlineLeft, atIndex: 0)
    }

    private func addBarlineRightForMeasureView(measureView: MeasureView) {
        let barlineRight = Barline(x: measureView.frame.maxX, top: 0, bottom: frame.height)
        barlineRight.lineWidth = 6
        barlineRight.strokeColor = UIColor.grayscaleColorWithDepthOfField(.Background).CGColor
        barlineRight.opacity = 0.5
        barlines.append(barlineRight)
        barlinesLayer.insertSublayer(barlineRight, atIndex: 0)
    }
    
    private func addMGRectsForMeasure(measure: MeasureView) {
        
    }
    
    private func addMeasureComponentsFromMeasure(measure: MeasureView, atX x: CGFloat) {
        if let timeSignature = measure.timeSignature { addTimeSignature(timeSignature, atX: x) }
        if let measureNumber = measure.measureNumber { addMeasureNumber(measureNumber, atX: x) }

        // barline will become a more complex object -- barline segments, etc
        // add barlineLeft
        let barlineLeft = Barline(x: x, top: 0, bottom: frame.height)
        barlineLeft.lineWidth = 6
        barlineLeft.opacity = 0.236
        barlines.append(barlineLeft)
        insertSublayer(barlineLeft, atIndex: 0)
    }
    
    private func addBarline(barline: Barline, atX x: CGFloat) {
        barlines.append(barline)
        barline.x = x
        insertSublayer(barline, atIndex: 0)
    }

    private func addStem(stem: Stem) {
        //eventsNode.insertSublayer(stem, atIndex: 0)
        //stems.append(stem)
    }
    
    private func addStems(stems: [Stem]) {
        for stem in stems { addStem(stem) }
    }

    public func build() {
        clearNodes()
        createTemporalInfoNode() // change name of this: // tempo always above?
        createEventsNode()
        createBGStrata()
        createPerformers()
        createInstrumentEventHandlers()
        decorateInstrumentEvents()
        createStemArticulations()
        manageGraphLines()
        createDMNodes()
        createSlurHandlers()
        addSlurs()
        setDefaultComponentTypesShownByID()
        hasBeenBuilt = true
    }
    
    private func setDefaultComponentTypesShownByID() {
        
        // make sure "performer" is in all component types
        for (id, _) in componentTypesByID {
            if !componentTypesByID[id]!.contains("performer") {
                componentTypesByID[id]!.append("performer")
            }
        }
        
        // then transfer all to componentTypesShown
        for (id, componentTypes) in componentTypesByID {
            componentTypesShownByID[id] = componentTypes
        }

        // filter out everyone by viewerID
        if viewerID != "omni" {
            let peerIDs = performerByID.keys.filter { $0 != self.viewerID }
            for id in peerIDs { componentTypesShownByID[id] = [] }
        }
    }
    
    private func addSlurs() {
        for (_, slurHandlers) in slurHandlersByID {
            for slurHandler in slurHandlers {
                if let slur = slurHandler.makeSlurInContext(eventsNode) {
                    eventsNode.insertSublayer(slur, atIndex: 0)
                }
            }
        }
    }
    
    private func createStemArticulations() {
        for bgStratum in bgStrata {
            for bgEvent in bgStratum.bgEvents {
                for saType in bgEvent.stemArticulationTypes {
                    if bgStratum.saNodeByType[saType] == nil {
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
    }
    
    private func manageGraphLines() {
        
        // WRAP: manage graph lines for empty measures
        for measureView in measureViews {

            var eventsContainedInMeasureByInstrument: [InstrumentView : [InstrumentEventHandler]] = [:]
            
            // initialize each array for each instrument (on the way, flattening all instr.)
            for performer in performers {
                for (_, instrument) in performer.instrumentByID {
                    eventsContainedInMeasureByInstrument[instrument] = []
                }
            }

            for eventHandler in instrumentEventHandlers {
                
                // if eventhandler exists within measure...
                if eventHandler.isContainedWithinDurationInterval(measureView.measure!.durationInterval) {

                    if let instrument = eventHandler.instrumentEvent?.instrument {
                        eventsContainedInMeasureByInstrument[instrument]!.append(eventHandler)
                    }
                }
            }

            for (instrument, eventHandlers) in eventsContainedInMeasureByInstrument {
                if eventHandlers.count == 0 {
                    for (_, graph) in instrument.graphByID {
                        let x = measureView.frame.minX
                        graph.stopLinesAtX(x)
                    }
                }
            }
        }
        
        // WRAP
        // does graph contain any events within the measure? if not: stop lines at measure
        for (_, performer) in performerByID {
            for (_, instrument) in performer.instrumentByID {
                for (_, graph) in instrument.graphByID {
                    if measureViews.count > 0 {
                        let x = measureViews.last!.frame.maxX
                        graph.stopLinesAtX(x)
                    }
                    else {
                        graph.stopLinesAtX(frame.width)
                    }
                    graph.build()
                }
                instrument.layout()
            }
        }
    }
    
    private func decorateInstrumentEvents() {
        for instrumentEventHandler in instrumentEventHandlers {
            instrumentEventHandler.decorateInstrumentEvent()
        }
    }

    private func getStemDirectionAndGForPID(pID: String) -> (StemDirection, CGFloat) {
        let s = getStemDirectionForPID(pID)
        let g = getGForPID(pID)
        return (s, g)
    }
    
    private func getStemDirectionForPID(pID: String) -> StemDirection {
        return pID == viewerID ? .Up : .Down
    }
    
    private func getGForPID(pID: String) -> CGFloat {
        return pID == viewerID ? self.g : 0.75 * self.g
    }
    
    // get this out of here
    private func createInstrumentEventHandlers() {
        
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
                
                // If DurationNode has no graphBearing components, don't try to populate graphs
                if durationNode.hasOnlyExtensionComponents || durationNode.components.count == 0 {
                    addInstrumentEventHandlerWithBGEvent(bgEvent, andInstrumentEvent: nil)
                    continue
                }
                
                for component in bgEvent.durationNode.components {
                    var instrumentEventHandlerSuccessfullyCreated: Bool = false
                    let pID = component.performerID, iID = component.instrumentID
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
                    else { fatalError("Unable to find PerformerView or InstrumentView") }
                    
                    // clean up
                    if !instrumentEventHandlerSuccessfullyCreated {
                        //print("instrument event unsuccessfully created!")
                    }
                }
            }
        }
        self.instrumentEventHandlers = instrumentEventHandlers
    }
    
    private func createSlurHandlers() {
        
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

                            // TODO: check that this is a valid id!
                            let id = componentSlurStart.performerID
                            let slurHandler = SlurHandler(id: id, graphEvent0: graphEvent)
                            addSlurHandler(slurHandler)
                        }
                        else if let componentSlurStop = component as? ComponentSlurStop {
                            
                            // TODO: check that this is a valid id!
                            let id = componentSlurStop.performerID
                            if let lastIncomplete = getLastIncompleteSlurHandlerWithID(id) {
                                lastIncomplete.graphEvent1 = graphEvent
                            } else {
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
    
    // Encapsulate in BGStratumFactory or something
    private func createBGStrata() {
        
        print("create BGStrata")
        
        // get this out of here
        func makeBGStrataFromDurationNodeStrata(durationNodeStrata: [[DurationNode]])
            -> [BGStratum]
        {
            // temp
            func performerIDsInStratum(stratum: DurationNodeStratum) -> [String] {
                var performerIDs: [String] = []
                for dn in stratum { performerIDs += performerIDsInDurationNode(dn) }
                return performerIDs
            }
            
            // temp
            func performerIDsInDurationNode(durationNode: DurationNode) -> [String] {
                return Array<String>(durationNode.instrumentIDsByPerformerID.keys)
            }
            
            
            // isolate sizing
            var bgStrata: [BGStratum] = []
            for durationNodeStratum in durationNodeStrata {
                
                // wrap --------------->
                let pIDs = performerIDsInStratum(durationNodeStratum)
                guard let firstValue = pIDs.first else { continue }
                var onlyOnePID: Bool {
                    for pID in pIDs { if pID != firstValue { return false } }
                    return true
                }
                
                var stemDirection: StemDirection = .Down
                var bgStratum_g: CGFloat = g
                if onlyOnePID {
                    let (s, g) = getStemDirectionAndGForPID(firstValue)
                    stemDirection = s
                    bgStratum_g = g
                }
                // <----------------- wrap
                
                
                // wrap --------------------->
                let bgStratum = BGStratum(stemDirection: stemDirection, g: bgStratum_g)
                bgStratum.system = self
                bgStratum.beatWidth = beatWidth
                bgStratum.pad_bottom = 0.5 * g
                // <----------------- wrap
                
                for durationNode in durationNodeStratum {
                    let offset_fromSystem = durationNode.durationInterval.startDuration - system.durationInterval.startDuration
                    let x = infoStartX + offset_fromSystem.width(beatWidth: beatWidth)
                    bgStratum.addBeamGroupWithDurationNode(durationNode, atX: x)
                }
                if !bgStratum.hasBeenBuilt { bgStratum.build() }
                bgStrata.append(bgStratum)
            }
            return bgStrata
        }

        let durationNodeArranger = DurationNodeStratumArranger(durationNodes: durationNodes)
        let durationNodeStrata = durationNodeArranger.makeDurationNodeStrata()
        let bgStrata = makeBGStrataFromDurationNodeStrata(durationNodeStrata)
        
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

    // ENCAPSULATE WITH DMNodeFactory()
    private func createDMNodes() {
        
        struct DMComponentContext {
            var eventHandler: InstrumentEventHandler
            var componentDynamic: ComponentDynamicMarking?
            var componentDMLigatures: [ComponentDynamicMarkingSpanner] = []
            
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

        var dmNodeByID: [String : DMNode] = [:]
        
        // deal with DYNAMIC MARKINGS
        for eventHandler in instrumentEventHandlers {
            
            // encapsulate in EVENT HANDLER?
            if eventHandler.bgEvent == nil || eventHandler.instrumentEvent == nil { continue
            }
            
            // create dmComponentContext
            var dmComponentContext = DMComponentContext(eventHandler: eventHandler)
            for component in eventHandler.bgEvent!.durationNode.components {
                if let componentDMLigature = component as? ComponentDynamicMarkingSpanner {
                    dmComponentContext.componentDMLigatures.append(componentDMLigature)
                }
                else if let componentDynamic = component as? ComponentDynamicMarking {
                    dmComponentContext.componentDynamic = componentDynamic
                }
            }
            
            // Create DynamicMarkings, ensuring DMNodes (no ligature consideration yet)
            if dmComponentContext.componentDynamic != nil {
                let x = eventHandler.bgEvent!.x_objective!
                
                // TODO: verify as valid (though temporary ) id
                let id = dmComponentContext.componentDynamic!.performerID // unsafe
                
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
                
                let marking = dmComponentContext.componentDynamic!.value
                dmNodeByID[id]!.addDynamicMarkingsWithString(marking, atX: x)
                
                // this is why we are refactoring this...
                // -- you shouldn't have to switch it to extract the property
                /*
                switch dmComponentContext.componentDynamic!.property {
                case .Dynamic(let marking):
                    dmNodeByID[id]!.addDynamicMarkingsWithString(marking, atX: x)
                default: break
                }
                */
            }
            
            // Create DMLigatures only if they are not frayed
            if dmComponentContext.componentDMLigatures.count > 0 {
                let x = eventHandler.bgEvent!.x_objective!
                
                // if there is a DynamicMarking
                if let componentDynamic = dmComponentContext.componentDynamic {
                    
                    // TODO: verify is valid ID!
                    let id = componentDynamic.performerID
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
                        switch componentDMLigature {
                        case is ComponentDynamicMarkingSpannerStart:
                            if let start_intValue = start_intValue {
                                dmNodeByID[id]!.startLigatureAtX(start_x,
                                    withDynamicMarkingIntValue: start_intValue
                                )
                            }
                        case is ComponentDynamicMarkingSpannerStop:
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
    
    private func handoffTimeSignatureFromMeasureView(measureView: MeasureView) {
        if let timeSignature = measureView.timeSignature {
            addTimeSignature(timeSignature, atX: measureView.frame.minX)
        }
    }
    
    private func handoffMeasureNumberFromMeasureView(measureView: MeasureView) {
        if measureView.measureNumber != nil {
            addMeasureNumber(measureView.measureNumber!, atX: measureView.frame.minX)
        }
    }
    
    // Must clean up
    private func adjustSlurs() {
        for (_, slurHandlers) in slurHandlersByID {
            
            // this works, but jesus...clean up
            for slurHandler in slurHandlers {
                if let graphEvent0 = slurHandler.graphEvent0, graphEvent1 = slurHandler.graphEvent1 {
                    if let graph0 = graphEvent0.graph, graph1 = graphEvent1.graph {
                        if let instrument0 = graph0.instrument, instrument1 = graph1.instrument {
                            if let performer0 = instrument0.performer, performer1 = instrument1.performer {
                                if eventsNode.hasNode(performer0) &&
                                    eventsNode.hasNode(performer1) &&
                                    performer0.hasNode(instrument0) &&
                                    performer1.hasNode(instrument1) &&
                                    instrument0.hasNode(graph0) &&
                                    instrument1.hasNode(graph1)
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
                else if let graphEvent0 = slurHandler.graphEvent0 {
                    if let graph0 = graphEvent0.graph {
                        if let instrument0 = graph0.instrument {
                            if let performer0 = instrument0.performer {
                                if eventsNode.hasNode(performer0) &&
                                    performer0.hasNode(instrument0) &&
                                    instrument0.hasNode(graph0)
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
                else if let graphEvent1 = slurHandler.graphEvent1 {
                    if let graph1 = graphEvent1.graph {
                        if let instrument1 = graph1.instrument {
                            if let performer1 = instrument1.performer {
                                if eventsNode.hasNode(performer1) &&
                                    performer1.hasNode(instrument1) &&
                                    instrument1.hasNode(graph1)
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
    
    /*
    // TODO:
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
    */
    
    private func getNextSystem() -> SystemLayer? {
        if page == nil { return nil }
        if let index = page!.systemLayers.indexOfObject(self) {
            if index < page!.systemLayers.count - 1 { return page!.systemLayers[index + 1] }
        }
        return nil
    }
    
    private func getPreviousSystem() -> SystemLayer? {
        if page == nil { return nil }
        if let index = page?.systemLayers.indexOfObject(self) {
            if index > 0 { return page!.systemLayers[index - 1] }
        }
        return nil
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
    
    private func getDescription() -> String {
        return "SystemLayer: totalDuration: \(totalDuration), offsetDuration: \(offsetDuration)"
    }
}