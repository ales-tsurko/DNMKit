//
//  DNMScoreModelManager.swift
//  DNMConverter
//
//  Created by James Bean on 11/4/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

public class DNMScoreModelManager {
    
    public init() {  }
    
    public func scoreModelByTitle() -> [String : DNMScoreModel] {
        var scoreModelByTitle: [String : DNMScoreModel] = [:]
        
        
        let fileManager = NSFileManager()
        let bundleURL = NSBundle.mainBundle().bundleURL
        let contents: NSArray = try! fileManager.contentsOfDirectoryAtURL(bundleURL,
            includingPropertiesForKeys: nil,
            options: NSDirectoryEnumerationOptions.SkipsHiddenFiles
        )
        let predicate = NSPredicate(format: "pathExtension == 'dnm'")
        for fileURL in contents.filteredArrayUsingPredicate(predicate) {
            let fileName = fileURL.lastPathComponent
            let parts = fileName.componentsSeparatedByString(".")
            
            // add contingency for different pieces (VERSIONS, etc) with same title
            if let fileName = parts.first {
                let scoreModel = DNMScoreModelFromShorthand(fileName: fileName)
                scoreModelByTitle[scoreModel.title] = scoreModel
            }
        }
        return scoreModelByTitle
    }
}