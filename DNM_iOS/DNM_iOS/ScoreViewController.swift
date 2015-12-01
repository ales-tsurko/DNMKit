//
//  ScoreViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

// TODO: THIS IS BEING REFACTORED INTO FROM ENVIRONMENT (in-process: 2015-12-01)
public class ScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI
    
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var viewSelectorTableView: UITableView!
    
    // DEPRECATE once refactored integrate contexts of _Environment into this
    //var environment: _Environment!
    
    // MARK: - Score Views
    
    /// All ScoreViews organized by ID
    private var scoreViewsByID = OrderedDictionary<String, ScoreView>()
    
    /// All ScoreViewIDs (populates ScoreViewTableView)
    private var scoreViewIDs: [String] = []
    
    /// _ScoreView currently displayed; TODO: change ScoreView to _ScoreView once refactored
    private var currentScoreView: ScoreView?
    
    /// Model of musical work
    public var scoreModel: DNMScoreModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func showScoreWithScoreModel(scoreModel: DNMScoreModel) {
        self.scoreModel = scoreModel
        populateScoreViewIDsWithScoreModel(scoreModel)
        manageColorMode()
        build()
    }
    
    private func build() {
        setupScoreViewTableView()
        createScoreViews()
        showScoreViewWithID("omni")
        goToFirstPage()
    }

    private func createScoreViews() {
        for viewerID in scoreViewIDs {
            let scoreView = ScoreView(scoreModel: scoreModel, viewerID: viewerID)
            scoreViewsByID[viewerID] = scoreView
        }
    }
    
    public func showScoreViewWithID(id: String) {
        if let scoreView = scoreViewsByID[id] {
            removeCurrentScoreView()
            view.insertSubview(scoreView, atIndex: 0)
            currentScoreView = scoreView
        }
    }
    
    private func removeCurrentScoreView() {
        // remove currentView is necessary
        if let currentScoreView = currentScoreView { currentScoreView.removeFromSuperview() }
    }
    
    private func populateScoreViewIDsWithScoreModel(scoreModel: DNMScoreModel) {
        let iIDsByPIDs = scoreModel.instrumentIDsAndInstrumentTypesByPerformerID
        scoreViewIDs = iIDsByPIDs.map { $0.0 } + ["omni"]
    }
    
    // MARK: - Setup
    
    private func setupScoreViewTableView() {
        viewSelectorTableView.delegate = self
        viewSelectorTableView.dataSource = self
    }
    
    private func manageColorMode() {
        view.backgroundColor = DNMColorManager.backgroundColor
        
        let bgView = UIView()
        bgView.backgroundColor = DNMColorManager.backgroundColor
        viewSelectorTableView.backgroundView = bgView
    }
    
    // MARK: - PageLayer Navigation
    
    public func goToFirstPage() {
        currentScoreView?.goToFirstPage()
    }
    
    public func goToLastPage() {
        currentScoreView?.goToLastPage()
    }
    
    public func goToNextPage() {
        currentScoreView?.goToNextPage()
    }
    
    public func goToPreviousPage() {
        currentScoreView?.goToPreviousPage()
    }
    
    @IBAction func didPressPreviousButton(sender: UIButton) {
        goToPreviousPage()
    }
    
    @IBAction func didPressNextButton(sender: UIButton) {
        goToNextPage()
    }
    
    // MARK: - View Selector UITableViewDelegate
    
    public func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath
    )
    {
        
        if let scoreView = tableView.cellForRowAtIndexPath(indexPath)
            as? ScoreSelectorTableViewCell
        {
            
        }
        // TODO: decouple representation and reference: in ScoreSelectorTableViewCell
        if let id = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text {
            showScoreViewWithID(id)
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreViewIDs.count
    }
    
    // TODO: CLEANUP
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        
        // make a specific one
        // format:
        // PerformerID -- bold
        // - InstrumentID (InstrumentType)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("scoreSelectorCell",
            forIndexPath: indexPath
        ) as! ScoreSelectorTableViewCell
        
        // set scoreView of cell
        cell.identifier = scoreViewIDs[indexPath.row]
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
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func didReceiveMemoryWarning() {
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
