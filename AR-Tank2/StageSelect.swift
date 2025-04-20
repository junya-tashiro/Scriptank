//
//  StageSelect.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/21.
//

import Foundation
import StoreKit

class StageSelect {
    let userDefaults = UserDefaults.standard
    
    let view: UIView
    
    var fieldSize: [Int]
    var wallsHorizontal: [(idx: Int, x: Int, len: Int)]
    var wallsVertical: [(idx: Int, z: Int, len: Int)]
    var index: Int
    
    var isUnlocked: Bool
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    
    let button = UIButton(frame: CGRectMake(0, 0, 150, 50))
    
    let unlockLabel = UILabel(frame: CGRectMake(0, 0, 300, 50))
    let clearButton = UIButton()
    
    let lockLabel = UILabel(frame: CGRectMake(0, 0, 160, 60))
    
    let goFunc: ([Int], [(idx: Int, x: Int, len: Int)], [(idx: Int, z: Int, len: Int)], Int) -> ()
    
    init(parental: UIView, view: UIView, fieldSize: [Int], wallsHorizontal: [(idx: Int, x: Int, len: Int)], wallsVertical: [(idx: Int, z: Int, len: Int)], screenWidth: CGFloat, index: Int, goFunc: @escaping ([Int], [(idx: Int, x: Int, len: Int)], [(idx: Int, z: Int, len: Int)], Int) -> ()) {
        self.view = parental
        self.fieldSize = fieldSize
        self.wallsHorizontal = wallsHorizontal
        self.wallsVertical = wallsVertical
        self.index = index
        self.goFunc = goFunc
        
        button.center.x = screenWidth / 2
        button.center.y = CGFloat(120 + 100 * index)
        button.layer.cornerRadius = 10
        button.backgroundColor = myBlue
        button.setTitle(NSLocalizedString("Stage", comment: "") + " " + String(index + 1), for: UIControl.State.normal)
        view.addSubview(button)
        
        lockLabel.center.x = screenWidth / 2
        lockLabel.center.y = CGFloat(120 + 100 * index)
        lockLabel.layer.cornerRadius = 10
        lockLabel.clipsToBounds = true
        lockLabel.text = "LOCKED"
        lockLabel.textColor = .black
        lockLabel.font = UIFont.systemFont(ofSize: 25)
        lockLabel.textAlignment = .center
        lockLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        isUnlocked = userDefaults.bool(forKey: "isUnlockedStage" + String(self.index))
        if isUnlocked {
            button.addTarget(self, action: #selector(self.go(_:)), for: UIControl.Event.touchUpInside)
        }
        else {
            view.addSubview(lockLabel)
        }
    }

    func unlock() {
        let isUnlockedNew = userDefaults.bool(forKey: "isUnlockedStage" + String(self.index))
        if isUnlockedNew {
            button.addTarget(self, action: #selector(self.go(_:)), for: UIControl.Event.touchUpInside)
            lockLabel.removeFromSuperview()
            if !self.isUnlocked {
                self.isUnlocked = true
                
                unlockLabel.center.x = self.view.frame.width / 2
                unlockLabel.center.y = self.view.frame.height / 2
                unlockLabel.layer.cornerRadius = 10
                unlockLabel.clipsToBounds = true
                unlockLabel.backgroundColor = UIColor.white
                unlockLabel.text = NSLocalizedString("New stage unlocked!", comment: "")
                unlockLabel.textAlignment = .center
                self.view.addSubview(unlockLabel)
                
                clearButton.frame = self.view.frame
                clearButton.addTarget(self, action: #selector(self.delete(_:)), for: UIControl.Event.touchUpInside)
                self.view.addSubview(clearButton)
                
                if self.index == 5 {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            }
        }
    }
    
    @IBAction func delete(_ sender: Any) {
        unlockLabel.removeFromSuperview()
        clearButton.removeFromSuperview()
    }
    
    @IBAction func go(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.goFunc(self.fieldSize, self.wallsHorizontal, self.wallsVertical, self.index)
    }
}
