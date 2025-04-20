//
//  EditorViewController.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/28.
//

import Foundation
import SceneKit

class EditorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let userDefaults = UserDefaults.standard
    
    let scrollView = UIScrollView()
    
    let editView = UIView()

    var fieldSize: [Int] = [0, 0]
    var wallsHorizontal: [(idx: Int, x: Int, len: Int)] = []
    var wallsVertical: [(idx: Int, z: Int, len: Int)] = []
    var battleIndex: Int = 0
    var enemy: [(x: Int, y: Int)] = []
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myOrange = UIColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
    let myPurple = UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0)
    let myBrown = UIColor(red: 0.4, green: 0.6, blue: 0.3, alpha: 1.0)
    
    var screenWidth: CGFloat = 0.0      //スクリーン幅
    var screenHeight: CGFloat = 0.0     //スクリーン高さ
    
    let clearButton = UIButton()
    let backButton = UIButton()         //戻るボタン
    let goToBattleButton = UIButton()   //対戦開始ボタン
    let helpButton = UIButton()
    
    var battleViewController: BattleViewController! = nil
    
    var editorElements: [EditorElement] = []
    
    var valueDecisionViewController: ValueDecisionViewController? = nil
    
    var pathViewController: PathViewController! = nil
    
    //ルーム検索, 設定用ビュー
    let nameInputLabel = UILabel()   //背景
    let nameBox = UITextField()      //入力ボックス
    let goButton = UIButton()        //決定ボタン
    let noButton = UIButton()        //戻るボタン
    
    let cancelButton = UIButton(frame: CGRectMake(0, 0, 70, 30))
    let decideButton = UIButton(frame: CGRectMake(0, 0, 70, 30))
    
    var variableBool: [String]   = []
    var variableInt: [String]    = []
    var variableFloat: [String]  = []
    var variableTank: [String]   = []
    var variableBullet: [String] = []
    var listBool: [String]   = []
    var listInt: [String]    = []
    var listFloat: [String]  = []
    var listTank: [String]   = []
    var listBullet: [String] = []
    let variableBoolBook:   [String] = ["shoot"]
    let variableIntBook:    [String] = ["count"]
    let variableFloatBook:  [String] = ["ref_x", "ref_y"]
    let variableTankBook:   [String] = ["self"]
    let variableBulletBook: [String] = []
    let listBoolBook:       [String] = []
    let listIntBook:        [String] = []
    let listFloatBook:      [String] = []
    let listTankBook:       [String] = ["enemys", "allys"]
    let listBulletBook:     [String] = ["bullets"]
    
    var state: Int = 0
    
    var dataList: [String] = []
    var nowName: String = ""
    let defineNew: String = NSLocalizedString("Define new", comment: "")
    var pickerView = UIPickerView()
    
    let label = UILabel(frame: CGRectMake(0, 0, 250, 50))
    let clear = UIButton()
    
    deinit {
        print("editorViewController is successfully deinitialized!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.variableBool   = self.variableBoolBook
        self.variableInt    = self.variableIntBook
        self.variableFloat  = self.variableFloatBook
        self.variableTank   = self.variableTankBook
        self.variableBullet = self.variableBulletBook
        self.listBool   = self.listBoolBook
        self.listInt    = self.listIntBook
        self.listFloat  = self.listFloatBook
        self.listTank   = self.listTankBook
        self.listBullet = self.listBulletBook
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBoolVariable), name: .addBtnForBoolVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForIntVariable), name: .addBtnForIntVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForFloatVariable), name: .addBtnForFloatVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForTankVariable), name: .addBtnForTankVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBulletVariable), name: .addBtnForBulletVariable, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBoolList), name: .addBtnForBoolList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForIntList), name: .addBtnForIntList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForFloatList), name: .addBtnForFloatList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForTankList), name: .addBtnForTankList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBulletList), name: .addBtnForBulletList, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBoolPrint), name: .addBtnForBoolPrint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForIntPrint), name: .addBtnForIntPrint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForFloatPrint), name: .addBtnForFloatPrint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForTankPrint), name: .addBtnForTankPrint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBulletPrint), name: .addBtnForBulletPrint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForTextPrint), name: .addBtnForTextPrint, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBoolAppend), name: .addBtnForBoolAppend, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForIntAppend), name: .addBtnForIntAppend, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForFloatAppend), name: .addBtnForFloatAppend, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForTankAppend), name: .addBtnForTankAppend, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBtnForBulletAppend), name: .addBtnForBulletAppend, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addViewForBoolVariable), name: .addViewForBoolVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addViewForIntVariable), name: .addViewForIntVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addViewForFloatVariable), name: .addViewForFloatVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addViewForTankVariable), name: .addViewForTankVariable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addViewForBulletVariable), name: .addViewForBulletVariable, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(variableForRepetition), name: .variableForRepetition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(listForRepetition), name: .listForRepetition, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteElement), name: .deleteElement, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveValue), name: .saveValue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(msgForFinishBattle), name: .finishBattle, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPathEditor), name: .showPathEditor, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deletePathEditor), name: .deletePathEditor, object: nil)
        
        //フレームサイズの格納
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
        
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight * 3 / 4)
        self.scrollView.center.y = self.screenHeight * 3 / 8
        self.scrollView.backgroundColor = UIColor.darkGray
        scrollView.contentSize = CGSize(width: 400, height: self.scrollView.frame.height + 50)
        view.addSubview(scrollView)
        
        clearButton.backgroundColor = UIColor.clear
        clearButton.frame = CGRect(x: 0, y: 0, width: 400, height: scrollView.frame.height + 50)
        clearButton.addTarget(self, action: #selector(clearBtnAction), for: .touchUpInside)
        scrollView.addSubview(clearButton)
        
        self.editView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight / 4)
        self.editView.center.y = self.screenHeight * 7 / 8
        self.editView.backgroundColor = UIColor.lightGray
        view.addSubview(editView)
        
        //戻るボタン
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.center = CGPoint(x: 50, y: 80)
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.backgroundColor = myBlue
        backButton.setTitle("←", for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(self.backBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(backButton)
        
        //対戦開始ボタン
        goToBattleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        goToBattleButton.center = CGPoint(x: self.screenWidth - 50, y: 80)
        goToBattleButton.layer.cornerRadius = backButton.frame.height / 2
        goToBattleButton.backgroundColor = myBlue
        goToBattleButton.setTitle("→", for: UIControl.State.normal)
        goToBattleButton.addTarget(self, action: #selector(self.goToBattleBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(goToBattleButton)
        
        //ヘルプボタン
        helpButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        helpButton.center = CGPoint(x: self.screenWidth - 50, y: 130)
        helpButton.layer.cornerRadius = backButton.frame.height / 2
        helpButton.backgroundColor = UIColor.clear
        helpButton.setTitle("?", for: UIControl.State.normal)
        helpButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        helpButton.layer.borderWidth = 2
        helpButton.layer.borderColor = UIColor.lightGray.cgColor
        helpButton.addTarget(self, action: #selector(self.helpBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(helpButton)
        
        self.decodeCommands()
        
        //pickerView
        pickerView.frame = CGRect(x: 0, y: 0, width: self.editView.frame.width, height: self.editView.frame.height * 3 / 4)
        pickerView.backgroundColor = UIColor.clear
        pickerView.center.x = self.editView.frame.width / 2
        pickerView.center.y = self.view.frame.height - self.editView.frame.height * 3 / 8
        pickerView.delegate = self
        pickerView.dataSource = self
        self.view.addSubview(pickerView)
        pickerView.isHidden = true
        
        cancelButton.center.x = 50
        cancelButton.center.y = 30
        cancelButton.layer.cornerRadius = 10
        cancelButton.setTitle(NSLocalizedString("Back", comment: ""), for: UIControl.State.normal)
        cancelButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        cancelButton.backgroundColor = UIColor.darkGray
        cancelButton.addTarget(self, action: #selector(self.cancelBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(cancelButton)
        self.cancelButton.isHidden = true
        
        decideButton.center.x = self.pickerView.frame.width - 50
        decideButton.center.y = 30
        decideButton.layer.cornerRadius = 10
        decideButton.setTitle(NSLocalizedString("OK", comment: ""), for: UIControl.State.normal)
        decideButton.backgroundColor = myBlue
        decideButton.addTarget(self, action: #selector(self.decideBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(decideButton)
        self.decideButton.isHidden = true
        
        //ルーム名入力ラベル
        nameInputLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 130)
        nameInputLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 50)
        nameInputLabel.layer.cornerRadius = 10
        nameInputLabel.clipsToBounds = true
        nameInputLabel.backgroundColor = UIColor.lightGray
        
        //ルーム名入力ボックス
        nameBox.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        nameBox.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 75)
        nameBox.placeholder = NSLocalizedString("variable name", comment: "")
        nameBox.backgroundColor = UIColor.lightGray
        nameBox.layer.borderWidth = 1
        nameBox.layer.borderColor = UIColor.black.cgColor
        nameBox.layer.cornerRadius = 5
        nameBox.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        nameBox.leftViewMode = .always
        
        //決定ボタン
        goButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        goButton.center = CGPoint(x: screenWidth / 2 + 60, y: screenHeight / 2 - 25)
        goButton.layer.cornerRadius = 5
        goButton.clipsToBounds = true
        goButton.backgroundColor = myBlue
        goButton.setTitle("OK", for: UIControl.State.normal)
        goButton.addTarget(self, action: #selector(goBtnAction), for: .touchUpInside)
        
        //戻るボタン
        noButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        noButton.center = CGPoint(x: screenWidth / 2 - 60, y: screenHeight / 2 - 25)
        noButton.layer.cornerRadius = 5
        noButton.clipsToBounds = true
        noButton.backgroundColor = UIColor.darkGray
        noButton.setTitle(NSLocalizedString("Back", comment: ""), for: UIControl.State.normal)
        noButton.addTarget(self, action: #selector(noBtnAction), for: .touchUpInside)
    }
    
    func addElementForBlank() {
        if self.editorElements.count == 0 {
            self.editorElements.append(EditorElement(view: self.scrollView, editView: self.editView, screenWidth: self.scrollView.frame.width, screenHeight: self.scrollView.frame.height, index: self.editorElements.count, indent: 0, addAboveFunc: self.addAboveFunc, addBelowFunc: self.addBelowFunc, deleteFunc: self.deleteFunc, choosenChange: self.choosenChange))
            self.editorElements[0].choosen = true
            self.editorElements[0].choosenUpdate()
        }
        else {
            for i in 0 ..< self.editorElements.count {
                if self.editorElements[i].state == 3 {
                    if i == self.editorElements.count - 1 {
                        self.addBelowFunc(index: i, indent: self.editorElements[i].indent + 1)
                    }
                    else if i < self.editorElements.count - 1 {
                        if self.editorElements[i+1].indent <= self.editorElements[i].indent {
                            self.addBelowFunc(index: i, indent: self.editorElements[i].indent + 1)
                        }
                    }
                }
            }
        }
    }
    
    func positionUpdate() {
        var n: Int = 0
        var w: CGFloat = 400
        var h: CGFloat = scrollView.frame.height + 50
        for editorElement in editorElements {
            editorElement.index = n
            editorElement.positionUpdate()
            n += 1
            
            if CGFloat(300 + 50 * editorElement.indent) + editorElement.bodyLen > w {
                w = CGFloat(300 + 50 * editorElement.indent) + editorElement.bodyLen
            }
        }
        if CGFloat(200 + 100 * editorElements.count) > h {
            h = CGFloat(200 + 100 * editorElements.count)
        }
        self.scrollView.contentSize = CGSize(width: w, height: h)
        self.clearButton.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        self.pickerView.isHidden = true
        self.cancelButton.isHidden = true
        self.decideButton.isHidden = true
    }
    
    func addAboveFunc(index: Int) {
        self.editorElements.insert(EditorElement(view: self.scrollView, editView: self.editView, screenWidth: self.scrollView.frame.width, screenHeight: self.scrollView.frame.height, index: index, indent: self.editorElements[index].indent, addAboveFunc: self.addAboveFunc, addBelowFunc: self.addBelowFunc, deleteFunc: self.deleteFunc, choosenChange: self.choosenChange), at: index)
        self.choosenChange(index: index)
        self.positionUpdate()
    }
    
    func addBelowFunc(index: Int, indent: Int) {
        var n = index + 1
        for i in index + 1 ..< self.editorElements.count {
            if editorElements[i].indent > indent {
                n += 1
            }
            else {
                break
            }
        }
        
        self.editorElements.insert(EditorElement(view: self.scrollView, editView: self.editView, screenWidth: self.scrollView.frame.width, screenHeight: self.scrollView.frame.height, index: index + 1, indent: indent, addAboveFunc: self.addAboveFunc, addBelowFunc: self.addBelowFunc, deleteFunc: self.deleteFunc, choosenChange: self.choosenChange), at: n)
        self.choosenChange(index: n)
        self.positionUpdate()
    }
    
    func deleteFunc(index: Int) {
        let i = self.editorElements[index].indent
        self.editorElements.remove(at: index)
        while true {
            if index > self.editorElements.count - 1 {
                break
            }
            else if editorElements[index].indent <= i {
                break
            }
            else {
                self.editorElements[index].deleteSelf()
                self.editorElements.remove(at: index)
            }
        }
        self.addElementForBlank()
        
        //ここで変数の名前一覧を確認, 使われていない変数は削除
        self.checkVariable()
        self.checkList()
        
        self.positionUpdate()
    }
    
    func checkVariable() {
        var variableBoolNew: Dictionary<String, Bool> = [:]
        var variableIntNew: Dictionary<String, Bool> = [:]
        var variableFloatNew: Dictionary<String, Bool> = [:]
        var variableTankNew: Dictionary<String, Bool> = [:]
        var variableBulletNew: Dictionary<String, Bool> = [:]
        
        for e in variableBool { variableBoolNew[e] = false }
        for e in variableInt { variableIntNew[e] = false }
        for e in variableFloat { variableFloatNew[e] = false }
        for e in variableTank { variableTankNew[e] = false }
        for e in variableBullet { variableBulletNew[e] = false }
        
        for editorElement in editorElements {
            if editorElement.state == 1 && editorElement.elementType == 0 {
                if editorElement.variableLabel.name != NSLocalizedString("Name", comment: "") {
                    variableBoolNew[editorElement.variableLabel.name] = true
                }
            }
            if editorElement.state == 1 && editorElement.elementType == 1 {
                if editorElement.variableLabel.name != NSLocalizedString("Name", comment: "") {
                    variableIntNew[editorElement.variableLabel.name] = true
                }
            }
            if editorElement.state == 1 && editorElement.elementType == 2 {
                if editorElement.variableLabel.name != NSLocalizedString("Name", comment: "") {
                    variableFloatNew[editorElement.variableLabel.name] = true
                }
            }
            if editorElement.state == 1 && editorElement.elementType == 3 {
                if editorElement.variableLabel.name != NSLocalizedString("Name", comment: "") {
                    variableTankNew[editorElement.variableLabel.name] = true
                }
            }
            if editorElement.state == 1 && editorElement.elementType == 4 {
                if editorElement.variableLabel.name != NSLocalizedString("Name", comment: "") {
                    variableBulletNew[editorElement.variableLabel.name] = true
                }
            }
            if editorElement.state == 3 && editorElement.elementType == 0 {
                if editorElement.conditionalLabel.variable != NSLocalizedString("Variable name", comment: "") {
                    variableBoolNew[editorElement.conditionalLabel.variable] = true
                }
            }
            if editorElement.state == 3 && editorElement.elementType == 1 {
                if editorElement.conditionalLabel.variable != NSLocalizedString("Variable name", comment: "") {
                    variableIntNew[editorElement.conditionalLabel.variable] = true
                }
            }
            if editorElement.state == 3 && editorElement.elementType == 2 {
                if editorElement.conditionalLabel.variable != NSLocalizedString("Variable name", comment: "") {
                    variableFloatNew[editorElement.conditionalLabel.variable] = true
                }
            }
            if editorElement.state == 3 && editorElement.elementType == 3 {
                if editorElement.conditionalLabel.variable != NSLocalizedString("Variable name", comment: "") {
                    variableTankNew[editorElement.conditionalLabel.variable] = true
                }
            }
            if editorElement.state == 3 && editorElement.elementType == 4 {
                if editorElement.conditionalLabel.variable != NSLocalizedString("Variable name", comment: "") {
                    variableBulletNew[editorElement.conditionalLabel.variable] = true
                }
            }
        }
        for elem in variableBoolBook   { variableBoolNew[elem] = true   }
        for elem in variableIntBook    { variableIntNew[elem] = true    }
        for elem in variableFloatBook  { variableFloatNew[elem] = true  }
        for elem in variableTankBook   { variableTankNew[elem] = true   }
        for elem in variableBulletBook { variableBulletNew[elem] = true }
        
        variableBool   = []
        variableInt    = []
        variableFloat  = []
        variableTank   = []
        variableBullet = []
        
        for elem in variableBoolNew   { if elem.value { variableBool.append(elem.key)   } }
        for elem in variableIntNew    { if elem.value { variableInt.append(elem.key)    } }
        for elem in variableFloatNew  { if elem.value { variableFloat.append(elem.key)  } }
        for elem in variableTankNew   { if elem.value { variableTank.append(elem.key)   } }
        for elem in variableBulletNew { if elem.value { variableBullet.append(elem.key) } }
    }
    
    func checkList() {
        var listBoolNew: Dictionary<String, Bool> = [:]
        var listIntNew: Dictionary<String, Bool> = [:]
        var listFloatNew: Dictionary<String, Bool> = [:]
        var listTankNew: Dictionary<String, Bool> = [:]
        var listBulletNew: Dictionary<String, Bool> = [:]
        
        for e in listBool { listBoolNew[e] = false }
        for e in listInt { listIntNew[e] = false }
        for e in listFloat { listFloatNew[e] = false }
        for e in listTank { listTankNew[e] = false }
        for e in listBullet { listBulletNew[e] = false }
        
        for editorElement in editorElements {
            if editorElement.state == 2 && editorElement.elementType == 0 {
                if editorElement.listLabel.name != NSLocalizedString("Name", comment: "") {
                    listBoolNew[editorElement.listLabel.name] = true
                }
            }
            if editorElement.state == 2 && editorElement.elementType == 1 {
                if editorElement.listLabel.name != NSLocalizedString("Name", comment: "") {
                    listIntNew[editorElement.listLabel.name] = true
                }
            }
            if editorElement.state == 2 && editorElement.elementType == 2 {
                if editorElement.listLabel.name != NSLocalizedString("Name", comment: "") {
                    listFloatNew[editorElement.listLabel.name] = true
                }
            }
            if editorElement.state == 2 && editorElement.elementType == 3 {
                if editorElement.listLabel.name != NSLocalizedString("Name", comment: "") {
                    listTankNew[editorElement.listLabel.name] = true
                }
            }
            if editorElement.state == 2 && editorElement.elementType == 4 {
                if editorElement.listLabel.name != NSLocalizedString("Name", comment: "") {
                    listBulletNew[editorElement.listLabel.name] = true
                }
            }
        }
        for elem in listBoolBook   { listBoolNew[elem] = true   }
        for elem in listIntBook    { listIntNew[elem] = true    }
        for elem in listFloatBook  { listFloatNew[elem] = true  }
        for elem in listTankBook   { listTankNew[elem] = true   }
        for elem in listBulletBook { listBulletNew[elem] = true }
        
        listBool   = []
        listInt    = []
        listFloat  = []
        listTank   = []
        listBullet = []
        
        for elem in listBoolNew   { if elem.value { listBool.append(elem.key)   } }
        for elem in listIntNew    { if elem.value { listInt.append(elem.key)    } }
        for elem in listFloatNew  { if elem.value { listFloat.append(elem.key)  } }
        for elem in listTankNew   { if elem.value { listTank.append(elem.key)   } }
        for elem in listBulletNew { if elem.value { listBullet.append(elem.key) } }
    }
    
    func choosenChange(index: Int) {
        self.addElementForBlank()
        for n in 0 ..< self.editorElements.count {
            self.editorElements[n].choosen = (n == index)
            self.editorElements[n].choosenUpdate()
        }
        self.positionUpdate()
    }
    
    @IBAction func clearBtnAction(_ sender: Any) {
        self.choosenChange(index: -1)
        self.pickerView.isHidden = true
        self.cancelButton.isHidden = true
        self.decideButton.isHidden = true
        
        self.nameInputLabel.removeFromSuperview()
        self.nameBox.removeFromSuperview()
        self.goButton.removeFromSuperview()
        self.noButton.removeFromSuperview()
        self.nameBox.text = ""
        self.nameBox.endEditing(true)
    }
    
    //戻るボタン押下時
    @IBAction func backBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.encodeCommands()
        self.editorElements = []
        self.dismiss(animated: false, completion: nil)
    }
    
    //対戦開始ボタン押下時
    @IBAction func goToBattleBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        //対戦画面をインスタンス化
        battleViewController = (self.storyboard?.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController)
        //フルスクリーンで表示
        battleViewController.modalPresentationStyle = .fullScreen
        //ソロプレイ用設定
        battleViewController.isSolo = true
        //CPU対戦用設定
        battleViewController.isCpuBattle = true
        
        battleViewController.fieldSize = self.fieldSize
        battleViewController.wallsHorizontal = self.wallsHorizontal
        battleViewController.wallsVertical = self.wallsVertical
        battleViewController.stageNum = self.battleIndex
        
        var cmds: [(Int, String)] = []
        for editorElement in editorElements {
            cmds.append((editorElement.indent, editorElement.makeCommand()))
        }
        
        battleViewController.cpuMember["myCPU"] = (commands: cmds, variableBool: [:], variableInt: [:], variableFloat: [:], variableTank: [:], variableBullet: [:], listBool: [:], listInt: [:], listFloat: [:], listTank: [:], listBullet: [:], path: "")
        
        //自分のタンクを追加
        battleViewController.addTank(ID: "myCPU", teamID: 0, position: SCNVector3(-0.025 * Float(battleViewController.fieldSize[0] - 1), 0, 0.025 * Float(battleViewController.fieldSize[1] - 3)))
        //敵のタンクを追加
        var i = 0
        for e in self.enemy {
            battleViewController.addTank(ID: "CPU-stage" + String(battleIndex+1) + "-" + String(i), teamID: 1, position: SCNVector3(0.05 * Float(e.x), 0, 0.05 * Float(e.y)))
            i += 1
        }
        
        self.present(battleViewController, animated: false, completion: nil)
    }
    
    //通知受信(バトル終了)
    @objc func msgForFinishBattle() {
        self.battleViewController = nil
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        for n in 0 ..< self.editorElements.count {
            self.editorElements[n].choosenUpdate()
        }
        self.pickerView.isHidden = true
        self.cancelButton.isHidden = true
        self.decideButton.isHidden = true
    }
    
    @IBAction func decideBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        for editorElement in editorElements {
            if editorElement.choosen {
                if self.nowName != self.defineNew {
                    if self.state == 0 || self.state == 1 || self.state == 2 || self.state == 3 || self.state == 4 {
                        editorElement.variableLabel.name = self.nowName
                    }
                    else if self.state == 5 || self.state == 6 || self.state == 7 || self.state == 8 || self.state == 9 {
                        editorElement.listLabel.name = self.nowName
                    }
                    else if self.state == 10 {
                        editorElement.values = "append " + self.nowName
                        //多言語対応用================================================
                        let language = Locale.preferredLanguages.first?.prefix(2)
                        if language == "ja" {
                            editorElement.text = self.nowName + "を追加"
                        }
                        else if language == "zh" {
                            editorElement.text = "加上 " + self.nowName
                        }
                        else {
                            editorElement.text = "append " + self.nowName
                        }
                        //多言語対応用================================================
                        editorElement.listLabel.state = 1
                        editorElement.valueChanged()
                    }
                    else if self.state == 11 {
                        editorElement.conditionalLabel.list = self.nowName
                        editorElement.body.setTitle(editorElement.conditionalLabel.makeLabelMsg(), for: UIControl.State.normal)
                        editorElement.valueChanged()
                    }
                    else if self.state == 12 {
                        editorElement.printLabel.value = self.nowName
                    }
                }
                else {
                    //ここで名前定義ビューを立ち上げ
                    nameBox.placeholder = NSLocalizedString("Variable name", comment: "")
                    self.view.addSubview(self.nameInputLabel)
                    self.view.addSubview(self.nameBox)
                    self.view.addSubview(self.goButton)
                    self.view.addSubview(self.noButton)
                    self.nameBox.becomeFirstResponder() //デフォルトでキーボード表示
                }
            }
        }
        for n in 0 ..< self.editorElements.count {
            self.editorElements[n].choosenUpdate()
        }
        self.pickerView.isHidden = true
        self.cancelButton.isHidden = true
        self.decideButton.isHidden = true
    }
    
    @objc func addBtnForBoolVariable() {
        self.dataList = [self.defineNew] + self.variableBool
        self.state = 0
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForIntVariable() {
        self.dataList = [self.defineNew] + self.variableInt
        self.state = 1
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForFloatVariable() {
        self.dataList = [self.defineNew] + self.variableFloat
        self.state = 2
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForTankVariable() {
        self.dataList = [self.defineNew] + self.variableTank
        self.state = 3
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForBulletVariable() {
        self.dataList = [self.defineNew] + self.variableBullet
        self.state = 4
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForBoolList() {
        self.dataList = [self.defineNew] + self.listBool
        self.state = 5
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForIntList() {
        self.dataList = [self.defineNew] + self.listInt
        self.state = 6
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForFloatList() {
        self.dataList = [self.defineNew] + self.listFloat
        self.state = 7
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForTankList() {
        self.dataList = [self.defineNew] + self.listTank
        self.state = 8
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForBulletList() {
        self.dataList = [self.defineNew] + self.listBullet
        self.state = 9
        self.pickerView.reloadAllComponents()
        self.cancelButton.isHidden = false
        self.decideButton.isHidden = false
        self.pickerView.isHidden = false
    }
    
    @objc func addBtnForBoolPrint() {
        if self.variableBool.count != 0 {
            self.dataList = self.variableBool
            self.state = 12
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Bool variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForIntPrint() {
        if self.variableInt.count != 0 {
            self.dataList = self.variableInt
            self.state = 12
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Int variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForFloatPrint() {
        if self.variableFloat.count != 0 {
            self.dataList = self.variableFloat
            self.state = 12
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Float variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForTankPrint() {
        if self.variableTank.count != 0 {
            self.dataList = self.variableTank
            self.state = 12
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Tank variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForBulletPrint() {
        if self.variableBullet.count != 0 {
            self.dataList = self.variableBullet
            self.state = 12
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Bullet variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForTextPrint() {
        self.state = 12
        //ここで名前定義ビューを立ち上げ
        self.view.addSubview(self.nameInputLabel)
        self.view.addSubview(self.nameBox)
        self.view.addSubview(self.goButton)
        self.view.addSubview(self.noButton)
        nameBox.placeholder = NSLocalizedString("Text", comment: "")
        self.nameBox.becomeFirstResponder() //デフォルトでキーボード表示
        
        for n in 0 ..< self.editorElements.count {
            self.editorElements[n].choosenUpdate()
        }
    }
    
    func addMsg(msg: String) {
        label.center.x = self.editView.frame.width / 2
        label.center.y = self.editView.frame.height / 2
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.backgroundColor = UIColor.lightGray
        label.textAlignment = .center
        label.text = msg
        self.editView.addSubview(label)
        
        clear.frame = self.view.frame
        clear.center.x = self.view.frame.width / 2
        clear.center.y = self.view.frame.height / 2
        clear.backgroundColor = UIColor.clear
        clear.addTarget(self, action: #selector(self.clearAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(clear)
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.label.removeFromSuperview()
        self.clear.removeFromSuperview()
        for n in 0 ..< self.editorElements.count {
            self.editorElements[n].choosenUpdate()
        }
    }
    
    @objc func addBtnForBoolAppend() {
        if self.variableBool.count != 0 {
            self.dataList = self.variableBool
            self.state = 10
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Bool variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForIntAppend() {
        if self.variableInt.count != 0 {
            self.dataList = self.variableInt
            self.state = 10
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Int variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForFloatAppend() {
        if self.variableFloat.count != 0 {
            self.dataList = self.variableFloat
            self.state = 10
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Float variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForTankAppend() {
        if self.variableTank.count != 0 {
            self.dataList = self.variableTank
            self.state = 10
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Tank variable not declared", comment: ""))
        }
    }
    
    @objc func addBtnForBulletAppend() {
        if self.variableBullet.count != 0 {
            self.dataList = self.variableBullet
            self.state = 10
            self.pickerView.reloadAllComponents()
            self.cancelButton.isHidden = false
            self.decideButton.isHidden = false
            self.pickerView.isHidden = false
        }
        else {
            for n in 0 ..< self.editorElements.count {
                self.editorElements[n].choosenUpdate()
            }
            self.addMsg(msg: NSLocalizedString("Bullet variable not declared", comment: ""))
        }
    }
    
    func makeValueDecisionView(type: Int) {
        //設定画面のインスタンス化
        self.valueDecisionViewController = (self.storyboard?.instantiateViewController(withIdentifier: "ValueDecisionViewController") as! ValueDecisionViewController)
        valueDecisionViewController!.type = type
        valueDecisionViewController!.variableBool   = self.variableBool
        valueDecisionViewController!.variableInt    = self.variableInt
        valueDecisionViewController!.variableFloat  = self.variableFloat
        valueDecisionViewController!.variableTank   = self.variableTank
        valueDecisionViewController!.variableBullet = self.variableBullet
        valueDecisionViewController!.listBool   = self.listBool
        valueDecisionViewController!.listInt    = self.listInt
        valueDecisionViewController!.listFloat  = self.listFloat
        valueDecisionViewController!.listTank   = self.listTank
        valueDecisionViewController!.listBullet = self.listBullet
        
        for editorElement in editorElements {
            if editorElement.choosen {
                for label in editorElement.labels {
                    valueDecisionViewController!.addCalcElement(text: label)
                }
            }
        }
        
        //画面を表示
        self.present(valueDecisionViewController!, animated: true, completion: nil)
    }
    
    @objc func showPathEditor() {
        self.pathViewController = (self.storyboard?.instantiateViewController(withIdentifier: "PathViewController") as! PathViewController)
        
        self.pathViewController.fieldSize = self.fieldSize
        self.pathViewController.wallsVertical = self.wallsVertical
        self.pathViewController.wallsHorizontal = self.wallsHorizontal
        self.pathViewController.enemy = self.enemy
        
        self.present(pathViewController!, animated: true, completion: nil)
    }
    
    @objc func deletePathEditor() {
        for editorElement in editorElements {
            if editorElement.choosen {
                if self.pathViewController.msg == "" {
                    self.pathViewController.msg = NSLocalizedString("Not entered yet", comment: "")
                }
                editorElement.body.setTitle(" " + NSLocalizedString("Path", comment: "") + " : " + self.pathViewController.msg + "  ", for: UIControl.State.normal)
                editorElement.text = self.pathViewController.msg
                editorElement.values = self.pathViewController.cmd
                editorElement.valueChanged()
                editorElement.typeChooseFlag = true
            }
        }
        self.pathViewController = nil
    }
    
    @objc func addViewForBoolVariable()   { self.makeValueDecisionView(type: 0) }
    @objc func addViewForIntVariable()    { self.makeValueDecisionView(type: 1) }
    @objc func addViewForFloatVariable()  { self.makeValueDecisionView(type: 2) }
    @objc func addViewForTankVariable()   { self.makeValueDecisionView(type: 3) }
    @objc func addViewForBulletVariable() { self.makeValueDecisionView(type: 4) }
    
    @objc func variableForRepetition() {
        for editorElement in editorElements {
            if editorElement.choosen {
                self.state = editorElement.elementType
            }
        }
        nameBox.placeholder = NSLocalizedString("Variable name", comment: "")
        self.view.addSubview(self.nameInputLabel)
        self.view.addSubview(self.nameBox)
        self.view.addSubview(self.goButton)
        self.view.addSubview(self.noButton)
        self.nameBox.becomeFirstResponder() //デフォルトでキーボード表示
    }
    
    @objc func listForRepetition() { 
        for element in editorElements {
            if element.choosen {
                if element.elementType == 0 {
                    if self.listBool.count != 0 {
                        self.dataList = self.listBool
                        self.state = 11
                        self.pickerView.reloadAllComponents()
                        self.cancelButton.isHidden = false
                        self.decideButton.isHidden = false
                        self.pickerView.isHidden = false
                    }
                    else {
                        for n in 0 ..< self.editorElements.count {
                            self.editorElements[n].choosenUpdate()
                        }
                        self.addMsg(msg: NSLocalizedString("Bool list not declared", comment: ""))
                    }
                }
                else if element.elementType == 1 {
                    if self.listInt.count != 0 {
                        self.dataList = self.listInt
                        self.state = 11
                        self.pickerView.reloadAllComponents()
                        self.cancelButton.isHidden = false
                        self.decideButton.isHidden = false
                        self.pickerView.isHidden = false
                    }
                    else {
                        for n in 0 ..< self.editorElements.count {
                            self.editorElements[n].choosenUpdate()
                        }
                        self.addMsg(msg: NSLocalizedString("Int list not declared", comment: ""))
                    }
                }
                else if element.elementType == 2 {
                    if self.listFloat.count != 0 {
                        self.dataList = self.listFloat
                        self.state = 11
                        self.pickerView.reloadAllComponents()
                        self.cancelButton.isHidden = false
                        self.decideButton.isHidden = false
                        self.pickerView.isHidden = false
                    }
                    else {
                        for n in 0 ..< self.editorElements.count {
                            self.editorElements[n].choosenUpdate()
                        }
                        self.addMsg(msg: NSLocalizedString("Float list not declared", comment: ""))
                    }
                }
                else if element.elementType == 3 {
                    if self.listTank.count != 0 {
                        self.dataList = self.listTank
                        self.state = 11
                        self.pickerView.reloadAllComponents()
                        self.cancelButton.isHidden = false
                        self.decideButton.isHidden = false
                        self.pickerView.isHidden = false
                    }
                    else {
                        for n in 0 ..< self.editorElements.count {
                            self.editorElements[n].choosenUpdate()
                        }
                        self.addMsg(msg: NSLocalizedString("Tank list not declared", comment: ""))
                    }
                }
                else if element.elementType == 4 {
                    if self.listBullet.count != 0 {
                        self.dataList = self.listBullet
                        self.state = 11
                        self.pickerView.reloadAllComponents()
                        self.cancelButton.isHidden = false
                        self.decideButton.isHidden = false
                        self.pickerView.isHidden = false
                    }
                    else {
                        for n in 0 ..< self.editorElements.count {
                            self.editorElements[n].choosenUpdate()
                        }
                        self.addMsg(msg: NSLocalizedString("Bullet list not declared", comment: ""))
                    }
                }
            }
        }
    }
    
    @objc func deleteElement() {
        self.cancelButton.isHidden = true
        self.decideButton.isHidden = true
        self.pickerView.isHidden = true
    }
    
    @objc func saveValue() {
        let elem = self.valueDecisionViewController?.getCommand()
        
        for editorElement in editorElements {
            if editorElement.choosen {
                editorElement.values = elem!.commands
                editorElement.text = elem!.text
                editorElement.labels = elem!.labels
                editorElement.valueChanged()
            }
        }
        
        self.valueDecisionViewController?.dismiss(animated: true, completion: nil)
        self.valueDecisionViewController = nil
    }
    
    @IBAction func goBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        guard let name = self.nameBox.text else {return}
        if name != "" {
            //新たな変数, リストが定義されていた場合一覧に追加
            var nameLists: [String] = []
            
            if self.state == 0      { nameLists = self.variableBool   }
            else if self.state == 1 { nameLists = self.variableInt    }
            else if self.state == 2 { nameLists = self.variableFloat  }
            else if self.state == 3 { nameLists = self.variableTank   }
            else if self.state == 4 { nameLists = self.variableBullet }
            else if self.state == 5 { nameLists = self.listBool       }
            else if self.state == 6 { nameLists = self.listInt        }
            else if self.state == 7 { nameLists = self.listFloat      }
            else if self.state == 8 { nameLists = self.listTank       }
            else if self.state == 9 { nameLists = self.listBullet     }
            
            var flag = true
            for nameList in nameLists {
                if nameList == name {
                    flag = false
                }
            }
            if flag {
                if self.state == 0      { self.variableBool.append(name)   }
                else if self.state == 1 { self.variableInt.append(name)    }
                else if self.state == 2 { self.variableFloat.append(name)  }
                else if self.state == 3 { self.variableTank.append(name)   }
                else if self.state == 4 { self.variableBullet.append(name) }
                else if self.state == 5 { self.listBool.append(name)       }
                else if self.state == 6 { self.listInt.append(name)        }
                else if self.state == 7 { self.listFloat.append(name)      }
                else if self.state == 8 { self.listTank.append(name)       }
                else if self.state == 9 { self.listBullet.append(name)     }
            }
            
            for editorElement in editorElements {
                if editorElement.choosen {
                    if self.state == 0 || self.state == 1 || self.state == 2 || self.state == 3 || self.state == 4 {
                        editorElement.variableLabel.name = name
                        editorElement.conditionalLabel.variable = name
                        editorElement.valueChanged()
                    }
                    else if self.state == 5 || self.state == 6 || self.state == 7 || self.state == 8 || self.state == 9 {
                        editorElement.listLabel.name = name
                    }
                    else if self.state == 12 {
                        editorElement.printLabel.value = name
                    }
                }
                editorElement.choosenUpdate()
            }
        }
        
        self.nameInputLabel.removeFromSuperview()
        self.nameBox.removeFromSuperview()
        self.goButton.removeFromSuperview()
        self.noButton.removeFromSuperview()
        self.nameBox.text = ""
        self.nameBox.endEditing(true)
    }
    
    @IBAction func noBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.nameInputLabel.removeFromSuperview()
        self.nameBox.removeFromSuperview()
        self.goButton.removeFromSuperview()
        self.noButton.removeFromSuperview()
        self.nameBox.text = ""
        self.nameBox.endEditing(true)
    }
    
    @IBAction func helpBtnAction(_ sender: Any) {
        let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
        self.present(helpViewController, animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.nowName = dataList[row]
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.nowName = dataList[row]
    }
    
    func encodeCommands() {
        var indents: [String] = []
        var states: [String] = []
        var elementTypes: [String] = []
        var typeChooseFlags: [String] = []
        var pushedAtFirsts: [String] = []
        var variableLabel_types: [String] = []
        var variableLabel_names: [String] = []
        var variableLabel_values: [String] = []
        var listLabel_types: [String] = []
        var listLabel_names: [String] = []
        var listLabel_operations: [String] = []
        var listLabel_states: [String] = []
        var conditionalLabel_types: [String] = []
        var conditionalLabel_consitions: [String] = []
        var conditionalLabel_variables: [String] = []
        var conditionalLabel_listTypes: [String] = []
        var conditionalLabel_lists: [String] = []
        var conditionalLabel_states: [String] = []
        var printLabel_types: [String] = []
        var printLabel_values: [String] = []
        var valuess: [String] = []
        var texts: [String] = []
        var labelss: [String] = []
        for editorElement in editorElements {
            indents.append(String(editorElement.indent))
            states.append(String(editorElement.state))
            elementTypes.append(String(editorElement.elementType))
            if editorElement.typeChooseFlag { typeChooseFlags.append("t") }
            else { typeChooseFlags.append("f") }
            if editorElement.pushedAtFirst { pushedAtFirsts.append("t") }
            else { pushedAtFirsts.append("f") }
            variableLabel_types.append(editorElement.variableLabel.type)
            variableLabel_names.append(editorElement.variableLabel.name)
            variableLabel_values.append(editorElement.variableLabel.value)
            listLabel_types.append(editorElement.listLabel.type)
            listLabel_names.append(editorElement.listLabel.name)
            listLabel_operations.append(editorElement.listLabel.operation)
            listLabel_states.append(String(editorElement.listLabel.state))
            conditionalLabel_types.append(editorElement.conditionalLabel.type)
            conditionalLabel_consitions.append(editorElement.conditionalLabel.condition)
            conditionalLabel_variables.append(editorElement.conditionalLabel.variable)
            conditionalLabel_listTypes.append(editorElement.conditionalLabel.listType)
            conditionalLabel_lists.append(editorElement.conditionalLabel.list)
            conditionalLabel_states.append(String(editorElement.conditionalLabel.state))
            printLabel_types.append(editorElement.printLabel.type)
            printLabel_values.append(editorElement.printLabel.value)
            valuess.append(editorElement.values)
            texts.append(editorElement.text)
            var labels: String = ""
            for l in editorElement.labels {
                labels.append(l + "#")
            }
            if labels != "" {
                labels.removeLast()
            }
            labelss.append(labels)
        }
        
        userDefaults.set(indents, forKey: "indents" + "ForStage" + String(self.battleIndex))
        userDefaults.set(states, forKey: "states" + "ForStage" + String(self.battleIndex))
        userDefaults.set(elementTypes, forKey: "elementTypes" + "ForStage" + String(self.battleIndex))
        userDefaults.set(typeChooseFlags, forKey: "typeChooseFlags" + "ForStage" + String(self.battleIndex))
        userDefaults.set(pushedAtFirsts, forKey: "pushedAtFirsts" + "ForStage" + String(self.battleIndex))
        userDefaults.set(variableLabel_types, forKey: "variableLabel_types" + "ForStage" + String(self.battleIndex))
        userDefaults.set(variableLabel_names, forKey: "variableLabel_names" + "ForStage" + String(self.battleIndex))
        userDefaults.set(variableLabel_values, forKey: "variableLabel_values" + "ForStage" + String(self.battleIndex))
        userDefaults.set(listLabel_types, forKey: "listLabel_types" + "ForStage" + String(self.battleIndex))
        userDefaults.set(listLabel_names, forKey: "listLabel_names" + "ForStage" + String(self.battleIndex))
        userDefaults.set(listLabel_operations, forKey: "listLabel_operations" + "ForStage" + String(self.battleIndex))
        userDefaults.set(listLabel_states, forKey: "listLabel_states" + "ForStage" + String(self.battleIndex))
        userDefaults.set(conditionalLabel_types, forKey: "conditionalLabel_types" + "ForStage" + String(self.battleIndex))
        userDefaults.set(conditionalLabel_consitions, forKey: "conditionalLabel_consitions" + "ForStage" + String(self.battleIndex))
        userDefaults.set(conditionalLabel_variables, forKey: "conditionalLabel_variables" + "ForStage" + String(self.battleIndex))
        userDefaults.set(conditionalLabel_listTypes, forKey: "conditionalLabel_listTypes" + "ForStage" + String(self.battleIndex))
        userDefaults.set(conditionalLabel_lists, forKey: "conditionalLabel_lists" + "ForStage" + String(self.battleIndex))
        userDefaults.set(conditionalLabel_states, forKey: "conditionalLabel_states" + "ForStage" + String(self.battleIndex))
        userDefaults.set(printLabel_types, forKey: "printLabel_types" + "ForStage" + String(self.battleIndex))
        userDefaults.set(printLabel_values, forKey: "printLabel_values" + "ForStage" + String(self.battleIndex))
        userDefaults.set(valuess, forKey: "valuess" + "ForStage" + String(self.battleIndex))
        userDefaults.set(texts, forKey: "texts" + "ForStage" + String(self.battleIndex))
        userDefaults.set(labelss, forKey: "labelss" + "ForStage" + String(self.battleIndex))
    }
    
    func decodeCommands() {
        let indents = userDefaults.stringArray(forKey: "indents" + "ForStage" + String(self.battleIndex)) ?? []
        let states = userDefaults.stringArray(forKey: "states" + "ForStage" + String(self.battleIndex)) ?? []
        let elementTypes = userDefaults.stringArray(forKey: "elementTypes" + "ForStage" + String(self.battleIndex)) ?? []
        let typeChooseFlags = userDefaults.stringArray(forKey: "typeChooseFlags" + "ForStage" + String(self.battleIndex)) ?? []
        let pushedAtFirsts = userDefaults.stringArray(forKey: "pushedAtFirsts" + "ForStage" + String(self.battleIndex)) ?? []
        let variableLabel_types = userDefaults.stringArray(forKey: "variableLabel_types" + "ForStage" + String(self.battleIndex)) ?? []
        let variableLabel_names = userDefaults.stringArray(forKey: "variableLabel_names" + "ForStage" + String(self.battleIndex)) ?? []
        let variableLabel_values = userDefaults.stringArray(forKey: "variableLabel_values" + "ForStage" + String(self.battleIndex)) ?? []
        let listLabel_types = userDefaults.stringArray(forKey: "listLabel_types" + "ForStage" + String(self.battleIndex)) ?? []
        let listLabel_names = userDefaults.stringArray(forKey: "listLabel_names" + "ForStage" + String(self.battleIndex)) ?? []
        let listLabel_operations = userDefaults.stringArray(forKey: "listLabel_operations" + "ForStage" + String(self.battleIndex)) ?? []
        let listLabel_states = userDefaults.stringArray(forKey: "listLabel_states" + "ForStage" + String(self.battleIndex)) ?? []
        let conditionalLabel_types = userDefaults.stringArray(forKey: "conditionalLabel_types" + "ForStage" + String(self.battleIndex)) ?? []
        let conditionalLabel_consitions = userDefaults.stringArray(forKey: "conditionalLabel_consitions" + "ForStage" + String(self.battleIndex)) ?? []
        let conditionalLabel_variables = userDefaults.stringArray(forKey: "conditionalLabel_variables" + "ForStage" + String(self.battleIndex)) ?? []
        let conditionalLabel_listTypes = userDefaults.stringArray(forKey: "conditionalLabel_listTypes" + "ForStage" + String(self.battleIndex)) ?? []
        let conditionalLabel_lists = userDefaults.stringArray(forKey: "conditionalLabel_lists" + "ForStage" + String(self.battleIndex)) ?? []
        let conditionalLabel_states = userDefaults.stringArray(forKey: "conditionalLabel_states" + "ForStage" + String(self.battleIndex)) ?? []
        let printLabel_types = userDefaults.stringArray(forKey: "printLabel_types" + "ForStage" + String(self.battleIndex)) ?? []
        let printLabel_values = userDefaults.stringArray(forKey: "printLabel_values" + "ForStage" + String(self.battleIndex)) ?? []
        let valuess = userDefaults.stringArray(forKey: "valuess" + "ForStage" + String(self.battleIndex)) ?? []
        let texts = userDefaults.stringArray(forKey: "texts" + "ForStage" + String(self.battleIndex)) ?? []
        let labelss = userDefaults.stringArray(forKey: "labelss" + "ForStage" + String(self.battleIndex)) ?? []
        
        if indents.count == 0 {
            self.editorElements.append(EditorElement(view: self.scrollView, editView: self.editView, screenWidth: self.scrollView.frame.width, screenHeight: self.scrollView.frame.height, index: self.editorElements.count, indent: 0, addAboveFunc: self.addAboveFunc, addBelowFunc: self.addBelowFunc, deleteFunc: self.deleteFunc, choosenChange: self.choosenChange))
        }
        
        for i in 0 ..< indents.count {
            let e = EditorElement(view: self.scrollView, editView: self.editView, screenWidth: self.scrollView.frame.width, screenHeight: self.scrollView.frame.height, index: self.editorElements.count, indent: Int(indents[i])!, addAboveFunc: self.addAboveFunc, addBelowFunc: self.addBelowFunc, deleteFunc: self.deleteFunc, choosenChange: self.choosenChange)
            e.state = Int(states[i])!
            e.elementType = Int(elementTypes[i])!
            e.typeChooseFlag = (typeChooseFlags[i] == "t")
            e.pushedAtFirst = (pushedAtFirsts[i] == "t")
            e.variableLabel.type = variableLabel_types[i]
            e.variableLabel.name = variableLabel_names[i]
            e.variableLabel.value = variableLabel_values[i]
            e.listLabel.type = listLabel_types[i]
            e.listLabel.name = listLabel_names[i]
            e.listLabel.operation = listLabel_operations[i]
            e.listLabel.state = Int(listLabel_states[i])!
            e.conditionalLabel.type = conditionalLabel_types[i]
            e.conditionalLabel.condition = conditionalLabel_consitions[i]
            e.conditionalLabel.variable = conditionalLabel_variables[i]
            e.conditionalLabel.listType = conditionalLabel_listTypes[i]
            e.conditionalLabel.list = conditionalLabel_lists[i]
            e.conditionalLabel.state = Int(conditionalLabel_states[i])!
            e.printLabel.type = printLabel_types[i]
            e.printLabel.value = printLabel_values[i]
            e.values = valuess[i]
            e.text = texts[i]
            e.labels = labelss[i].components(separatedBy: "#")
            
            if e.state == 4 {
                if e.text == "" {
                    e.text = NSLocalizedString("Not entered yet", comment: "")
                }
                e.body.setTitle(" " + NSLocalizedString("Path", comment: "") + " : " + e.text + "  ", for: UIControl.State.normal)
            }
            
            e.isRestored = true
            e.choosen = true
            e.choosenUpdate()
            e.valueChanged()
            
            editorElements.append(e)
        }
        self.choosenChange(index: -1)
        
        if editorElements.count == 1 && editorElements[0].body.title(for:  UIControl.State.normal) == NSLocalizedString(" Choose process", comment: "") {
            editorElements[0].deleteSelf()
            editorElements = []
            editorElements.append(EditorElement(view: self.scrollView, editView: self.editView, screenWidth: self.scrollView.frame.width, screenHeight: self.scrollView.frame.height, index: self.editorElements.count, indent: 0, addAboveFunc: self.addAboveFunc, addBelowFunc: self.addBelowFunc, deleteFunc: self.deleteFunc, choosenChange: self.choosenChange))
            editorElements[0].choosen = true
            editorElements[0].choosenUpdate()
        }
        self.checkVariable()
        self.checkList()
    }
}
