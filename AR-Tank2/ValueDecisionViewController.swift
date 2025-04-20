//
//  ValueDecisionViewController.swift
//  AR-Tank
//
//  Created by 田代純也 on 2024/01/01.
//

import Foundation
import SceneKit

class ValueDecisionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    var screenWidth: CGFloat = 0.0      //スクリーン幅
    var screenHeight: CGFloat = 0.0     //スクリーン高さ
    
    let scrollView = UIScrollView()
    
    var type: Int = 0
    
    weak var timer: Timer?
    
    let backButton = UIButton()         //戻るボタン
    let saveButton = UIButton()         //保存ボタン
    
    var calcElements: [UILabel] = []
    let chooseBar = UILabel(frame: CGRectMake(3.5, 0, 10, 50))
    var chooseBarIndex: Int = 0
    
    var variableBool:   [String] = []
    var variableInt:    [String] = []
    var variableFloat:  [String] = []
    var variableTank:   [String] = []
    var variableBullet: [String] = []
    var listBool:       [String] = []
    var listInt:        [String] = []
    var listFloat:      [String] = []
    var listTank:       [String] = []
    var listBullet:     [String] = []
    
    var dataList: [String] = []
    var nowName: String = ""
    
    var leftValue: [String] = []
    var RightValue: [String] = []
    var compareOperator: [String] = ["==", "!=", "<", "<=", ">=", ">"]
    var nowLeft: String = ""
    var nowRight: String = ""
    var nowOperator: String = ""
    
    var pickMode: Int = 0
    let pickerView = UIPickerView()
    let pickerForEval = UIPickerView()
    let clearButton = UIButton()
    let backGround = UILabel()
    let goButton = UIButton(frame: CGRectMake(0, 0, 70, 40))
    let noButton = UIButton(frame: CGRectMake(0, 0, 70, 40))
    
    let xButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
    let yButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
    let thetaButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
    var choosen: Int = 0
    
    let numLabel = UILabel(frame: CGRectMake(0, 0, 40, 40))
    let pButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
    let mButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
    
    let blue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.updateFunc()
        })
        
        self.view.backgroundColor = UIColor.black
        
        //フレームサイズの格納
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
        
        self.addButton(type: self.type)
        
        clearButton.frame = self.view.frame
        clearButton.addTarget(self, action: #selector(self.noBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        backGround.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 50, height: self.screenHeight / 2)
        backGround.center.x = self.screenWidth / 2
        backGround.center.y = self.screenHeight / 2
        self.backGround.layer.cornerRadius = 10
        backGround.clipsToBounds = true
        backGround.backgroundColor = UIColor.white
        backGround.layer.cornerRadius = 10

        goButton.center = CGPoint(x: screenWidth / 2 + 80, y: screenHeight / 4 + 50)
        goButton.backgroundColor = self.blue
        goButton.layer.cornerRadius = 20
        goButton.setTitle(NSLocalizedString("OK", comment: ""), for: UIControl.State.normal)
        goButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        goButton.addTarget(self, action: #selector(self.goBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        noButton.center = CGPoint(x: screenWidth / 2 - 80, y: screenHeight / 4 + 50)
        noButton.backgroundColor = UIColor.lightGray
        noButton.layer.cornerRadius = 20
        noButton.setTitle(NSLocalizedString("Back", comment: ""), for: UIControl.State.normal)
        noButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        noButton.addTarget(self, action: #selector(self.noBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        xButton.center = CGPoint(x: screenWidth / 2 - 60, y: screenHeight / 4 + 120)
        xButton.backgroundColor = UIColor.lightGray
        xButton.layer.cornerRadius = xButton.frame.width / 2
        xButton.layer.borderColor = UIColor.blue.cgColor
        xButton.setTitle("x", for: UIControl.State.normal)
        xButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        xButton.addTarget(self, action: #selector(self.xBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        yButton.center = CGPoint(x: screenWidth / 2, y: screenHeight / 4 + 120)
        yButton.backgroundColor = UIColor.lightGray
        yButton.layer.cornerRadius = thetaButton.frame.width / 2
        yButton.layer.borderColor = UIColor.blue.cgColor
        yButton.setTitle("y", for: UIControl.State.normal)
        yButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        yButton.addTarget(self, action: #selector(self.yBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        thetaButton.center = CGPoint(x: screenWidth / 2 + 60, y: screenHeight / 4 + 120)
        thetaButton.backgroundColor = UIColor.lightGray
        thetaButton.layer.cornerRadius = thetaButton.frame.width / 2
        thetaButton.layer.borderColor = UIColor.blue.cgColor
        thetaButton.setTitle("θ", for: UIControl.State.normal)
        thetaButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        thetaButton.addTarget(self, action: #selector(self.thetaBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        numLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight / 4 + 120)
        numLabel.backgroundColor = UIColor.lightGray
        numLabel.layer.cornerRadius = xButton.frame.width / 2
        numLabel.clipsToBounds = true
        numLabel.textAlignment = .center
        numLabel.textColor = UIColor.black
        numLabel.text = "0"
        
        pButton.center = CGPoint(x: screenWidth / 2 + 60, y: screenHeight / 4 + 120)
        pButton.backgroundColor = UIColor.lightGray
        pButton.layer.cornerRadius = xButton.frame.width / 2
        pButton.layer.borderColor = UIColor.blue.cgColor
        pButton.setTitle("+", for: UIControl.State.normal)
        pButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        pButton.addTarget(self, action: #selector(self.pBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        mButton.center = CGPoint(x: screenWidth / 2 - 60, y: screenHeight / 4 + 120)
        mButton.backgroundColor = UIColor.lightGray
        mButton.layer.cornerRadius = xButton.frame.width / 2
        mButton.layer.borderColor = UIColor.blue.cgColor
        mButton.setTitle("-", for: UIControl.State.normal)
        mButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        mButton.addTarget(self, action: #selector(self.mBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        //pickerビュー
        pickerView.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 50, height: self.screenHeight / 2 - 100)
        pickerView.center.x = self.screenWidth / 2
        pickerView.center.y = self.screenHeight / 2 + 100
        pickerView.backgroundColor = UIColor.clear
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerForEval.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 50, height: self.screenHeight / 2 - 100)
        pickerForEval.center.x = self.screenWidth / 2
        pickerForEval.center.y = self.screenHeight / 2 + 100
        pickerForEval.backgroundColor = UIColor.clear
        pickerForEval.delegate = self
        pickerForEval.dataSource = self
        
        //スクロールビュー
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 50, height: 50)
        self.scrollView.center.x = self.screenWidth / 2
        self.scrollView.center.y = self.screenHeight / 8 + 25
        self.scrollView.layer.cornerRadius = 5
        self.scrollView.layer.borderWidth = 1
        self.scrollView.layer.borderColor = UIColor.black.cgColor
        self.scrollView.backgroundColor = UIColor.darkGray
        self.scrollView.contentSize = CGSize(width: self.screenWidth, height: 50)
        view.addSubview(scrollView)
        
        if self.type == 0 || self.type == 1 || self.type == 2 {
            self.chooseBar.text = "|"
            self.chooseBar.textColor = UIColor.white
            self.scrollView.addSubview(self.chooseBar)
        }
        
        //戻るボタン
        backButton.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        backButton.center = CGPoint(x: screenWidth / 2 - 80, y: 50)
        backButton.layer.cornerRadius = 20
        backButton.backgroundColor = UIColor.lightGray
        backButton.setTitle(NSLocalizedString("No reflection", comment: ""), for: UIControl.State.normal)
        backButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(self.backBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(backButton)
        
        //保存して戻るボタン
        saveButton.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        saveButton.center = CGPoint(x: screenWidth / 2 + 80, y: 50)
        saveButton.layer.cornerRadius = 20
        saveButton.backgroundColor = self.blue
        saveButton.setTitle(NSLocalizedString("Reflection", comment: ""), for: UIControl.State.normal)
        saveButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        saveButton.addTarget(self, action: #selector(self.saveBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(saveButton)
    }
    
    func addButton(type: Int) {
        if type == 0 {
            //true
            let trueBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            trueBtn.center.x = screenWidth / 2 - 65
            trueBtn.center.y = screenHeight / 4
            trueBtn.backgroundColor = UIColor.darkGray
            trueBtn.layer.cornerRadius = 20
            trueBtn.setTitle("True", for: UIControl.State.normal)
            trueBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            trueBtn.addTarget(self, action: #selector(self.trueBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(trueBtn)
            
            //false
            let falseBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            falseBtn.center.x = screenWidth / 2 - 65
            falseBtn.center.y = screenHeight / 4 + 60
            falseBtn.backgroundColor = UIColor.darkGray
            falseBtn.layer.cornerRadius = 20
            falseBtn.setTitle("False", for: UIControl.State.normal)
            falseBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            falseBtn.addTarget(self, action: #selector(self.falseBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(falseBtn)
            //and
            let andBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            andBtn.center.x = screenWidth / 2 - 65
            andBtn.center.y = screenHeight / 4 + 120
            andBtn.backgroundColor = UIColor.darkGray
            andBtn.layer.cornerRadius = 20
            andBtn.setTitle("and", for: UIControl.State.normal)
            andBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            andBtn.addTarget(self, action: #selector(self.andBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(andBtn)
            //or
            let orBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            orBtn.center.x = screenWidth / 2 - 65
            orBtn.center.y = screenHeight / 4 + 180
            orBtn.backgroundColor = UIColor.darkGray
            orBtn.layer.cornerRadius = 20
            orBtn.setTitle("or", for: UIControl.State.normal)
            orBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            orBtn.addTarget(self, action: #selector(self.orBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(orBtn)
            //not
            let notBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            notBtn.center.x = screenWidth / 2 - 65
            notBtn.center.y = screenHeight / 4 + 240
            notBtn.backgroundColor = UIColor.darkGray
            notBtn.layer.cornerRadius = 20
            notBtn.setTitle("not ( )", for: UIControl.State.normal)
            notBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            notBtn.addTarget(self, action: #selector(self.notBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(notBtn)
            //()
            let parenthnessBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            parenthnessBtn.center.x = screenWidth / 2 - 65
            parenthnessBtn.center.y = screenHeight / 4 + 300
            parenthnessBtn.backgroundColor = UIColor.darkGray
            parenthnessBtn.layer.cornerRadius = 20
            parenthnessBtn.setTitle("( )", for: UIControl.State.normal)
            parenthnessBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            parenthnessBtn.addTarget(self, action: #selector(self.parenthnessBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(parenthnessBtn)
            //宣言済み変数
            let declaredBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            declaredBtn.center.x = screenWidth / 2 + 65
            declaredBtn.center.y = screenHeight / 4
            declaredBtn.backgroundColor = UIColor.darkGray
            declaredBtn.layer.cornerRadius = 20
            declaredBtn.setTitle(NSLocalizedString("Defined", comment: ""), for: UIControl.State.normal)
            declaredBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            declaredBtn.addTarget(self, action: #selector(self.declaredBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(declaredBtn)
            //リスト参照
            let fromListBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            fromListBtn.center.x = screenWidth / 2 + 65
            fromListBtn.center.y = screenHeight / 4 + 60
            fromListBtn.backgroundColor = UIColor.darkGray
            fromListBtn.layer.cornerRadius = 20
            fromListBtn.setTitle(NSLocalizedString("List element", comment: ""), for: UIControl.State.normal)
            fromListBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            fromListBtn.addTarget(self, action: #selector(self.fromListBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(fromListBtn)
            //Int評価
            let evalIntBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            evalIntBtn.center.x = screenWidth / 2 + 65
            evalIntBtn.center.y = screenHeight / 4 + 120
            evalIntBtn.backgroundColor = UIColor.darkGray
            evalIntBtn.layer.cornerRadius = 20
            evalIntBtn.setTitle(NSLocalizedString("Eval Int", comment: ""), for: UIControl.State.normal)
            evalIntBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            evalIntBtn.addTarget(self, action: #selector(self.evalIntBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(evalIntBtn)
            //Float評価
            let evalFloatBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            evalFloatBtn.center.x = screenWidth / 2 + 65
            evalFloatBtn.center.y = screenHeight / 4 + 180
            evalFloatBtn.backgroundColor = UIColor.darkGray
            evalFloatBtn.layer.cornerRadius = 20
            evalFloatBtn.setTitle("Eval Float", for: UIControl.State.normal)
            evalFloatBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            evalFloatBtn.addTarget(self, action: #selector(self.evalFloatBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(evalFloatBtn)
            
            //delete
            let deleteButton = UIButton(frame: CGRectMake(0, 0, 120, 50))
            deleteButton.center.x = screenWidth / 2 + 65
            deleteButton.center.y = screenHeight / 4 + 360
            deleteButton.backgroundColor = UIColor.lightGray
            deleteButton.layer.cornerRadius = 20
            deleteButton.setTitle("delete", for: UIControl.State.normal)
            deleteButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            deleteButton.addTarget(self, action: #selector(self.deleteBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(deleteButton)
            
            //to left
            let toLeftButton = UIButton(frame: CGRectMake(0, 0, 55, 50))
            toLeftButton.center.x = screenWidth / 2 - 97.5
            toLeftButton.center.y = screenHeight / 4 + 360
            toLeftButton.backgroundColor = UIColor.lightGray
            toLeftButton.layer.cornerRadius = 20
            toLeftButton.setTitle("<", for: UIControl.State.normal)
            toLeftButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            toLeftButton.addTarget(self, action: #selector(self.toLeftBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(toLeftButton)
            
            //to right
            let toRightButton = UIButton(frame: CGRectMake(0, 0, 55, 50))
            toRightButton.center.x = screenWidth / 2 - 32.5
            toRightButton.center.y = screenHeight / 4 + 360
            toRightButton.backgroundColor = UIColor.lightGray
            toRightButton.layer.cornerRadius = 20
            toRightButton.setTitle(">", for: UIControl.State.normal)
            toRightButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            toRightButton.addTarget(self, action: #selector(self.toRightBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(toRightButton)
        }
        
        else if type == 1 {
            //宣言済み変数
            let declaredBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            declaredBtn.center.x = screenWidth / 2 - 65
            declaredBtn.center.y = screenHeight / 4
            declaredBtn.backgroundColor = UIColor.darkGray
            declaredBtn.layer.cornerRadius = 20
            declaredBtn.setTitle(NSLocalizedString("Defined", comment: ""), for: UIControl.State.normal)
            declaredBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            declaredBtn.addTarget(self, action: #selector(self.declaredBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(declaredBtn)
            //リスト参照
            let fromListBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            fromListBtn.center.x = screenWidth / 2 + 65
            fromListBtn.center.y = screenHeight / 4
            fromListBtn.backgroundColor = UIColor.darkGray
            fromListBtn.layer.cornerRadius = 20
            fromListBtn.setTitle(NSLocalizedString("List element", comment: ""), for: UIControl.State.normal)
            fromListBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            fromListBtn.addTarget(self, action: #selector(self.fromListBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(fromListBtn)
            //リスト長さ
            let lengthListBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            lengthListBtn.center.x = screenWidth / 2 - 65
            lengthListBtn.center.y = screenHeight / 4 + 60
            lengthListBtn.backgroundColor = UIColor.darkGray
            lengthListBtn.layer.cornerRadius = 20
            lengthListBtn.setTitle(NSLocalizedString("List length", comment: ""), for: UIControl.State.normal)
            lengthListBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            lengthListBtn.addTarget(self, action: #selector(self.lengthListBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(lengthListBtn)
            //+
            let plusBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            plusBtn.center.x = screenWidth / 2 + 97.5
            plusBtn.center.y = screenHeight / 4 + 300
            plusBtn.backgroundColor = self.blue
            plusBtn.layer.cornerRadius = 20
            plusBtn.setTitle("+", for: UIControl.State.normal)
            plusBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            plusBtn.addTarget(self, action: #selector(self.plusBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(plusBtn)
            //-
            let minusBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            minusBtn.center.x = screenWidth / 2 + 97.5
            minusBtn.center.y = screenHeight / 4 + 240
            minusBtn.backgroundColor = self.blue
            minusBtn.layer.cornerRadius = 20
            minusBtn.setTitle("-", for: UIControl.State.normal)
            minusBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            minusBtn.addTarget(self, action: #selector(self.minusBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(minusBtn)
            //*
            let timesBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            timesBtn.center.x = screenWidth / 2 + 97.5
            timesBtn.center.y = screenHeight / 4 + 180
            timesBtn.backgroundColor = self.blue
            timesBtn.layer.cornerRadius = 20
            timesBtn.setTitle("×", for: UIControl.State.normal)
            timesBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            timesBtn.addTarget(self, action: #selector(self.timesBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(timesBtn)
            //÷
            let devideBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            devideBtn.center.x = screenWidth / 2 + 97.5
            devideBtn.center.y = screenHeight / 4 + 120
            devideBtn.backgroundColor = self.blue
            devideBtn.layer.cornerRadius = 20
            devideBtn.setTitle("÷", for: UIControl.State.normal)
            devideBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            devideBtn.addTarget(self, action: #selector(self.devideBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(devideBtn)
            //%
            let remainderBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            remainderBtn.center.x = screenWidth / 2 + 65
            remainderBtn.center.y = screenHeight / 4 + 60
            remainderBtn.backgroundColor = self.blue
            remainderBtn.layer.cornerRadius = 20
            remainderBtn.setTitle(NSLocalizedString("Remainder", comment: ""), for: UIControl.State.normal)
            remainderBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            remainderBtn.addTarget(self, action: #selector(self.remainderBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(remainderBtn)
            //()
            let parenthnessBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            parenthnessBtn.center.x = screenWidth / 2 - 65
            parenthnessBtn.center.y = screenHeight / 4 + 300
            parenthnessBtn.backgroundColor = UIColor.darkGray
            parenthnessBtn.layer.cornerRadius = 20
            parenthnessBtn.setTitle("( )", for: UIControl.State.normal)
            parenthnessBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            parenthnessBtn.addTarget(self, action: #selector(self.parenthnessBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(parenthnessBtn)
            
            //0~9
            let numBtn0 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn0.center.x = screenWidth / 2 + 32.5
            numBtn0.center.y = screenHeight / 4 + 300
            numBtn0.backgroundColor = UIColor.darkGray
            numBtn0.layer.cornerRadius = 20
            numBtn0.setTitle("0", for: UIControl.State.normal)
            numBtn0.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn0.addTarget(self, action: #selector(self.numBtn0(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn0)
            
            let numBtn1 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn1.center.x = screenWidth / 2 - 97.5
            numBtn1.center.y = screenHeight / 4 + 240
            numBtn1.backgroundColor = UIColor.darkGray
            numBtn1.layer.cornerRadius = 20
            numBtn1.setTitle("1", for: UIControl.State.normal)
            numBtn1.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn1.addTarget(self, action: #selector(self.numBtn1(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn1)
            
            let numBtn2 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn2.center.x = screenWidth / 2 - 32.5
            numBtn2.center.y = screenHeight / 4 + 240
            numBtn2.backgroundColor = UIColor.darkGray
            numBtn2.layer.cornerRadius = 20
            numBtn2.setTitle("2", for: UIControl.State.normal)
            numBtn2.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn2.addTarget(self, action: #selector(self.numBtn2(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn2)
            
            let numBtn3 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn3.center.x = screenWidth / 2 + 32.5
            numBtn3.center.y = screenHeight / 4 + 240
            numBtn3.backgroundColor = UIColor.darkGray
            numBtn3.layer.cornerRadius = 20
            numBtn3.setTitle("3", for: UIControl.State.normal)
            numBtn3.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn3.addTarget(self, action: #selector(self.numBtn3(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn3)
            
            let numBtn4 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn4.center.x = screenWidth / 2 - 97.5
            numBtn4.center.y = screenHeight / 4 + 180
            numBtn4.backgroundColor = UIColor.darkGray
            numBtn4.layer.cornerRadius = 20
            numBtn4.setTitle("4", for: UIControl.State.normal)
            numBtn4.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn4.addTarget(self, action: #selector(self.numBtn4(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn4)
            
            let numBtn5 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn5.center.x = screenWidth / 2 - 32.5
            numBtn5.center.y = screenHeight / 4 + 180
            numBtn5.backgroundColor = UIColor.darkGray
            numBtn5.layer.cornerRadius = 20
            numBtn5.setTitle("5", for: UIControl.State.normal)
            numBtn5.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn5.addTarget(self, action: #selector(self.numBtn5(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn5)
            
            let numBtn6 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn6.center.x = screenWidth / 2 + 32.5
            numBtn6.center.y = screenHeight / 4 + 180
            numBtn6.backgroundColor = UIColor.darkGray
            numBtn6.layer.cornerRadius = 20
            numBtn6.setTitle("6", for: UIControl.State.normal)
            numBtn6.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn6.addTarget(self, action: #selector(self.numBtn6(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn6)
            
            let numBtn7 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn7.center.x = screenWidth / 2 - 97.5
            numBtn7.center.y = screenHeight / 4 + 120
            numBtn7.backgroundColor = UIColor.darkGray
            numBtn7.layer.cornerRadius = 20
            numBtn7.setTitle("7", for: UIControl.State.normal)
            numBtn7.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn7.addTarget(self, action: #selector(self.numBtn7(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn7)
            
            let numBtn8 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn8.center.x = screenWidth / 2 - 32.5
            numBtn8.center.y = screenHeight / 4 + 120
            numBtn8.backgroundColor = UIColor.darkGray
            numBtn8.layer.cornerRadius = 20
            numBtn8.setTitle("8", for: UIControl.State.normal)
            numBtn8.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn8.addTarget(self, action: #selector(self.numBtn8(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn8)
            
            let numBtn9 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn9.center.x = screenWidth / 2 + 32.5
            numBtn9.center.y = screenHeight / 4 + 120
            numBtn9.backgroundColor = UIColor.darkGray
            numBtn9.layer.cornerRadius = 20
            numBtn9.setTitle("9", for: UIControl.State.normal)
            numBtn9.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn9.addTarget(self, action: #selector(self.numBtn9(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn9)
            
            //delete
            let deleteButton = UIButton(frame: CGRectMake(0, 0, 120, 50))
            deleteButton.center.x = screenWidth / 2 + 65
            deleteButton.center.y = screenHeight / 4 + 360
            deleteButton.backgroundColor = UIColor.lightGray
            deleteButton.layer.cornerRadius = 20
            deleteButton.setTitle("delete", for: UIControl.State.normal)
            deleteButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            deleteButton.addTarget(self, action: #selector(self.deleteBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(deleteButton)
            
            //to left
            let toLeftButton = UIButton(frame: CGRectMake(0, 0, 55, 50))
            toLeftButton.center.x = screenWidth / 2 - 97.5
            toLeftButton.center.y = screenHeight / 4 + 360
            toLeftButton.backgroundColor = UIColor.lightGray
            toLeftButton.layer.cornerRadius = 20
            toLeftButton.setTitle("<", for: UIControl.State.normal)
            toLeftButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            toLeftButton.addTarget(self, action: #selector(self.toLeftBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(toLeftButton)
            
            //to right
            let toRightButton = UIButton(frame: CGRectMake(0, 0, 55, 50))
            toRightButton.center.x = screenWidth / 2 - 32.5
            toRightButton.center.y = screenHeight / 4 + 360
            toRightButton.backgroundColor = UIColor.lightGray
            toRightButton.layer.cornerRadius = 20
            toRightButton.setTitle(">", for: UIControl.State.normal)
            toRightButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            toRightButton.addTarget(self, action: #selector(self.toRightBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(toRightButton)
        }
        
        else if type == 2 {
            //宣言済み変数
            let declaredBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            declaredBtn.center.x = screenWidth / 2 - 65
            declaredBtn.center.y = screenHeight / 4
            declaredBtn.backgroundColor = UIColor.darkGray
            declaredBtn.layer.cornerRadius = 20
            declaredBtn.setTitle(NSLocalizedString("Defined", comment: ""), for: UIControl.State.normal)
            declaredBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            declaredBtn.addTarget(self, action: #selector(self.declaredBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(declaredBtn)
            //リスト参照
            let fromListBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            fromListBtn.center.x = screenWidth / 2 + 65
            fromListBtn.center.y = screenHeight / 4
            fromListBtn.backgroundColor = UIColor.darkGray
            fromListBtn.layer.cornerRadius = 20
            fromListBtn.setTitle(NSLocalizedString("List element", comment: ""), for: UIControl.State.normal)
            fromListBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            fromListBtn.addTarget(self, action: #selector(self.fromListBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(fromListBtn)
            //タンク要素
            let fromTankBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            fromTankBtn.center.x = screenWidth / 2 - 65
            fromTankBtn.center.y = screenHeight / 4 + 60
            fromTankBtn.backgroundColor = UIColor.darkGray
            fromTankBtn.layer.cornerRadius = 20
            fromTankBtn.setTitle(NSLocalizedString("Tank var", comment: ""), for: UIControl.State.normal)
            fromTankBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            fromTankBtn.addTarget(self, action: #selector(self.fromTankBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(fromTankBtn)
            //bullet要素
            let fromBulletBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            fromBulletBtn.center.x = screenWidth / 2 + 65
            fromBulletBtn.center.y = screenHeight / 4 + 60
            fromBulletBtn.backgroundColor = UIColor.darkGray
            fromBulletBtn.layer.cornerRadius = 20
            fromBulletBtn.setTitle(NSLocalizedString("Bullet var", comment: ""), for: UIControl.State.normal)
            fromBulletBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            fromBulletBtn.addTarget(self, action: #selector(self.fromBulletBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(fromBulletBtn)
            //+
            let plusBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            plusBtn.center.x = screenWidth / 2 + 97.5
            plusBtn.center.y = screenHeight / 4 + 300
            plusBtn.backgroundColor = self.blue
            plusBtn.layer.cornerRadius = 20
            plusBtn.setTitle("+", for: UIControl.State.normal)
            plusBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            plusBtn.addTarget(self, action: #selector(self.plusBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(plusBtn)
            //-
            let minusBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            minusBtn.center.x = screenWidth / 2 + 97.5
            minusBtn.center.y = screenHeight / 4 + 240
            minusBtn.backgroundColor = self.blue
            minusBtn.layer.cornerRadius = 20
            minusBtn.setTitle("-", for: UIControl.State.normal)
            minusBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            minusBtn.addTarget(self, action: #selector(self.minusBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(minusBtn)
            //*
            let timesBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            timesBtn.center.x = screenWidth / 2 + 97.5
            timesBtn.center.y = screenHeight / 4 + 180
            timesBtn.backgroundColor = self.blue
            timesBtn.layer.cornerRadius = 20
            timesBtn.setTitle("×", for: UIControl.State.normal)
            timesBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            timesBtn.addTarget(self, action: #selector(self.timesBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(timesBtn)
            //÷
            let devideBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            devideBtn.center.x = screenWidth / 2 + 97.5
            devideBtn.center.y = screenHeight / 4 + 120
            devideBtn.backgroundColor = self.blue
            devideBtn.layer.cornerRadius = 20
            devideBtn.setTitle("÷", for: UIControl.State.normal)
            devideBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            devideBtn.addTarget(self, action: #selector(self.devideBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(devideBtn)
            //()
            let parenthnessBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            parenthnessBtn.center.x = screenWidth / 2 - 97.5
            parenthnessBtn.center.y = screenHeight / 4 + 300
            parenthnessBtn.backgroundColor = UIColor.darkGray
            parenthnessBtn.layer.cornerRadius = 20
            parenthnessBtn.setTitle("( )", for: UIControl.State.normal)
            parenthnessBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            parenthnessBtn.addTarget(self, action: #selector(self.parenthnessBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(parenthnessBtn)
            //・
            let dotBtn = UIButton(frame: CGRectMake(0, 0, 55, 50))
            dotBtn.center.x = screenWidth / 2 - 32.5
            dotBtn.center.y = screenHeight / 4 + 300
            dotBtn.backgroundColor = UIColor.darkGray
            dotBtn.layer.cornerRadius = 20
            dotBtn.setTitle(".", for: UIControl.State.normal)
            dotBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            dotBtn.addTarget(self, action: #selector(self.dotBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(dotBtn)
            
            //0~9
            let numBtn0 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn0.center.x = screenWidth / 2 + 32.5
            numBtn0.center.y = screenHeight / 4 + 300
            numBtn0.backgroundColor = UIColor.darkGray
            numBtn0.layer.cornerRadius = 20
            numBtn0.setTitle("0", for: UIControl.State.normal)
            numBtn0.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn0.addTarget(self, action: #selector(self.numBtn0(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn0)
            
            let numBtn1 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn1.center.x = screenWidth / 2 - 97.5
            numBtn1.center.y = screenHeight / 4 + 240
            numBtn1.backgroundColor = UIColor.darkGray
            numBtn1.layer.cornerRadius = 20
            numBtn1.setTitle("1", for: UIControl.State.normal)
            numBtn1.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn1.addTarget(self, action: #selector(self.numBtn1(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn1)
            
            let numBtn2 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn2.center.x = screenWidth / 2 - 32.5
            numBtn2.center.y = screenHeight / 4 + 240
            numBtn2.backgroundColor = UIColor.darkGray
            numBtn2.layer.cornerRadius = 20
            numBtn2.setTitle("2", for: UIControl.State.normal)
            numBtn2.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn2.addTarget(self, action: #selector(self.numBtn2(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn2)
            
            let numBtn3 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn3.center.x = screenWidth / 2 + 32.5
            numBtn3.center.y = screenHeight / 4 + 240
            numBtn3.backgroundColor = UIColor.darkGray
            numBtn3.layer.cornerRadius = 20
            numBtn3.setTitle("3", for: UIControl.State.normal)
            numBtn3.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn3.addTarget(self, action: #selector(self.numBtn3(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn3)
            
            let numBtn4 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn4.center.x = screenWidth / 2 - 97.5
            numBtn4.center.y = screenHeight / 4 + 180
            numBtn4.backgroundColor = UIColor.darkGray
            numBtn4.layer.cornerRadius = 20
            numBtn4.setTitle("4", for: UIControl.State.normal)
            numBtn4.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn4.addTarget(self, action: #selector(self.numBtn4(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn4)
            
            let numBtn5 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn5.center.x = screenWidth / 2 - 32.5
            numBtn5.center.y = screenHeight / 4 + 180
            numBtn5.backgroundColor = UIColor.darkGray
            numBtn5.layer.cornerRadius = 20
            numBtn5.setTitle("5", for: UIControl.State.normal)
            numBtn5.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn5.addTarget(self, action: #selector(self.numBtn5(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn5)
            
            let numBtn6 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn6.center.x = screenWidth / 2 + 32.5
            numBtn6.center.y = screenHeight / 4 + 180
            numBtn6.backgroundColor = UIColor.darkGray
            numBtn6.layer.cornerRadius = 20
            numBtn6.setTitle("6", for: UIControl.State.normal)
            numBtn6.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn6.addTarget(self, action: #selector(self.numBtn6(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn6)
            
            let numBtn7 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn7.center.x = screenWidth / 2 - 97.5
            numBtn7.center.y = screenHeight / 4 + 120
            numBtn7.backgroundColor = UIColor.darkGray
            numBtn7.layer.cornerRadius = 20
            numBtn7.setTitle("7", for: UIControl.State.normal)
            numBtn7.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn7.addTarget(self, action: #selector(self.numBtn7(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn7)
            
            let numBtn8 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn8.center.x = screenWidth / 2 - 32.5
            numBtn8.center.y = screenHeight / 4 + 120
            numBtn8.backgroundColor = UIColor.darkGray
            numBtn8.layer.cornerRadius = 20
            numBtn8.setTitle("8", for: UIControl.State.normal)
            numBtn8.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn8.addTarget(self, action: #selector(self.numBtn8(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn8)
            
            let numBtn9 = UIButton(frame: CGRectMake(0, 0, 55, 50))
            numBtn9.center.x = screenWidth / 2 + 32.5
            numBtn9.center.y = screenHeight / 4 + 120
            numBtn9.backgroundColor = UIColor.darkGray
            numBtn9.layer.cornerRadius = 20
            numBtn9.setTitle("9", for: UIControl.State.normal)
            numBtn9.setTitleColor(UIColor.white, for: UIControl.State.normal)
            numBtn9.addTarget(self, action: #selector(self.numBtn9(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(numBtn9)
            
            //other function
            let otherFuncBtn = UIButton(frame: CGRectMake(0, 0, 250, 50))
            otherFuncBtn.center.x = screenWidth / 2
            otherFuncBtn.center.y = screenHeight / 4 + 360
            otherFuncBtn.backgroundColor = UIColor.lightGray
            otherFuncBtn.layer.cornerRadius = 20
            otherFuncBtn.setTitle(NSLocalizedString("Other funcs", comment: ""), for: UIControl.State.normal)
            otherFuncBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
            otherFuncBtn.addTarget(self, action: #selector(self.otherFuncBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(otherFuncBtn)
            
            //delete
            let deleteButton = UIButton(frame: CGRectMake(0, 0, 120, 50))
            deleteButton.center.x = screenWidth / 2 + 65
            deleteButton.center.y = screenHeight / 4 + 420
            deleteButton.backgroundColor = UIColor.lightGray
            deleteButton.layer.cornerRadius = 20
            deleteButton.setTitle("delete", for: UIControl.State.normal)
            deleteButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            deleteButton.addTarget(self, action: #selector(self.deleteBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(deleteButton)
            
            //to left
            let toLeftButton = UIButton(frame: CGRectMake(0, 0, 55, 50))
            toLeftButton.center.x = screenWidth / 2 - 97.5
            toLeftButton.center.y = screenHeight / 4 + 420
            toLeftButton.backgroundColor = UIColor.lightGray
            toLeftButton.layer.cornerRadius = 20
            toLeftButton.setTitle("<", for: UIControl.State.normal)
            toLeftButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            toLeftButton.addTarget(self, action: #selector(self.toLeftBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(toLeftButton)
            
            //to right
            let toRightButton = UIButton(frame: CGRectMake(0, 0, 55, 50))
            toRightButton.center.x = screenWidth / 2 - 32.5
            toRightButton.center.y = screenHeight / 4 + 420
            toRightButton.backgroundColor = UIColor.lightGray
            toRightButton.layer.cornerRadius = 20
            toRightButton.setTitle(">", for: UIControl.State.normal)
            toRightButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            toRightButton.addTarget(self, action: #selector(self.toRightBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(toRightButton)
        }
        else if type == 3 {
            //宣言済み変数
            let declaredBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            declaredBtn.center.x = screenWidth / 2 - 65
            declaredBtn.center.y = screenHeight / 4
            declaredBtn.backgroundColor = UIColor.darkGray
            declaredBtn.layer.cornerRadius = 20
            declaredBtn.setTitle(NSLocalizedString("Defined", comment: ""), for: UIControl.State.normal)
            declaredBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            declaredBtn.addTarget(self, action: #selector(self.declaredBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(declaredBtn)
            //リスト参照
            let fromListBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            fromListBtn.center.x = screenWidth / 2 + 65
            fromListBtn.center.y = screenHeight / 4
            fromListBtn.backgroundColor = UIColor.darkGray
            fromListBtn.layer.cornerRadius = 20
            fromListBtn.setTitle(NSLocalizedString("List element", comment: ""), for: UIControl.State.normal)
            fromListBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            fromListBtn.addTarget(self, action: #selector(self.fromListBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(fromListBtn)
            //初期値代入
            let initTankBtn = UIButton(frame: CGRectMake(0, 0, 250, 50))
            initTankBtn.center.x = screenWidth / 2
            initTankBtn.center.y = screenHeight / 4 + 60
            initTankBtn.backgroundColor = UIColor.lightGray
            initTankBtn.layer.cornerRadius = 20
            initTankBtn.setTitle(NSLocalizedString("Initialize tank var", comment: ""), for: UIControl.State.normal)
            initTankBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
            initTankBtn.addTarget(self, action: #selector(self.initTankBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(initTankBtn)
        }
        
        else if type == 4 {
            //宣言済み変数
            let declaredBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            declaredBtn.center.x = screenWidth / 2 - 65
            declaredBtn.center.y = screenHeight / 4
            declaredBtn.backgroundColor = UIColor.darkGray
            declaredBtn.layer.cornerRadius = 20
            declaredBtn.setTitle(NSLocalizedString("Defined", comment: ""), for: UIControl.State.normal)
            declaredBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            declaredBtn.addTarget(self, action: #selector(self.declaredBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(declaredBtn)
            //リスト参照
            let fromListBtn = UIButton(frame: CGRectMake(0, 0, 120, 50))
            fromListBtn.center.x = screenWidth / 2 + 65
            fromListBtn.center.y = screenHeight / 4
            fromListBtn.backgroundColor = UIColor.darkGray
            fromListBtn.layer.cornerRadius = 20
            fromListBtn.setTitle(NSLocalizedString("List element", comment: ""), for: UIControl.State.normal)
            fromListBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            fromListBtn.addTarget(self, action: #selector(self.fromListBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(fromListBtn)
            //初期値代入
            let initBulletBtn = UIButton(frame: CGRectMake(0, 0, 250, 50))
            initBulletBtn.center.x = screenWidth / 2
            initBulletBtn.center.y = screenHeight / 4 + 60
            initBulletBtn.backgroundColor = UIColor.lightGray
            initBulletBtn.layer.cornerRadius = 20
            initBulletBtn.setTitle(NSLocalizedString("Initialize bullet var", comment: ""), for: UIControl.State.normal)
            initBulletBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
            initBulletBtn.addTarget(self, action: #selector(self.initBulletBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(initBulletBtn)
        }
    }
    
    func updateFunc() {
        self.chooseBar.isHidden = !self.chooseBar.isHidden
    }
    
    func addCalcElement(text: String) {
        let label = UILabel()
        label.text = " " + text + "  "
        label.textColor = UIColor.white
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: 0, y: 5, width: size.width, height: 40)
        self.scrollView.addSubview(label)
        calcElements.insert(label, at: self.chooseBarIndex)
        self.calcElementUpdatePosition()
        self.toRight()
    }
    
    func calcElementUpdatePosition() {
        var x: CGFloat = 7.0
        for calcElement in calcElements {
            let size = calcElement.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            calcElement.frame = CGRect(x: x, y: 5, width: size.width, height: calcElement.frame.height)
            x += calcElement.frame.width
        }
        
        if x > self.screenWidth {
            self.scrollView.contentSize = CGSize(width: x, height: 50)
        }
        else {
            self.scrollView.contentSize = CGSize(width: self.screenWidth, height: 50)
        }
        
    }
    
    func toLeft() {
        let newIdx = self.chooseBarIndex - 1
        if newIdx >= 0 {
            self.chooseBarIndex = newIdx
        }
        else {
            self.chooseBarIndex = 0
        }
        
        var d: CGFloat = 7.0
        for i in 0 ..< self.chooseBarIndex {
            d += self.calcElements[i].frame.width
        }
        self.chooseBar.center.x = d
    }
    
    func toRight() {
        let newIdx = self.chooseBarIndex + 1
        if newIdx <= self.calcElements.count {
            self.chooseBarIndex = newIdx
        }
        else {
            self.chooseBarIndex = self.calcElements.count
        }
        
        var d: CGFloat = 7.0
        for i in 0 ..< self.chooseBarIndex {
            d += self.calcElements[i].frame.width
        }
        self.chooseBar.center.x = d
    }
    
    //戻るボタン押下時
    @IBAction func backBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.dismiss(animated: true, completion: nil)
    }
    
    //保存ボタン押下時
    @IBAction func saveBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        NotificationCenter.default.post(name: .saveValue, object: nil)
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.chooseBarIndex != 0 {
            var counter: Int = 0
            var idx: Int = self.chooseBarIndex - 1
            while true {
                if calcElements[idx].text == " )  " {
                    counter += 1
                }
                else if calcElements[idx].text!.contains("(") {
                    if counter == 0 {
                        //自身とその対応する括弧を削除
                        calcElements[idx].removeFromSuperview()
                        self.calcElements.remove(at: idx)
                        self.calcElementUpdatePosition()
                        counter = 1
                        while true {
                            if calcElements[idx].text!.contains("(") {
                                counter += 1
                            }
                            else if calcElements[idx].text == " )  " {
                                counter -= 1
                            }
                            if counter == 0 {
                                calcElements[idx].removeFromSuperview()
                                self.calcElements.remove(at: idx)
                                self.calcElementUpdatePosition()
                                self.toLeft()
                                return
                            }
                            idx += 1
                        }
                    }
                    counter -= 1
                }
                else if calcElements[idx].text == " (  " || calcElements[idx].text == " not (  " {
                    
                }
                
                calcElements[idx].removeFromSuperview()
                self.calcElements.remove(at: idx)
                self.calcElementUpdatePosition()
                self.toLeft()
                
                idx -= 1
                
                if counter == 0 {
                    return
                }
            }
        }
    }
    
    func addNum(value: Int) {
        if self.chooseBarIndex == 0 {
            self.addCalcElement(text: String(value))
            UISelectionFeedbackGenerator().selectionChanged()
        }
        else {
            let del: Set<Character> = [" "]
            var txt = self.calcElements[self.chooseBarIndex - 1].text!
            txt.removeAll(where: { del.contains($0) })
            let arr = txt.components(separatedBy: ".")
            if arr.count == 1 {
                if var num = Int(txt) {
                    if txt.count < 7 {
                        if num != 0 {
                            num = (abs(num) * 10 + value) * num / abs(num)
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                        self.calcElements[self.chooseBarIndex - 1].text = " " + String(num) + "  "
                        self.calcElementUpdatePosition()
                        var d: CGFloat = 7.0
                        for i in 0 ..< self.chooseBarIndex {
                            d += self.calcElements[i].frame.width
                        }
                        self.chooseBar.center.x = d
                    }
                }
                else if txt == "-" {
                    if self.chooseBarIndex == 1 || self.calcElements[self.chooseBarIndex - 2].text!.contains("("){
                        self.calcElements[self.chooseBarIndex - 1].text = " -" + String(value) + "  "
                        self.calcElementUpdatePosition()
                        var d: CGFloat = 7.0
                        for i in 0 ..< self.chooseBarIndex {
                            d += self.calcElements[i].frame.width
                        }
                        self.chooseBar.center.x = d
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                    else {
                        self.addCalcElement(text: String(value))
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                }
                else {
                    self.addCalcElement(text: String(value))
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
            else if arr.count == 2 {
                if txt.count < 7 {
                    if arr[1] == "" {
                        self.calcElements[self.chooseBarIndex - 1].text = " " + String(arr[0]) + "." + String(value) + "  "
                    }
                    else {
                        self.calcElements[self.chooseBarIndex - 1].text = " " + String(arr[0]) + "." + arr[1] + String(value) + "  "
                    }
                    self.calcElementUpdatePosition()
                    var d: CGFloat = 7.0
                    for i in 0 ..< self.chooseBarIndex {
                        d += self.calcElements[i].frame.width
                    }
                    self.chooseBar.center.x = d
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
        }
    }
    
    @IBAction func trueBtnAction(_ sender: Any)  {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "true")
    }
    @IBAction func falseBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "false")
    }
    @IBAction func andBtnAction(_ sender: Any)   {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "and")
    }
    @IBAction func orBtnAction(_ sender: Any)    {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "or")
    }
     
    @IBAction func plusBtnAction(_ sender: Any)      {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "+")
    }
    @IBAction func minusBtnAction(_ sender: Any)     {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "-")
    }
    @IBAction func timesBtnAction(_ sender: Any)     {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "*")
    }
    @IBAction func devideBtnAction(_ sender: Any)    {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "/")
    }
    @IBAction func remainderBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "%")
    }
    
    @IBAction func numBtn0(_ sender: Any) { self.addNum(value: 0) }
    @IBAction func numBtn1(_ sender: Any) { self.addNum(value: 1) }
    @IBAction func numBtn2(_ sender: Any) { self.addNum(value: 2) }
    @IBAction func numBtn3(_ sender: Any) { self.addNum(value: 3) }
    @IBAction func numBtn4(_ sender: Any) { self.addNum(value: 4) }
    @IBAction func numBtn5(_ sender: Any) { self.addNum(value: 5) }
    @IBAction func numBtn6(_ sender: Any) { self.addNum(value: 6) }
    @IBAction func numBtn7(_ sender: Any) { self.addNum(value: 7) }
    @IBAction func numBtn8(_ sender: Any) { self.addNum(value: 8) }
    @IBAction func numBtn9(_ sender: Any) { self.addNum(value: 9) }
    
    @IBAction func dotBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.chooseBarIndex != 0 {
            let del: Set<Character> = [" "]
            var txt = self.calcElements[self.chooseBarIndex - 1].text!
            txt.removeAll(where: { del.contains($0) })
            if let num = Int(txt) {
                self.calcElements[self.chooseBarIndex - 1].text = " " + String(num) + ".  "
                self.calcElementUpdatePosition()
                var d: CGFloat = 7.0
                for i in 0 ..< self.chooseBarIndex {
                    d += self.calcElements[i].frame.width
                }
                self.chooseBar.center.x = d
            }
        }
    }
    
    @IBAction func notBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "not (")
        self.addCalcElement(text: ")")
        self.toLeft()
    }
    @IBAction func parenthnessBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addCalcElement(text: "(")
        self.addCalcElement(text: ")")
        self.toLeft()
    }
    
    func addMessageLabel(msg: String) {
        self.backGround.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        self.backGround.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight / 3)
        self.backGround.text = msg
        self.backGround.textAlignment = .center
        self.view.addSubview(self.backGround)
        self.view.addSubview(self.clearButton)
    }
    
    func addPickerView(pickMode: Int) {
        self.pickMode = pickMode
        //代入する変数を単純選択
        if pickMode == 0 || pickMode == 1 || pickMode == 2 || pickMode == 3 || pickMode == 4 {
            if pickMode == 0 { self.dataList = self.variableBool }
            else if pickMode == 1 { self.dataList = self.variableInt }
            else if pickMode == 2 { self.dataList = self.variableFloat }
            else if pickMode == 3 { self.dataList = self.variableTank }
            else if pickMode == 4 { self.dataList = self.variableBullet }
            self.pickerView.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerView)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
        }
        //リストから代入
        else if pickMode == 5 || pickMode == 6 || pickMode == 7 || pickMode == 8 || pickMode == 9 {
            if pickMode == 5 { self.dataList = self.listBool }
            else if pickMode == 6 { self.dataList = self.listInt }
            else if pickMode == 7 { self.dataList = self.listFloat }
            else if pickMode == 8 { self.dataList = self.listTank }
            else if pickMode == 9 { self.dataList = self.listBullet }
            self.pickerView.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerView)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
            
            self.view.addSubview(self.numLabel)
            self.view.addSubview(self.pButton)
            self.view.addSubview(self.mButton)
            self.numLabel.text = "0"
        }
        //リスト長さ
        else if pickMode == 10 {
            self.dataList = self.listBool + self.listInt + self.listFloat + self.listTank + self.listBullet
            self.pickerView.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerView)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
        }
        //Tank型変数の要素
        else if pickMode == 11 {
            self.dataList = self.variableTank
            self.pickerView.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerView)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
            
            self.view.addSubview(self.xButton)
            self.view.addSubview(self.yButton)
            self.choosenChange(idx: 0)
        }
        //Bullet型変数の要素
        else if pickMode == 12 {
            self.dataList = self.variableBullet
            self.pickerView.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerView)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
            
            self.view.addSubview(self.xButton)
            self.view.addSubview(self.yButton)
            self.view.addSubview(self.thetaButton)
            self.choosenChange(idx: 0)
        }
        
        //Float型各種関数
        else if pickMode == 13 {
            self.dataList = ["sin ( )", "cos ( )", "sqrt ( )", "abs ( )"]
            self.pickerView.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerView)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
        }
        
        //Int比較
        else if pickMode == 14 {
            self.leftValue = self.variableInt
            self.RightValue = self.variableInt
            self.pickerForEval.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerForEval)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
        }
        
        //Float比較
        else if pickMode == 15 {
            self.leftValue = self.variableFloat
            self.RightValue = self.variableFloat
            self.pickerForEval.reloadAllComponents()
            self.view.addSubview(self.clearButton)
            self.view.addSubview(self.backGround)
            self.view.addSubview(self.pickerForEval)
            self.view.addSubview(self.goButton)
            self.view.addSubview(self.noButton)
        }
    }
    
    func getText() -> String {
        if pickMode == 0 || pickMode == 1 || pickMode == 2 || pickMode == 3 || pickMode == 4 {
            return self.nowName
        }
        else if pickMode == 5 || pickMode == 6 || pickMode == 7 || pickMode == 8 || pickMode == 9 {
            return self.nowName + ":" + self.numLabel.text!
        }
        else if pickMode == 10 {
            return self.nowName + ":len"
        }
        else if pickMode == 11 || pickMode == 12 {
            var txt = self.nowName
            if self.choosen == 0 { txt.append(":x") }
            else if self.choosen == 1 { txt.append(":y")}
            else if self.choosen == 2 { txt.append(":θ")}
            return txt
        }
        else if pickMode == 13 {
            var txt = self.nowName
            txt.removeLast(2)
            self.addCalcElement(text: txt)
            return ")"
        }
        else if pickMode == 14 {
            return "Int[" + self.nowLeft + " " + self.nowOperator + " " + self.nowRight + "]"
        }
        else if pickMode == 15 {
            return "Float[" + self.nowLeft + " " + self.nowOperator + " " + self.nowRight + "]"
        }
        return ""
    }
    
    func getCommand() -> (commands: String, text: String, labels: [String]) {
        var text = ""
        var labels: [String] = []
        
        var postfix: [String] = []
        var stack: [String] = []
        
        let priority: Dictionary<String, Int> = [
            "("    : 0,
            "sin(" : 0,
            "cos(" : 0,
            "sqrt(": 0,
            "abs(" : 0,
            "not("  : 0,
            ")"    : 0,
            "+"    : 1,
            "-"    : 1,
            "and"  : 1,
            "or"   : 1,
            "*"    : 2,
            "/"    : 2,
            "%"    : 2
            ]
        
        let space: Set<Character> = [" "]
        for calcElement in calcElements {
            var txt = calcElement.text
            txt?.removeFirst()
            txt?.removeLast(2)
            labels.append(txt!)
            if txt!.contains("==") || txt!.contains("!=") || txt!.contains("<") || txt!.contains(">") || txt!.contains("<=") || txt!.contains(">=") {
                
            }
            else {
                txt?.removeAll(where: { space.contains($0) })
            }
            
            text += " " + txt!
            
            if !priority.keys.contains(txt!) {
                if txt == "true" { postfix.append("t") }
                else if txt == "false" { postfix.append("f") }
                else if txt == NSLocalizedString("Init Tank", comment: "") { postfix.append("0.0 0.0") }
                else if txt == NSLocalizedString("Init Bullet", comment: "") { postfix.append("0.0 0.0 0.0") }
                else { postfix.append(txt!) }
            }
            else {
                if stack.count == 0 {
                    stack.append(txt!)
                }
                else {
                    if txt!.contains("(") {
                        stack.append(txt!)
                    }
                    else if txt == ")" {
                        while true {
                            if stack[stack.count - 1].contains("("){
                                if stack[stack.count - 1] == "sin(" { postfix.append("sin") }
                                else if stack[stack.count - 1] == "cos(" { postfix.append("cos") }
                                else if stack[stack.count - 1] == "sqrt(" { postfix.append("sqrt") }
                                else if stack[stack.count - 1] == "abs(" { postfix.append("abs") }
                                else if stack[stack.count - 1] == "not(" { postfix.append("!") }
                                break
                            }
                            else {
                                if stack[stack.count - 1] == "and" { postfix.append("&&") }
                                else if stack[stack.count - 1] == "or" { postfix.append("||") }
                                else { postfix.append(stack[stack.count - 1]) }
                                stack.removeLast()
                            }
                        }
                        stack.removeLast()
                    }
                    else if priority[txt!]! > priority[stack[stack.count - 1]]! {
                        stack.append(txt!)
                    }
                    else {
                        while stack.count != 0 {
                            if stack[stack.count - 1].contains("(") {
                                break
                            }
                            if stack[stack.count - 1] == "and" { postfix.append("&&") }
                            else if stack[stack.count - 1] == "or" { postfix.append("||") }
                            else { postfix.append(stack[stack.count - 1]) }
                            stack.removeLast()
                        }
                        stack.append(txt!)
                    }
                }
            }
        }
        while stack.count != 0 {
            if stack[stack.count - 1] == "and" { postfix.append("&&") }
            else if stack[stack.count - 1] == "or" { postfix.append("||") }
            else { postfix.append(stack[stack.count - 1]) }
            stack.removeLast()
        }
        var commands = ""
        for p in postfix {
            if p.prefix(4) == "Int[" {
                var list = p.components(separatedBy: " ")
                list[0].removeFirst(4)
                list[2].removeLast()
                commands.append("(Int " + list[0] + " " + list[2] + " " + list[1] + ") ")
            }
            else if p.prefix(6) == "Float[" {
                var list = p.components(separatedBy: " ")
                list[0].removeFirst(6)
                list[2].removeLast()
                commands.append("(Float " + list[0] + " " + list[2] + " " + list[1] + ") ")
            }
            else {
                commands.append(p + " ")
            }
        }
        if commands != "" {
            commands.removeLast()
        }
        return (commands: commands, text: text, labels: labels)
    }
    
    @IBAction func declaredBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.type == 0 {
            if self.variableBool.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Bool variable not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 0) }
        }
        else if self.type == 1 {
            if self.variableInt.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Int variable not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 1) }
        }
        else if self.type == 2 {
            if self.variableFloat.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Float variable not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 2) }
        }
        else if self.type == 3 {
            if self.variableTank.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Tank variable not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 3) }
        }
        else if self.type == 4 {
            if self.variableBullet.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Bullet variable not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 4) }
        }
    }
    
    @IBAction func fromListBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.type == 0 {
            if self.listBool.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Bool list not declared", comment: ""))
                return
            }
            else {
                self.addPickerView(pickMode: 5) }
        }
        else if self.type == 1 {
            if self.listInt.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Int list not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 6) }
        }
        else if self.type == 2 {
            if self.listFloat.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Float list not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 7) }
        }
        else if self.type == 3 {
            if self.listTank.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Tank list not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 8) }
        }
        else if self.type == 4 {
            if self.listBullet.count == 0 {
                self.addMessageLabel(msg: NSLocalizedString("Bullet list not declared", comment: ""))
                return
            }
            else { self.addPickerView(pickMode: 9) }
        }
    }
    
    @IBAction func evalIntBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if variableInt.count == 0 {
            self.addMessageLabel(msg: NSLocalizedString("Int variable not declared", comment: ""))
        }
        else {
            self.addPickerView(pickMode: 14)
        }
    }
    
    @IBAction func evalFloatBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if variableFloat.count == 0 {
            self.addMessageLabel(msg: NSLocalizedString("Float variable not declared", comment: ""))
        }
        else {
            self.addPickerView(pickMode: 15)
        }
    }
    
    @IBAction func lengthListBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if listBool.count + listInt.count + listFloat.count + listTank.count + listBullet.count == 0 {
            self.addMessageLabel(msg: NSLocalizedString("List not declared", comment: ""))
        }
        else {
            self.addPickerView(pickMode: 10)
        }
    }
    
    @IBAction func fromTankBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if variableTank.count == 0 {
            self.addMessageLabel(msg: NSLocalizedString("Tank variable not declared", comment: ""))
        }
        else {
            self.addPickerView(pickMode: 11)
        }
    }
    
    @IBAction func fromBulletBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if variableBullet.count == 0 {
            self.addMessageLabel(msg: NSLocalizedString("Bullet variable not declared", comment: ""))
        }
        else {
            self.addPickerView(pickMode: 12)
        }
    }
    
    @IBAction func otherFuncBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addPickerView(pickMode: 13)
    }
    
    @IBAction func initTankBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.calcElements.count == 1 {
            self.toLeft()
            self.calcElements[0].removeFromSuperview()
            self.calcElements = []
        }
        self.addCalcElement(text: NSLocalizedString("Init Tank", comment: ""))
    }
    
    @IBAction func initBulletBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.calcElements.count == 1 {
            self.toLeft()
            self.calcElements[0].removeFromSuperview()
            self.calcElements = []
        }
        self.addCalcElement(text: NSLocalizedString("Init Bullet", comment: ""))
    }
    
    @IBAction func toLeftBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.toLeft()
    }
    @IBAction func toRightBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.toRight()
    }
    
    @IBAction func goBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if self.type == 3 || self.type == 4 {
            if self.calcElements.count == 1 {
                self.toLeft()
                self.calcElements[0].removeFromSuperview()
                self.calcElements = []
            }
        }
        self.addCalcElement(text: self.getText())
        if self.pickMode == 13 { self.toLeft() }
        
        self.clearButton.removeFromSuperview()
        self.backGround.removeFromSuperview()
        self.goButton.removeFromSuperview()
        self.noButton.removeFromSuperview()
        self.xButton.removeFromSuperview()
        self.yButton.removeFromSuperview()
        self.thetaButton.removeFromSuperview()
        self.numLabel.removeFromSuperview()
        self.pButton.removeFromSuperview()
        self.mButton.removeFromSuperview()
        self.pickerView.removeFromSuperview()
        self.pickerForEval.removeFromSuperview()
        
        self.backGround.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 50, height: self.screenHeight / 2)
        self.backGround.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight / 2)
        self.backGround.text = ""
    }
    
    @IBAction func noBtnAction(_ sender: Any) {
        self.clearButton.removeFromSuperview()
        self.backGround.removeFromSuperview()
        self.goButton.removeFromSuperview()
        self.noButton.removeFromSuperview()
        self.xButton.removeFromSuperview()
        self.yButton.removeFromSuperview()
        self.thetaButton.removeFromSuperview()
        self.numLabel.removeFromSuperview()
        self.pButton.removeFromSuperview()
        self.mButton.removeFromSuperview()
        self.pickerView.removeFromSuperview()
        self.pickerForEval.removeFromSuperview()
        
        self.backGround.frame = CGRect(x: 0, y: 0, width: self.screenWidth - 50, height: self.screenHeight / 2)
        self.backGround.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight / 2)
        self.backGround.text = ""
    }
    
    func choosenChange(idx: Int) {
        self.choosen = idx
        if idx == 0 {
            self.xButton.layer.borderWidth = 2
            self.yButton.layer.borderWidth = 0
            self.thetaButton.layer.borderWidth = 0
        }
        else if idx == 1 {
            self.xButton.layer.borderWidth = 0
            self.yButton.layer.borderWidth = 2
            self.thetaButton.layer.borderWidth = 0
        }
        else if idx == 2 {
            self.xButton.layer.borderWidth = 0
            self.yButton.layer.borderWidth = 0
            self.thetaButton.layer.borderWidth = 2
        }
    }
    
    @IBAction func xBtnAction(_ sender: Any)     {
        UISelectionFeedbackGenerator().selectionChanged()
        self.choosenChange(idx: 0)
    }
    @IBAction func yBtnAction(_ sender: Any)     {
        UISelectionFeedbackGenerator().selectionChanged()
        self.choosenChange(idx: 1)
    }
    @IBAction func thetaBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.choosenChange(idx: 2)
    }
    
    @IBAction func pBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.numLabel.text = String(Int(self.numLabel.text!)! + 1)
    }
    @IBAction func mBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        let a = Int(self.numLabel.text!)!
        if a > 0 {
            self.numLabel.text = String(Int(self.numLabel.text!)! - 1)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == self.pickerView { return 1 }
        else if pickerView == self.pickerForEval { return 3 }
        else { return 0 }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerView {
            return dataList.count
        }
        else if pickerView == self.pickerForEval {
            if component == 0 { return leftValue.count }
            else if component == 1 { return compareOperator.count }
            else if component == 2 { return RightValue.count }
            else { return 0 }
        }
        else { return 0 }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var name: String = ""
        if pickerView == self.pickerView {
            self.nowName = dataList[row]
            name = self.nowName
        }
        else if pickerView == self.pickerForEval {
            if component == 0 {
                self.nowLeft = leftValue[row]
                name = self.nowLeft
            }
            else if component == 1 {
                self.nowOperator = compareOperator[row]
                name = self.nowOperator
            }
            else if component == 2 {
                self.nowRight = RightValue[row]
                name = self.nowRight
            }
        }
        return name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerView {
            self.nowName = dataList[row]
        }
        else if pickerView == self.pickerForEval {
            if component == 0 { self.nowLeft = leftValue[row] }
            else if component == 1 { self.nowOperator = compareOperator[row] }
            else if component == 2 { self.nowRight = RightValue[row] }
        }
    }
}
