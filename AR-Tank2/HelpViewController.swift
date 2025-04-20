//
//  HelpViewController.swift
//  AR-Tank2
//
//  Created by 田代純也 on 2024/01/10.
//

import Foundation
import SceneKit

class HelpViewController: UIViewController {
    
    let scrollView: UIScrollView = UIScrollView()
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    var y: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = myBlue
        
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        
        let helpLabel = UILabel(frame: CGRectMake(0, 0, 150, 50))
        helpLabel.center = CGPoint(x: screenWidth / 2, y: 25)
        helpLabel.text = NSLocalizedString("Help", comment: "")
        helpLabel.textColor = UIColor.white
        helpLabel.textAlignment = .center
        helpLabel.font = UIFont.systemFont(ofSize: 25)
        self.view.addSubview(helpLabel)
        
        addTitle(txt: "How to play")
        
        addBody(txt: "In this stage, you control your tank not by yourself but by program.")
        addBody(txt: "During the battle, your tank repeats the program edited here.")
        
        addTitle(txt: "How to controll tank by program")
        
        addBody(txt: "By changing the value of the Bool variable [shoot] to True, your tank shoots a bullet.")
        addBody(txt: "By changing the value of the Int variables [ref_x] and [ref_y], the x-coordinate and y-coordinate of your tank's aim are updated.")
        addBody(txt: "By setting a route from the [Path] menu, you can input a movement plan into your tank.")
        addBody(txt: "Once inputted, your tank's movement plan will not be updated until the movement plan is completed or STOP order is sent.")
        addBody(txt: "The Int variable [count] is the current number of turns.")
        addBody(txt: "The Tank variable [self] is your tank.")
        addBody(txt: "The Tank list [enemys] is a list of all living enemy tanks.")
        addBody(txt: "The bullet type list [bullets] is a list of all bullets on the field released by tanks other than your tank.")
        
        addTitle(txt: "How to use program blocks")
        
        addBody(txt: "There are five types of variables and lists: Bool, Int, Float, Tank, and Bullet.")
        addBody(txt: "Tank variable has two values: x and y, which means x-coordinate and y-coordinate.")
        addBody(txt: "Bullet variable has three values: x, y, and θ, which means x-coordinate, y-coordinate, and angle of bullet.")
        addBody(txt: "For list, you can do two operations: [initialize] and [add elements to the end].")
        addBody(txt: "[If] block executes the processing of the indented blocks if the following condition is true.")
        addBody(txt: "[While] block repeats the processing of the indented blocks while the following condition is true.")
        addBody(txt: "[For] block repeats the process of the indented blocks, assigning each element of the list to specified variable in turn.")
        
        scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 50)
        scrollView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 + 25)
        scrollView.contentSize = CGSize(width: screenWidth, height: y + 100)
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
    }
    
    func addTitle(txt: String) {
        y += 15
        
        let label = UILabel(frame: CGRectMake(0, 0, screenWidth - 40, 50))
        label.text = NSLocalizedString(txt, comment: "")
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20)
        let size = label.sizeThatFits(CGSize(width: label.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        label.center.x = 10 + label.frame.width / 2
        label.center.y = y + label.frame.height / 2
        self.scrollView.addSubview(label)
        
        y += label.frame.height + 15
        
        let bar = UILabel(frame: CGRectMake(0, 0, screenWidth - 15, 2))
        bar.backgroundColor = myBlue
        bar.center.x = screenWidth / 2
        bar.center.y = y - 10
        self.scrollView.addSubview(bar)
    }
    
    func addBody(txt: String) {
        let dotLabel = UILabel(frame: CGRectMake(0, 0, 20, 50))
        dotLabel.text = "・"
        dotLabel.textColor = myBlue
        dotLabel.font = UIFont.systemFont(ofSize: 17)
        let dotSize = dotLabel.sizeThatFits(CGSize(width: dotLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        dotLabel.frame = CGRect(x: 0, y: 0, width: dotSize.width, height: dotSize.height)
        dotLabel.center.x = 15
        dotLabel.center.y = y + dotLabel.frame.height / 2
        self.scrollView.addSubview(dotLabel)
        
        let label = UILabel(frame: CGRectMake(0, 0, screenWidth - 40, 50))
        label.text = NSLocalizedString(txt, comment: "")
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
        let size = label.sizeThatFits(CGSize(width: label.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        label.center.x = 25 + label.frame.width / 2
        label.center.y = y + label.frame.height / 2
        self.scrollView.addSubview(label)
        
        y += label.frame.height + 5
    }
}
