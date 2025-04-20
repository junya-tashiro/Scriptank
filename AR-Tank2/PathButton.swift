//
//  PathButton.swift
//  AR-Tank
//
//  Created by 田代純也 on 2024/01/09.
//

import Foundation
import SwiftUI

class PathButton {
    let x: Int
    let y: Int
    let fieldSize: [Int]
    let enemy: [(x: Int, y: Int)]
    let scrollView: UIScrollView
    let body = UIButton(frame: CGRectMake(0, 0, 50, 50))
    
    let onlyShow: Bool
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myRed = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0)
    let myGray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    
    let pushedFunc: (_ x: Int, _ y: Int) -> ()
    
    init(x: Int, y: Int, scrollView: UIScrollView, pushedFunc: @escaping (_ x: Int, _ y: Int) -> (), fieldSize: [Int], enemy: [(x: Int, y: Int)], onlyShow: Bool) {
        self.x = x
        self.y = y
        self.scrollView = scrollView
        self.pushedFunc = pushedFunc
        self.fieldSize = fieldSize
        self.enemy = enemy
        self.onlyShow = onlyShow
        
        body.center = CGPoint(x: Int(self.scrollView.contentSize.width) / 2 + 60 * x, y: Int(self.scrollView.contentSize.height) / 2 + 60 * y)
        
        self.setColor()
        if !self.onlyShow {
            self.setInitText()
        }
        
        body.layer.cornerRadius = 5
        body.setTitleColor(UIColor.white, for: UIControl.State.normal)
        if !self.onlyShow {
            body.addTarget(self, action: #selector(self.btnAction(_:)), for: UIControl.Event.touchUpInside)
        }
        self.scrollView.addSubview(body)
    }
    
    func setColor() {
        if self.x == (self.fieldSize[0] - 1) / 2 || self.x == (self.fieldSize[0] - 3) / 2 {
            if self.y == -(self.fieldSize[1] - 1) / 2 || self.y == -(self.fieldSize[1] - 3) / 2 {
                self.body.backgroundColor = myRed
            }
            else {
                self.body.backgroundColor = myGray
            }
        }
        else if self.x == -(self.fieldSize[0] - 1) / 2 || self.x == -(self.fieldSize[0] - 3) / 2 {
            if self.y == (self.fieldSize[1] - 1) / 2 || self.y == (self.fieldSize[1] - 3) / 2 {
                self.body.backgroundColor = myBlue
            }
            else {
                self.body.backgroundColor = myGray
            }
        }
        else {
            self.body.backgroundColor = myGray
        }
    }
    
    func setInitText() {
        if self.x == -(self.fieldSize[0] - 1) / 2 && self.y == (self.fieldSize[1] - 3) / 2 {
            body.setTitle("⚪︎", for: UIControl.State.normal)
        }
        else {
            var flag: Bool = true
            for e in enemy {
                if e.x == self.x && e.y == self.y {
                    body.setTitle("×", for: UIControl.State.normal)
                    flag = false
                }
            }
            if flag {
                body.setTitle("", for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func btnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.pushedFunc(x, y)
    }
}
