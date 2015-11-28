//
//  ScoreViewController.swift
//  DNM_iOS
//
//  Created by James Bean on 11/26/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMModel

class ScoreViewController: UIViewController {

    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    var environment: Environment!
    
    var scoreModel: DNMScoreModel?
    var scoreString: String?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, scoreString: String?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.scoreString = scoreString
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func manageColorMode() {
        
        DNMColorManager.colorMode = .Light
        view.backgroundColor = DNMColorManager.backgroundColor
    }
    
    func showScoreWithScoreModel(scoreModel: DNMScoreModel) {
        manageColorMode()
        createEnviromentWithScoreModel(scoreModel)
    }
    
    func createEnviromentWithScoreModel(scoreModel: DNMScoreModel) {
        environment = Environment(scoreModel: scoreModel)
        environment.build()
        view.addSubview(environment)
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
