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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let filePath = NSBundle.mainBundle().pathForResource("test_piece", ofType: "dnm") {
            print("filePath: \(filePath)")
        }
        let code = 
        
        let tokenizer = Tokenizer()
        tokenizer.tokenizeString(<#T##string: String##String#>)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

