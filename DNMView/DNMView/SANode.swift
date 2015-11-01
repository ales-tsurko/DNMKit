//
//  SANode.swift
//  denm_view
//
//  Created by James Bean on 9/24/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class SANode: ViewNode {
    
    public var height: CGFloat = 0
    
    public var components: [CALayer] = []
    public var articulations: [CALayer] = [] // subclass at some point?
    
    public init(left: CGFloat, top: CGFloat, height: CGFloat) {
        super.init()
        self.left = left
        self.top = top
        self.height = height
        layoutFlow_vertical = .Middle
        frame = CGRectMake(left, top, 100, height) // 100 is hack, see also DENode
    }
    
    public init(left: CGFloat, top: CGFloat) {
        super.init()
        self.left = left
        self.top = top
        layoutFlow_vertical = .Middle
    }
    
    public override init() {
        super.init()
        layoutFlow_vertical = .Middle
    }

    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addStemArticulation(stemArticulation: CALayer) {
        articulations.append(stemArticulation)
        components.append(stemArticulation)
        addSublayer(stemArticulation)
    }
    
    public func addTremoloAtX(x: CGFloat) {
        let tremolo = Tremolo(x: x, top: 0, width: 0.5 * height)
        addArticulation(tremolo)
    }
    
    private func addArticulation(articulation: CALayer) {
        articulations.append(articulation)
        components.append(articulation)
        addSublayer(articulation)
    }
    
    override func flowHorizontally() {
        for component in components { component.position.y = 0.5 * frame.height }
    }
    
    override func setWidthWithContents() {
        if components.count == 0 { return }
        let maxX = components.sort({$0.frame.maxX > $1.frame.maxX}).first!.frame.maxX
        frame = CGRectMake(frame.minX, frame.minY, maxX, frame.height)
    }
    
    override func setHeightWithContents() {
        if components.count == 0 { return }
        let maxHeight = components.sort({$0.frame.height > $1.frame.height}).first!.frame.height
        frame = CGRectMake(frame.minX, frame.minY, frame.width, maxHeight)
    }
}

