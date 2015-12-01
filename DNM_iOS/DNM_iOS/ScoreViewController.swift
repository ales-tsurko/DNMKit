//
//  ScoreViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// TODO: THIS IS BEING REFACTORED INTO FROM ENVIRONMENT (in-process: 2015-11-29)
class ScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI
    
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var viewSelectorTableView: UITableView!
    
    // DEPRECATE once refactored integrate contexts of _Environment into this
    //var environment: _Environment!
    
    // MARK: - Score Views
    
    /// All ScoreViews organized by ID; TODO: change ScoreView to _ScoreView once refactored
    var scoreViewsByID: [String: ScoreView] = [:]
    
    /// All ScoreViewIDs (populates ScoreViewTableView)
    var scoreViewIDs: [String] = []
    
    /// _ScoreView currently displayed; TODO: change ScoreView to _ScoreView once refactored
    var currentScoreView: ScoreView?
    
    /// Model of musical work
    var scoreModel: DNMScoreModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showScoreWithScoreModel(scoreModel: DNMScoreModel) {
        self.scoreModel = scoreModel
        populateScoreViewIDsWithScoreModel(scoreModel)
        manageColorMode()
        build()
        // test
        view.backgroundColor = UIColor.redColor()
        //createEnviromentWithScoreModel(scoreModel)
    }
    
    func build() {
        setupScoreViewTableView()
        createScoreViews()
        showScoreViewWithID("omni")
        goToFirstPage()
    }
    
    /*
    // ----------------------------------------------------------------------------------------
    // TO BE DEPRECATED
    func createEnviromentWithScoreModel(scoreModel: DNMScoreModel) {
        environment = _Environment(scoreModel: scoreModel)
        environment.build()
        view.insertSubview(environment, atIndex: 0)
        
        // temp

        
        viewSelectorTableView.reloadData()
    }
    // ----------------------------------------------------------------------------------------
    */    

    // Creates and stores a _ScoreView for each scoreViewID; 
    // TODO: change ScoreView to _ScoreView once refactored
    func createScoreViews() {
        for viewerID in scoreViewIDs {
            let scoreView = ScoreView(scoreModel: scoreModel, viewerID: viewerID)
            scoreViewsByID[viewerID] = scoreView
        }
    }
    
    func showScoreViewWithID(id: String) {
        if let scoreView = scoreViewsByID[id] {
            removeCurrentScoreView()
            
            // insert subview below any ScoreViewController UIViews
            view.insertSubview(scoreView, atIndex: 0)
            
            // set currentScoreView to this view
            currentScoreView = scoreView
            
            // setFrame() // if necessary
        }
    }
    
    private func removeCurrentScoreView() {
        // remove currentView is necessary
        if let currentScoreView = currentScoreView { currentScoreView.removeFromSuperview() }
    }
    
    func populateScoreViewIDsWithScoreModel(scoreModel: DNMScoreModel) {
        let iIDsByPIDs = scoreModel.instrumentIDsAndInstrumentTypesByPerformerID
        
        // add IDs for each Performer (_ScoreView), as well as the full score ("omni")
        scoreViewIDs = iIDsByPIDs.map { $0.0 } + ["omni"]
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
    
    
    // MARK: - Page Navigation
    
    func goToFirstPage() {
        currentScoreView?.goToFirstPage()
    }
    
    func goToLastPage() {
        currentScoreView?.goToLastPage()
    }
    
    func goToNextPage() {
        currentScoreView?.goToNextPage()
    }
    
    func goToPreviousPage() {
        currentScoreView?.goToPreviousPage()
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
