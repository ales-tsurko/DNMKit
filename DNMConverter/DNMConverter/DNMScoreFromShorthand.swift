//
//  DNMScoreFromShorthand.swift
//  DNMConverter
//
//  Created by James Bean on 11/1/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation
import DNMModel

public func DNMScoreFromShorthand(name name: String) -> ScoreInfo {
    
    let filePath = NSBundle.mainBundle().pathForResource(name, ofType: "txt")!
    let code = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)

    let items = Scanner(code: code).getItems()
    let tokens = Tokenizer(items: items).getTokens()
    let actions = Parser(tokens: tokens).getActions()
    let interpreter = Interpreter(actions: actions)
    
    let scoreInfo: ScoreInfo = interpreter.makeScoreInfo()
    return scoreInfo
}
