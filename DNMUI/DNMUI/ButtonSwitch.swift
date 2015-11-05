//
//  ButtonSwitch.swift
//  denm_view
//
//  Created by James Bean on 9/25/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

public class ButtonSwitch: UIButton {
    
    public var id: String = ""
    public var text: String = ""
    public var isOn: Bool = true {
        didSet { backgroundColor = isOn ? UIColor.redColor() : UIColor.grayColor() }
    }
    
    public init(
        width: CGFloat = 60, height: CGFloat = 40, text: String, id: String = ""
    )
    {
        super.init(frame: CGRectMake(0, 0, width, height))
        self.text = text
        self.id = id
        backgroundColor = UIColor.lightGrayColor()
        layer.opacity = 0.666
        setTitle(text, forState: UIControlState.Normal)
        addTarget(self, action: "switchIsOn", forControlEvents: UIControlEvents.TouchUpInside)
        switchOn()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public func switchIsOn() {
        isOn ? switchOff() : switchOn()
    }
    
    public func switchOn() {
        isOn = true
    }
    
    public func switchOff() {
        isOn = false
    }
}

public class ButtonSwitchMaster: ButtonSwitch {
    
    public override var isOn: Bool {
        didSet { backgroundColor = isOn ? UIColor.blackColor() : UIColor.grayColor() }
    }
    
    public override init(width: CGFloat = 60, height: CGFloat = 40, text: String, id: String = "") {
        super.init(width: width, height: height, text: text, id: id)
    }

    public override init(frame: CGRect) { super.init(frame: frame) }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}