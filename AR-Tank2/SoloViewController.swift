//
//  SoloViewController.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/20.
//

import Foundation
import SceneKit

class SoloViewController: UIViewController {
    let userDefaults = UserDefaults.standard
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myBlue2 = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
    
    let scrollView = UIScrollView()
    
    var screenWidth: CGFloat = 0.0      //スクリーン幅
    var screenHeight: CGFloat = 0.0     //スクリーン高さ
    
    let backButton = UIButton()         //戻るボタン
    
    var battleViewController: BattleViewController! = nil
    var editorViewController: EditorViewController! = nil
    
    var stageSelects: [StageSelect] = []
    var stageType: [Bool] = []
    var enemys: [[(x: Int, y: Int)]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(msgForFinishBattle), name: .finishBattle, object: nil)
        
        //フレームサイズの格納
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
        
        self.scrollView.frame = self.view.frame
        scrollView.contentSize = CGSize(width: self.screenWidth, height: 2100)
        scrollView.backgroundColor = UIColor.lightGray
        view.addSubview(scrollView)
        
        let whiteLabel = UILabel(frame: CGRectMake(20, 0, self.screenWidth - 40, 100))
        whiteLabel.backgroundColor = UIColor.lightGray
        self.view.addSubview(whiteLabel)
        
        //戻るボタン
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.center = CGPoint(x: 50, y: 80)
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.backgroundColor = myBlue
        backButton.setTitle("←", for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(self.backBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(backButton)
        
        //ステージ1
        addStage(fieldSize: [5, 3],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: false,
                 enemy: [(x: 2, y: 0)])
        //ステージ2
        addStage(fieldSize: [5, 3],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: false,
                 enemy: [(x: 2, y: 0)])
        //ステージ3
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [(idx: 2, x:  2, len: 0),
                                   (idx: 3, x: -2, len: 0)],
                 wallsVertical: [(idx: 2, z:  1, len: 0),
                                 (idx: 2, z:  2, len: 0),
                                 (idx: 5, z: -2, len: 0),
                                 (idx: 5, z: -1, len: 0)],
                 type: false,
                 enemy: [(x: 3, y: -1)])
        //ステージ4
        addStage(fieldSize: [5, 3],
                 wallsHorizontal: [(idx: 1, x: -1, len: 0),
                                   (idx: 2, x:  1, len: 0)],
                 wallsVertical: [(idx: 2, z:  0, len: 0),
                                 (idx: 2, z:  1, len: 0),
                                 (idx: 3, z:  0, len: 0),
                                 (idx: 3, z: -1, len: 0)],
                 type: false,
                 enemy: [(x: 0, y: -1), (x: 0, y: 1), (x: 2, y: 0)])
        //ステージ5
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: false,
                 enemy: [(x: 3, y: -1), (x: 2, y: -2)])
        //ステージ6
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: false,
                 enemy: [(x: -3, y: -2), (x: 3, y: 2)])
        //ステージ7
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: false,
                 enemy: [(x: 3, y: -1), (x: 2, y: -2)])
        //ステージ8
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [],
                 wallsVertical: [(idx: 2, z:  1, len: 1),
                                 (idx: 5, z: -1, len: 1)],
                 type: false,
                 enemy: [(x: 3, y: -1)])
        //ステージ9
        addStage(fieldSize: [9, 7],
                 wallsHorizontal: [(idx: 2, x: 0, len: 2),
                                   (idx: 5, x: 0, len: 2)],
                 wallsVertical: [],
                 type: false,
                 enemy: [(x: 4, y: -2)])
        //ステージ10
        addStage(fieldSize: [9, 7],
                 wallsHorizontal: [],
                 wallsVertical: [(idx: 3, z:  1, len: 2),
                                 (idx: 6, z: -1, len: 2)],
                 type: false,
                 enemy: [(x: -3, y: -2), (x: 0, y: 2), (x: 3, y: -2)])
        //ステージ11
        addStage(fieldSize: [5, 3],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: true,
                 enemy: [(x: 2, y: 0)])
        //ステージ12
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [],
                 wallsVertical: [(idx: 2, z:  1, len: 1),
                                 (idx: 5, z: -1, len: 1)],
                 type: true,
                 enemy: [(x: 3, y: -1)])
        //ステージ13
        addStage(fieldSize: [5, 3],
                 wallsHorizontal: [],
                 wallsVertical: [(idx: 2, z:  0, len: 0),
                                 (idx: 2, z:  1, len: 0),
                                 (idx: 3, z:  0, len: 0),
                                 (idx: 3, z: -1, len: 0)],
                 type: true,
                 enemy: [(x: 2, y: 0)])
        //ステージ14
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: true,
                 enemy: [(x: -3, y: -2), (x: 3, y: 2)])
        //ステージ15
        addStage(fieldSize: [9, 3],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: true,
                 enemy: [(x: 3, y: 0)])
        //ステージ16
        addStage(fieldSize: [9, 3],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: true,
                 enemy: [(x: 2, y: -1), (x: 2, y: 0), (x: 2, y: 1)])
        //ステージ17
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [],
                 wallsVertical: [],
                 type: true,
                 enemy: [(x: -3, y: -2), (x: 3, y: 2)])
        //ステージ18
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [(idx: 2, x:  2, len: 0),
                                   (idx: 3, x: -2, len: 0)],
                 wallsVertical: [(idx: 2, z:  1, len: 0),
                                 (idx: 2, z:  2, len: 0),
                                 (idx: 5, z: -2, len: 0),
                                 (idx: 5, z: -1, len: 0)],
                 type: true,
                 enemy: [(x: 3, y: -1)])
        //ステージ19
        addStage(fieldSize: [9, 7],
                 wallsHorizontal: [(idx: 2, x: -3, len: 0),
                                   (idx: 3, x: -3, len: 0),
                                   (idx: 5, x: -0, len: 0)],
                 wallsVertical: [(idx: 2, z: -1, len: 0),
                                 (idx: 4, z:  2, len: 0),
                                 (idx: 5, z:  2, len: 0)],
                 type: true,
                 enemy: [(x: 3, y: -2), (x: 0, y: 2), (x: -3, y: -1)])
        //ステージ20
        addStage(fieldSize: [7, 5],
                 wallsHorizontal: [(idx: 2, x:  2, len: 0)],
                 wallsVertical: [(idx: 5, z: -2, len: 0),
                                 (idx: 5, z: -1, len: 0)],
                 type: true,
                 enemy: [(x: 3, y: -1), (x: -3, y: -2), (x: 3, y: 2)])
    }
    
    func addStage(fieldSize: [Int], wallsHorizontal: [(idx: Int, x: Int, len: Int)], wallsVertical: [(idx: Int, z: Int, len: Int)], type: Bool, enemy: [(x: Int, y: Int)]) {
        let new = StageSelect(parental: self.view, view: self.scrollView, fieldSize: fieldSize, wallsHorizontal: wallsHorizontal, wallsVertical: wallsVertical, screenWidth: self.screenWidth, index: stageSelects.count, goFunc: goFunc)
        if type {
            new.button.backgroundColor = myBlue2
        }
        stageSelects.append(new)
        stageType.append(type)
        enemys.append(enemy)
    }
    
    func goFunc(fieldSize: [Int], wallsHorizontal: [(idx: Int, x: Int, len: Int)], wallsVertical: [(idx: Int, z: Int, len: Int)], idx: Int) {
        //ステージ前半
        if !stageType[idx] {
            //対戦画面をインスタンス化
            battleViewController = (self.storyboard?.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController)
            //フルスクリーンで表示
            battleViewController.modalPresentationStyle = .fullScreen
            //ソロプレイ用設定
            battleViewController.isSolo = true
            
            battleViewController.fieldSize = fieldSize
            battleViewController.wallsHorizontal = wallsHorizontal
            battleViewController.wallsVertical = wallsVertical
            battleViewController.stageNum = idx
            //自分のタンクを追加
            battleViewController.addTank(ID: UIDevice.current.identifierForVendor!.uuidString, teamID: 0, position: SCNVector3(-0.025 * Float(battleViewController.fieldSize[0] - 1), 0, 0.025 * Float(battleViewController.fieldSize[1] - 3)))
            //敵のタンクを追加
            var i = 0
            for enemy in enemys[idx] {
                battleViewController.addTank(ID: "CPU-stage" + String(idx+1) + "-" + String(i), teamID: 1, position: SCNVector3(0.05 * Float(enemy.x), 0, 0.05 * Float(enemy.y)))
                i += 1
            }
            self.present(battleViewController, animated: false, completion: nil)
        }
        //ステージ後半
        else {
            //設定画面のインスタンス化
            editorViewController = (self.storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as! EditorViewController)
            //フルスクリーンで表示
            editorViewController.modalPresentationStyle = .fullScreen
            
            editorViewController.fieldSize = fieldSize
            editorViewController.wallsHorizontal = wallsHorizontal
            editorViewController.wallsVertical = wallsVertical
            editorViewController.battleIndex = idx
            editorViewController.enemy = enemys[idx]
            
            //画面を表示
            self.present(editorViewController, animated: false, completion: nil)

        }
    }

    //戻るボタン押下時
    @IBAction func backBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        self.dismiss(animated: false, completion: nil)
    }
    
    //通知受信(バトル終了)
    @objc func msgForFinishBattle() {
        self.battleViewController = nil
        
        for stageSelect in stageSelects {
            stageSelect.unlock()
        }
    }
}
