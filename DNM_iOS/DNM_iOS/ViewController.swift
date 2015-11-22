//
//  ViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

class ViewController: UIViewController {

    var environment: Environment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let pitch = try Pitch(string: "cs4")
        }
        catch let error {
            print(error)
        }
        
        
        
        DNMColorManager.colorMode = ColorMode.Light
        view.backgroundColor = DNMColorManager.backgroundColor
        
        //ScoreManager.allScores()

        if let filePath = NSBundle.mainBundle().pathForResource("test_piece", ofType: "dnm") {
            let code = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            
            // encapsulate
            let tokenizer = Tokenizer()
            let tokenContainer = tokenizer.tokenizeString(code)
            print(tokenContainer)
            let parser = Parser()
            let scoreModel = parser.parseTokenContainer(tokenContainer)
            
            print("scoreModel: \(scoreModel)")
            
            environment = Environment(scoreModel: scoreModel)
            environment.build()
            
            view.addSubview(environment)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

