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

// TODO: Reintegrate ViewSelector
class ViewController: UIViewController {

    var environment: Environment!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DNMColorManager.colorMode = ColorMode.Light
        view.backgroundColor = DNMColorManager.backgroundColor
        
        var scoreModelsByTitle: [String : DNMScoreModel] = [:]
        
        
        
        // get scoresByTitles
        
        let scoreModel = DNMScoreModelFromShorthand(fileName: "parse_slurTest")
        print("scoreModel.title: \(scoreModel.title)")
        
        environment = Environment(scoreModel: scoreModel)
        environment.build()
        view.addSubview(environment)

        print("after everything is done:")
        
        if let curPageView = environment.currentView {
            for (s, system) in curPageView.systems.enumerate() {
                print("system: \(s); height: \(system.frame.height)")
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

