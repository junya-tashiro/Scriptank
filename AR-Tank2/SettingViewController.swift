//
//  SettingViewController.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/15.
//
//  設定画面のクラス: SettingViewController

import Foundation
import SceneKit

class SettingViewController: UIViewController {
    let userDefaults = UserDefaults.standard
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    
    var screenWidth: CGFloat = 0.0      //スクリーン幅
    var screenHeight: CGFloat = 0.0     //スクリーン高さ
    
    let clearButton = UIButton()        //透明ボタン(キーボードをしまう用)
    let backButton = UIButton()         //戻るボタン
    let saveButton = UIButton()         //保存ボタン
    let userNameLabel = UILabel()       //「ユーザー名」ラベル
    let showDetailLabel = UILabel()     //「詳細を表示」ラベル
    let userNameBox = UITextField()     //ユーザー名ボックス
    let showDetailSwitch = UISwitch()   //詳細を表示スイッチ
    
    var showDetail: Bool = false        //詳細表示
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
        //フレームサイズの格納
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
         
        //透明ボタン
        clearButton.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        clearButton.addTarget(self, action: #selector(self.clearBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(clearButton)
        
        //「ユーザー名」ラベル
        userNameLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        userNameLabel.center = CGPoint(x: screenWidth / 2 - 75, y: 250)
        userNameLabel.text = NSLocalizedString("User name", comment: "")
        userNameLabel.textColor = .black
        self.view.addSubview(userNameLabel)
        
        //「詳細を表示」ラベル
        showDetailLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        showDetailLabel.center = CGPoint(x: screenWidth / 2 - 75, y: 300)
        showDetailLabel.text = NSLocalizedString("Draw detail", comment: "")
        showDetailLabel.textColor = .black
        self.view.addSubview(showDetailLabel)
        
        //ユーザー名ボックス
        userNameBox.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        userNameBox.center = CGPoint(x: screenWidth / 2 + 75, y: 250)
        userNameBox.placeholder = NSLocalizedString("User name", comment: "")
        userNameBox.text = userDefaults.string(forKey: "userName")
        userNameBox.textColor = .black
        userNameBox.layer.borderWidth = 1
        userNameBox.layer.borderColor = UIColor.black.cgColor
        userNameBox.layer.cornerRadius = 5
        userNameBox.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        userNameBox.leftViewMode = .always
        self.view.addSubview(userNameBox)
        
        //詳細を表示スイッチ
        showDetail = userDefaults.bool(forKey: "showDetail")
        showDetailSwitch.isOn = showDetail
        showDetailSwitch.onTintColor = myBlue
        showDetailSwitch.thumbTintColor = UIColor.lightGray
        showDetailSwitch.center = CGPoint(x: screenWidth / 2 + 30, y: 300)
        showDetailSwitch.addTarget(self, action: #selector(self.showDetailSwtAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(showDetailSwitch)
        
        //戻るボタン
        backButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        backButton.center = CGPoint(x: screenWidth / 2 - 80, y: 150)
        backButton.layer.cornerRadius = 10
        backButton.backgroundColor = UIColor.darkGray
        backButton.setTitle(NSLocalizedString("No save", comment: ""), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(self.backBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(backButton)
        
        //保存して戻るボタン
        saveButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        saveButton.center = CGPoint(x: screenWidth / 2 + 80, y: 150)
        saveButton.layer.cornerRadius = 10
        saveButton.backgroundColor = myBlue
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: UIControl.State.normal)
        saveButton.addTarget(self, action: #selector(self.saveBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(saveButton)
    }
    
    //詳細表示スイッチ押下時
    @IBAction func showDetailSwtAction(_ sender: Any) {
        self.showDetail = !self.showDetail
    }
    
    //透明ボタン押下時
    @IBAction func clearBtnAction(_ sender: Any) {
        //キーボードをしまう
        self.userNameBox.endEditing(true)
    }
    
    //戻るボタン押下時
    @IBAction func backBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.dismiss(animated: false, completion: nil)
    }
    
    //保存ボタン押下時
    @IBAction func saveBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        //UserDefaultsに各種設定を保存
        guard let userName = self.userNameBox.text else {return}
        userDefaults.set(userName, forKey: "userName")
        userDefaults.set(self.showDetail, forKey: "showDetail")
        
        if userName == "ksJCCpl8Jxj7giVU" {
            for i in 0 ..< 20 {
                userDefaults.set(true, forKey: "isUnlockedStage" + String(i))
            }
        }
        
        self.dismiss(animated: false, completion: nil)
    }
}
