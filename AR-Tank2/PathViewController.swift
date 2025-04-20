//
//  PathViewController.swift
//  AR-Tank
//
//  Created by 田代純也 on 2024/01/08.
//

import Foundation

import Foundation
import SceneKit

class PathViewController: UIViewController {
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myOrange = UIColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
    
    var screenWidth: CGFloat = 0.0      //スクリーン幅
    var screenHeight: CGFloat = 0.0     //スクリーン高さ
    
    var fieldSize: [Int] = []
    var wallsHorizontal: [(idx: Int, x: Int, len: Int)] = []
    var wallsVertical: [(idx: Int, z: Int, len: Int)] = []
    var enemy: [(x: Int, y: Int)] = []
    
    var onlyShow: Bool = false
    
    let resetButton = UIButton(frame: CGRectMake(0, 0, 100, 40))
    let stopTankButton = UIButton(frame: CGRectMake(0, 0, 100, 40))
    let okButton = UIButton(frame: CGRectMake(0, 0, 100, 40))
    
    let valueView = UIScrollView()
    let valueLabel = UILabel()
    let pathLabel = UILabel(frame: CGRectMake(0, 0, 60, 40))
    
    let scrollView = UIScrollView()
    
    var pathButtons: [PathButton] = []
    
    var count: Int = 0
    var msg: String = ""
    var cmd: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
        //フレームサイズの格納
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
        
        //scrollView
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight * 3 / 4)
        self.scrollView.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight * 9 / 16)
        var w = self.screenWidth
        var h = self.screenHeight
        if Float(60 * (fieldSize[0] + 3)) > Float(self.scrollView.frame.width) {
            w = CGFloat(60 * (fieldSize[0] + 3))
        }
        if Float(60 * (fieldSize[1] + 3)) > Float(self.scrollView.frame.height) {
            h = CGFloat(60 * (fieldSize[1] + 3))
        }
        self.scrollView.contentSize = CGSize(width: w, height: h)
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentSize.width / 2 - self.scrollView.frame.width / 2, y: self.scrollView.contentSize.height / 2 - self.scrollView.frame.height / 2)
        self.scrollView.backgroundColor = UIColor.lightGray
        self.view.addSubview(scrollView)
        
        if !self.onlyShow {
            self.resetButton.center = CGPoint(x: self.screenWidth / 2 - 120, y: self.screenHeight / 16)
            self.resetButton.backgroundColor = UIColor.darkGray
            self.resetButton.setTitle(NSLocalizedString("Redo", comment: ""), for: UIControl.State.normal)
            self.resetButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.resetButton.layer.cornerRadius = 10
            self.resetButton.addTarget(self, action: #selector(self.resetBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(self.resetButton)
            
            self.stopTankButton.center = CGPoint(x: self.screenWidth / 2 , y: self.screenHeight / 16)
            self.stopTankButton.backgroundColor = myOrange
            self.stopTankButton.setTitle(NSLocalizedString("STOP", comment: ""), for: UIControl.State.normal)
            self.stopTankButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.stopTankButton.layer.cornerRadius = 10
            self.stopTankButton.addTarget(self, action: #selector(self.stopTankBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(self.stopTankButton)
            
            self.okButton.center = CGPoint(x: self.screenWidth / 2 + 120, y: self.screenHeight / 16)
            self.okButton.backgroundColor = myBlue
            self.okButton.setTitle(NSLocalizedString("Reflection", comment: ""), for: UIControl.State.normal)
            self.okButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.okButton.layer.cornerRadius = 10
            self.okButton.addTarget(self, action: #selector(self.okBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(self.okButton)
            
            self.valueView.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 120, height: 40)
            self.valueView.center = CGPoint(x: self.screenWidth / 2 + 30, y: self.screenHeight / 16 + 60)
            self.valueView.contentSize = CGSize(width: self.valueView.frame.width, height: self.valueView.frame.height)
            self.valueView.backgroundColor = UIColor.clear
            self.valueView.layer.cornerRadius = 5
            self.valueView.layer.borderColor = UIColor.black.cgColor
            self.valueView.layer.borderWidth = 1
            self.view.addSubview(self.valueView)
            
            self.valueLabel.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 125, height: 40)
            self.valueLabel.center = CGPoint(x: self.valueView.contentSize.width / 2, y: self.valueView.contentSize.height / 2)
            self.valueLabel.backgroundColor = UIColor.clear
            self.valueLabel.textColor = UIColor.black
            self.valueView.addSubview(self.valueLabel)
            
            self.pathLabel.center = CGPoint(x: 60, y: self.screenHeight / 16 + 60)
            self.pathLabel.text = NSLocalizedString("Path", comment: "") + "："
            self.view.addSubview(self.pathLabel)
        }
        
        wallsHorizontal.append((idx: 0, x: 0, len: (self.fieldSize[0] - 1) / 2))
        wallsHorizontal.append((idx: self.fieldSize[1], x: 0, len: (self.fieldSize[0] - 1) / 2))
        wallsVertical.append((idx: 0, z: 0, len: (self.fieldSize[1] - 1) / 2))
        wallsVertical.append((idx: self.fieldSize[0], z: 0, len: (self.fieldSize[1] - 1) / 2))
        
        for wall in wallsHorizontal {
            let label = UILabel(frame: CGRectMake(0, 0, CGFloat(60 * (2 * wall.len + 1)), 2))
            label.backgroundColor = UIColor.black
            label.center.x = CGFloat(Int(self.scrollView.contentSize.width) / 2 + 60 * wall.x)
            label.center.y = CGFloat(Int(self.scrollView.contentSize.height) / 2 - 30 * self.fieldSize[1] + 60 * wall.idx)
            self.scrollView.addSubview(label)
        }
        
        for wall in wallsVertical {
            let label = UILabel(frame: CGRectMake(0, 0, 2, CGFloat(60 * (2 * wall.len + 1))))
            label.backgroundColor = UIColor.black
            label.center.x = CGFloat(Int(self.scrollView.contentSize.width) / 2 - 30 * self.fieldSize[0] + 60 * wall.idx)
            label.center.y = CGFloat(Int(self.scrollView.contentSize.height) / 2 + 60 * wall.z)
            self.scrollView.addSubview(label)
        }
        
        for i in -(fieldSize[0] - 1) / 2 ..< (fieldSize[0] + 1) / 2 {
            for j in -(fieldSize[1] - 1) / 2 ..< (fieldSize[1] + 1) / 2 {
                self.pathButtons.append(PathButton(x: i, y: j, scrollView: self.scrollView, pushedFunc: pushedFunc, fieldSize: self.fieldSize, enemy: self.enemy, onlyShow: self.onlyShow))
            }
        }
        
        for i in -(fieldSize[0] - 1) / 2 ..< (fieldSize[0] + 1) / 2 {
            let label = UILabel(frame: CGRectMake(0, 0, 50, 50))
            label.center.x = CGFloat(Int(self.scrollView.contentSize.width) / 2 + (60 * i))
            label.center.y = self.scrollView.contentSize.height / 2 - CGFloat(30 * (self.fieldSize[1] + 1))
            label.backgroundColor = UIColor.clear
            label.text = String(i)
            label.textAlignment = .center
            label.textColor = UIColor.black
            self.scrollView.addSubview(label)
        }
        
        for j in -(fieldSize[1] - 1) / 2 ..< (fieldSize[1] + 1) / 2 {
            let label = UILabel(frame: CGRectMake(0, 0, 50, 50))
            label.center.x = self.scrollView.contentSize.width / 2 - CGFloat(30 * (self.fieldSize[0] + 1))
            label.center.y = CGFloat(Int(self.scrollView.contentSize.height) / 2 + (60 * j))
            label.backgroundColor = UIColor.clear
            label.text = String(j)
            label.textAlignment = .center
            label.textColor = UIColor.black
            self.scrollView.addSubview(label)
        }
        
        let labelx = UILabel(frame: CGRectMake(0, 0, 50, 50))
        labelx.center.x = CGFloat(Int(self.scrollView.contentSize.width) / 2)
        labelx.center.y = self.scrollView.contentSize.height / 2 - CGFloat(30 * (self.fieldSize[1] + 2))
        labelx.backgroundColor = UIColor.clear
        labelx.text = String("x")
        labelx.font = labelx.font.withSize(25)
        labelx.textAlignment = .center
        labelx.textColor = UIColor.black
        self.scrollView.addSubview(labelx)
        
        let labely = UILabel(frame: CGRectMake(0, 0, 50, 50))
        labely.center.x = self.scrollView.contentSize.width / 2 - CGFloat(30 * (self.fieldSize[0] + 2))
        labely.center.y = CGFloat(Int(self.scrollView.contentSize.height) / 2)
        labely.backgroundColor = UIColor.clear
        labely.text = String("y")
        labely.font = labelx.font.withSize(25)
        labely.textAlignment = .center
        labely.textColor = UIColor.black
        self.scrollView.addSubview(labely)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.pathButtons = []
        if msg != "" && cmd != "" {
            msg.removeLast(2)
            cmd.removeLast()
        }
        if !self.onlyShow {
            NotificationCenter.default.post(name: .deletePathEditor, object: nil)
        }
    }
    
    @IBAction func resetBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.count = 0
        self.msg = ""
        self.cmd = ""
        for pathButton in pathButtons {
            pathButton.setInitText()
        }
        
        self.msgChanged()
    }
    
    @IBAction func stopTankBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.count = 0
        self.msg = " " + NSLocalizedString("Stop Tank", comment: "") + "  "
        self.cmd = "cancel" + " "
        for pathButton in pathButtons {
            pathButton.setInitText()
        }
        
        self.msgChanged()
    }
    
    @IBAction func okBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.dismiss(animated: true)
    }
    
    func msgChanged() {
        self.valueLabel.text = msg
        let size = valueLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        if size.width >= self.valueView.frame.width - 5 {
            self.valueLabel.frame = CGRect(x: 0, y: 0, width: size.width, height: self.valueLabel.frame.height)
            self.valueView.contentSize = CGSize(width: size.width + 5, height: self.valueView.contentSize.height)
        }
        else {
            self.valueLabel.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 125, height: 40)
            self.valueView.contentSize = CGSize(width: self.valueView.frame.width, height: self.valueView.frame.height)
        }
    }
    
    func pushedFunc(x: Int, y: Int) {
        if self.count == 0 {
            msg = ""
            cmd = ""
        }
        for pathButton in pathButtons {
            if x == pathButton.x && y == pathButton.y {
                pathButton.body.setTitle(String(self.count + 1), for: UIControl.State.normal)
            }
        }
        self.count += 1
        msg.append(" (" + String(x) + ", " + String(y) + ") →")
        cmd.append(String(x) + "," + String(y) + "/")
        
        self.msgChanged()
    }
}
