//
//  ViewController.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/11/21.
//
//  ホーム画面のクラス: ViewController


import Foundation
import SceneKit

class ViewController: UIViewController {
    let userDefaults = UserDefaults.standard
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    
    var screenWidth: CGFloat = 0.0      //スクリーン幅
    var screenHeight: CGFloat = 0.0     //スクリーン高さ
    let multiPlayButton = UIButton()    //「みんなで遊ぶ」ボタン
    let soloPlayButton = UIButton()     //「ひとりで遊ぶ」ボタン
    let advertiserButton = UIButton()   //「ルームを作る」ボタン
    let browserButton = UIButton()      //「ルームに参加する」ボタン
    let backButtonClear = UIButton()    //ボタン外を押すとホーム状態に戻る
    
    let settingButton = UIButton()      //設定ボタン
    
    //ルーム検索, 設定用ビュー
    let roomInputLabel = UILabel()      //背景
    let roomNameBox = UITextField()     //入力ボックス
    let goButton = UIButton()           //決定ボタン
    let cancelButton = UIButton()       //戻るボタン
    var isAdvertiser: Bool = true
    
    let messageLabel = UILabel()        //メッセージ(ルーム切断時など)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
        //初期値として各種設定の状態をUserDefaultsに保存
        userDefaults.register(defaults: ["userName": "myName",
                                         "showDetail": true,
                                         "isUnlockedStage0": true,
                                         "isUnlockedStage1": false,
                                         "isUnlockedStage2": false,
                                         "isUnlockedStage3": false,
                                         "isUnlockedStage4": false,
                                         "isUnlockedStage5": false,
                                         "isUnlockedStage6": false,
                                         "isUnlockedStage7": false,
                                         "isUnlockedStage8": false,
                                         "isUnlockedStage9": false,
                                         "isUnlockedStage10": true,
                                         "isUnlockedStage11": false,
                                         "isUnlockedStage12": false,
                                         "isUnlockedStage13": false,
                                         "isUnlockedStage14": false,
                                         "isUnlockedStage15": false,
                                         "isUnlockedStage16": false,
                                         "isUnlockedStage17": false,
                                         "isUnlockedStage18": false,
                                         "isUnlockedStage19": false])
        
        //通知を検知
        NotificationCenter.default.addObserver(self, selector: #selector(msgForCanNotConnect), name: .canNotConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(msgForAdvertiserDisappered), name: .advertiserDisappeared, object: nil)
        
        //フレームサイズの格納
        screenWidth = self.view.frame.width
        screenHeight = self.view.frame.height
        
        //「みんなで遊ぶ」ボタン
        multiPlayButton.backgroundColor = myBlue
        multiPlayButton.setTitle(NSLocalizedString("Multi", comment: ""), for: UIControl.State.normal)
        multiPlayButton.frame = CGRect(x: 0, y: 0, width: 160, height: 50)
        multiPlayButton.layer.cornerRadius = 10
        multiPlayButton.center = CGPoint(x: screenWidth / 2, y: screenHeight / 3)
        multiPlayButton.addTarget(self, action: #selector(multiPlay), for: .touchUpInside)
        self.view.addSubview(multiPlayButton)
        
        //「ひとりで遊ぶ」ボタン
        soloPlayButton.backgroundColor = myBlue
        soloPlayButton.setTitle(NSLocalizedString("Solo", comment: ""), for: UIControl.State.normal)
        soloPlayButton.frame = CGRect(x: 0, y: 0, width: 160, height: 50)
        soloPlayButton.layer.cornerRadius = 10
        soloPlayButton.center = CGPoint(x: screenWidth / 2, y: screenHeight * 2 / 3)
        soloPlayButton.addTarget(self, action: #selector(soloPlay), for: .touchUpInside)
        self.view.addSubview(soloPlayButton)
        
        //ボタン外の透明ボタン
        backButtonClear.backgroundColor = UIColor.clear
        backButtonClear.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        backButtonClear.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        self.view.addSubview(backButtonClear)
        backButtonClear.isHidden = true
        
        //「ルームを作る」ボタン
        advertiserButton.backgroundColor = myBlue
        advertiserButton.setTitle(NSLocalizedString("Make room", comment: ""), for: UIControl.State.normal)
        advertiserButton.frame = CGRect(x: 0, y: 0, width: 160, height: 50)
        advertiserButton.layer.cornerRadius = 10
        advertiserButton.center = CGPoint(x: screenWidth / 2, y: screenHeight / 3)
        advertiserButton.addTarget(self, action: #selector(multiPlayForAdvertiser), for: .touchUpInside)
        self.view.addSubview(advertiserButton)
        advertiserButton.isHidden = true
        
        //「ルームを探す」ボタン
        browserButton.backgroundColor = myBlue
        browserButton.setTitle(NSLocalizedString("Join room", comment: ""), for: UIControl.State.normal)
        browserButton.frame = CGRect(x: 0, y: 0, width: 160, height: 50)
        browserButton.layer.cornerRadius = 10
        browserButton.center = CGPoint(x: screenWidth / 2, y: screenHeight * 2 / 3)
        browserButton.addTarget(self, action: #selector(multiPlayForBrowser), for: .touchUpInside)
        self.view.addSubview(browserButton)
        browserButton.isHidden = true
        
        //ルーム名入力ラベル
        roomInputLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 130)
        roomInputLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 50)
        roomInputLabel.layer.cornerRadius = 10
        roomInputLabel.backgroundColor = UIColor.white
        roomInputLabel.clipsToBounds = true
        self.view.addSubview(roomInputLabel)
        roomInputLabel.isHidden = true
        
        //ルーム名入力ボックス
        roomNameBox.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        roomNameBox.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 75)
        roomNameBox.placeholder = NSLocalizedString("Room name", comment: "")
        roomNameBox.layer.borderWidth = 1
        roomNameBox.layer.borderColor = UIColor.black.cgColor
        roomNameBox.layer.cornerRadius = 5
        roomNameBox.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        roomNameBox.leftViewMode = .always
        self.view.addSubview(roomNameBox)
        roomNameBox.isHidden = true
        
        //決定ボタン
        goButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        goButton.center = CGPoint(x: screenWidth / 2 + 60, y: screenHeight / 2 - 25)
        goButton.layer.cornerRadius = 5
        goButton.backgroundColor = myBlue
        goButton.addTarget(self, action: #selector(goBtnAction), for: .touchUpInside)
        self.view.addSubview(goButton)
        self.goButton.isHidden = true
        
        //戻るボタン
        cancelButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        cancelButton.center = CGPoint(x: screenWidth / 2 - 60, y: screenHeight / 2 - 25)
        cancelButton.layer.cornerRadius = 5
        cancelButton.backgroundColor = UIColor.darkGray
        cancelButton.setTitle(NSLocalizedString("Back", comment: ""), for: UIControl.State.normal)
        cancelButton.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        self.view.addSubview(cancelButton)
        self.cancelButton.isHidden = true
        
        //設定ボタン
        settingButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        settingButton.center = CGPoint(x: screenWidth - 60, y: 120)
        settingButton.layer.cornerRadius = settingButton.frame.height / 2
        settingButton.backgroundColor = UIColor.clear
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
        let a = renderer.image { _ in
            UIImage(systemName: "gearshape.fill")!.draw(in: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        }
        settingButton.setImage(a, for: UIControl.State.normal)
        settingButton.tintColor = UIColor.darkGray
        settingButton.addTarget(self, action: #selector(settingBtnAction), for: .touchUpInside)
        self.view.addSubview(settingButton)
        
        messageLabel.frame = CGRect(x: 0, y: 0, width: screenWidth - 50, height: 70)
        messageLabel.center = CGPoint(x: screenWidth / 2, y: 90)
        messageLabel.layer.cornerRadius = 5
        messageLabel.clipsToBounds = true
        messageLabel.backgroundColor = UIColor.white
        messageLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(messageLabel)
        self.messageLabel.isHidden = true
    }
    
    //「みんなで遊ぶ」押下時
    @objc func multiPlay() {
        UISelectionFeedbackGenerator().selectionChanged()
        //「みんなで遊ぶ」「ひとりで遊ぶ」ボタンを非表示に
        multiPlayButton.isHidden = true
        soloPlayButton.isHidden = true
        
        //「ルームを作る/探す」ボタンを追加してボタン以外を押したらホームに戻るように
        backButtonClear.isHidden = false
        advertiserButton.isHidden = false
        browserButton.isHidden = false
    }
    
    //「ひとりで遊ぶ」押下時
    @objc func soloPlay() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let soloViewController = self.storyboard?.instantiateViewController(withIdentifier: "SoloViewController") as! SoloViewController
        //フルスクリーンで表示
        soloViewController.modalPresentationStyle = .fullScreen
        self.present(soloViewController, animated: false, completion: nil)
    }
    
    //「ルームを作る」押下時
    @objc func multiPlayForAdvertiser() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        //「ルームを作る/探す」ボタンを非表示に
        self.advertiserButton.isHidden = true
        self.browserButton.isHidden = true
        
        //ルームの入力用表示
        self.roomInputLabel.isHidden = false
        self.roomNameBox.isHidden = false
        self.roomNameBox.becomeFirstResponder() //デフォルトでキーボード表示
        self.goButton.isHidden = false
        self.goButton.setTitle(NSLocalizedString("Make", comment: ""), for: UIControl.State.normal)
        self.cancelButton.isHidden = false
        
        //advertiser用設定
        self.isAdvertiser = true
    }
    
    //「ルームを探す」押下時
    @objc func multiPlayForBrowser() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        //「ルームを作る/探す」ボタンを非表示に
        self.advertiserButton.isHidden = true
        self.browserButton.isHidden = true
        
        //ルームの入力用表示
        self.roomInputLabel.isHidden = false
        self.roomNameBox.isHidden = false
        self.roomNameBox.becomeFirstResponder() //デフォルトでキーボード表示
        self.goButton.isHidden = false
        self.goButton.setTitle(NSLocalizedString("Join", comment: ""), for: UIControl.State.normal)
        self.cancelButton.isHidden = false
        
        //browser用設定
        self.isAdvertiser = false
    }
    
    //透明ボタン押下時
    @objc func backBtnAction() {
        //みんなで遊ぶボタン押下時のオブジェクトを全て非表示に
        self.backButtonClear.isHidden = true
        self.advertiserButton.isHidden = true
        self.browserButton.isHidden = true
        
        //メッセージも非表示に
        self.messageLabel.isHidden = true
        
        //ルーム入力画面のオブジェクトも全て非表示に
        self.roomInputLabel.isHidden = true
        self.roomNameBox.isHidden = true
        self.roomNameBox.text = ""
        self.roomNameBox.endEditing(true)
        self.goButton.isHidden = true
        self.cancelButton.isHidden = true
        
        //ホーム状態の3オブジェクトを再表示
        self.soloPlayButton.isHidden = false
        self.multiPlayButton.isHidden = false
        self.settingButton.isHidden = false
    }
    
    //決定ボタン(ルーム名入力後)
    @objc func goBtnAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        //対戦画面のインスタンス化
        guard let roomName = self.roomNameBox.text else {return}
        let battleViewController = self.storyboard?.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
        
        //フルスクリーンで表示
        battleViewController.modalPresentationStyle = .fullScreen
        
        //ルーム名を設定
        battleViewController.roomName = roomName
        
        //advertiser用設定
        battleViewController.isAdvertiser = self.isAdvertiser
        
        //MultipeerConnectivityの初期化
        battleViewController.initMultipeerSession(isAdvertiser: self.isAdvertiser, receivedDataHandler: battleViewController.receivedData)
        
        //ルーム名入力ビューを非表示
        self.roomInputLabel.isHidden = true
        self.roomNameBox.isHidden = true
        self.roomNameBox.text = ""
        self.goButton.isHidden = true
        self.cancelButton.isHidden = true
        self.backButtonClear.isHidden = true
        
        //初期状態の3オブジェクトを表示
        self.soloPlayButton.isHidden = false
        self.multiPlayButton.isHidden = false
        self.settingButton.isHidden = false
        
        //画面を表示
        self.present(battleViewController, animated: false, completion: nil)
    }
    
    //戻るボタン(ルーム名入力画面)
    @objc func cancelBtnAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        //ルーム名入力ビューを非表示
        self.roomInputLabel.isHidden = true
        self.roomNameBox.isHidden = true
        self.roomNameBox.text = ""
        self.roomNameBox.endEditing(true)
        self.goButton.isHidden = true
        self.cancelButton.isHidden = true
        
        //初期状態の3オブジェクトを表示
        self.advertiserButton.isHidden = false
        self.browserButton.isHidden = false
    }
    
    //設定ボタン押下時
    @objc func settingBtnAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        //設定画面のインスタンス化
        let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        //フルスクリーンで表示
        settingViewController.modalPresentationStyle = .fullScreen
        //画面を表示
        self.present(settingViewController, animated: false, completion: nil)
    }
    
    //通知受信(ルーム検索開始後10秒経過後に通知送信してホームに戻ってくる)
    @objc func msgForCanNotConnect() {
        self.messageLabel.text = NSLocalizedString("Can't find the room.", comment: "")
        self.messageLabel.isHidden = false
        self.backButtonClear.isHidden = false
        //2秒後に自動で通知削除
        self.perform(#selector(backBtnAction), with: nil, afterDelay: 2.0)
    }
    
    //通知受信(リーダーがルームを抜けた際に通知送信してホームに戻ってくる)
    @objc func msgForAdvertiserDisappered() {
        DispatchQueue.main.sync {
            self.messageLabel.text = NSLocalizedString("Leader disconnected the room.", comment: "")
            self.messageLabel.isHidden = false
            self.backButtonClear.isHidden = false
            //2秒後に自動で通知削除
            self.perform(#selector(backBtnAction), with: nil, afterDelay: 2.0)
        }
    }
}
