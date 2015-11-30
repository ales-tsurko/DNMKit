//
//  ScoreViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

class ScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI
    
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var viewSelectorTableView: UITableView!
    
    // integrate contexts of Environment into this
    var environment: Environment!
    
    // MARK: - Score Views
    
    /// All ScoreViews organized by ID
    var scoreViewsByID: [String: ScoreView] = [:]
    
    /// All ScoreViewIDs (populates ScoreViewTableView)
    var scoreViewIDs: [String] = []
    
    /// ScoreView currently displayed
    var currentScoreView: ScoreView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    
    func build() {
        setupScoreViewTableView()
        createViews()
    }
    
    func createViews() {
        for id in scoreViewIDs {
            
            // manage systems
            
        }
    }
    
    func showScoreViewWithID(id: String) {
        if let scoreView = scoreViewsByID[id] {
            removeCurrentScoreView()
            
            // insert subview below any ScoreViewController UIViews
            view.insertSubview(scoreView, atIndex: 0)
            
            // set currentScoreView to this view
            currentScoreView = scoreView
            
            // setFrame() // necessary
        }
    }
    
    private func removeCurrentScoreView() {
        // remove currentView is necessary
        if let currentScoreView = currentScoreView {
            currentScoreView.removeFromSuperview()
        }
    }
    
    func populateScoreViewIDsWithScoreModel(scoreModel: DNMScoreModel) {
        let iIDsByPIDs = scoreModel.instrumentIDsAndInstrumentTypesByPerformerID
        
        // add IDs for each Performer (ScoreView), as well as the full score ("omni")
        scoreViewIDs = iIDsByPIDs.map { $0.0 } + ["omni"]
    }
    
    func showScoreWithScoreModel(scoreModel: DNMScoreModel) {
        manageColorMode()
        createEnviromentWithScoreModel(scoreModel)
    }
    
    func createEnviromentWithScoreModel(scoreModel: DNMScoreModel) {
        environment = Environment(scoreModel: scoreModel)
        environment.build()
        view.insertSubview(environment, atIndex: 0)
        
        // temp
        populateScoreViewIDsWithScoreModel(scoreModel)

        viewSelectorTableView.reloadData()
    }
    
    // MARK: - Setup
    
    func setupScoreViewTableView() {
        viewSelectorTableView.delegate = self
        viewSelectorTableView.dataSource = self
    }
    
    func manageColorMode() {
        view.backgroundColor = DNMColorManager.backgroundColor
        
        let bgView = UIView()
        bgView.backgroundColor = DNMColorManager.backgroundColor
        viewSelectorTableView.backgroundView = bgView
    }
    
    
    func goToNextPage() {
        print("go to next page")
    }
    
    func goToPreviousPage() {
        print("go to prev page")
    }
    
    
    @IBAction func didPressPreviousButton(sender: UIButton) {
        print("did press prev button")
        goToPreviousPage()
    }
    
    @IBAction func didPressNextButton(sender: UIButton) {
        print("did press next button")
        goToNextPage()
    }
    
    // MARK: - View Selector UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreViewIDs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // make a specific one
        // format:
        // PerformerID -- bold
        // - InstrumentID (InstrumentType)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("scoreSelectorCell",
            forIndexPath: indexPath
            ) as! ScoreSelectorTableViewCell
        
        cell.textLabel?.text = scoreViewIDs[indexPath.row]
        
        // SET COLOR IF VIEWER ID, or OMNI
        
        // color
        cell.textLabel?.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        cell.backgroundColor = UIColor.grayscaleColorWithDepthOfField(DepthOfField.Background)
        
        // make cleaner
        let selBGView = UIView()
        selBGView.backgroundColor = UIColor.grayscaleColorWithDepthOfField(.Middleground)
        cell.selectedBackgroundView = selBGView
        return cell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
