//
//  ViewController.swift
//  DNMKitExample_iOS
//
//  Created by James Bean on 10/31/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMConverter
import DNMUtility
import DNMModel
import DNMView
import DNMUI

class ViewController: UIViewController {

    var environment: Environment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let d = Duration(1,16)
        print(d)
        
        // PARSE SHORTHAND
        let filePath = NSBundle.mainBundle().pathForResource("parse_slurTest", ofType: "txt")!
        let code = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        
        let items = Scanner(code: code).getItems()
        //for item in items { print(item) }
        let tokens = Tokenizer(items: items).getTokens()
        //for token in tokens { print(token) }
        let actions = Parser(tokens: tokens).getActions()
        for action in actions { print(action) }
        let interpreter = Interpreter(actions: actions)
        
        let scoreInfo: ScoreInfo = interpreter.makeScoreInfo()
        print("scoreInfo: \(scoreInfo)")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

