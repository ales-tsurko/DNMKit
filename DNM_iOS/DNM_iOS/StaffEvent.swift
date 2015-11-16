//
//  StaffEvent.swift
//  denm_view
//
//  Created by James Bean on 8/24/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

public class StaffEvent: GraphEvent, Guido {
    
    public var pitchVerticality: PitchVerticality = PitchVerticality()
    
    public var maxPitchSpelling: PitchSpelling? { get { return getMaxPitchSpelling() } }
    public var minPitchSpelling: PitchSpelling? { get { return getMinPitchSpelling() } }

    public var pitchesByNoteheadType: [NoteheadType : [Pitch]] = [:]
    
    public var ledgerLines: [CAShapeLayer] = []
    public var noteheads: [Notehead] = []
    public var accidentals: [Accidental] = []
    
    public var g: CGFloat = 12
    
    public var middleCPosition: CGFloat = 0
    
    //public var s: CGFloat = 1
    
    public var gS: CGFloat { get { return g * s } }
    
    //public var slurConnectionY: CGFloat? /*{ get { return getSlurConnectionY() } }*/
    public override var stemEndY: CGFloat { get { return getStemEndY() } }
    
    private func getStemEndY() -> CGFloat {
        return stemDirection == .Down
            ? maxInfoY
            : minInfoY
    }
    
    public var middleCStaffPosition: CGFloat = 0
    
    public override var maxInfoY: CGFloat { get { return getMaxInfoY() } }
    public override var minInfoY: CGFloat { get { return getMinInfoY() } }
    
    public var info_yRef: CGFloat {
        get { return stemDirection == .Down ? maxInfoY : minInfoY }
    }
    
    public init(
        x: CGFloat,
        stemDirection: StemDirection = .Down,
        staff: Staff? = nil,
        stem: Stem? = nil
    )
    {
        super.init()
        self.x = x
        self.graph = staff
        if staff != nil { self.g = staff!.g }
        if staff != nil { self.s = staff!.s }
        self.stem = stem
        self.stemDirection = stemDirection
    }
    
    public init(x: CGFloat, g: CGFloat, s: CGFloat = 1, staff: Staff? = nil, stem: Stem? = nil) {
        super.init()
        self.x = x
        self.g = g
        self.s = s
        self.graph = staff
        self.stem = stem
    }
    
    public override init() { super.init() }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addPitch(pitch: Pitch, withNoteheadType noteheadType: NoteheadType) {
        pitchVerticality.addPitch(pitch)
        if pitchesByNoteheadType[noteheadType] == nil {
            pitchesByNoteheadType[noteheadType] = [pitch]
        }
        else { pitchesByNoteheadType[noteheadType]!.append(pitch) }
    }
    
    public func addPitch(pitch: Pitch,
        respellVerticality shouldRespellVerticality: Bool = false,
        andUpdateView shouldUpdateView: Bool = false
    )
    {
        pitchVerticality.addPitch(pitch)
        
        if pitchesByNoteheadType[.Ord] == nil { pitchesByNoteheadType[.Ord] = [pitch] }
        else { pitchesByNoteheadType[.Ord]!.append(pitch) }

        
        if shouldRespellVerticality {
            spellPitches()
        }
        if shouldUpdateView {
            //print("should update view", terminator: "")
            // TO-DO:
            // deal with logic:
            // -- clear pitch spellings
            // -- respell pitches
            // -- redraw all accidentals / noteheads (re-adjust positions)
            // -- redraw all lines?
        }
    }
    
    public func setMiddleCPosition(middleCPosition: CGFloat?) {
        if let mcp = middleCPosition { self.middleCPosition = mcp }
        else { self.middleCPosition = 5 * g }
    }
    
    public override func addArticulationWithType(type: ArticulationType) {
        //print("add articulation with type: \(type)", terminator: "")
        let articulation = Articulation.withType(type, x: 0, y: 0, g: g)
        if articulation != nil { articulations.append(articulation!) }
        addSublayer(articulation!)
    }
    
    public override func build() {
        if !pitchVerticality.allPitchesHaveBeenSpelled { spellPitches() }
        setFrame()
        createNoteheads()
        createAccidentals()
        moveNoteheads()
        moveAccidentals()
        moveArticulations()
        createLedgerLines()
    }
    
    private func getPlacementInStaffWithY(y: CGFloat) -> PlacementInStaff {
        if abs(y) % g == 0 { return .Line }
        else if abs(y) % (0.5 * g) == 0 { return .Space }
        return .Floating
    }
    
    private func getIsWithinStaffWithY(y: CGFloat) -> Bool {
        if stemDirection == .Down && y < 4 * g { return true }
        if stemDirection == .Up && y > 0 { return true }
        return false
    }
    
    internal override func moveArticulations() {
        sortArticulationsByType()
        
        // y value of highest or lowest notehead
        let yRef: CGFloat = stemDirection == .Down ? maxInfoY : minInfoY
        
        // if reference notehead is on line or in space
        let placement = getPlacementInStaffWithY(yRef)
        
        // if lines need to be avoided
        let isWithinStaff = getIsWithinStaffWithY(yRef)
        
        // direction: 1.0 or -1.0 (multiplier) of ΔY
        let dir: CGFloat = stemDirection == .Down ? 1 : -1
        
        // set initial value of y value of articulation
        let y_initial_offset = placement == .Line && isWithinStaff ? 1.5 * g * dir : g * dir
        
        // if first articulation is outside of staff, then compress, otherwise...
        let ΔY: CGFloat = getIsWithinStaffWithY(yRef + y_initial_offset) ? g : 0.75 * g
        
        // accumulate y val for each accidental
        var y = yRef + y_initial_offset
        
        // move articulations
        for articulation in articulations {
            articulation.position.y = y
            y += ΔY * dir
        }
        slurConnectionY = y
    }
    
    private func createLedgerLines() {
        if pitchVerticality.pitches.count > 0 {
            createLedgerLinesAbove()
            createLedgerLinesBelow()
        }
    }
    
    private func createLedgerLinesAbove() {
        let max = maxPitchSpelling!
        let yMax = getYWithLetterName(max.letterName, andOctave: max.octave)
        if yMax <= -g {
            let amountAbove: Int = Int(floor((g - yMax) / g)) - 1
            self.ledgerLines = ((graph as? Staff)?.addLedgerLinesAtX(x, toLevel: amountAbove))!
        }
    }
    
    internal func createLedgerLinesBelow() {
        let min = minPitchSpelling!
        let yMin = getYWithLetterName(min.letterName, andOctave: min.octave)
        if yMin >= 5 * g {
            let amountBelow: Int = -Int(floor((yMin - 4 * g) / g))
            (graph as? Staff)?.addLedgerLinesAtX(x, toLevel: amountBelow)
        }
    }
    
    private func createNoteheads() {
        assert(pitchVerticality.allPitchesHaveBeenSpelled,
            "all pitches must be spelled to create noteheads for pitches"
        )
        for (noteheadType, pitches) in pitchesByNoteheadType {
            for pitch in pitches {
                let s = pitch.spelling!
                let y: CGFloat = getYWithLetterName(s.letterName, andOctave: s.octave)
                createNoteheadWithType(noteheadType, atY: y)
            }
        }
        
        
        /*
        for pitch in pitchVerticality.pitches {
            let s = pitch.spelling!
            let y: CGFloat = getYWithLetterName(s.letterName, andOctave: s.octave)
            createNoteheadWithType(.Ord, atY: y)
        }
        */
    }
    
    private func createAccidentals() {
        assert(pitchVerticality.allPitchesHaveBeenSpelled,
            "all pitches must be spelled to create noteheads for pitches"
        )
        for pitch in pitchVerticality.pitches {
            let s = pitch.spelling!
            let y: CGFloat = getYWithLetterName(s.letterName, andOctave: s.octave)
            createAccidentalWithCoarse(s.coarse, andFine: s.fine, atY: y)
        }
    }
    
    private func moveNoteheads() {
        let verticality = NoteheadVerticality(noteheads: noteheads)
        let mover = NoteheadVerticalityMover(
            verticality: verticality,
            g: g,
            stemDirection: stemDirection
        )
        mover.move()
    }
    
    private func moveAccidentals() {
        let verticality = AccidentalVerticality(accidentals: accidentals)
        let mover = AccidentalVerticalityMover(
            verticality: verticality,
            staffEvent: self,
            initialOffset: -getNoteheadsMinX()
        )
        mover.move()
    }
    
    private func getNoteheadsMinX() -> CGFloat {
        if noteheads.count == 0 { return 0 }
        var minX: CGFloat?
        for notehead in noteheads {
            if minX == nil { minX = notehead.frame.minX }
            else if notehead.frame.minX < minX {
                minX = notehead.frame.minX
            }
        }
        return minX!
    }
    
    public override func getMaxInfoY() -> CGFloat {
        if noteheads.count == 0 { return 0 }
        var maxY: CGFloat?
        for n in noteheads {
            if maxY == nil { maxY = n.position.y }
            else if n.position.y > maxY! { maxY = n.position.y }
        }
        return maxY!
    }
    
    public override func getMinInfoY() -> CGFloat {
        if noteheads.count == 0 { return 0 }
        var minY: CGFloat?
        for n in noteheads {
            if minY == nil { minY = n.position.y }
            else if n.position.y < minY! { minY = n.position.y }
        }
        return minY!
    }
    
    public func spellPitches() {
        pitchVerticality.clearPitchSpellings()
        PitchVerticalitySpeller(verticality: pitchVerticality).spell()
    }
    
    public func createAccidentalWithCoarse(coarse: Float, andFine fine: Float, atY y: CGFloat) {
        let type = AccidentalTypeMake(coarse: coarse, fine: fine)!
        let accidental = Accidental.withType(type, x: 0, y: y, g: g, s: s)!
        accidentals.append(accidental)
        addSublayer(accidental)
    }
    
    public func createNoteheadWithType(type: NoteheadType, atY y: CGFloat) {
        let notehead = Notehead.withType(type, x: 0, y: y, g: g, s: s)!
        noteheads.append(notehead)
        addSublayer(notehead)
    }
    
    private func getYWithLetterName(letterName: PitchLetterName, andOctave octave: Int) -> CGFloat {
        let octaveDisplacement = 3.5 * g * CGFloat(4 - octave)
        let letterNameDisplacement = CGFloat(letterName.staffSpaces) * g
        return middleCPosition + octaveDisplacement - letterNameDisplacement
    }
    
    private func getMaxPitchSpelling() -> PitchSpelling? {
        if pitchVerticality.pitches.count == 0 { return nil }
        var maxPitchSpelling: PitchSpelling?
        for pitch in pitchVerticality.pitches {
            if maxPitchSpelling == nil { maxPitchSpelling = pitch.spelling! }
            else {
                if pitch.spelling != nil && pitch.spelling! > maxPitchSpelling! {
                    maxPitchSpelling = pitch.spelling!
                }
            }
        }
        return maxPitchSpelling
    }
    
    private func getMinPitchSpelling() -> PitchSpelling? {
        if pitchVerticality.pitches.count == 0 { return nil }
        var minPitchSpelling: PitchSpelling?
        for pitch in pitchVerticality.pitches {
            if minPitchSpelling == nil { minPitchSpelling = pitch.spelling! }
            else {
                if pitch.spelling != nil && pitch.spelling! < minPitchSpelling! {
                    minPitchSpelling = pitch.spelling!
                }
            }
        }
        return minPitchSpelling
    }
    
    internal override func getMinY() -> CGFloat {
        if sublayers == nil { return 0 }
        var minY: CGFloat = 0
        for sublayer in sublayers! {
            if sublayer.frame.minY < minY { minY = sublayer.frame.minY }
        }
        return minY
    }
    
    internal override func getMaxY() -> CGFloat {
        if sublayers == nil { return 4 * g }
        var maxY: CGFloat?
        for sublayer in sublayers! {
            if maxY == nil { maxY = sublayer.frame.maxY }
            else if sublayer.frame.maxY > maxY! {
                maxY = sublayer.frame.maxY
            }
        }
        return maxY! > 4 * g ? maxY! : 4 * g
    }
    
    public override func clear() {
        super.clear()
        clearLedgerLines()
    }
    
    public func clearLedgerLines() {
        for ledgerLine in ledgerLines {
            ledgerLine.removeFromSuperlayer()
        }
    }
    
    private func setFrame() {
        frame = CGRectMake(x, 0, 0, 0)
    }
}
