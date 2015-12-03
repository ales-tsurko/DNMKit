//
//  ScoreViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel


public class ScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI
    
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var viewSelectorTableView: UITableView!
    
    // MARK: - Score Views
    
    /// All ScoreViews organized by ID
    private var scoreViewsByID = OrderedDictionary<PerformerID, ScoreView>()
    
    /// All ScoreViewIDs (populates ScoreViewTableView) // performerIDs + "omni"
    private var scoreViewIDs: [PerformerID] = []

    // Identifiers for each PerformerView in the ensemble
    private var performerIDs: [PerformerID] = []
    
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
    
    /**
    Show the ScoreView with a PerformerID
    
    - parameter id: PerformerID
    */
    public func showScoreViewWithID(id: PerformerID) {
        if let scoreView = scoreViewsByID[id] {
            removeCurrentScoreView()
            showScoreView(scoreView)
        }
    }
    
    private func createScoreViews() {
        for viewerID in scoreViewIDs {
            let peerIDs = performerIDs.filter { $0 != viewerID }
            let scoreView = ScoreView(
                scoreModel: scoreModel, viewerID: viewerID, peerIDs: peerIDs
            )
            scoreViewsByID[viewerID] = scoreView
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
        setViewSelectorTableViewBackground()
    }
    
    private func setViewSelectorTableViewBackground() {
        let bgView = UIView()
        bgView.backgroundColor = DNMColorManager.backgroundColor
        viewSelectorTableView.backgroundView = bgView
    }
    
    // MARK: - PageLayer Navigation
    
    /**
    Go to the first page of the currently displayed ScoreView
    */
    public func goToFirstPage() {
        currentScoreView?.goToFirstPage()
    }

    /**
    Go to the last page of the currently displayed ScoreView
    */
    public func goToLastPage() {
        currentScoreView?.goToLastPage()
    }
    
    /**
    Go to the next page of the currently displayed ScoreView
    */
    public func goToNextPage() {
        currentScoreView?.goToNextPage()
    }
    
    /**
    Go to the previous page of the currently displayed ScoreView
    */
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
    
    // extend beyond title
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("scoreSelectorCell",
            forIndexPath: indexPath
        ) as! ScoreSelectorTableViewCell
        
        let viewerID = scoreViewIDs[indexPath.row]
        
        // do all this in ScoreSelectorTableViewCell implementation
        cell.identifier = viewerID
        cell.textLabel?.text = viewerID
        setVisualAttributesOfTableViewCell(cell)
        resizeViewSelectorTableView()
        return cell
    }

    // do this in ScoreSelectorTableViewCell
    private func setVisualAttributesOfTableViewCell(cell: UITableViewCell) {
        cell.textLabel?.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        cell.backgroundColor = UIColor.grayscaleColorWithDepthOfField(DepthOfField.Background)

        let selBGView = UIView()
        selBGView.backgroundColor = UIColor.grayscaleColorWithDepthOfField(.Middleground)
        cell.selectedBackgroundView = selBGView
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
