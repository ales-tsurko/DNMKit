//
//  ScoreManager.swift
//  DNM_iOS
//
//  Created by James Bean on 11/20/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

public class ScoreManager {
    
    /*
    public var documentDirectoryURL: NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.fir
    }
    */
    
    public var something: Int = 0
    
    public class var allScoreTitles: [String] { return getAllScoreTitles() }
    
    public class func allScores() -> [DNMScoreModel] {

        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        guard let documentDirectoryURL: NSURL = urls.first else { return [] }

        let contents: NSArray = try! fileManager.contentsOfDirectoryAtURL(documentDirectoryURL,
            includingPropertiesForKeys: nil,
            options: .SkipsHiddenFiles
        )
        
        let predicate = NSPredicate(format: "pathExtension == 'dnm'")
        
        for fileURL in contents.filteredArrayUsingPredicate(predicate) {
            let url = fileURL as! NSURL
            if let scoreModel = DNMScoreModel(url: url) { print(scoreModel) }
        }

        return []
    }
    
    public static func getAllScoreTitles() -> [String] {
        return []
    }
    
    public init() {
        
    }
}

extension DNMScoreModel {
    
    public init?(url: NSURL) {
        do {
            let code = try String(contentsOfURL: url)
            let tokenizer = Tokenizer()
            let tokenContainer = tokenizer.tokenizeString(code)
            let parser = Parser()
            self = parser.parseTokenContainer(tokenContainer)
        }
        catch _ {
            print("could not open file!")
        }
        return nil
    }
}