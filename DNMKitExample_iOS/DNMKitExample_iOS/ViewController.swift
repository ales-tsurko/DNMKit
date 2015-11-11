//
//  ViewController.swift
//  DNMKitExample_iOS
//
//  Created by James Bean on 10/31/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import UIKit
import DNMConverter
import DNMUtility
import DNMModel
import DNMView
import DNMUI

// TODO: Reintegrate ViewSelector
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var scoreTableView: UITableView!
    var scoreModelByTitle: [String : DNMScoreModel] = [:]
    var scoreTitles: [String] = []
    var environment: Environment!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DNMColorManager.colorMode = ColorMode.Dark
        view.backgroundColor = DNMColorManager.backgroundColor
        

        let fileName = "tokenize"
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "dnm")!
        let code = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        
        //let str = "#\n| 3 16 VC cc \np 60 d pppfo [ a - . > (\n p 60.25 93 ) \n"
        let tokenizer = Tokenizer()
        let tokenContainer = tokenizer.tokenizeString(code)
        
        //let parser = Parser()
        //let scoreModel = parser.parseTokenContainer(tokenContainer)
        
        //print(tokenContainer)
        //print(scoreModel)

        /*
        for measure in scoreModel.measures {
            print(measure)
        }
        */
        
        //addScoreTableView()
        
        //let environment = Environment(scoreModel: scoreModel)
        //view.addSubview(environment)
        
        /*
        let point1 = CGPoint(x: 100, y: 100)
        let point2 = CGPoint(x: 435.265, y: 200)
        
        let bezierCurve = BezierCurveLinear(point1: point1, point2: point2)
        var styledCurve: StyledBezierCurve = ConcreteStyledBezierCurve(carrierCurve: bezierCurve)
        
        styledCurve = BezierCurveStyleWidthVariable(
            styledBezierCurve: styledCurve,
            widthAtBeginning: 50,
            widthAtEnd: 1
        )
        
        styledCurve = BezierCurveStylerDashes(styledBezierCurve: styledCurve, dashWidth: 20)
        
        let shape = CAShapeLayer()
        shape.path = styledCurve.uiBezierPath.CGPath
        shape.fillColor = UIColor.grayColor().CGColor
        //view.layer.addSublayer(shape)
        */

        /*
        addScoreTableView()
        */
    }
    
    func addScoreTableView() {
        scoreModelByTitle = DNMScoreModelManager().scoreModelByTitle()
        for (title, _) in scoreModelByTitle { scoreTitles.append(title) }
        
        // this is sloppy
        let cellHeight: CGFloat = 40
        scoreTableView = UITableView(frame:
            CGRect(x: 25, y: 25, width: 200, height: cellHeight * CGFloat(scoreTitles.count))
        )
        scoreTableView.dataSource = self
        scoreTableView.delegate = self
        scoreTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        scoreTableView.tableFooterView = UIView(frame: CGRectZero)
        view.addSubview(scoreTableView)
    }
    
    func showScoreWithTitle(title: String) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        scoreTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if let title = cell.textLabel?.text {
            if let scoreModel = scoreModelByTitle[title] {
                tableView.removeFromSuperview()
                self.environment = Environment(scoreModel: scoreModel)
                self.environment.build()
                view.addSubview(environment)
                addMenuButton()
            }
        }
    }
    
    func addMenuButton() {
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        menuButton.setTitle("menu", forState: UIControlState.Normal)
        menuButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        menuButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        menuButton.layer.position.y = view.frame.height - (0.5 * menuButton.frame.height)
        menuButton.layer.position.x = 0.5 * view.frame.width
        menuButton.addTarget(self, action: "goToMainPage", forControlEvents: .TouchUpInside)
        view.addSubview(menuButton)
        
    }
    
    func goToMainPage() {
        if environment.superview != nil { environment.removeFromSuperview() }
        view.addSubview(scoreTableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
            forIndexPath: indexPath
        )
        let title = scoreTitles[indexPath.row]
        cell.textLabel?.text = title

        cell.backgroundColor = DNMColorManager.backgroundColor
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        cell.selectedBackgroundView?.backgroundColor = UIColor.grayscaleColorWithDepthOfField(.Background)
        cell.textLabel?.textColor = UIColor.grayscaleColorWithDepthOfField(.Foreground)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)
        -> CGFloat {
        return 40
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

