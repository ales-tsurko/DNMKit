//
//  SubdivisionGraphic.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class SubdivisionGraphic: CAShapeLayer, BuildPattern {
    
    public var x: CGFloat = 0
    public var top: CGFloat = 0
    public var height: CGFloat = 0
    public var width: CGFloat { get { return 0.382 * height } }
    public var stemDirection: StemDirection = .Down
    
    public var amountBeams: Int = 0
    
    public var hasBeenBuilt: Bool = false
    
    public init(
        x: CGFloat,
        top: CGFloat,
        height: CGFloat,
        stemDirection: StemDirection,
        amountBeams: Int
    )
    {
        self.x = x
        self.top = top
        self.height = height
        self.stemDirection = stemDirection
        self.amountBeams = amountBeams
        super.init()
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func build() {
        setFrame()
        path = makePath()
        setVisualAttributes()
        hasBeenBuilt = true
    }
    
    private func makePath() -> CGPath {
        let path = UIBezierPath()
        addStemToPath(path)
        addBeamsToPath(path)
        return path.CGPath
    }
    
    private func addStemToPath(path: UIBezierPath) {
        let stemWidth = 0.0382 * height
        let x = stemDirection == .Down ? 0 : width - stemWidth
        let stem = UIBezierPath(rect: CGRectMake(x, 0, stemWidth, height))
        path.appendPath(stem)
    }
    
    private func addBeamsToPath(path: UIBezierPath) {
        let beamWidth = (0.25 - (0.0382 * CGFloat(amountBeams))) * height
        let beamΔY = (0.382 - (0.0382 * CGFloat(amountBeams))) * height
        let beamsInitY = stemDirection == .Down ? 0 : height - beamWidth
        for b in 0..<amountBeams {
            let y = stemDirection == .Down
                ? beamsInitY + CGFloat(b) * beamΔY
                : beamsInitY - CGFloat(b) * beamΔY
            let beam = UIBezierPath(rect: CGRectMake(0, y, width, beamWidth))
            path.appendPath(beam)
        }
    }
    
    private func setVisualAttributes() {
        fillColor = UIColor.grayscaleColorWithDepthOfField(.Middleground).CGColor
        lineWidth = 0
        backgroundColor = DNMColorManager.backgroundColor.CGColor
    }
    
    private func setFrame() {
        frame = CGRectMake(x - 0.5 * width, top, width, height)
    }
}
