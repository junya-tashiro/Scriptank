//
//  Member.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/13.
//

import Foundation
import SwiftUI

class Member {
    let view: UIView
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myRed = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0)
    let name: String
    let initID: String
    var ID: String
    var index: Int
    var levelIndex: Int = 0
    let cpu: [String] = ["Lv.0", "Lv.1", "Lv.2", "Lv.3", "Lv.4"]
    let screenWidth: CGFloat
    var isCpu: Bool
    let updateShowFunc: () -> ()
    var team: Bool = false
    let label = UILabel(frame: CGRectMake(0, 0, 150, 50))
    let button = UIButton(frame: CGRectMake(0, 0, 40, 40))
    let deleteButton = UIButton(frame: CGRectMake(0, 0, 20, 20))
    let levelButton = UIButton(frame: CGRectMake(0, 0, 60, 30))
    var deleteFlag: Bool = false
    init(view: UIView, name: String, ID: String, index: Int, screenWidth: CGFloat, isCpu: Bool, updateShowFunc: @escaping () -> ()) {
        self.view = view
        self.name = name
        self.initID = ID
        self.ID = ID
        self.index = index
        self.screenWidth = screenWidth
        self.isCpu = isCpu
        self.updateShowFunc = updateShowFunc
        self.label.center.x = screenWidth / 2 - 45
        self.label.center.y = CGFloat(210 + 50 * index)
        self.label.text = self.name
        self.label.textColor = .black
        self.button.center.x = screenWidth / 2 + 45
        self.button.center.y = CGFloat(210 + 50 * index)
        self.button.layer.cornerRadius = 5
        self.button.backgroundColor = myBlue
        self.button.addTarget(self, action: #selector(self.changeTeam(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.label)
        self.view.addSubview(self.button)
        if isCpu {
            self.deleteButton.center.x = screenWidth / 2 + 90
            self.deleteButton.center.y = CGFloat(210 + 50 * index)
            self.deleteButton.setTitle("-", for: UIControl.State.normal)
            self.deleteButton.backgroundColor = myRed
            self.deleteButton.layer.cornerRadius = self.deleteButton.frame.height / 2
            self.deleteButton.addTarget(self, action: #selector(self.deleteBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(self.deleteButton)
            
            self.levelButton.center.x = screenWidth / 2 - 30
            self.levelButton.center.y = CGFloat(210 + 50 * index)
            self.levelButton.backgroundColor = UIColor.darkGray
            self.levelButton.setTitle(self.cpu[self.levelIndex], for: UIControl.State.normal)
            self.levelButton.layer.cornerRadius = 5
            self.levelButton.addTarget(self, action: #selector(self.levelBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(self.levelButton)
            
            self.ID = self.initID + "-" + self.cpu[self.levelIndex]
        }
        self.updateShowFunc()
    }
    
    func updatePosition(idx: Int) {
        self.index = idx
        self.label.center.y = CGFloat(210 + 50 * index)
        self.button.center.y = CGFloat(210 + 50 * index)
        if isCpu {
            self.deleteButton.center.y = CGFloat(210 + 50 * index)
            self.levelButton.center.y = CGFloat(210 + 50 * index)
        }
    }
    
    func goBattle() {
        self.label.isHidden = true
        self.button.isHidden = true
        self.deleteButton.isHidden = true
        self.levelButton.isHidden = true
    }
    
    @IBAction func levelBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.levelIndex == self.cpu.count - 1 {
            self.levelIndex = 0
        }
        else {
            self.levelIndex += 1
        }
        self.levelButton.setTitle(self.cpu[self.levelIndex], for: UIControl.State.normal)
        self.ID = self.initID + "-" + self.cpu[self.levelIndex]
    }
    
    @IBAction func changeTeam(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.team {
            self.button.backgroundColor = myBlue
        }
        else {
            self.button.backgroundColor = myRed
        }
        self.team = !self.team
        self.updateShowFunc()
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.deleteFlag = true
        self.label.isHidden = true
        self.button.isHidden = true
        self.deleteButton.isHidden = true
        self.levelButton.isHidden = true
        self.updateShowFunc()
    }
    
    deinit {
        label.isHidden = true
        button.isHidden = true
        deleteButton.isHidden = true
        levelButton.isHidden = true
    }
}

class MemberForBrowser {
    let view: UIView
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myRed = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0)
    let name: String
    var index: Int
    let screenWidth: CGFloat
    let label = UILabel()
    let teamLabel = UILabel()
    init(view: UIView, name: String, index: Int, screenWidth: CGFloat, team: String) {
        self.view = view
        self.name = name
        self.index = index
        self.screenWidth = screenWidth
        label.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        label.center.x = screenWidth / 2 - 45
        label.center.y = CGFloat(210 + 50 * index)
        label.text = self.name
        teamLabel.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        teamLabel.layer.cornerRadius = 5
        teamLabel.clipsToBounds = true
        teamLabel.center.x = screenWidth / 2 + 45
        teamLabel.center.y = CGFloat(210 + 50 * index)
        if team == "red" {
            teamLabel.backgroundColor = myRed
        }
        else if team == "blue" {
            teamLabel.backgroundColor = myBlue
        }
        self.view.addSubview(label)
        self.view.addSubview(teamLabel)
    }
    
    deinit {
        label.isHidden = true
        teamLabel.isHidden = true
    }
}
