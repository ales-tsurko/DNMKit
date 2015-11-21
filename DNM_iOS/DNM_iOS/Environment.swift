//
//  Environment.swift
//  denm_view
//
//  Created by James Bean on 9/20/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// Consider making this a UIViewController subclass
public class Environment: UIView {
    
    public var viewSelector: RadioGroupPanelVertical!
    public var viewSelectorDot: UIView!
    
    public var views: [PerformerView] = []
    public var viewByID: [String: PerformerView] = [:]
    public var currentView: PerformerView?
    
    public var pages: [Page] = []
    public var currentPage: Page?
    public var currentPageIndex: Int?
    
    public var systems: [System] = []
    
    public var durationNodes: [DurationNode] = []
    
    // Change to Measure, rather than MeasureView
    public var measures: [Measure] = []
    
    public var measureViews: [MeasureView] = []
    
    public var tempoMarkings: [TempoMarking] = []
    public var rehearsalMarkings: [RehearsalMarking] = []
    
    public var g: CGFloat = 10 // ?! // hack
    public var beatWidth: CGFloat = 110 // ?! // hack
    
    // get rid of this
    public var page_pad: CGFloat = 25
    
    public var componentTypesShownByID: [String : [String]] = [:]

    //public var iIDsAndInstrumentTypesByPID: [[String : [(String, InstrumentType)]]] = []
    
    public var instrumentIDsAndInstrumentTypesByPerformerID = OrderedDictionary<
        String, OrderedDictionary<String, InstrumentType>
    >()
    
    /*
    public var _iIDsAndInstrumentTypesByPID = OrderedDictionary<
        String, OrderedDictionary<String, InstrumentType>
    >()
    */
    
    public var viewIDs: [String] = []
    
    public init(scoreModel: DNMScoreModel) {
        super.init(frame: CGRectZero)

        self.measures = scoreModel.measures
        self.tempoMarkings = scoreModel.tempoMarkings
        self.rehearsalMarkings = scoreModel.rehearsalMarkings
        self.durationNodes = scoreModel.durationNodes
        self.instrumentIDsAndInstrumentTypesByPerformerID = scoreModel.instrumentIDsAndInstrumentTypesByPerformerID
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        createViews()
        goToViewWithID("omni") // set default view
        goToFirstPage()
        addPageControlButtons()
        addViewSelector()
    }
    
    public func createViews() {
        
        // Get ViewIDs
        self.viewIDs = getViewIDs()
        
        for id in viewIDs {
            
            // Create all Systems for the whole piece, regardless of Page
            let systems = makeSystemsWithViewerID(id)
            
            // Create a Performer(Interface)View, passing ALL Systems!
            let view = PerformerView(id: id, systems: systems)
            
            viewByID[id] = view
            views.append(view)
        }
    }
    
    public func goToViewWithID(id: String) {
        if let view = viewByID[id] {
            
            // Remove currentView
            if let currentView = currentView { currentView.removeFromSuperview() }
            
            insertSubview(view, atIndex: 0) // keep it under any other UI stuff (ViewSelector)
            currentView = view
            setFrame()
        }
    }
    
    private func getViewIDs() -> [String] {
        let viewIDs = instrumentIDsAndInstrumentTypesByPerformerID.map { $0.0 } + ["omni"]
        return viewIDs
    }
    
    public func setFrame() {
        //if let currentView = currentView { frame = currentView.frame }
        frame = UIScreen.mainScreen().bounds
    }
    
    // MARK: Page Navigation
    public func goToLastPage() {
        currentView?.goToLastPage()
    }
    
    public func goToFirstPage() {
        currentView?.goToFirstPage()
    }
    
    public func goToPage(number number: Int) {
        currentView?.goToPageAtIndex(number - 1)
    }
    
    private func goToPage(index index: Int) {
        currentView?.goToPageAtIndex(index)
    }
    
    public func goToNextPage() {
        currentView?.goToNextPage()
    }
    
    public func goToPreviousPage() {
        currentView?.goToPreviousPage()
    }
    

    public func addViewSelector() {
        let w: CGFloat = 50
        let viewSelector = ViewSelector(
            left: 0, top: 0, width: w, target: self, titles: viewIDs
        )
        viewSelector.build()
        viewSelector.layer.position.x = frame.width - (0.5 * viewSelector.frame.width)
        addSubview(viewSelector)
    }
    
    public func addPageControlButtons() {
        addPageControlButtonPrevious()
        addPageControlButtonNext()
    }
    
    private func addPageControlButtonNext() {
        let nextPageButton = PageControlButton.withType(.Next)!
        nextPageButton.layer.position = CGPoint(
            x: frame.width - (0.5 * nextPageButton.frame.width),
            y: frame.height - (0.5 * nextPageButton.frame.height)
        )
        nextPageButton.addTarget(self,
            action: "goToNextPage", forControlEvents: .TouchUpInside
        )
        addSubview(nextPageButton)
    }
    
    private func addPageControlButtonPrevious() {
        let previousPageButton = PageControlButton.withType(.Previous)!
        previousPageButton.layer.position = CGPoint(
            x: 0.5 * previousPageButton.frame.width,
            y: frame.height - (0.5 * previousPageButton.frame.height)
        )
        previousPageButton.addTarget(self,
            action: "goToPreviousPage", forControlEvents: .TouchUpInside
        )
        addSubview(previousPageButton)
    }
    
    // manageSpanners()
    public func manageHorizontalLigatures() {
        // DMLigature
        // DurationalExtension
        // Slur
    }
    
    public func makeSystemsWithViewerID(id: String) -> [System] {
        
        //measureViews = makeMeasureViewsWithMeasures(measures)
        
        /*
        // this should become unnecessary: set properties of measure
        for (m, measure) in measureViews.enumerate() {
            measure.number = m + 1
            measure.beatWidth = beatWidth
        }
        */
        
        print("measures ---------------------------")
        
        for measure in measures { print(measure) }
        
        let maximumWidth = UIScreen.mainScreen().bounds.width - 2 * page_pad
        let maximumDuration = maximumWidth.durationWithBeatWidth(beatWidth)
        print("maximumDuration: \(maximumDuration)")
        var systems: [System] = []
        var measureIndex: Int = 0
        var accumDuration: Duration = DurationZero
        while measureIndex < measures.count {
            
            if let measureRange = Measure.rangeFromMeasures(measures,
                startingAtIndex: measureIndex, constrainedByDuration: maximumDuration
            )
            {
                print("measureRange: \(measureRange)")
                let system = System(g: g, beatWidth: 110, viewerID: id)
                system.offsetDuration = accumDuration
                
                // set the Measure range (model)
                system.setMeasuresWithMeasures(measureRange)
                
                system.instrumentIDsAndInstrumentTypesByPerformerID = instrumentIDsAndInstrumentTypesByPerformerID
                
                // encapsulate: internal
                let start = system.offsetDuration
                let stop = system.offsetDuration + system.totalDuration // DurationSpan.duration...
                let durationNodeRange = DurationNode.rangeFromDurationNodes(durationNodes,
                    afterDuration: start, untilDuration: stop
                )
                system.durationNodes = durationNodeRange
                systems.append(system)
                
                if let lastMeasure = measureRange.last {
                    if let lastMeasureIndex: Int = measures.indexOf(lastMeasure) {
                        measureIndex = lastMeasureIndex + 1
                        
                        // system.durationSpan.duration
                        accumDuration += system.totalDuration
                    }
                    
                    
                    /*
                    if let lastMeasureIndex: Int = measures.indexOf(lastMeasure) {
                        measureIndex = lastMeasureIndex + 1
                        accumDuration += system.totalDuration // DurationSpan.stopDuration
                    }
                    */
                }
            }
        }
        
        // PRELIMINARY BUILD
        for system in systems { system.build() }
        
        // ADD FRAYED LIGATURES, ADD DMNODES IF NECESSARY
        manageDMLigaturesForSystems(systems)
        manageSlursForSystems(systems)
        
        // COMPLETE BUILD
        for system in systems {
            
            // encapsulate
            // make show only view id, unless omni view
            if id != "omni" {
                let ids_complement = viewIDs.filter({$0 != id})
                for id in ids_complement { system.componentTypesShownByID[id] = [] }
            }
            
            system.arrangeNodesWithComponentTypesPresent() // need to get slurs in there somehow
            
            // probably not the best place for this
            system.createStems()
            
            manageTempoMarkingsForSystem(system)
            manageRehearsalMarkingsForSystem(system)
        }
        return systems
    }
    
    private func makeMeasureViewsWithMeasures(measures: [Measure]) -> [MeasureView] {
        var measureViews: [MeasureView] = []
        // for measure in measures { let measureView = MeasureView(measure: measure) }
        
        for measure in measures {
            let duration = measure.duration
            let measureView = MeasureView(duration: duration)
            measureView.hasTimeSignature = measure.hasTimeSignature
            measureViews.append(measureView)
        }
        return measureViews
    }
    
    private func manageRehearsalMarkingsForSystem(system: System) {
        for rehearsalMarking in rehearsalMarkings {
            if rehearsalMarking.offsetDuration >= system.offsetDuration &&
                rehearsalMarking.offsetDuration < system.totalDuration
            {
                let durationFromSystemStart = (
                    rehearsalMarking.offsetDuration - system.offsetDuration
                )
                let x = durationFromSystemStart.width(beatWidth: beatWidth) + system.infoStartX
                if let type = RehearsalMarkingType(rawValue: rehearsalMarking.type) {
                    system.addRehearsalMarkingWithIndex(rehearsalMarking.index,
                        type: type, atX: x
                    )
                }
            }
        }
    }
    
    private func manageTempoMarkingsForSystem(system: System) {
        for tempoMarking in tempoMarkings {
            if tempoMarking.offsetDuration >= system.offsetDuration &&
                tempoMarking.offsetDuration < system.totalDuration
            {
                let durationFromSystemStart = tempoMarking.offsetDuration - system.offsetDuration
                let x = durationFromSystemStart.width(beatWidth: beatWidth) + system.infoStartX
                
                system.addTempoMarkingWithValue(tempoMarking.value, andSubdivisionLevel: tempoMarking.subdivisionLevel, atX: x)
            }
        }
    }
    
    public func manageSlursForSystems(systems: [System]) {
        struct SlurSpan {
            var systemStartIndex: Int?
            var systemStopIndex: Int?
        }
    }
    
    public func manageDMLigaturesForSystems(systems: [System]) {
        
        // encapsulate: create ligature spans
        struct DMLigatureSpan {
            var systemStartIndex: Int?
            var systemStopIndex: Int?
            var startIntValue: Int?
            var stopIntValue: Int?
            
            init(systemStartIndex: Int, startIntValue: Int) {
                self.systemStartIndex = systemStartIndex
                self.startIntValue = startIntValue
            }
            
            init(systemStopIndex: Int, stopIntValue: Int) {
                self.systemStartIndex = systemStopIndex
                self.stopIntValue = stopIntValue
            }
            
            mutating func setSystemStopIndex(systemStopIndex: Int, stopIntValue: Int) {
                self.systemStopIndex = systemStopIndex
                self.stopIntValue = stopIntValue
            }
            
            mutating func setSystemStartIndex(systemStartIndex: Int, startIntValue: Int) {
                self.systemStartIndex = systemStartIndex
                self.startIntValue = startIntValue
            }
        }
        
        var dmLigatureSpansByID: [String : [DMLigatureSpan]] = [:]

        for (s, system) in systems.enumerate() {
            for (id, dmNode) in system.dmNodeByID {
                for ligature in dmNode.ligatures {
                    if ligature.hasBeenBuilt { continue }
                    if ligature.initialDynamicMarkingIntValue == nil {
                        if let finalIntValue = ligature.finalDynamicMarkingIntValue {
                            if dmLigatureSpansByID[id] == nil {
                                let dmLigatureSpan = DMLigatureSpan(
                                    systemStopIndex: s, stopIntValue: finalIntValue
                                )
                                dmLigatureSpansByID[id] = [dmLigatureSpan]
                            }
                            else {
                                for (d, var dmLigatureSpan) in dmLigatureSpansByID[id]!.enumerate() {
                                    if dmLigatureSpan.stopIntValue == nil {
                                        dmLigatureSpan.setSystemStopIndex(s, stopIntValue: finalIntValue)
                                        dmLigatureSpansByID[id]!.removeAtIndex(d)
                                        dmLigatureSpansByID[id]!.insert(dmLigatureSpan, atIndex: d)
                                        break
                                    }
                                }
                            }
                        }
                    }
                    else {
                        if let initialValue = ligature.initialDynamicMarkingIntValue {
                            if dmLigatureSpansByID[id] == nil {
                                // create
                                let dmLigatureSpan = DMLigatureSpan(
                                    systemStartIndex: s, startIntValue: initialValue
                                )
                                dmLigatureSpansByID[id] = [dmLigatureSpan]
                            }
                            else {
                                // find and append
                                for (d, var dmLigatureSpan) in dmLigatureSpansByID[id]!.enumerate() {
                                    if dmLigatureSpan.startIntValue == nil {
                                        dmLigatureSpan.setSystemStartIndex(s, startIntValue: initialValue)
                                        dmLigatureSpansByID[id]!.removeAtIndex(d)
                                        dmLigatureSpansByID[id]!.insert(dmLigatureSpan, atIndex: d)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // encapsulate: now add ligature components to dmNode
        
        for (id, dmLigatureSpans) in dmLigatureSpansByID {
            for dmLigatureSpan in dmLigatureSpans {
                
                let startSystem = systems[dmLigatureSpan.systemStartIndex!]
                let stopIntValue = dmLigatureSpan.stopIntValue!
                let lastDMNode = startSystem.dmNodeByID[id]!
                let lastLigature = lastDMNode.ligatures.last!
                if lastLigature.finalDynamicMarkingIntValue == nil {
                    let x = startSystem.frame.width + 20
                    lastLigature.completeHalfOpenToX(x, withDynamicMarkingIntValue: stopIntValue)
                    lastLigature.position.y = 0.5 * lastDMNode.frame.height
                }
                
                let stopSystem = systems[dmLigatureSpan.systemStopIndex!]
                let startIntValue = dmLigatureSpan.startIntValue!
                let firstDMNode = stopSystem.dmNodeByID[id]!
                let firstLigature = firstDMNode.ligatures.first!
                if firstLigature.initialDynamicMarkingIntValue == nil {
                    firstLigature.completeHalfOpenFromLeftWithDynamicMarkingIntValue(startIntValue)
                    firstLigature.position.y = 0.5 * firstDMNode.frame.height
                }
                
                for s in dmLigatureSpan.systemStartIndex! + 1..<dmLigatureSpan.systemStopIndex! {
                    
                    if systems[s].dmNodeByID[id] == nil {
                        // create dmNode
                        let dmNode = DMNode(height: 2.5 * g) // hack
                        dmNode.startLigatureAtX(0, withDynamicMarkingIntValue: startIntValue)
                        dmNode.ligatures.last!.completeHalfOpenToX(systems[s].frame.width + 20,
                            withDynamicMarkingIntValue: stopIntValue
                        )
                        dmNode.ligatures.last!.position.y = 0.5 * dmNode.frame.height
                        
                        dmNode.build()
                        systems[s].dmNodeByID[id] = dmNode
                        
                        // hail mary
                        systems[s].eventsNode.insertNode(dmNode,
                            afterNode: systems[s].performerByID[id]!
                        )
                        
                        // dmNode.startLigature
                        // dmNode.completeHalfOpenToX
                    }
                }
            }
        }
    }
    

}
