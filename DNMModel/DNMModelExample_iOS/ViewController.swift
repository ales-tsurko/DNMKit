//
//  ViewController.swift
//  DNMModelExample_iOS
//
//  Created by James Bean on 11/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let string = "#\n| 4 8 VN vn Violin\n\t1 p 60 d fff [\n\t\t1 p 60"
        
        let tokenizer = Tokenizer()
        tokenizer._tokenizeString(string)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

