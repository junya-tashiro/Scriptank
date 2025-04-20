//
//  BattleViewController.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/11.
//
//  対戦画面のクラス: BattleViewController
//  データ受信時の動作, 接続用のクラス拡張, タップ検出時の動作, タンクの自律行動生成関数は別ファイルに

import Foundation
import SceneKit
import ARKit
import MultipeerConnectivity

class BattleViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let userDefaults = UserDefaults.standard
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myRed = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0)
    
    weak var timer: Timer?
    
    //MultipeerConnectivity用
    static let serviceType = "ar-tank"
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    var mpsession: MCSession!
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    var otherPeerID: MCPeerID?
    
    var isSolo: Bool = false                            //「ひとりで遊ぶ」より来たか否か
    var isAdvertiser: Bool = true                       //「ルームを作る」より来たか否か
    var isCpuBattle: Bool = false                       //CPU同士の対戦か
    var roomName: String = "artank"                     //ルーム名(ビュー表示時に更新)
    var myName: String = "myName"                       //ユーザー名(ビュー表示時に更新)
    
    var members: [Member] = []                          //参加者(通信接続時に使用)
    var membersForBrowser: [MemberForBrowser] = []      //参加者(Browserが更新状況を見る用)
    var standby: Dictionary<String, Bool> = [:]         //各browserの準備状態
    
    let retryLabel = UILabel(frame: CGRectMake(0, 0, 300, 50))
    let retryButton = UIButton()
    
    var touch1: UITouch! = nil
    var touch2: UITouch! = nil
    var touchPos:    (x1: Float, z1: Float, x2: Float, z2: Float) = (x1: 0.0, z1: 0.0, x2: 0.0, z2: 0.0)
    var touchPosPre: (x1: Float, z1: Float, x2: Float, z2: Float) = (x1: 0.0, z1: 0.0, x2: 0.0, z2: 0.0)
    var isMoveFieldMode: Bool = false
    var didNotMoveField: Bool = true
    
    var needAlert: Bool = false
    
    var stopProcess: Bool = false
    
    let isTest: Bool = false
    var isChiikawa: Bool = false
    
    var chiikawaNode = SCNNode()
    
    //スクリーンサイズ
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    //スコープ
    let scopePoint = UIView(frame: CGRectMake(0, 0, 5, 5))
    let scopeLeft = UIView(frame: CGRectMake(0, 0, 30, 1))
    let scopeRight = UIView(frame: CGRectMake(0, 0, 30, 1))
    let scopeUp = UIView(frame: CGRectMake(0, 0, 1, 30))
    let scopeDown = UIView(frame: CGRectMake(0, 0, 1, 30))
    let scopeFrame = UIView(frame: CGRectMake(0, 0, 80, 80))
    
    //降参ボタン
    let backGround = UILabel(frame: CGRectMake(0, 0, 200, 100))
    let msgLabel = UILabel(frame: CGRectMake(0, 0, 200, 50))
    let yesButton = UIButton(frame: CGRectMake(0, 0, 70, 40))
    let noButton = UIButton(frame: CGRectMake(0, 0, 70, 40))
    
    //タンクの移動操作
    let controller = UIView(frame: CGRectMake(0, 0, 50, 50))
    let controllerCenter = UIView(frame: CGRectMake(0, 0, 70, 70))
    let shootButton = UIButton(frame: CGRectMake(0, 0, 70, 70))
    
    //終了時のメッセージ
    let finishLabel = UILabel(frame: CGRectMake(0, 0, 200, 50))
    
    //戻るボタン
    let backButton = UIButton(frame: CGRectMake(0, 0, 200, 50))
    
    //通信接続時
    let background = UILabel()
    let okButton = UIButton(frame: CGRectMake(0, 0, 100, 40))
    let addCPUButton = UIButton(frame: CGRectMake(0, 0, 150, 40))
    let chooseFieldButtonCheck = UIButton(frame: CGRectMake(0, 0, 120, 40))
    let chooseFieldButtonUp = UIButton(frame: CGRectMake(0, 0, 30, 30))
    let chooseFieldButtonDown = UIButton(frame: CGRectMake(0, 0, 30, 30))
    
    //対戦フィールド設置場所
    let fieldCheckBackground = UILabel()
    let fieldCheckLabel = UILabel()
    let fieldCheckGoButton = UIButton()
    let fieldCheckCancelButton = UIButton()
    let setFieldButton = UIButton(frame: CGRectMake(0, 0, 150, 50))
    
    //開始ボタン
    let startButton = UIButton(frame: CGRectMake(0, 0, 150, 50))
    let startLabel = UILabel(frame: CGRectMake(0, 0, 150, 40))
    
    //平面向け！メッセージ
    let msgToPlane = UILabel(frame: CGRectMake(0, 0, 300, 50))
    var canStart: Bool = false
    
    //コンソール
    let consoleView = UIScrollView()
    let console = UILabel()
    var consoleText = ""
    
    //AR設定
    var configuration: ARWorldTrackingConfiguration! = ARWorldTrackingConfiguration()
    
    let fieldPlaceNode = SCNNode()
    let originNode = SCNNode()
    var originTheta: Float = 0.0
    
    var canJoin: Bool = true
    var connectedFlag: Bool = false
    var canSetField: Bool = false
    var standbyFlag: Bool = false
    var startCountFlag: Bool = false
    var startFlag: Bool = false
    var originFlag: Bool = false
    var finishFlag: Bool = false
    var nowFieldChecking: Bool = false
    
    var fieldChoosen: Int = 0
    var fields: [(name: String, fieldSize: [Int], wallsHorizontal: [(idx: Int, x: Int, len: Int)] , wallsVertical: [(idx: Int, z: Int, len: Int)])] =
    [(name: "Stage 1",
      fieldSize: [5, 3],
      wallsHorizontal: [],
      wallsVertical: []),
     (name: "Stage 2",
      fieldSize: [7, 5],
      wallsHorizontal: [],
      wallsVertical: []),
     (name: "Stage 3",
      fieldSize: [9, 7],
      wallsHorizontal: [],
      wallsVertical: []),
     (name: "Stage 4",
      fieldSize: [7, 5],
      wallsHorizontal: [],
      wallsVertical: [(idx: 2, z:  1, len: 1),
                      (idx: 5, z: -1, len: 1)]),
     (name: "Stage 5",
      fieldSize: [7, 5],
      wallsHorizontal: [(idx: 2, x:  2, len: 0),
                        (idx: 3, x: -2, len: 0)],
      wallsVertical: [(idx: 2, z:  1, len: 0),
                      (idx: 2, z:  2, len: 0),
                      (idx: 5, z: -2, len: 0),
                      (idx: 5, z: -1, len: 0)]),
     (name: "Stage 6",
      fieldSize: [9, 7],
      wallsHorizontal: [(idx: 2, x: 0, len: 2),
                        (idx: 5, x: 0, len: 2)],
      wallsVertical: [])
     ]
    
    //フィールドの大きさ
    var fieldSize: [Int] = [] //x: 5, 7, 9   , z: 3, 5, 7
    var wallsHorizontal: [(idx: Int, x: Int, len: Int)] = []
    var wallsVertical: [(idx: Int, z: Int, len: Int)] = []
    var stageNum: Int = 0
    
    var autonomousTank: Dictionary<String, (String, Int, SCNVector3, Float, Int, String) -> (Float, Bool, String)> = [:]
    
    var tanks: [Tank] = []  //タンク
    var walls: [Wall] = []  //壁
    
    var canMove: [[Bool]] = []
    
    var cpuMember: Dictionary<String, (commands: [(Int, String)],
                                    variableBool  : Dictionary<String, Bool>,
                                    variableInt   : Dictionary<String, Int>,
                                    variableFloat : Dictionary<String, Float>,
                                    variableTank  : Dictionary<String, (x: Float, y: Float)>,
                                    variableBullet: Dictionary<String, (x: Float, y: Float, theta: Float)>,
                                    listBool  : Dictionary<String, [Bool]>,
                                    listInt   : Dictionary<String, [Int]>,
                                    listFloat : Dictionary<String, [Float]>,
                                    listTank  : Dictionary<String, [(x: Float, y: Float)]>,
                                    listBullet: Dictionary<String, [(x: Float, y: Float, theta: Float)]>,
                                    path: String)> = [:]
    
    deinit {
        print("battleViewControler is successfully deintialized!!")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            self?.updateFunc()
        })
        
        self.view.isMultipleTouchEnabled = true
        
        //ユーザー名の取得
        self.myName = userDefaults.string(forKey: "userName")!

        
        //スクリーンサイズの格納
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
        
        //フィールド設置ボタン
        setFieldButton.center.x = screenWidth / 2
        setFieldButton.center.y = screenHeight / 2 - 100
        setFieldButton.layer.cornerRadius = 10
        setFieldButton.clipsToBounds = true
        setFieldButton.backgroundColor = myBlue
        setFieldButton.setTitle(NSLocalizedString("Set field", comment: ""), for: UIControl.State.normal)
        setFieldButton.addTarget(self, action: #selector(self.setField(_:)), for: UIControl.Event.touchUpInside)
        
        //開始ボタン
        startButton.center.x = screenWidth / 2
        startButton.center.y = screenHeight / 2 - 100
        startButton.layer.cornerRadius = 10
        startButton.clipsToBounds = true
        startButton.backgroundColor = myBlue
        startButton.setTitle(NSLocalizedString("Battle start", comment: ""), for: UIControl.State.normal)
        startButton.addTarget(self, action: #selector(self.start(_:)), for: UIControl.Event.touchUpInside)
        
        //開始メッセージ
        startLabel.center.x = screenWidth / 2
        startLabel.center.y = screenHeight / 2 - 100
        startLabel.backgroundColor = UIColor.white
        startLabel.layer.cornerRadius = 10
        startLabel.clipsToBounds = true
        startLabel.alpha = 0.8
        startLabel.text = "3"
        startLabel.textAlignment = NSTextAlignment.center
        
        //フィールド設置をやり直すか確認するボタン
        fieldCheckBackground.frame = CGRect(x: 0, y: 0, width: 250, height: 130)
        fieldCheckBackground.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 50)
        fieldCheckBackground.backgroundColor = UIColor.white
        fieldCheckBackground.layer.cornerRadius = 5
        fieldCheckBackground.clipsToBounds = true
        self.view.addSubview(fieldCheckBackground)
        fieldCheckBackground.isHidden = true
        
        fieldCheckLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        fieldCheckLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 75)
        fieldCheckLabel.textAlignment = NSTextAlignment.center
        fieldCheckLabel.text = NSLocalizedString("Standby?", comment: "")
        fieldCheckLabel.textColor = .black
        fieldCheckLabel.layer.cornerRadius = 5
        fieldCheckLabel.clipsToBounds = true
        self.view.addSubview(fieldCheckLabel)
        fieldCheckLabel.isHidden = true
        
        fieldCheckGoButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        fieldCheckGoButton.center = CGPoint(x: screenWidth / 2 + 60, y: screenHeight / 2 - 25)
        fieldCheckGoButton.layer.cornerRadius = 5
        fieldCheckGoButton.clipsToBounds = true
        fieldCheckGoButton.backgroundColor = myBlue
        fieldCheckGoButton.addTarget(self, action: #selector(self.fieldCheckGoAction(_:)), for: UIControl.Event.touchUpInside)
        fieldCheckGoButton.setTitle("OK", for: UIControl.State.normal)
        self.view.addSubview(fieldCheckGoButton)
        fieldCheckGoButton.isHidden = true
        
        fieldCheckCancelButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        fieldCheckCancelButton.center = CGPoint(x: screenWidth / 2 - 60, y: screenHeight / 2 - 25)
        fieldCheckCancelButton.layer.cornerRadius = 5
        fieldCheckCancelButton.clipsToBounds = true
        fieldCheckCancelButton.backgroundColor = UIColor.lightGray
        fieldCheckCancelButton.addTarget(self, action: #selector(self.fieldCheckCancelAction(_:)), for: UIControl.Event.touchUpInside)
        fieldCheckCancelButton.setTitle(NSLocalizedString("Redo", comment: ""), for: UIControl.State.normal)
        self.view.addSubview(fieldCheckCancelButton)
        fieldCheckCancelButton.isHidden = true
        
        msgToPlane.center.x = self.screenWidth / 2
        msgToPlane.center.y = self.screenHeight * 3 / 4
        msgToPlane.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        msgToPlane.text = NSLocalizedString("Capture", comment: "")
        msgToPlane.textColor = .black
        msgToPlane.textAlignment = .center
        msgToPlane.layer.cornerRadius = 10
        msgToPlane.clipsToBounds = true
        self.view.addSubview(msgToPlane)
        msgToPlane.isHidden = true
        
        sceneView.delegate = self   // デリゲートを設定
        sceneView.scene = SCNScene()    // シーンを作成して登録
        
        sceneView.autoenablesDefaultLighting = true;    // ライトの追加
        configuration.planeDetection = .horizontal      //平面検出
        
        //マルチプレイ
        if !self.isSolo {
            if self.isAdvertiser {
                //通信接続画面(advertiser用)
                self.connectViewForAdvertiser()
            }
            else {
                //通信接続画面(browser用)
                self.connectViewForBrowser()
                //10秒後にフラグが立っていなかったらホームに戻る
                self.perform(#selector(failToBrowse), with: nil, afterDelay: 10)
            }
        }
        //ソロプレイ
        else {
            //AR画面の開始
            sceneView.session.run(configuration)
            
            //フィールド設置用
            sceneView.scene.rootNode.addChildNode(self.fieldPlaceNode)
            let pointNode = SCNNode()
            pointNode.geometry = SCNSphere(radius: 0.001)
            pointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            self.fieldPlaceNode.addChildNode(pointNode)
            self.fieldPlaceNode.isHidden = true
            
            //原点ノード
            sceneView.scene.rootNode.addChildNode(self.originNode)
            self.originNode.isHidden = true
            
            //壁の設置
            self.setField()
            self.fieldPlaceNode.geometry = SCNBox(width: 0.05 * CGFloat(self.fieldSize[0]), height: 0.0001, length: 0.05 * CGFloat(self.fieldSize[1]), chamferRadius: 0.0)
        }
        
        //戻るボタン
        backButton.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        backButton.layer.cornerRadius = 10
        backButton.center.x = self.screenWidth / 2 - 100
        backButton.center.y = 100
        backButton.backgroundColor = UIColor.darkGray
        backButton.setTitle("← " + NSLocalizedString("Disconnect", comment: ""), for: UIControl.State.normal)
        self.backButton.addTarget(self, action: #selector(self.backBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.backButton)
        
        if self.isSolo {
            self.backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.backButton.layer.cornerRadius = 20
            self.backButton.backgroundColor = myBlue
            self.backButton.setTitle("←", for: UIControl.State.normal)
            self.backButton.center.x = 50
            self.backButton.center.y = 100
        }
    }
    
    //接続失敗時
    @objc func failToBrowse() {
        //接続成功フラグが立っていなかったら
        if !self.connectedFlag {
            //通知送信
            NotificationCenter.default.post(name: .canNotConnect, object: nil)
            //ホーム画面に戻る
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //通信接続画面(Advertiser)
    func connectViewForAdvertiser() {
        //背景
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.backgroundColor = UIColor.lightGray
        self.view.addSubview(background)
        
        //決定ボタン
        okButton.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        okButton.center.x = screenWidth - 100
        okButton.center.y = 100
        okButton.layer.cornerRadius = 10
        okButton.backgroundColor = myBlue
        okButton.setTitle(NSLocalizedString("Battle", comment: "") + " →", for: UIControl.State.normal)
        okButton.addTarget(self, action: #selector(self.ok(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(okButton)
        
        //CPU追加ボタン
        addCPUButton.center.x = screenWidth / 2
        addCPUButton.center.y = 260
        addCPUButton.layer.cornerRadius = 5
        addCPUButton.backgroundColor = myBlue
        addCPUButton.setTitle(NSLocalizedString("Add CPU", comment: ""), for: UIControl.State.normal)
        addCPUButton.addTarget(self, action: #selector(self.addCPU(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(addCPUButton)
        
        chooseFieldButtonCheck.center.x = screenWidth / 2
        chooseFieldButtonCheck.center.y = 150
        chooseFieldButtonCheck.layer.cornerRadius = 5
        chooseFieldButtonCheck.backgroundColor = UIColor.lightGray
        chooseFieldButtonCheck.layer.borderColor = myBlue.cgColor
        chooseFieldButtonCheck.layer.borderWidth = 1
        chooseFieldButtonCheck.setTitle(self.fields[self.fieldChoosen].name, for: UIControl.State.normal)
        chooseFieldButtonCheck.setTitleColor(myBlue, for: UIControl.State.normal)
        chooseFieldButtonCheck.addTarget(self, action: #selector(self.chooseFieldBtnCheckAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(chooseFieldButtonCheck)
        
        chooseFieldButtonUp.center.x = screenWidth / 2 + 80
        chooseFieldButtonUp.center.y = 150
        chooseFieldButtonUp.layer.cornerRadius = 15
        chooseFieldButtonUp.backgroundColor = UIColor.lightGray
        chooseFieldButtonUp.setTitle(">", for: UIControl.State.normal)
        chooseFieldButtonUp.setTitleColor(myBlue, for: UIControl.State.normal)
        chooseFieldButtonUp.addTarget(self, action: #selector(self.chooseFieldBtnUpAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(chooseFieldButtonUp)
        
        chooseFieldButtonDown.center.x = screenWidth / 2 - 80
        chooseFieldButtonDown.center.y = 150
        chooseFieldButtonDown.layer.cornerRadius = 15
        chooseFieldButtonDown.backgroundColor = UIColor.lightGray
        chooseFieldButtonDown.setTitle("<", for: UIControl.State.normal)
        chooseFieldButtonDown.setTitleColor(myBlue, for: UIControl.State.normal)
        chooseFieldButtonDown.addTarget(self, action: #selector(self.chooseFieldBtnDownAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(chooseFieldButtonDown)
        
        self.fieldSize = self.fields[self.fieldChoosen].fieldSize
        self.wallsVertical = self.fields[self.fieldChoosen].wallsVertical
        self.wallsHorizontal = self.fields[self.fieldChoosen].wallsHorizontal
        
        //自身をメンバーに追加
        members.append(Member(view: self.view, name: self.myName, ID: UIDevice.current.identifierForVendor!.uuidString, index: 0, screenWidth: self.screenWidth, isCpu: false, updateShowFunc: updateShowFunc))
        self.addCPUButton.center.y = CGFloat(210 + 50 * members.count)
        
        //自身の状態をスタンバイに
        standby[UIDevice.current.identifierForVendor!.uuidString] = true
    }
    
    @IBAction func chooseFieldBtnCheckAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        let pathViewController = self.storyboard?.instantiateViewController(withIdentifier: "PathViewController") as! PathViewController
        pathViewController.onlyShow = true
        pathViewController.fieldSize = self.fields[self.fieldChoosen].fieldSize
        pathViewController.wallsVertical = self.fields[self.fieldChoosen].wallsVertical
        pathViewController.wallsHorizontal = self.fields[self.fieldChoosen].wallsHorizontal
        self.present(pathViewController, animated: true, completion: nil)
    }
    
    @IBAction func chooseFieldBtnUpAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.fieldChoosen < self.fields.count - 1 {
            self.fieldChoosen += 1
        }
        
        chooseFieldButtonCheck.setTitle(self.fields[self.fieldChoosen].name, for: UIControl.State.normal)
        self.fieldSize = self.fields[self.fieldChoosen].fieldSize
        self.wallsVertical = self.fields[self.fieldChoosen].wallsVertical
        self.wallsHorizontal = self.fields[self.fieldChoosen].wallsHorizontal
    }
    
    @IBAction func chooseFieldBtnDownAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.fieldChoosen > 0 {
            self.fieldChoosen -= 1
        }
        
        chooseFieldButtonCheck.setTitle(self.fields[self.fieldChoosen].name, for: UIControl.State.normal)
        self.fieldSize = self.fields[self.fieldChoosen].fieldSize
        self.wallsVertical = self.fields[self.fieldChoosen].wallsVertical
        self.wallsHorizontal = self.fields[self.fieldChoosen].wallsHorizontal
    }
    
    //通信接続画面(Browser)
    func connectViewForBrowser() {
        //背景
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.backgroundColor = UIColor.lightGray
        self.view.addSubview(background)
    }
    
    //描画更新(advertiser用)
    func updateShowFunc() {
        if !self.stopProcess {
            //各ボタンの位置を更新
            for n in 0 ..< members.count {
                if members[n].deleteFlag {
                    members.remove(at: n)
                    break
                }
            }
            for n in 0 ..< members.count {
                members[n].updatePosition(idx: n)
            }
            self.addCPUButton.center.y = CGFloat(210 + 50 * members.count)
            
            //データ送信
            var str = "MMBR"
            for member in members {
                str.append("/")
                str.append(member.name)
                str.append(",")
                if member.team {
                    str.append("red")
                }
                else {
                    str.append("blue")
                }
            }
            sendToAllPeers(Data(str.utf8))
        }
    }
    
    //CPU追加ボタン
    var cpuNum = 1
    @IBAction func addCPU(_ sender: Any) {
        if self.members.count < 8 {
            UISelectionFeedbackGenerator().selectionChanged()
            //メンバーに追加
            members.append(Member(view: self.view, name: "CPU" + String(cpuNum), ID: "CPU-" + String(cpuNum), index: self.members.count, screenWidth: self.screenWidth, isCpu: true, updateShowFunc: updateShowFunc))
            cpuNum += 1
            self.updateShowFunc()
        }
    }
    
    //決定ボタン(対戦画面に移行)
    @IBAction func ok(_ sender: Any) {
        //各チームの人数が均等か確認
        var countRed = 0
        var countBlue = 0
        for member in members {
            if member.team {
                countRed += 1
            }
            else {
                countBlue += 1
            }
        }
        if countRed <= 4 && countRed == countBlue {
            UISelectionFeedbackGenerator().selectionChanged()
            //各種オブジェクトの非表示化
            self.background.isHidden = true
            sceneView.session.run(configuration)
            sceneView.scene.rootNode.addChildNode(self.fieldPlaceNode)
            let pointNode = SCNNode()
            pointNode.geometry = SCNSphere(radius: 0.001)
            pointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            self.fieldPlaceNode.addChildNode(pointNode)
            self.fieldPlaceNode.isHidden = true
            
            self.backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.backButton.layer.cornerRadius = 20
            self.backButton.backgroundColor = myBlue
            self.backButton.setTitle("←", for: UIControl.State.normal)
            self.backButton.center.x = 50
            self.backButton.center.y = 100
            
            sceneView.scene.rootNode.addChildNode(self.originNode)
            self.originNode.isHidden = true
            
            self.setField()
            self.fieldPlaceNode.geometry = SCNBox(width: 0.05 * CGFloat(self.fieldSize[0]), height: 0.0001, length: 0.05 * CGFloat(self.fieldSize[1]), chamferRadius: 0.0)
            
            self.okButton.removeFromSuperview()
            for member in members {
                member.goBattle()
            }
            self.addCPUButton.removeFromSuperview()
            self.chooseFieldButtonCheck.removeFromSuperview()
            self.chooseFieldButtonUp.removeFromSuperview()
            self.chooseFieldButtonDown.removeFromSuperview()
            
            //タンクの追加
            var teamID = 1
            var position = SCNVector3(0, 0, 0)
            var idxRed = 0
            var idxBlue = 0
            for member in members {
                self.canJoin = false
                if member.team {
                    teamID = 1
                    if idxRed == 0 {
                        position = SCNVector3(0.025 * Float(self.fieldSize[0] - 1), 0, -0.025 * Float(self.fieldSize[1] - 3))
                    }
                    else if idxRed == 1 {
                        position = SCNVector3(0.025 * Float(self.fieldSize[0] - 3), 0, -0.025 * Float(self.fieldSize[1] - 3))
                    }
                    else if idxRed == 2 {
                        position = SCNVector3(0.025 * Float(self.fieldSize[0] - 1), 0, -0.025 * Float(self.fieldSize[1] - 1))
                    }
                    else if idxRed == 3 {
                        position = SCNVector3(0.025 * Float(self.fieldSize[0] - 3), 0, -0.025 * Float(self.fieldSize[1] - 1))
                    }
                    idxRed += 1
                }
                else {
                    teamID = 0
                    if idxBlue == 0 {
                        position = SCNVector3(-0.025 * Float(self.fieldSize[0] - 1), 0, 0.025 * Float(self.fieldSize[1] - 3))
                    }
                    else if idxBlue == 1 {
                        position = SCNVector3(-0.025 * Float(self.fieldSize[0] - 3), 0, 0.025 * Float(self.fieldSize[1] - 3))
                    }
                    else if idxBlue == 2 {
                        position = SCNVector3(-0.025 * Float(self.fieldSize[0] - 1), 0, 0.025 * Float(self.fieldSize[1] - 1))
                    }
                    else if idxBlue == 3 {
                        position = SCNVector3(-0.025 * Float(self.fieldSize[0] - 3), 0, 0.025 * Float(self.fieldSize[1] - 1))
                    }
                    idxBlue += 1
                }
                self.addTank(ID: member.ID, teamID: teamID, position: position)
                
                //データ送信
                let str = "GOTO/battle/" + String(self.fieldSize[0]) + "/" + String(self.fieldSize[1])
                self.sendToAllPeers(Data(str.utf8))
            }
            //advertiseの停止
            self.serviceAdvertiser.stopAdvertisingPeer()
        }
        else {
            //チームの人数が均等でない場合
            self.retryLabel.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight / 2 - 100)
            self.retryLabel.backgroundColor = UIColor.white
            self.retryLabel.layer.cornerRadius = 5
            self.retryLabel.clipsToBounds = true
            self.retryLabel.text = NSLocalizedString("Balance the number of Tanks", comment: "")
            self.retryLabel.textAlignment = .center
            self.view.addSubview(self.retryLabel)
            
            self.retryButton.frame = self.view.frame
            self.retryButton.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight / 2)
            self.retryButton.backgroundColor = UIColor.clear
            self.retryButton.addTarget(self, action: #selector(self.retryBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(self.retryButton)
        }
    }
    
    @IBAction func retryBtnAction(_ sender: Any) {
        self.retryLabel.removeFromSuperview()
        self.retryButton.removeFromSuperview()
    }
    
    //タンク同士, タンクと壁の衝突判定
    func collisionDetectionWithTank(idx: Int) -> Bool {
        let x = tanks[idx].position.x + tanks[idx].velocity_x
        let z = tanks[idx].position.z + tanks[idx].velocity_z
        for n in 0 ..< self.tanks.count {
            if n != idx && self.tanks[n].state {
                if (self.tanks[n].position.x - x) *  (self.tanks[n].position.x - x) + (self.tanks[n].position.z - z) * (self.tanks[n].position.z - z) < 0.026 * 0.026 {
                    tanks[idx].updateVelocity(x: 0, z: 0)
                    return false
                }
            }
        }
        for wall in walls {
            if wall.calcDistance(x: x, z: z) < 0.015 {
                return false
            }
        }
        return true
    }
    
    //タンクと弾丸の衝突判定
    func collisionDetectionWithBullet(idx: Int, x: Float, z: Float) {
        for n in 0 ..< self.tanks.count {
            if self.tanks[idx].state {
                for bullet in self.tanks[n].bullets {
                    if bullet.state {
                        if (bullet.position.x - x) *  (bullet.position.x - x) + (bullet.position.z - z) * (bullet.position.z - z) < 0.013 * 0.013 && idx != n {
                            bullet.delete()
                            self.tanks[idx].delete()
                            let str = tanks[idx].getStringData()!
                            if str != "" && !self.isSolo{
                                let data: Data = Data(str.utf8)
                                self.sendToAllPeers(data)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //弾丸同士, 弾丸と壁の衝突判定
    func collisionDetectionBullets(idx: Int) {
        for bullet in self.tanks[idx].bullets {
            if bullet.state == true {
                let x = bullet.position.x
                let z = bullet.position.z
                for tank in tanks {
                    for b in tank.bullets {
                        if !(tank.ID == tanks[idx].ID && b.number == bullet.number) && b.state == true{
                            if (b.position.x - x) * (b.position.x - x) + (b.position.z - z) * (b.position.z - z) < 0.006 * 0.006 {
                                bullet.delete()
                                b.delete()
                            }
                        }
                    }
                }
                for wall in walls {
                    if wall.calcDistance(x: x, z: z) < 0.004 {
                        bullet.delete()
                    }
                }
                if self.isChiikawa && !self.chiikawaNode.isHidden {
                    if self.isInArea(x: bullet.position.x - chiikawaNode.position.x, z: bullet.position.z - chiikawaNode.position.z, xmin: -0.02, xmax: 0.02, zmin: -0.02, zmax: 0.02) {
                        self.chiikawaNode.isHidden = true
                        bullet.delete()
                    }
                }
            }
        }
    }
    
    //4つの直線に囲まれた範囲内かを計算
    func isInArea(x: Float, z: Float, xmin: Float, xmax: Float, zmin: Float, zmax: Float) -> Bool {
        return xmin < x && x < xmax && zmin < z && z < zmax
    }
    
    //相手陣地への侵入判定
    func territoryOccupied(territoryID: Int, tank: Tank) -> Bool {
        if !tank.state {
            return false
        }
        else {
            if territoryID == 1 && tank.teamID == 0 {
                return isInArea(x: tank.position.x, z: tank.position.z, xmin: 0.025 * Float(self.fieldSize[0] - 4), xmax: 0.025 * Float(self.fieldSize[0]), zmin: -0.025 * Float(self.fieldSize[1]), zmax: -0.025 * Float(self.fieldSize[1] - 4))
            }
            else if territoryID == 0 && tank.teamID == 1 {
                return isInArea(x: tank.position.x, z: tank.position.z, xmin: -0.025 * Float(self.fieldSize[0]), xmax: -0.025 * Float(self.fieldSize[0] - 4), zmin: 0.025 * Float(self.fieldSize[1] - 4), zmax: 0.025 * Float(self.fieldSize[1]))
            }
            else {
                return false
            }
        }
    }
    
    //終了時の処理
    func finishMatch(winner: Int) {
        if !self.finishFlag {
            UISelectionFeedbackGenerator().selectionChanged()
            DispatchQueue.main.async { [self] in
                self.finishLabel.center.x = screenWidth / 2
                self.finishLabel.center.y = screenHeight / 2
                self.finishLabel.backgroundColor = UIColor.white
                self.finishLabel.layer.cornerRadius = 5
                self.finishLabel.clipsToBounds = true
                self.finishLabel.alpha = 0.8
                
                self.backButton.isHidden = false
                self.backButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
                self.backButton.center.x = screenWidth / 2
                self.backButton.center.y = screenHeight / 2 + 100
                self.backButton.layer.cornerRadius = 5
                self.backButton.clipsToBounds = true
                self.backButton.backgroundColor = myBlue
                self.backButton.setTitle(NSLocalizedString("To home", comment: ""), for: UIControl.State.normal)
            }

            var str: String = "FNSH/"
            
            var myTeam: Int = 0
            for tank in tanks {
                if tank.ID == UIDevice.current.identifierForVendor!.uuidString || tank.ID == "myCPU" {
                    if tank.teamID == 1 { myTeam = 1 }
                    else { myTeam = -1 }
                }
            }
            if winner == 1 { str.append("red") }
            else if winner == -1 { str.append("blue")}

            if winner == myTeam {
                DispatchQueue.main.async {
                    self.finishLabel.font = UIFont.systemFont(ofSize: 20)
                    self.finishLabel.text = "You win!!"
                    self.finishLabel.textColor = .black
                }
                if self.isSolo {
                    userDefaults.set(true, forKey: "isUnlockedStage" + String(self.stageNum + 1))
                }
            }
            else if winner == -1 * myTeam {
                DispatchQueue.main.async {
                    self.finishLabel.font = UIFont.systemFont(ofSize: 20)
                    self.finishLabel.text = "You lose..."
                    self.finishLabel.textColor = .black
                }
            }
            else if winner == 0 {
                DispatchQueue.main.async {
                    self.finishLabel.font = UIFont.systemFont(ofSize: 20)
                    self.finishLabel.text = "Draw"
                    self.finishLabel.textColor = .black
                }
                str.append("draw")
            }
            DispatchQueue.main.async {
                self.finishLabel.textAlignment = NSTextAlignment.center
                self.view.addSubview(self.finishLabel)
                self.view.addSubview(self.backButton)
            }
                
            if !self.isSolo {
                let data: Data = Data(str.utf8)
                self.sendToAllPeers(data)
            }
            self.deleteButtonFromScreen()
            self.finishFlag = true
            
            self.needAlert = false
        }
    }
    
    var count: Int = 0
    var cpuStart: Bool = false
    var preTime: Date! = nil
    var nowTime: Date! = nil
    
    func updateFunc() {
        if !self.stopProcess {
            //バトルスタートのカウントダウン
            if self.startCountFlag {
                if count == 0 {
                    self.startLabel.textColor = .black
                    self.view.addSubview(self.startLabel)
                }
                else if count == 10 {
                    self.startLabel.text = "2"
                }
                else if count == 20 {
                    self.startLabel.text = "1"
                }
                else if count == 30 {
                    self.startLabel.text = NSLocalizedString("Battle start", comment: "")
                    self.startFlag = true
                }
                else if count == 31 {
                    self.cpuStart = true
                }
                else if count == 50 {
                    self.startLabel.isHidden = true
                    self.startCountFlag = false
                }
                count += 1
            }
            //スタート後の処理
            if self.startFlag && !self.finishFlag{
                //引き分け判定
                var flag = true
                for tank in tanks {
                    if tank.state {
                        flag = false
                    }
                }
                if flag {
                    self.finishMatch(winner: -0)
                }
            }
            
            //タンクの位置情報更新
            if self.startFlag && !self.finishFlag{
                for n in 0 ..< tanks.count {
                    if tanks[n].ID.prefix(3) == "CPU" || tanks[n].ID == "myCPU" {
                        if self.cpuStart {
                            tanks[n].update()
                        }
                    }
                    else {
                        tanks[n].update()
                    }
                }
            }
        }
    }
    //毎フレーム呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !self.stopProcess {
            if self.nowFieldChecking {
                DispatchQueue.main.async {
                    self.msgToPlane.isHidden = true
                }
            }
            else {
                if self.finishFlag || (self.canStart && self.isCpuBattle) {
                    DispatchQueue.main.async {
                        self.msgToPlane.removeFromSuperview()
                    }
                }
                else {
                    let center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
                    let centerTest = sceneView.hitTest(center, types: .existingPlaneUsingExtent)
                    if let centerResult = centerTest.first {
                        if self.canStart {
                            DispatchQueue.main.async {
                                self.msgToPlane.isHidden = true
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.msgToPlane.frame = CGRect(x: 0, y: 0, width: 350, height: 50)
                                self.msgToPlane.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight * 3 / 4)
                                self.msgToPlane.text = NSLocalizedString("Tap on the plane to set field", comment: "")
                                self.msgToPlane.isHidden = false
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.msgToPlane.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
                            self.msgToPlane.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight * 3 / 4)
                            self.msgToPlane.text = NSLocalizedString("Capture a flat surface", comment: "")
                            self.msgToPlane.isHidden = false
                        }
                    }
                }
            }
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == AVAuthorizationStatus.denied {
                DispatchQueue.main.async {
                    self.msgToPlane.text = NSLocalizedString("Allow Scriptank to use camera.", comment: "")
                    self.msgToPlane.center.x = self.screenWidth / 2
                    self.msgToPlane.center.y = self.screenHeight / 2
                    self.msgToPlane.isHidden = false
                }
            }
            
            //ループの処理時間でタンクと弾丸の速度を更新する
            if nowTime == nil {
                nowTime = Date()
            }
            preTime = nowTime
            nowTime = Date()
            let elapsed = Float(nowTime.timeIntervalSince(preTime))
            if elapsed < 3.0 {
                for tank in tanks {
                    //陣地侵入判定
                    if territoryOccupied(territoryID: 0, tank: tank) {
                        self.finishMatch(winner: 1)
                    }
                    else if territoryOccupied(territoryID: 1, tank: tank) {
                        self.finishMatch(winner: -1)
                    }
                    
                    if tank.state {
                        tank.velocity = 0.0625 * elapsed
                        if tank.velocity_x != 0 || tank.velocity_z != 0 {
                            tank.updateVelocity(x: tank.velocity_x / sqrtf(pow(tank.velocity_x, 2) + pow(tank.velocity_z, 2)), z: tank.velocity_z / sqrtf(pow(tank.velocity_x, 2) + pow(tank.velocity_z, 2)))
                        }
                    }
                    for bullet in tank.bullets {
                        if bullet.state {
                            bullet.velocity = 0.125 * elapsed
                        }
                    }
                }
            }
            //スタート後の処理
            if self.startFlag && !self.finishFlag{
                //ルーティーン処理
                for n in 0 ..< tanks.count {
                    //衝突判定
                    collisionDetectionBullets(idx: n)
                    collisionDetectionWithBullet(idx: n,
                                                 x: tanks[n].position.x,
                                                 z: tanks[n].position.z)
                    if tanks[n].ID == UIDevice.current.identifierForVendor!.uuidString {
                        //自分のタンクの胴体向き更新
                        let center = CGPoint(x: Int(self.screenWidth / 2), y: Int(self.screenHeight / 2))
                        let centerTest = sceneView.hitTest(center, types: .existingPlaneUsingExtent)
                        if !centerTest.isEmpty{
                            if let centerResult = centerTest.first {
                                let centerx = centerResult.worldTransform.columns.3.x - originNode.position.x
                                let centerz = centerResult.worldTransform.columns.3.z - originNode.position.z
                                let centerxRotated = centerx * cos(self.originTheta) - centerz * sin(self.originTheta)
                                let centerzRotated = centerx * sin(self.originTheta) + centerz * cos(self.originTheta)
                                tanks[n].rotateBody(centerx: centerxRotated, centerz: centerzRotated)
                            }
                        }
                        //自分のタンクのデータ送信
                        let str = tanks[n].getStringData()!
                        if str != "" && !self.isSolo {
                            let data: Data = Data(str.utf8)
                            self.sendToAllPeers(data)
                        }
                    }
                    //CPUデータ送信
                    if self.isAdvertiser && tanks[n].ID.components(separatedBy: "-")[0] == "CPU" {
                        let str = tanks[n].getStringData()!
                        if str != "" && !self.isSolo {
                            let data: Data = Data(str.utf8)
                            self.sendToAllPeers(data)
                        }
                    }
                    tanks[n].updateShow(canMove: collisionDetectionWithTank(idx: n))
                }
            }
            
            //フィールド位置更新
            self.moveField()
        }
    }
    
    func moveField() {
        if self.isMoveFieldMode && self.touch1 != nil && self.touch2 != nil && !self.originNode.isHidden {
            touchPosPre = touchPos
            let touchPos1 = touch1.location(in: sceneView)
            let hitTest1 = sceneView.hitTest(touchPos1, types: .existingPlaneUsingExtent)
            if !hitTest1.isEmpty {
                if let hitResult1 = hitTest1.first {
                    touchPos.x1 = hitResult1.worldTransform.columns.3.x
                    touchPos.z1 = hitResult1.worldTransform.columns.3.z
                }
                else { touchPos = touchPosPre }
            }
            else { touchPos = touchPosPre }
            
            let touchPos2 = touch2.location(in: sceneView)
            let hitTest2 = sceneView.hitTest(touchPos2, types: .existingPlaneUsingExtent)
            if !hitTest2.isEmpty {
                if let hitResult2 = hitTest2.first {
                    touchPos.x2 = hitResult2.worldTransform.columns.3.x
                    touchPos.z2 = hitResult2.worldTransform.columns.3.z
                }
                else { touchPos = touchPosPre }
            }
            else { touchPos = touchPosPre }
            
            if self.didNotMoveField { self.didNotMoveField = false }
            else {
                self.originNode.position.x += (touchPos.x1 + touchPos.x2) / 2 - (touchPosPre.x1 + touchPosPre.x2) / 2
                self.originNode.position.z += (touchPos.z1 + touchPos.z2) / 2 - (touchPosPre.z1 + touchPosPre.z2) / 2
                
                let w = atan2(touchPos.z1 - touchPos.z2, touchPos.x1 - touchPos.x2) - atan2(touchPosPre.z1 - touchPosPre.z2, touchPosPre.x1 - touchPosPre.x2)
                self.originNode.rotation.w -= w
                self.originTheta -= w
                
                let s = self.originNode.scale.x * sqrt(pow(touchPos.x1 - touchPos.x2, 2) + pow(touchPos.z1 - touchPos.z2, 2)) / sqrt(pow(touchPosPre.x1 - touchPosPre.x2, 2) + pow(touchPosPre.z1 - touchPosPre.z2, 2))
                self.originNode.scale = SCNVector3(s, s, s)
            }
        }
    }
    
    //tanksの中に同一IDのTankがなければ追加してデータ送信
    func addTank(ID: String, teamID: Int, position: SCNVector3) {
        self.setCpuForSolo()
        var flag = true
        for tank in tanks {
            if tank.ID == ID {
                flag = false
            }
        }
        if flag {
            let list = ID.components(separatedBy: "-")
            if autonomousTank.keys.contains(ID) {
                tanks.append(Tank(ID: ID, teamID: teamID, node: self.originNode, position: position, autonomousBehavior: autonomousTank[ID]!))
            }
            else if list.count == 3 {
                if list[0] == "CPU" && autonomousTank.keys.contains(list[2]) {
                    let t = Tank(ID: ID, teamID: teamID, node: self.originNode, position: position, autonomousBehavior: autonomousTank[list[2]]!)
                    let str = t.getStringData()!
                    if str != "" && !self.isSolo {
                        let data: Data = Data(str.utf8)
                        self.sendToAllPeers(data)
                    }
                    tanks.append(t)
                }
            }
            else {
                let t = Tank(ID: ID, teamID: teamID, node: self.originNode, position: position, autonomousBehavior: self.noUpdate)
                let str = t.getStringData()!
                if str != "" && !self.isSolo {
                    let data: Data = Data(str.utf8)
                    self.sendToAllPeers(data)
                }
                tanks.append(t)
            }
        }
    }
    
    //wallsの中に同一IDのWallがなければ追加してデータ送信
    func addWall(ID: String, x: Float, z: Float, n: Int, theta: Float) {
        var flag = true
        for wall in walls {
            if wall.ID == ID {
                flag = false
            }
        }
        if flag {
            let w = Wall(node: self.originNode, ID: ID, x: x, z: z, n: n, theta: theta)
            let str = w.getStringData()!
            if str != "" && !self.isSolo {
                let data: Data = Data(str.utf8)
                self.sendToAllPeers(data)
            }
            walls.append(w)
        }
    }
    
    //フィールド設置
    func setField() {
        self.addWall(ID: "up", x:  0.000, z: -0.025 * Float(self.fieldSize[1]), n: Int((self.fieldSize[0] - 1) / 2), theta: 0.0)
        self.addWall(ID: "down", x:  0.000, z: 0.025 * Float(self.fieldSize[1]), n: Int((self.fieldSize[0] - 1) / 2), theta: 0.0)
        self.addWall(ID: "left", x:  -0.025 * Float(self.fieldSize[0]), z: 0.000, n: Int((self.fieldSize[1] - 1) / 2), theta: Float.pi/2)
        self.addWall(ID: "right", x:  0.025 * Float(self.fieldSize[0]), z: 0.000, n: Int((self.fieldSize[1] - 1) / 2), theta: Float.pi/2)
        
        //ここで壁を追加
        var n = 0
        for wall in self.wallsHorizontal {
            let x = 0.05 * Float(wall.x)
            let z = -0.025 * Float(self.fieldSize[1]) + 0.05 * Float(wall.idx)
            self.addWall(ID: String(n), x: x, z: z, n: wall.len, theta: 0)
            n += 1
        }
        for wall in self.wallsVertical {
            let x = -0.025 * Float(self.fieldSize[0]) + 0.05 * Float(wall.idx)
            let z = 0.05 * Float(wall.z)
            self.addWall(ID: String(n), x: x, z: z, n: wall.len, theta: Float.pi / 2)
            n += 1
        }
        
        //陣地の追加
        let homeNodeRed = SCNNode()
        homeNodeRed.geometry = SCNBox(width: 0.1, height: 0.0001, length: 0.1, chamferRadius: 0)
        homeNodeRed.position = SCNVector3(0.025 * Float(self.fieldSize[0] - 2), 0, -0.025 * Float(self.fieldSize[1] - 2))
        homeNodeRed.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.9)
        self.originNode.addChildNode(homeNodeRed)
        
        let homeNodeBlue = SCNNode()
        homeNodeBlue.geometry = SCNBox(width: 0.1, height: 0.0001, length: 0.1, chamferRadius: 0)
        homeNodeBlue.position = SCNVector3(-0.025 * Float(self.fieldSize[0] - 2), 0, 0.025 * Float(self.fieldSize[1] - 2))
        homeNodeBlue.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.9)
        self.originNode.addChildNode(homeNodeBlue)
        
        if userDefaults.bool(forKey: "showDetail") {
            self.addCones()
        }
        
        //各ポイント間が移動可能か否かを判定
        for n in -((fieldSize[0] - 1) / 2) ..< ((fieldSize[0] + 1) / 2) {
            for m in -((fieldSize[1] - 1) / 2) ..< ((fieldSize[1] + 1) / 2) {
                let positionFrom = SCNVector3(0.05 * Float(n), 0, 0.05 * Float(m))
                var bools: [Bool] = []
                for j in -((fieldSize[0] - 1) / 2) ..< ((fieldSize[0] + 1) / 2) {
                    for k in -((fieldSize[1] - 1) / 2) ..< ((fieldSize[1] + 1) / 2) {
                        let positionTo = SCNVector3(0.05 * Float(j), 0, 0.05 * Float(k))
                        bools.append(self.isNotDevidedWithWall(position1: positionFrom, position2: positionTo, len: 0.015))
                    }
                }
                self.canMove.append(bools)
            }
        }
        if self.isChiikawa {
            //ちいかわ
            guard let chiikawaScene = SCNScene(named: "chiikawa.scn") else {return}
            chiikawaNode = chiikawaScene.rootNode.childNode(withName: "chiikawa", recursively: true)!
            chiikawaNode.rotation = SCNVector4(0.0, 1.0, 0.0, -Float.pi/2)
            chiikawaNode.scale = SCNVector3(0.15, 0.15, 0.15)
            originNode.addChildNode(chiikawaNode)
        }
        
        //テスト=========================
        if self.isTest {
            let pNode = SCNNode(geometry: SCNBox(width: 2.0, height: 0.001, length: 2.0, chamferRadius: 0.0))
            pNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            pNode.position.y -= 0.34
            self.originNode.addChildNode(pNode)
            
            let pNode2 = SCNNode(geometry: SCNBox(width: 2.0, height: 0.001, length: 2.0, chamferRadius: 0.0))
            pNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            pNode2.position.y += 1.0
            self.originNode.addChildNode(pNode2)
            
            let wNode = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 0.001, chamferRadius: 0.0))
            wNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            wNode.position.z -= 1.0
            self.originNode.addChildNode(wNode)
            
            let wNode4 = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 0.001, chamferRadius: 0.0))
            wNode4.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            wNode4.position.z += 1.0
            self.originNode.addChildNode(wNode4)
            
            let wNode2 = SCNNode(geometry: SCNBox(width: 0.001, height: 2.0, length: 2.0, chamferRadius: 0.0))
            wNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            wNode2.position.x -= 1.0
            self.originNode.addChildNode(wNode2)
            
            let wNode3 = SCNNode(geometry: SCNBox(width: 0.001, height: 2.0, length: 2.0, chamferRadius: 0.0))
            wNode3.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            wNode3.position.x += 1.0
            self.originNode.addChildNode(wNode3)
            
            guard let tableScene = SCNScene(named: "table.scn") else {return}
            let tableNode = tableScene.rootNode.childNode(withName: "table", recursively: true)!
            tableNode.position.y -= 0.34
            self.originNode.addChildNode(tableNode)
        }
        //============================
    }
    
    //カラーコーンの追加
    func addCones() {
        guard let conesScene1 = SCNScene(named: "cones.scn") else {return}
        let conesNode1 = conesScene1.rootNode.childNode(withName: "cones", recursively: true)!
        conesNode1.position = SCNVector3(-0.025 * Float(self.fieldSize[0] + 1), 0.0, 0.025 * Float(self.fieldSize[1] + 1))
        conesNode1.scale = SCNVector3(1.2, 1.2, 1.2)
        self.originNode.addChildNode(conesNode1)
        guard let conesScene2 = SCNScene(named: "cones.scn") else {return}
        let conesNode2 = conesScene2.rootNode.childNode(withName: "cones", recursively: true)!
        conesNode2.position = SCNVector3(0.025 * Float(self.fieldSize[0] + 1), 0.0, 0.025 * Float(self.fieldSize[1] + 1))
        conesNode2.rotation = SCNVector4(0, 1, 0, Float.pi / 2)
        conesNode2.scale = SCNVector3(1.2, 1.2, 1.2)
        self.originNode.addChildNode(conesNode2)
        guard let conesScene3 = SCNScene(named: "cones.scn") else {return}
        let conesNode3 = conesScene3.rootNode.childNode(withName: "cones", recursively: true)!
        conesNode3.position = SCNVector3(0.025 * Float(self.fieldSize[0] + 1), 0.0, -0.025 * Float(self.fieldSize[1] + 1))
        conesNode3.rotation = SCNVector4(0, 1, 0, Float.pi)
        conesNode3.scale = SCNVector3(1.2, 1.2, 1.2)
        self.originNode.addChildNode(conesNode3)
        guard let conesScene4 = SCNScene(named: "cones.scn") else {return}
        let conesNode4 = conesScene4.rootNode.childNode(withName: "cones", recursively: true)!
        conesNode4.position = SCNVector3(-0.025 * Float(self.fieldSize[0] + 1), 0.0, -0.025 * Float(self.fieldSize[1] + 1))
        conesNode4.rotation = SCNVector4(0, 1, 0, -Float.pi / 2)
        conesNode4.scale = SCNVector3(1.2, 1.2, 1.2)
        self.originNode.addChildNode(conesNode4)
    }
    
    //タンク操作用の各オブジェクトを設置
    func addButtonToScreen() {
        if !self.isCpuBattle {
            scopePoint.center.x = screenWidth / 2
            scopePoint.center.y = screenHeight / 2
            scopePoint.layer.cornerRadius = scopePoint.frame.height / 2
            scopePoint.backgroundColor = UIColor.red
            self.view.addSubview(scopePoint)
            
            scopeLeft.center.x = screenWidth / 2 - 30
            scopeLeft.center.y = screenHeight / 2
            scopeLeft.backgroundColor = UIColor.black
            self.view.addSubview(scopeLeft)
            
            scopeRight.center.x = screenWidth / 2 + 30
            scopeRight.center.y = screenHeight / 2
            scopeRight.backgroundColor = UIColor.black
            self.view.addSubview(scopeRight)
            
            scopeUp.center.x = screenWidth / 2
            scopeUp.center.y = screenHeight / 2 + 30
            scopeUp.backgroundColor = UIColor.black
            self.view.addSubview(scopeUp)
            
            scopeDown.center.x = screenWidth / 2
            scopeDown.center.y = screenHeight / 2 - 30
            scopeDown.backgroundColor = UIColor.black
            self.view.addSubview(scopeDown)
            
            scopeFrame.center.x = screenWidth / 2
            scopeFrame.center.y = screenHeight / 2
            scopeFrame.backgroundColor = UIColor.clear
            scopeFrame.layer.borderWidth = 1
            scopeFrame.layer.borderColor = CGColor(gray: 0, alpha: 1)
            scopeFrame.layer.cornerRadius = scopeFrame.frame.height / 2
            self.view.addSubview(scopeFrame)
            
            controllerCenter.center.x = 80
            controllerCenter.center.y = screenHeight - 120
            controllerCenter.layer.cornerRadius = controllerCenter.frame.height / 2
            controllerCenter.backgroundColor = UIColor.white
            controllerCenter.alpha = 0.5
            self.view.addSubview(controllerCenter)
            
            controller.center.x = 80
            controller.center.y = screenHeight - 120
            controller.layer.cornerRadius = controller.frame.height / 2
            controller.backgroundColor = UIColor.black
            controller.alpha = 0.8
            self.view.addSubview(controller)
            
            shootButton.center.x = screenWidth - 80
            shootButton.center.y = screenHeight - 120
            shootButton.layer.cornerRadius = shootButton.frame.height / 2
            shootButton.backgroundColor = UIColor.black
            shootButton.alpha = 0.8
            shootButton.addTarget(self, action: #selector(self.attack(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(shootButton)
        }
        else {
            consoleView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight / 4)
            consoleView.contentSize = CGSize(width: screenWidth, height: screenHeight / 4)
            consoleView.center.x = screenWidth / 2
            consoleView.center.y = screenHeight * 7 / 8
            consoleView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            self.view.addSubview(consoleView)
            
            console.frame = CGRect(x: 15, y: 0, width: screenWidth - 30, height: screenHeight / 4)
            console.numberOfLines = 0
            console.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
            addToConsole(txt: NSLocalizedString("The contents of the PrintBlock and code errors will be displayed here", comment: ""))
            console.textColor = UIColor.white
            console.sizeToFit()
            consoleView.addSubview(console)
        }
    }
    
    func addToConsole(txt: String) {
        consoleText.append("\n>> " + txt)
        console.text = consoleText + "\n"
        console.sizeToFit()
        console.frame = CGRect(x: 15, y: 0, width: screenWidth - 30, height: console.frame.height)
        consoleView.contentSize = CGSize(width: screenWidth, height: console.frame.height)
        if consoleView.contentSize.height > consoleView.frame.height {
            consoleView.contentOffset = CGPoint(x: 0, y: consoleView.contentSize.height - consoleView.frame.height)
        }
    }
    
    //タンク操作用の各オブジェクトを削除
    func deleteButtonFromScreen() {
        DispatchQueue.main.async { [self] in
            self.scopePoint.isHidden = true
            self.scopeLeft.isHidden = true
            self.scopeRight.isHidden = true
            self.scopeUp.isHidden = true
            self.scopeDown.isHidden = true
            self.scopeFrame.isHidden = true
            self.controllerCenter.isHidden = true
            self.controller.isHidden = true
            self.shootButton.isHidden = true
        }
    }
    
    // 平面が検出されたとき呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        //ノード作成
        let planeNode = SCNNode()
        //ジオメトリ作成
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.materials.first?.diffuse.contents = UIColor.black.withAlphaComponent(0.0)
        //ノードにGeometryとTransformを指定
        planeNode.geometry = geometry
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        //検出したアンカーに対応するノードに子ノードとして持たせる
        node.addChildNode(planeNode)
    }
    
    //攻撃ボタン
    @IBAction func attack(_ sender: Any) {
        for tank in self.tanks {
            if tank.ID == UIDevice.current.identifierForVendor!.uuidString {
                tank.shootFlag = true
            }
        }
    }
    
    //フィールドセットボタン
    @IBAction func setField(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.setFieldButton.isHidden = true
        
        if !self.isSolo {
            sendToAllPeers(Data("GOTO/setfield".utf8))
        }
        self.originNode.isHidden = false
        
        self.view.addSubview(startButton)
    }
    
    //スタートボタン
    @IBAction func start(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.startButton.isHidden = true
        if !self.isSolo {
            sendToAllPeers(Data("GOTO/start".utf8))
        }
        if !self.isSolo {
            self.serviceAdvertiser.stopAdvertisingPeer()
        }
        self.startCountFlag = true
    }
    
    //戻るボタン
    @IBAction func backBtnAction(_ sender: Any) {
        if !self.needAlert {
            UISelectionFeedbackGenerator().selectionChanged()
            self.stopProcess = true
            if !self.isSolo {
                var str = "MMBR/dropout/"
                if self.isAdvertiser {
                    str.append("advertiser")
                }
                else {
                    str.append(UIDevice.current.identifierForVendor!.uuidString)
                }
                sendToAllPeers(Data(str.utf8))
            }
            
            self.tanks = []
            self.walls = []
            self.members = []
            self.membersForBrowser = []
            self.autonomousTank = [:]
            
            mpsession = nil
            serviceAdvertiser = nil
            serviceBrowser = nil
            
            self.timer?.invalidate()
            
            self.dismiss(animated: false, completion: nil)
            
            self.sceneView.session.pause()
            self.sceneView = nil
            
            self.configuration = nil
            
            NotificationCenter.default.post(name: .finishBattle, object: nil)
        }
        else {
            UISelectionFeedbackGenerator().selectionChanged()
            backGround.center.x = self.screenWidth / 2
            backGround.center.y = self.screenHeight / 2
            backGround.backgroundColor = UIColor.white
            backGround.layer.cornerRadius = 5
            backGround.clipsToBounds = true
            self.view.addSubview(backGround)
            
            msgLabel.center.x = self.screenWidth / 2
            msgLabel.center.y = self.screenHeight / 2 - 25
            msgLabel.backgroundColor = UIColor.clear
            msgLabel.textColor = UIColor.black
            if self.isSolo {
                msgLabel.text = NSLocalizedString("To home?", comment: "")
            }
            else {
                msgLabel.text = NSLocalizedString("Withdraw from battle?", comment: "")
            }
            msgLabel.textAlignment = .center
            self.view.addSubview(msgLabel)
            
            yesButton.center.x = self.screenWidth / 2 + 50
            yesButton.center.y = self.screenHeight / 2 + 20
            yesButton.backgroundColor = myBlue.withAlphaComponent(0.8)
            yesButton.layer.cornerRadius = 5
            yesButton.clipsToBounds = true
            yesButton.setTitle(NSLocalizedString("Yes", comment: ""), for: UIControl.State.normal)
            yesButton.addTarget(self, action: #selector(self.yesBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(yesButton)

            noButton.center.x = self.screenWidth / 2 - 50
            noButton.center.y = self.screenHeight / 2 + 20
            noButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
            noButton.layer.cornerRadius = 5
            noButton.clipsToBounds = true
            noButton.setTitle(NSLocalizedString("No", comment: ""), for: UIControl.State.normal)
            noButton.addTarget(self, action: #selector(self.noBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(noButton)
            
            self.backButton.isHidden = true
        }
    }
    
    //フィールドを設置するボタン
    @IBAction func fieldCheckGoAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.fieldPlaceNode.isHidden = true
        self.fieldCheckBackground.isHidden = true
        self.fieldCheckLabel.isHidden = true
        self.fieldCheckGoButton.isHidden = true
        self.fieldCheckCancelButton.isHidden = true
        
        self.nowFieldChecking = false
        self.canStart = true
        
        self.addButtonToScreen()
        
        //自分のタンクに矢印を追加
        for tank in tanks {
            if tank.ID == UIDevice.current.identifierForVendor!.uuidString || tank.ID == "myCPU" {
                let arrowNode = SCNNode()
                arrowNode.geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.007, height: 0.02)
                arrowNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.7)
                arrowNode.position.y += 0.035
                arrowNode.rotation = SCNVector4(0, 0, 1, Float.pi)
                tank.legNode.addChildNode(arrowNode)
            }
        }
        
        var flag = true
        for elem in self.standby {
            if !elem.value {
                flag = false
            }
        }
        //全てのpeerがstandby状態になった時
        if flag {
            self.canSetField = true
        }
        
        if !self.isAdvertiser {
            let str = "GOTO/standby/" + UIDevice.current.identifierForVendor!.uuidString
            sendToAllPeers(Data(str.utf8))
            //戻るボタン押下時にアラート出現
            self.needAlert = true
        }
        else {
            if self.canSetField {
                //スタートスイッチの追加 
                //ソロプレイでなければ フィールド設置ボタンに
                if self.isSolo {
                    self.view.addSubview(startButton)
                }
                else {
                    self.view.addSubview(setFieldButton)
                }
                //戻るボタン押下時にアラート出現
                self.needAlert = true
            }
            else {
                self.canSetField = true
            }
        }
        self.standbyFlag = true
        
        if self.isSolo {
            self.originNode.isHidden = false
        }
    }
    
    //フィールドを設置し直すボタン
    @IBAction func fieldCheckCancelAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        self.nowFieldChecking = false
        self.fieldPlaceNode.isHidden = true
        self.fieldCheckBackground.isHidden = true
        self.fieldCheckLabel.isHidden = true
        self.fieldCheckGoButton.isHidden = true
        self.fieldCheckCancelButton.isHidden = true
    }
    
    @IBAction func yesBtnAction(_ sender: Any) {
        self.stopProcess = true
        
        if self.isSolo {
            UISelectionFeedbackGenerator().selectionChanged()
            self.finishMatch(winner: 1)
            self.startButton.removeFromSuperview()
            self.startLabel.removeFromSuperview()
            
            backGround.removeFromSuperview()
            msgLabel.removeFromSuperview()
            yesButton.removeFromSuperview()
            noButton.removeFromSuperview()
            
            self.needAlert = false
            self.backButton.isHidden = false
        }
        
        else {
            UISelectionFeedbackGenerator().selectionChanged()
            for tank in tanks {
                if tank.ID == UIDevice.current.identifierForVendor!.uuidString {
                    tank.delete()
                    let str = tank.getStringData()!
                    if str != "" {
                        let data: Data = Data(str.utf8)
                        self.sendToAllPeers(data)
                    }
                }
            }
            
            if !self.startCountFlag && self.isAdvertiser {
                sendToAllPeers(Data("MMBR/dropout/advertiser".utf8))
            }
            
            self.tanks = []
            self.walls = []
            self.members = []
            self.membersForBrowser = []
            self.autonomousTank = [:]
            
            mpsession = nil
            serviceAdvertiser = nil
            serviceBrowser = nil
            
            self.timer?.invalidate()
            
            self.dismiss(animated: false, completion: nil)
            
            self.sceneView.session.pause()
            self.sceneView = nil
            
            self.configuration = nil
            
            NotificationCenter.default.post(name: .finishBattle, object: nil)
        }
    }
    
    @IBAction func noBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        backGround.removeFromSuperview()
        msgLabel.removeFromSuperview()
        yesButton.removeFromSuperview()
        noButton.removeFromSuperview()
        
        self.backButton.isHidden = false
    }
}
