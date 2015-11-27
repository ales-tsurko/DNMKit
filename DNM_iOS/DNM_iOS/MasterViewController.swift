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

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var signInOrUpOrOnLabel: UILabel!
    @IBOutlet weak var signInOrUpLabel: UILabel!
    @IBOutlet weak var dnmLogoLabel: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    // MARK: Score Object Management
    var scoreObjects: [PFObject] = []
    
    // kill
    let testUsername = "jsbean"
    let testPassword = "w1pjcmyk"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = UIColor.grayColor().CGColor
        tableView.layer.borderWidth = 1
    }
    
    func manageLoginStatus() {

        if PFUser.currentUser() == nil {
            PFUser.logInWithUsernameInBackground(testUsername, password: testPassword) {
                (user, error) -> () in
                if let error = error { print("could not log in: \(error)") }
            }
            enterSignInMode()
        }
        else { enterSignedInMode() }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        fetchAllObjectsFromLocalDatastore()
        fetchAllObjects()
        
        print("about to reload table view data")
        tableView.reloadData()
    }
    
    func addTestObject() {
        print("add test object")
        
        // need to get url of files (perhaps that are presaved?)
        
        let string = "p 60 d fff a -"
        if let scoreData = string.dataUsingEncoding(NSUTF8StringEncoding) {
            let score = PFObject(className: "Score")
            score["username"] = testUsername
            score["title"] = "newest piece"
            //score["score"] = scoreFile
            score["text"] = "yes yes yes yes yes"
            print("scoreObj: \(score)")
            
            score.saveEventually { (success, error) -> Void in
                if success {
                    print("success!")
                }
                else {
                    
                }
                if let error = error {
                    print("could not save: \(error)")
                }
            }
        }
    }
    
    func fetchAllObjectsFromLocalDatastore() {
        print("fetch all objects from local datastore")
        let query = PFQuery(className: "Score")
        query.fromLocalDatastore()
        query.whereKey("username", equalTo: testUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> () in
            
            print("find objects with block: objects: \(objects); error: \(error)")
            
            if let error = error { print(error) }
            else if let objects = objects {
                self.scoreObjects = objects
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchAllObjects() {
        
        PFObject.unpinAllObjectsInBackground()
        
        let query = PFQuery(className: "Score")
        query.whereKey("username", equalTo: testUsername)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> () in
            if let error = error {
                // error
            }
            else if let objects = objects {
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
    
    //
    func enterSignInMode() {
        print("enter sign in mode")
        loginStatusLabel.hidden = true
        usernameField.hidden = false
        passwordField.hidden = false
    }
    
    // signed in
    func enterSignedInMode() {
        usernameField.hidden = true
        passwordField.hidden = true
        loginStatusLabel.hidden = false
        if let username = PFUser.currentUser()?.username {
            loginStatusLabel.text = "logged in as \(username)"
        }
    }
    
    // need to sign up
    func enterSignUpmMode() {
        print("enter sign up mode")
    }


    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        
        print("tableview cell for row at index path: \(indexPath.row)")
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
            forIndexPath: indexPath
        ) as! MasterTableViewCell
        cell.textLabel?.text = scoreObjects[indexPath.row]["title"] as? String
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row at indexPath: \(indexPath)")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreObjects.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
