//
//  DENode.swift
//  denm_view
//
//  Created by James Bean on 8/23/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public class DENode: ViewNode {
    
    public var height: CGFloat = 0
    
    public var components: [CALayer] = []
    public var durationalExtensions: [DurationalExtension] = []
    public var augmentationDots: [AugmentationDot] = []
    
    public init(left: CGFloat, top: CGFloat, height: CGFloat) {
        super.init()
        self.left = left
        self.top = top
        self.height = height
        layoutFlow_vertical = .Middle
        setsWidthWithContents = true
        setsHeightWithContents = false
        frame = CGRectMake(left, top, 100, height) // 100 is hack, see also SANode
    }
    
    public init(left: CGFloat, top: CGFloat) {
        super.init()
        self.left = left
        self.top = top
        layoutFlow_vertical = .Middle
        setsWidthWithContents = true
        setsHeightWithContents = true
    }
    
    public override init() {
        super.init()
        layoutFlow_vertical = .Middle
    }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func addAugmentationDotAtX(x: CGFloat) {
        let augmentationDot = AugmentationDot(x: x, y: 0.5 * height, width: height)
        addAugmentationDot(augmentationDot)
    }
    
    public func addDurationalExtensionFromLeft(left: CGFloat, toRight right: CGFloat) {
        let durationalExtension = DurationalExtension(
            y: 0, left: left, right: right, width: height
        )
        addDurationalExtension(durationalExtension)
    }
    
    public func addAugmentationDot(augmentationDot: AugmentationDot) {
        augmentationDots.append(augmentationDot)
        components.append(augmentationDot)
        addSublayer(augmentationDot)
    }
    
    public func addDurationalExtension(durationalExtension: DurationalExtension) {
        durationalExtensions.append(durationalExtension)
        components.append(durationalExtension)
        addSublayer(durationalExtension)
    }

    override func flowVertically() {
        for component in components { component.position.y = 0.5 * frame.height }
    }
    
    override func setWidthWithContents() {
        var maxWidth: CGFloat = 0
        for augmentationDot in augmentationDots {
            if maxWidth == 0 {
                maxWidth = augmentationDot.frame.maxX
            }
            else if augmentationDot.frame.maxX > maxWidth {
                maxWidth = augmentationDot.frame.maxX
            }
        }
        
        for durationalExtension in durationalExtensions {
            if durationalExtension.right > maxWidth {
                maxWidth = durationalExtension.right
            }
        }
        frame = CGRectMake(frame.minX, frame.minY, maxWidth, frame.height)
    }
}
