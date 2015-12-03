//
//  MasterViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel
import Parse
import Bolts

// TODO: manage signed in / signed out: tableview.reloadData

public class MasterViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate
{
    // MARK: - UI
    
    @IBOutlet weak var scoreSelectorTableView: UITableView!
    @IBOutlet weak var colorModeLabel: UILabel!
    @IBOutlet weak var colorModeLightLabel: UILabel!
    @IBOutlet weak var colorModeDarkLabel: UILabel!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var signInOrOutOrUpButton: UIButton!
    @IBOutlet weak var signInOrUpButton: UIButton!
    @IBOutlet weak var dnmLogoLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - Model
    
    private var scoreModelSelected: DNMScoreModel?
    
    // MARK: - Views
    
    // change to PerformerInterfaceView
    private var viewByID: [String: ScoreView] = [:]
    private var currentView: ScoreView?
    
    // MARK: - Score Object Management
    
    private var scoreObjects: [PFObject] = []
    private var loginState: LoginState = .SignIn
    
    // MARK: - Startup
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScoreSelectorTableView()
        setupTextFields()
    }
    
    public override func viewDidAppear(animated: Bool) {
        manageLoginStatus() // necessary to wait until viewDidAppear?
        fetchAllObjectsFromLocalDatastore()
        fetchAllObjects()
    }
    
    private func setupView() {
        updateUIForColorMode()
    }
    
    private func setupScoreSelectorTableView() {
        scoreSelectorTableView.delegate = self
        scoreSelectorTableView.dataSource = self
    }
    
    private func setupTextFields() {
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    // MARK: - UI
    
    @IBAction func didEnterUsername(sender: AnyObject) {
        
        // move on to password field
        passwordField.becomeFirstResponder()
    }
    
    
    @IBAction func didEnterPassword(sender: AnyObject) {
        
        if let username = usernameField.text, password = passwordField.text {
            
            // make sure the username and password is legit legit
            if username.characters.count > 0 && password.characters.count >= 8 {
                
                // disable keyboard
                passwordField.resignFirstResponder()
                
                // don't do this by the text of the button: enum LoginState { }
                switch signInOrOutOrUpButton.currentTitle! {
                case "SIGN UP":
                    let user = PFUser()
                    user.username = username
                    user.password = password
                    do {
                        try user.signUp()
                        enterSignedInMode()
                    }
                    catch {
                        print("could not sign up user")
                        // manage this in the UI
                    }
                    
                case "SIGN IN":
                    do {
                        try PFUser.logInWithUsername(username, password: password)
                        enterSignedInMode()
                    }
                    catch {
                        print(error)
                    }
                default: break
                }
            }
        }
    }
    
    @IBAction func didPressSignInOrOutOrUpButton(sender: AnyObject) {
        // don't do this with the text
        if let title = signInOrOutOrUpButton.currentTitle {
            if title == "SIGN OUT?" {
                if PFUser.currentUser() != nil {
                    PFUser.logOutInBackground()
                    scoreObjects = []
                    scoreSelectorTableView.reloadData()
                    enterSignInMode()
                }
            }
        }
    }
    
    @IBAction func didPressSignInOrUpButton(sender: AnyObject) {
        // don't do this with text!
        if let title = signInOrUpButton.currentTitle {
            if title == "SIGN UP?" {
                enterSignUpmMode()
            } else if title == "SIGN IN?" {
                enterSignInMode()
            }
        }
    }
    
    @IBAction func didChangeValueOfSwitch(sender: UISwitch) {
        
        // state on = dark, off = light
        switch sender.on {
        case true: DNMColorManager.colorMode = ColorMode.Dark
        case false: DNMColorManager.colorMode = ColorMode.Light
        }
        updateUIForColorMode()
    }
    
    private func updateUIForColorMode() {
        view.backgroundColor = DNMColorManager.backgroundColor
        scoreSelectorTableView.reloadData()
        
        // enscapsulate
        let bgView = UIView()
        bgView.backgroundColor = DNMColorManager.backgroundColor
        scoreSelectorTableView.backgroundView = bgView
        
        loginStatusLabel.textColor = UIColor.grayscaleColorWithDepthOfField(.MiddleForeground)
        
        colorModeLabel.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        colorModeLightLabel.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        colorModeDarkLabel.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        
        // textfields
        usernameField.backgroundColor = UIColor.grayscaleColorWithDepthOfField(.Background)
        usernameField.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        passwordField.backgroundColor = UIColor.grayscaleColorWithDepthOfField(.Background)
        passwordField.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        
        dnmLogoLabel.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
    }
    
    
    func updateLoginStatusLabel() {
        if let username = PFUser.currentUser()?.username {
            loginStatusLabel.hidden = false
            loginStatusLabel.text = "logged in as \(username)"
        } else {
            loginStatusLabel.hidden = true
        }
    }
    
    private func showScoreSelectorTableView() {
        scoreSelectorTableView.hidden = false
    }
    
    private func hideScoreSelectorTableView() {
        scoreSelectorTableView.hidden = true
    }
    
    // MARK: - Parse Management
    
    func manageLoginStatus() {
        PFUser.currentUser() == nil ? enterSignInMode() : enterSignedInMode()
    }
    
    func enterSignInMode() {
        
        // hide score selector table view -- later: animate offscreen left
        hideScoreSelectorTableView()
        
        signInOrOutOrUpButton.hidden = false
        signInOrOutOrUpButton.setTitle("SIGN IN", forState: .Normal)
        
        signInOrUpButton.hidden = false
        signInOrUpButton.setTitle("SIGN UP?", forState: .Normal)
        
        loginStatusLabel.hidden = true
        
        usernameField.hidden = false
        passwordField.hidden = false
    }
    
    // signed in
    func enterSignedInMode() {
        fetchAllObjectsFromLocalDatastore()
        fetchAllObjects()
        showScoreSelectorTableView()
        updateLoginStatusLabel()
        
        // hide username field, clear contents
        usernameField.hidden = true
        usernameField.text = nil
        
        // hide password field, clear contents
        passwordField.hidden = true
        passwordField.text = nil
        
        signInOrUpButton.hidden = true
        
        signInOrOutOrUpButton.hidden = false
        signInOrOutOrUpButton.setTitle("SIGN OUT?", forState: .Normal)
    }
    
    // need to sign up
    func enterSignUpmMode() {
        signInOrOutOrUpButton.setTitle("SIGN UP", forState: .Normal)
        signInOrUpButton.setTitle("SIGN IN?", forState: .Normal)
    }
    
    // MARK: - UITableViewDelegate Methods
    
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
            forIndexPath: indexPath
            ) as! ScoreSelectorTableViewCell
        
        // text
        cell.textLabel?.text = scoreObjects[indexPath.row]["title"] as? String
        
        // color
        cell.textLabel?.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        cell.backgroundColor = UIColor.grayscaleColorWithDepthOfField(DepthOfField.Background)
        
        // make cleaner
        let selBGView = UIView()
        selBGView.backgroundColor = UIColor.grayscaleColorWithDepthOfField(.Middleground)
        cell.selectedBackgroundView = selBGView
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let scoreString = scoreObjects[indexPath.row]["text"] {
            let scoreModel = makeScoreModelWithString(scoreString as! String)
            scoreModelSelected = scoreModel
            performSegueWithIdentifier("showScore", sender: self)
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == "showScore" {
            let scoreViewController = segue.destinationViewController as! ScoreViewController
            if let scoreModel = scoreModelSelected {
                scoreViewController.showScoreWithScoreModel(scoreModel)
            }
        }
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int)
        -> UIView?
    {
        return UIView(frame: CGRectZero)
    }
    
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreObjects.count
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Parse
    
    private func fetchAllObjectsFromLocalDatastore() {
        if let username = PFUser.currentUser()?.username {
            let query = PFQuery(className: "Score")
            query.fromLocalDatastore()
            query.whereKey("username", equalTo: username)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> () in
                if let error = error { print(error) }
                else if let objects = objects {
                    self.scoreObjects = objects
                    self.scoreSelectorTableView.reloadData()
                }
            }
        }
    }
    
    private func fetchAllObjects() {
        if let username = PFUser.currentUser()?.username {
            PFObject.unpinAllObjectsInBackground()
            let query = PFQuery(className: "Score")
            query.whereKey("username", equalTo: username)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> () in
                
                if let objects = objects where error == nil {
                    self.scoreObjects = objects
                    do {
                        try PFObject.pinAll(objects)
                    }
                    catch {
                        print("couldnt pin")
                    }
                    self.fetchAllObjectsFromLocalDatastore()
                }
            }
        }
    }
    
    // MARK: - Model
    
    public func makeScoreModelWithString(string: String) -> DNMScoreModel {
        let tokenizer = Tokenizer()
        let tokenContainer = tokenizer.tokenizeString(string)
        let parser = Parser()
        let scoreModel = parser.parseTokenContainer(tokenContainer)
        return scoreModel
    }
}

private enum LoginState {
    case SignedIn, SignIn, SignUp
}
