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

class MasterViewController: UIViewController,
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
    
    private var scoreModelSelected: DNMScoreModel?

    // MARK: Score Object Management
    
    var scoreObjects: [PFObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScoreSelectorTableView()
        resizeScoreSelectorTableViewIfNecessary()
        setupTextFields()
    }
    
    func setupTextFields() {
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func setupView() {
        setDefaultColorMode()
        updateColorMode()
    }
    
    func setDefaultColorMode() {
        DNMColorManager.colorMode = .Dark
    }
    
    func updateColorMode() {
        view.backgroundColor = DNMColorManager.backgroundColor
        scoreSelectorTableView.reloadData()
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
    
    func setupScoreSelectorTableView() {
        scoreSelectorTableView.delegate = self
        scoreSelectorTableView.dataSource = self
    }
    
    // being called too many times -- figure out the multithread issue here
    func resizeScoreSelectorTableViewIfNecessary() {
        
        /*
        dispatch_async(dispatch_get_main_queue()) {
            var frame = self.scoreSelectorTableView.frame
            let height = self.scoreSelectorTableView.contentSize.height
            if height <= frame.height {
                frame.size.height = height
                self.scoreSelectorTableView.frame = frame
                self.scoreSelectorTableView.scrollEnabled = false
            } else {
                self.scoreSelectorTableView.scrollEnabled = true
            }
        }
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        manageLoginStatus()
        fetchAllObjectsFromLocalDatastore()
        fetchAllObjects()
        scoreSelectorTableView.reloadData()
        resizeScoreSelectorTableViewIfNecessary()
    }
    
    func manageLoginStatus() {
        PFUser.currentUser() == nil ? enterSignInMode() : enterSignedInMode()
    }
    
    func updateLoginStatusLabel() {
        if let username = PFUser.currentUser()?.username {
            loginStatusLabel.hidden = false
            loginStatusLabel.text = "logged in as \(username)"
        } else {
            loginStatusLabel.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == "showScore" {
            let scoreViewController = segue.destinationViewController as! ScoreViewController
            if let scoreModel = scoreModelSelected {
                scoreViewController.showScoreWithScoreModel(scoreModel)
            }
        }
    }
    
    func makeScoreModelWithString(string: String) -> DNMScoreModel {
        let tokenizer = Tokenizer()
        let tokenContainer = tokenizer.tokenizeString(string)
        let parser = Parser()
        let scoreModel = parser.parseTokenContainer(tokenContainer)
        return scoreModel
    }
    
    func fetchAllObjectsFromLocalDatastore() {
        if let username = PFUser.currentUser()?.username {
            let query = PFQuery(className: "Score")
            query.fromLocalDatastore()
            query.whereKey("username", equalTo: username)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> () in
                if let error = error { print(error) }
                else if let objects = objects {
                    self.scoreObjects = objects
                    self.scoreSelectorTableView.reloadData()
                    self.resizeScoreSelectorTableViewIfNecessary()
                }
            }
        }
    }
    
    func fetchAllObjects() {
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
    
    //
    func enterSignInMode() {

        // hide score selector table view -- later: animate offscreen left
        scoreSelectorTableView.hidden = true
        
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
        
        
        scoreSelectorTableView.hidden = false
        
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

    
    @IBAction func didEnterUsername(sender: AnyObject) {
    
        passwordField.becomeFirstResponder()
    }
    
    
    @IBAction func didEnterPassword(sender: AnyObject) {

        if let username = usernameField.text, password = passwordField.text {
            
            // make sure its legit
            if username.characters.count > 0 && password.characters.count >= 8 {
                
                // disable keyboard
                passwordField.resignFirstResponder()
                
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
        print("sign in or out or up")
        
        // don't this by text
        
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
        if let title = signInOrUpButton.currentTitle {
            if title == "SIGN UP?" {
                enterSignUpmMode()
            } else if title == "SIGN IN?" {
                enterSignInMode()
            }
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let scoreString = scoreObjects[indexPath.row]["text"] {
            let scoreModel = makeScoreModelWithString(scoreString as! String)
            scoreModelSelected = scoreModel
            performSegueWithIdentifier("showScore", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreObjects.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didChangeValueOfSwitch(sender: UISwitch) {
        
        // state on = dark, off = light
        switch sender.on {
        case true: DNMColorManager.colorMode = ColorMode.Dark
        case false: DNMColorManager.colorMode = ColorMode.Light
        }
        updateColorMode()
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
