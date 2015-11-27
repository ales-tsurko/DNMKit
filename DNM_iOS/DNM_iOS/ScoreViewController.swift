//
//  ScoreViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
