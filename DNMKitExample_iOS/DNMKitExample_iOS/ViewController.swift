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
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var scoreTableView: UITableView!
    
    var scoreModelByTitle: [String : DNMScoreModel] = [:]
    var scoreTitles: [String] = []
    var environment: Environment!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DNMColorManager.colorMode = ColorMode.Light
        view.backgroundColor = DNMColorManager.backgroundColor

        scoreModelByTitle = DNMScoreModelManager().scoreModelByTitle()
        for (title, _) in scoreModelByTitle { scoreTitles.append(title) }
        
        scoreTableView.dataSource = self
        scoreTableView.delegate = self
        scoreTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        /*
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
        */
    }
    
    func showScoreWithTitle(title: String) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        print("table view cell for row index path")
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
            forIndexPath: indexPath
        )
        let title = scoreTitles[indexPath.row]
        cell.textLabel?.text = title
        return cell
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

