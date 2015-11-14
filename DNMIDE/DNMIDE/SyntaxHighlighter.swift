//
//  SyntaxHighlighter.swift
//  DNMIDE
//
//  Created by James Bean on 11/13/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Cocoa
import DNMJSON

public class SyntaxHighlighter {
    
    public init() {
        
    }
    
    public class StyleSheet {
        class var sharedInstance: JSON {
            struct Static {
                static let instance: JSON = Static.getInstance()
                static func getInstance() -> JSON {
                    let bundle = NSBundle(forClass: StyleSheet.self)
                    let filePath = bundle.pathForResource("SyntaxHighlightingStyleSheet",
                        ofType: "json"
                    )!
                    let jsonData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
                    let jsonObj: JSON = JSON(data: jsonData)
                    return jsonObj
                }
            }
            return Static.instance
        }
    }
}
