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
    
    // MARK: - Score Views
    
    /// All ScoreViews organized by ID
    private var scoreViewsByID = OrderedDictionary<String, ScoreView>()
    
    /// All ScoreViewIDs (populates ScoreViewTableView) // performerIDs + "omni"
    private var scoreViewIDs: [String] = []

    // Identifiers for each PerformerView in the ensemble
    private var performerIDs: [String] = []
    
    /// ScoreView currently displayed
    private var currentScoreView: ScoreView?
    
    /// Model of an entire musical work
    public var scoreModel: DNMScoreModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func showScoreWithScoreModel(scoreModel: DNMScoreModel) {
        self.scoreModel = scoreModel // maybe don't make this an ivar?
        setPerformerIDsWithScoreModel(scoreModel)
        setScoreViewIDsWithScoreModel(scoreModel)
        manageColorMode()
        build()
    }
    
    private func build() {
        setupScoreViewTableView()
        createScoreViews()
        showScoreViewWithID("omni")
        goToFirstPage()
    }

    // MARK: ScoreView Management
    
    private func createScoreViews() {
        for viewerID in scoreViewIDs {
            let peerIDs: [String] = performerIDs.filter { $0 != viewerID }
            let scoreView = ScoreView(
                scoreModel: scoreModel, viewerID: viewerID, peerIDs: peerIDs
            )
            scoreViewsByID[viewerID] = scoreView
        }
    }
    
    public func showScoreViewWithID(id: String) {
        if let scoreView = scoreViewsByID[id] {
            removeCurrentScoreView()
            showScoreView(scoreView)
        }
    }
    
    private func showScoreView(scoreView: ScoreView) {
        view.insertSubview(scoreView, atIndex: 0)
        currentScoreView = scoreView
    }
    
    private func removeCurrentScoreView() {
        if let currentScoreView = currentScoreView { currentScoreView.removeFromSuperview() }
    }
    
    private func setPerformerIDsWithScoreModel(scoreModel: DNMScoreModel) {
        performerIDs = scoreModel.instrumentIDsAndInstrumentTypesByPerformerID.keys
    }
    
    private func setScoreViewIDsWithScoreModel(scoreModel: DNMScoreModel) {
        scoreViewIDs = performerIDs + ["omni"]
    }
    
    // MARK: - UI Setup
    
    private func setupScoreViewTableView() {
        viewSelectorTableView.delegate = self
        viewSelectorTableView.dataSource = self
        viewSelectorTableView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        viewSelectorTableView.translatesAutoresizingMaskIntoConstraints = true
        positionViewSelectorTableView()
    }
    
    private func manageColorMode() {
        view.backgroundColor = DNMColorManager.backgroundColor
        
        // wrap this up in a method
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
    
    private func resizeViewSelectorTableView() {
        let contentsHeight = viewSelectorTableView.contentSize.height
        let frameHeight = viewSelectorTableView.frame.height
        if contentsHeight <= frameHeight {
            var frame = viewSelectorTableView.frame
            frame.size.height = contentsHeight
            viewSelectorTableView.frame = frame
        }
    }
    
    private func positionViewSelectorTableView() {
        let pad: CGFloat = 20
        let right = view.bounds.width
        let centerX = right - 0.5 * viewSelectorTableView.frame.width - pad
        viewSelectorTableView.layer.position.x = centerX
    }
    
    // MARK: - View Selector UITableViewDelegate

    public func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath
    )
    {
        if let identifier = (tableView.cellForRowAtIndexPath(indexPath)
            as? ScoreSelectorTableViewCell)?.identifier
        {
            showScoreViewWithID(identifier)
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreViewIDs.count
    }
    
    // TODO: CLEANUP, add Fields
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        // PerformerID -- bold
        // - InstrumentID (InstrumentType)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("scoreSelectorCell",
            forIndexPath: indexPath
        ) as! ScoreSelectorTableViewCell
        
        let viewerID = scoreViewIDs[indexPath.row]
        cell.identifier = viewerID
        cell.textLabel?.text = viewerID
        
        // SET COLOR IF VIEWER ID, or OMNI
        
        // manageStyling within ScoreSelectorTableViewCell
        // color
        cell.textLabel?.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        cell.backgroundColor = UIColor.grayscaleColorWithDepthOfField(DepthOfField.Background)
        

        
        // make cleaner
        let selBGView = UIView()
        selBGView.backgroundColor = UIColor.grayscaleColorWithDepthOfField(.Middleground)
        cell.selectedBackgroundView = selBGView
        
        resizeViewSelectorTableView()
        
        return cell
    }
    
    /*
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    */
    
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
