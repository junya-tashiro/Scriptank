//
//  EditorElement.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/28.
//

import Foundation
import SwiftUI

class EditorElement {
    let view: UIScrollView
    let editView: UIView
    var index: Int
    let indent: Int
    var commands: String = ""
    
    let myBlue = UIColor(red: 0.2, green: 0.1, blue: 0.7, alpha: 1.0)
    let myOrange = UIColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
    let myPurple = UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0)
    let myGreen = UIColor(red: 0.4, green: 0.6, blue: 0.3, alpha: 1.0)
    
    let variableLabel = VariableLabel()
    let listLabel = ListLabel()
    let conditionalLabel = ConditionalLabel()
    let printLabel = PrintLabel()
    
    var pathViewController: PathViewController! = nil
    
    var pushedAtFirst: Bool = true
    var typeChooseFlag: Bool = false
    var choosen: Bool = false
    var isRestored: Bool = false
    
    let addAboveFunc: (Int) -> ()
    let addBelowFunc: (Int, Int) -> ()
    let deleteFunc: (Int) -> ()
    let choosenChange: (Int) -> ()
    
    let body = UIButton(frame: CGRectMake(0, 0, 150, 50))
    var bodyLen: CGFloat = 150
    
    let deleteButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
    let addBelowButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
    let addAboveButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
    
    var elementType: Int = 0
    
    let forVariable = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forList = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forConditional = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forPath = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forPrint = UIButton(frame: CGRectMake(0, 0, 160, 30))
    var chooseButtons: [UIButton] = []
    
    let forBool = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forInt = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forFloat = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forTank = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forBullet = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forText = UIButton(frame: CGRectMake(0, 0, 160, 30))
    
    let forIf = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forFor = UIButton(frame: CGRectMake(0, 0, 160, 30))
    let forWhile = UIButton(frame: CGRectMake(0, 0, 160, 30))
    
    var typeChooseButtons: [UIButton] = []
    
    let nameButton = UIButton(frame: CGRectMake(0, 0, 160, 40))
    let valueButton = UIButton(frame: CGRectMake(0, 0, 160, 40))
    let initButton = UIButton(frame: CGRectMake(0, 0, 70, 40))
    let appendButton = UIButton(frame: CGRectMake(0, 0, 70, 40))
    
    let conditionButton = UIButton(frame: CGRectMake(0, 0, 160, 40))
    let variableButton = UIButton(frame: CGRectMake(0, 0, 160, 40))
    let listButton = UIButton(frame: CGRectMake(0, 0, 160, 40))
    
    let cantEditLabel = UILabel(frame: CGRectMake(0, 0, 200, 50))
    
    var state: Int = 0
    
    var values: String = ""
    var text: String = ""
    var labels: [String] = []
    
    init(view: UIScrollView, editView: UIView, screenWidth: CGFloat, screenHeight: CGFloat, index: Int, indent: Int, addAboveFunc: @escaping (Int) -> (), addBelowFunc: @escaping (Int, Int) -> (), deleteFunc: @escaping (Int) -> (), choosenChange: @escaping (Int) -> ()) {
        self.view = view
        self.editView = editView
        self.index = index
        self.indent = indent
        self.addAboveFunc = addAboveFunc
        self.addBelowFunc = addBelowFunc
        self.deleteFunc = deleteFunc
        self.choosenChange = choosenChange
        
        self.setEditView()
        self.setButton()
        self.setEditViewForTypeChoose()
    }
    
    func setEditViewForTypeChoose() {
        self.typeChooseButtons = [self.forBool, self.forInt, self.forFloat, self.forTank, self.forBullet]
        
        self.forBool.center.x = self.editView.frame.width / 4
        self.forBool.center.y = self.editView.frame.height * 3 / 10
        self.forBool.layer.cornerRadius = 10
        self.forBool.setTitle(NSLocalizedString("Bool", comment: ""), for: UIControl.State.normal)
        self.forBool.addTarget(self, action: #selector(self.forBoolBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        self.forInt.center.x = self.editView.frame.width / 4
        self.forInt.center.y = self.editView.frame.height / 2
        self.forInt.setTitle(NSLocalizedString("Int", comment: ""), for: UIControl.State.normal)
        self.forInt.addTarget(self, action: #selector(self.forIntBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        self.forFloat.center.x = self.editView.frame.width / 4
        self.forFloat.center.y = self.editView.frame.height * 7 / 10
        self.forFloat.setTitle(NSLocalizedString("Float", comment: ""), for: UIControl.State.normal)
        self.forFloat.addTarget(self, action: #selector(self.forFloatBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        self.forTank.center.x = self.editView.frame.width * 3 / 4
        self.forTank.center.y = self.editView.frame.height * 3 / 10
        self.forTank.setTitle(NSLocalizedString("Tank", comment: ""), for: UIControl.State.normal)
        self.forTank.addTarget(self, action: #selector(self.forTankBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        self.forBullet.center.x = self.editView.frame.width * 3 / 4
        self.forBullet.center.y = self.editView.frame.height / 2
        self.forBullet.setTitle(NSLocalizedString("Bullet", comment: ""), for: UIControl.State.normal)
        self.forBullet.addTarget(self, action: #selector(self.forBulletBtnAction(_:)), for: UIControl.Event.touchUpInside)
        
        for typeChooseButton in typeChooseButtons {
            typeChooseButton.layer.cornerRadius = 10
            typeChooseButton.backgroundColor = myBlue
            self.editView.addSubview(typeChooseButton)
            typeChooseButton.isHidden = true
        }
    }
    
    func setEditView() {
        self.chooseButtons = [self.forVariable, self.forList, self.forConditional, self.forPath, self.forPrint]
        
        self.forVariable.center.x = self.editView.frame.width / 4
        self.forVariable.center.y = self.editView.frame.height * 3 / 10
        self.forVariable.layer.cornerRadius = 5
        self.forVariable.setTitle(NSLocalizedString("About variable", comment: ""), for: UIControl.State.normal)
        self.forVariable.backgroundColor = myBlue
        self.forVariable.addTarget(self, action: #selector(self.forVariableBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forVariable)
        
        self.forList.center.x = self.editView.frame.width / 4
        self.forList.center.y = self.editView.frame.height / 2
        self.forList.layer.cornerRadius = 5
        self.forList.setTitle(NSLocalizedString("About list", comment: ""), for: UIControl.State.normal)
        self.forList.backgroundColor = myGreen
        self.forList.addTarget(self, action: #selector(self.forListBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forList)
        
        self.forConditional.center.x = self.editView.frame.width * 3 / 4
        self.forConditional.center.y = self.editView.frame.height * 3 / 10
        self.forConditional.layer.cornerRadius = 5
        self.forConditional.setTitle(NSLocalizedString("If/Repetition", comment: ""), for: UIControl.State.normal)
        self.forConditional.backgroundColor = myPurple
        self.forConditional.addTarget(self, action: #selector(self.forConditionalBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forConditional)
        
        self.forPath.center.x = self.editView.frame.width * 3 / 4
        self.forPath.center.y = self.editView.frame.height / 2
        self.forPath.layer.cornerRadius = 5
        self.forPath.setTitle(NSLocalizedString("Path", comment: ""), for: UIControl.State.normal)
        self.forPath.backgroundColor = myOrange
        self.forPath.addTarget(self, action: #selector(self.forPathBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forPath)
        
        self.forPrint.center.x = self.editView.frame.width / 4
        self.forPrint.center.y = self.editView.frame.height * 7 / 10
        self.forPrint.layer.cornerRadius = 5
        self.forPrint.setTitle(NSLocalizedString("Print", comment: ""), for: UIControl.State.normal)
        self.forPrint.backgroundColor = UIColor.brown
        self.forPrint.addTarget(self, action: #selector(self.forPrintBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forPrint)
        
        self.cantEditLabel.center.x = self.editView.frame.width / 2
        self.cantEditLabel.center.y = self.editView.frame.height / 2
        self.cantEditLabel.numberOfLines = 0
        self.cantEditLabel.text = NSLocalizedString("You can't edit restored blocks", comment: "")
        self.cantEditLabel.textAlignment = .center
        self.editView.addSubview(self.cantEditLabel)
        self.cantEditLabel.isHidden = true
    }
    
    func setEditViewForConditional() {
        for chooseButton in chooseButtons {
            chooseButton.removeFromSuperview()
        }
        chooseButtons = [self.forIf, self.forFor, self.forWhile]
        
        self.forIf.center.x = self.editView.frame.width / 2
        self.forIf.center.y = self.editView.frame.height * 3 / 10
        self.forIf.layer.cornerRadius = 5
        self.forIf.setTitle("If", for: UIControl.State.normal)
        self.forIf.backgroundColor = myPurple
        self.forIf.addTarget(self, action: #selector(self.forIfBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forIf)
        
        self.forFor.center.x = self.editView.frame.width / 2
        self.forFor.center.y = self.editView.frame.height / 2
        self.forFor.layer.cornerRadius = 5
        self.forFor.setTitle("For", for: UIControl.State.normal)
        self.forFor.backgroundColor = myPurple
        self.forFor.addTarget(self, action: #selector(self.forForBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forFor)
        
        self.forWhile.center.x = self.editView.frame.width / 2
        self.forWhile.center.y = self.editView.frame.height * 7 / 10
        self.forWhile.layer.cornerRadius = 5
        self.forWhile.setTitle("While", for: UIControl.State.normal)
        self.forWhile.backgroundColor = myPurple
        self.forWhile.addTarget(self, action: #selector(self.forWhileBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.editView.addSubview(self.forWhile)
    }
    
    func setButton() {
        self.body.center.x = CGFloat(120 + 50 * self.indent) + (self.bodyLen / 2 - 75)
        self.body.center.y = CGFloat(100 + 70 * self.index)
        self.body.layer.cornerRadius = 10
        self.body.setTitle(NSLocalizedString(" Choose process", comment: ""), for: UIControl.State.normal)
        self.body.contentHorizontalAlignment = .left
        self.body.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        self.body.layer.borderColor = UIColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 1.0).cgColor
        self.body.addTarget(self, action: #selector(self.bodyBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.body)
        
        self.deleteButton.layer.cornerRadius = self.deleteButton.frame.width / 2
        self.deleteButton.center.x = CGFloat(220 + 50 * self.indent) + (self.bodyLen - 150)
        self.deleteButton.center.y = CGFloat(100 + 70 * self.index)
        self.deleteButton.setTitle("-", for: UIControl.State.normal)
        self.deleteButton.backgroundColor = myOrange
        self.deleteButton.addTarget(self, action: #selector(self.deleteBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.deleteButton)
        
        self.addAboveButton.layer.cornerRadius = self.addAboveButton.frame.width / 2
        self.addAboveButton.center.x = CGFloat(260 + 50 * self.indent) + (self.bodyLen - 150)
        self.addBelowButton.center.y = CGFloat(100 + 70 * self.index)
        self.addAboveButton.setTitle("+↑", for: UIControl.State.normal)
        self.addAboveButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        self.addAboveButton.addTarget(self, action: #selector(self.addAboveBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.addAboveButton)
        
        self.addBelowButton.layer.cornerRadius = self.addBelowButton.frame.width / 2
        self.addBelowButton.center.x = CGFloat(300 + 50 * self.indent) + (self.bodyLen - 150)
        self.addAboveButton.center.y = CGFloat(100 + 70 * self.index)
        self.addBelowButton.setTitle("+↓", for: UIControl.State.normal)
        self.addBelowButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        self.addBelowButton.addTarget(self, action: #selector(self.addBelowBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.addBelowButton)
    }
    
    func makeCommand() -> String{
        self.commands = ""
        if self.state == 1 {
            if self.elementType == 0      { self.commands.append("Bool ")    }
            else if self.elementType == 1 { self.commands.append("Int ")     }
            else if self.elementType == 2 { self.commands.append("Float ")   }
            else if self.elementType == 3 { self.commands.append("Tank ")    }
            else if self.elementType == 4 { self.commands.append("Bullet ")  }
            commands.append(self.variableLabel.name + " " + self.values)
        }
        else if self.state == 2 {
            if self.elementType == 0      { self.commands.append("lBool ")    }
            else if self.elementType == 1 { self.commands.append("lInt ")     }
            else if self.elementType == 2 { self.commands.append("lFloat ")   }
            else if self.elementType == 3 { self.commands.append("lTank ")    }
            else if self.elementType == 4 { self.commands.append("lBullet ")  }
            commands.append(self.listLabel.name + " " + self.values)
        }
        else if self.state == 3 {
            if self.elementType == 0 || self.elementType == 1 || self.elementType == 2 || self.elementType == 3 || self.elementType == 4 {
                self.commands.append("for ")
                self.commands.append(self.conditionalLabel.variable)
                if self.elementType == 0      { self.commands.append(" in lBool ")    }
                else if self.elementType == 1 { self.commands.append(" in lInt ")     }
                else if self.elementType == 2 { self.commands.append(" in lFloat ")   }
                else if self.elementType == 3 { self.commands.append(" in lTank ")    }
                else if self.elementType == 4 { self.commands.append(" in lBullet ")  }
                self.commands.append(self.conditionalLabel.list)
            }
            else if self.elementType == 5 {
                self.commands.append("if " + self.values)
            }
            else if self.elementType == 7 {
                self.commands.append("while " + self.values)
            }
        }
        else if self.state == 4 {
            self.commands.append("path " + self.values)
        }
        else if self.state == 5 {
            self.commands.append("print ")
            if self.elementType == 0      { self.commands.append("Bool " + self.printLabel.value)   }
            else if self.elementType == 1 { self.commands.append("Int " + self.printLabel.value)    }
            else if self.elementType == 2 { self.commands.append("Float " + self.printLabel.value)  }
            else if self.elementType == 3 { self.commands.append("Tank " + self.printLabel.value)   }
            else if self.elementType == 4 { self.commands.append("Bullet " + self.printLabel.value) }
            else if self.elementType == 5 { self.commands.append("(" + self.printLabel.value + ")")}
            
        }
        return commands
    }
    
    func positionUpdate() {
        self.body.frame = CGRect(x: 0, y: 0, width: self.bodyLen, height: 50)
        self.body.center.x = CGFloat(120 + 50 * self.indent) + (self.bodyLen / 2 - 75)
        self.body.center.y = CGFloat(100 + 70 * self.index)
        self.deleteButton.center.x = CGFloat(220 + 50 * self.indent) + (self.bodyLen - 150)
        self.deleteButton.center.y = CGFloat(100 + 70 * self.index)
        self.addAboveButton.center.x = CGFloat(260 + 50 * self.indent) + (self.bodyLen - 150)
        self.addBelowButton.center.y = CGFloat(100 + 70 * self.index)
        self.addBelowButton.center.x = CGFloat(300 + 50 * self.indent) + (self.bodyLen - 150)
        self.addAboveButton.center.y = CGFloat(100 + 70 * self.index)
    }
    
    func choosenUpdate() {
        changeState(state: self.state)
    }
    
    func valueChanged() {
        if self.state == 1 {
            self.variableLabel.value = self.text
            self.body.setTitle(variableLabel.makeLabelMsg(), for: UIControl.State.normal)
        }
        else if self.state == 2 {
            self.listLabel.operation = self.text
            self.body.setTitle(listLabel.makeLabelMsg(), for: UIControl.State.normal)
        }
        else if self.state == 3 {
            self.conditionalLabel.condition = self.text
            self.body.setTitle(conditionalLabel.makeLabelMsg(), for: UIControl.State.normal)
        }
        let size = self.body.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        if size.width > 200 {
            self.bodyLen = size.width
        }
        else {
            self.bodyLen = 200
        }
        self.positionUpdate()
    }
    
    func changeState(state: Int) {
        self.state = state
        //自分が選択されているとき
        if self.choosen {
            self.body.layer.borderWidth = 2
            //0: 要素を選択してください
            if self.state == 0 {
                for chooseButton in chooseButtons {
                    chooseButton.isHidden = false
                }
            }
            //1: 変数の宣言, 更新
            else if self.state == 1 {
                self.body.backgroundColor = self.forVariable.backgroundColor
                for chooseButton in chooseButtons {
                    chooseButton.removeFromSuperview()
                }
                if !self.typeChooseFlag {
                    for typeChooseButton in typeChooseButtons {
                        typeChooseButton.isHidden = false
                    }
                }
                
                self.nameButton.isHidden = false
                self.valueButton.isHidden = false
                
                self.body.setTitle(variableLabel.makeLabelMsg(), for: UIControl.State.normal)
                if self.bodyLen < 200 {
                    self.bodyLen = 200
                }
                self.positionUpdate()
            }
            //2: リストの宣言, 要素追加
            else if self.state == 2 {
                self.body.backgroundColor = self.forList.backgroundColor
                for chooseButton in chooseButtons {
                    chooseButton.removeFromSuperview()
                }
                if !self.typeChooseFlag {
                    for typeChooseButton in typeChooseButtons {
                        typeChooseButton.isHidden = false
                    }
                }
                
                self.nameButton.isHidden = false
                self.initButton.isHidden = false
                self.appendButton.isHidden = false
                
                self.body.setTitle(listLabel.makeLabelMsg(), for: UIControl.State.normal)
                if self.bodyLen < 200 {
                    self.bodyLen = 200
                }
                self.positionUpdate()
            }
            //3: if, for while文
            else if self.state == 3 {
                self.body.backgroundColor = self.forConditional.backgroundColor
                self.setEditViewForConditional()
                if !self.typeChooseFlag {
                    self.body.setTitle(NSLocalizedString(" Conditional", comment: ""), for: UIControl.State.normal)
                    for chooseButton in chooseButtons {
                        chooseButton.isHidden = false
                    }
                }
                else if self.elementType == 5 || self.elementType == 7 {
                    self.conditionButton.isHidden = false
                }
                else if self.elementType == 6 {
                    for typeChooseButton in typeChooseButtons {
                        typeChooseButton.isHidden = false
                    }
                }
                else {
                    for chooseButton in chooseButtons {
                        chooseButton.removeFromSuperview()
                    }
                }
                self.variableButton.isHidden = false
                self.listButton.isHidden = false
                
                
            }
            //4: pathの宣言
            else if self.state == 4 {
                self.body.backgroundColor = self.forPath.backgroundColor
                for chooseButton in chooseButtons {
                    chooseButton.removeFromSuperview()
                }
                if !self.typeChooseFlag {
                    self.body.setTitle(NSLocalizedString(" Path", comment: ""), for: UIControl.State.normal)
                }
            }
            //5: print文
            else if self.state == 5 {
                self.body.backgroundColor = self.forPrint.backgroundColor
                for chooseButton in chooseButtons {
                    chooseButton.removeFromSuperview()
                }

                if !self.typeChooseFlag {
                    for typeChooseButton in typeChooseButtons {
                        typeChooseButton.isHidden = false
                    }
                }
                
                self.nameButton.isHidden = false

                self.body.setTitle(printLabel.makeLabelMsg(), for: UIControl.State.normal)
                self.valueChanged()
            }
        }
        //自分が選択されていないとき
        else {
            self.body.layer.borderWidth = 0
            
            for chooseButton in chooseButtons {
                chooseButton.isHidden = true
            }
            
            for typeChooseButton in typeChooseButtons {
                typeChooseButton.isHidden = true
            }
            
            self.nameButton.isHidden = true
            self.valueButton.isHidden = true
            self.initButton.isHidden = true
            self.appendButton.isHidden = true
            self.conditionButton.isHidden = true
            self.variableButton.isHidden = true
            self.listButton.isHidden = true
        }
        if self.isRestored {
            for chooseButton in chooseButtons {
                chooseButton.removeFromSuperview()
            }
            for typeChooseButton in typeChooseButtons {
                typeChooseButton.removeFromSuperview()
            }
            self.cantEditLabel.isHidden = !self.choosen
        }
    }
    
    func decideType(type: Int) {
        self.elementType = type
        self.typeChooseFlag = true
        if self.state == 1 {
            for typeChooseButton in typeChooseButtons {
                typeChooseButton.removeFromSuperview()
            }
            if type == 0 { variableLabel.type = NSLocalizedString("Bool", comment: "") }
            else if type == 1 { variableLabel.type = NSLocalizedString("Int", comment: "") }
            else if type == 2 { variableLabel.type = NSLocalizedString("Float", comment: "") }
            else if type == 3 { variableLabel.type = NSLocalizedString("Tank", comment: "") }
            else if type == 4 { variableLabel.type = NSLocalizedString("Bullet", comment: "") }
            
            self.body.setTitle(variableLabel.makeLabelMsg(), for: UIControl.State.normal)
            
            let size = self.body.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            if size.width > 200 {
                self.bodyLen = size.width
            }
            self.positionUpdate()
        }
        else if self.state == 2 {
            for typeChooseButton in typeChooseButtons {
                typeChooseButton.removeFromSuperview()
            }
            if type == 0 { listLabel.type = NSLocalizedString("Bool list", comment: "") }
            else if type == 1 { listLabel.type = NSLocalizedString("Int list", comment: "") }
            else if type == 2 { listLabel.type = NSLocalizedString("Float list", comment: "") }
            else if type == 3 { listLabel.type = NSLocalizedString("Tank list", comment: "") }
            else if type == 4 { listLabel.type = NSLocalizedString("Bullet list", comment: "") }
            
            self.body.setTitle(listLabel.makeLabelMsg(), for: UIControl.State.normal)
            
            let size = self.body.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            if size.width > 200 {
                self.bodyLen = size.width
            }
            self.positionUpdate()
        }
        else if self.state == 3 {
            for chooseButton in chooseButtons {
                chooseButton.removeFromSuperview()
            }
            if type == 0 || type == 1 || type == 2 || type == 3 || type == 4 {
                self.conditionalLabel.state = 1
                if type == 0 { conditionalLabel.listType = "Bool:" }
                else if type == 1 { conditionalLabel.listType = "Int:" }
                else if type == 2 { conditionalLabel.listType = "Float:" }
                else if type == 3 { conditionalLabel.listType = "Tank:" }
                else if type == 4 { conditionalLabel.listType = "Bullet:" }
                self.body.setTitle(conditionalLabel.makeLabelMsg(), for: UIControl.State.normal)
                let size = self.body.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                if size.width > 200 { self.bodyLen = size.width }
                self.positionUpdate()
                
                for typeChooseButton in typeChooseButtons {
                    typeChooseButton.removeFromSuperview()
                }
                //変数, リスト選択ボタン
                self.variableButton.center.x = self.editView.frame.width / 2
                self.variableButton.center.y = self.editView.frame.height / 2 - 30
                self.variableButton.layer.cornerRadius = 5
                self.variableButton.setTitle(NSLocalizedString("Input var name", comment: ""), for: UIControl.State.normal)
                self.variableButton.backgroundColor = myPurple
                self.variableButton.addTarget(self, action: #selector(self.variableBtnAction(_:)), for: UIControl.Event.touchUpInside)
                self.editView.addSubview(self.variableButton)
                self.variableButton.isHidden = false
                
                self.listButton.center.x = self.editView.frame.width / 2
                self.listButton.center.y = self.editView.frame.height / 2 + 30
                self.listButton.layer.cornerRadius = 5
                self.listButton.setTitle(NSLocalizedString("Choose list", comment: ""), for: UIControl.State.normal)
                self.listButton.backgroundColor = myPurple
                self.listButton.addTarget(self, action: #selector(self.listBtnAction(_:)), for: UIControl.Event.touchUpInside)
                self.editView.addSubview(self.listButton)
                self.listButton.isHidden = false
                
            }
            else {
                //条件選択でif
                if type == 5 {
                    conditionalLabel.type = "if"
                    //条件入力ボタン
                    self.conditionButton.center.x = self.editView.frame.width / 2
                    self.conditionButton.center.y = self.editView.frame.height / 2
                    self.conditionButton.layer.cornerRadius = 5
                    self.conditionButton.setTitle(NSLocalizedString("Input condition", comment: ""), for: UIControl.State.normal)
                    self.conditionButton.backgroundColor = myPurple
                    self.conditionButton.addTarget(self, action: #selector(self.conditionBtnAction(_:)), for: UIControl.Event.touchUpInside)
                    self.editView.addSubview(self.conditionButton)
                    self.conditionButton.isHidden = false
                }
                //条件選択でfor
                else if type == 6 {
                    conditionalLabel.type = "for"
                    //リスト種類選択
                    for typeChooseButton in typeChooseButtons {
                        typeChooseButton.backgroundColor = myPurple
                        typeChooseButton.isHidden = false
                    }
                }
                //条件選択でwhile
                else if type == 7 {
                    conditionalLabel.type = "while"
                    //条件入力ボタン
                    self.conditionButton.center.x = self.editView.frame.width / 2
                    self.conditionButton.center.y = self.editView.frame.height / 2
                    self.conditionButton.layer.cornerRadius = 5
                    self.conditionButton.setTitle(NSLocalizedString("Input condition", comment: ""), for: UIControl.State.normal)
                    self.conditionButton.backgroundColor = myPurple
                    self.conditionButton.addTarget(self, action: #selector(self.conditionBtnAction(_:)), for: UIControl.Event.touchUpInside)
                    self.editView.addSubview(self.conditionButton)
                    self.conditionButton.isHidden = false
                }
                
                self.typeChooseFlag = true
                
                self.body.setTitle(conditionalLabel.makeLabelMsg(), for: UIControl.State.normal)
                
                let size = self.body.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                if size.width > 200 {
                    self.bodyLen = size.width
                }
                self.positionUpdate()
            }
        }
        
        else if self.state == 5 {
            for typeChooseButton in typeChooseButtons {
                typeChooseButton.removeFromSuperview()
            }
            if type == 0 { printLabel.type = NSLocalizedString("Bool", comment: "") }
            else if type == 1 { printLabel.type = NSLocalizedString("Int", comment: "") }
            else if type == 2 { printLabel.type = NSLocalizedString("Float", comment: "") }
            else if type == 3 { printLabel.type = NSLocalizedString("Tank", comment: "") }
            else if type == 4 { printLabel.type = NSLocalizedString("Bullet", comment: "") }
            else if type == 5 { printLabel.type = NSLocalizedString("Text", comment: "") }
            
            self.body.setTitle(printLabel.makeLabelMsg(), for: UIControl.State.normal)
            
            let size = self.body.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            if size.width > 200 {
                self.bodyLen = size.width
            }
            self.positionUpdate()
        }
        
        //名前選択用ラベルと値入力を追加
        if self.state == 1 {
            self.nameButton.center.x = self.editView.frame.width / 2
            self.nameButton.center.y = self.editView.frame.height / 2 - 30
            self.nameButton.layer.cornerRadius = 5
            self.nameButton.setTitle(NSLocalizedString("Choose name", comment: ""), for: UIControl.State.normal)
            self.nameButton.backgroundColor = myBlue
            self.nameButton.addTarget(self, action: #selector(self.nameBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.editView.addSubview(self.nameButton)
            self.nameButton.isHidden = false
            
            self.valueButton.center.x = self.editView.frame.width / 2
            self.valueButton.center.y = self.editView.frame.height / 2 + 30
            self.valueButton.layer.cornerRadius = 5
            self.valueButton.setTitle(NSLocalizedString("Input value", comment: ""), for: UIControl.State.normal)
            self.valueButton.backgroundColor = myBlue
            self.valueButton.addTarget(self, action: #selector(self.valueBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.editView.addSubview(self.valueButton)
            self.valueButton.isHidden = false
        }
        else if self.state == 2 {
            self.nameButton.center.x = self.editView.frame.width / 2
            self.nameButton.center.y = self.editView.frame.height / 2 - 30
            self.nameButton.layer.cornerRadius = 5
            self.nameButton.setTitle(NSLocalizedString("Choose name", comment: ""), for: UIControl.State.normal)
            self.nameButton.backgroundColor = myGreen
            self.nameButton.addTarget(self, action: #selector(self.nameBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.editView.addSubview(self.nameButton)
            self.nameButton.isHidden = false
            
            self.initButton.center.x = self.editView.frame.width / 2 + 45
            self.initButton.center.y = self.editView.frame.height / 2 + 30
            self.initButton.layer.cornerRadius = 5
            self.initButton.setTitle(NSLocalizedString("Initialize", comment: ""), for: UIControl.State.normal)
            self.initButton.backgroundColor = myGreen
            self.initButton.addTarget(self, action: #selector(self.initBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.editView.addSubview(self.initButton)
            self.initButton.isHidden = false
            
            self.appendButton.center.x = self.editView.frame.width / 2 - 45
            self.appendButton.center.y = self.editView.frame.height / 2 + 30
            self.appendButton.layer.cornerRadius = 5
            self.appendButton.setTitle(NSLocalizedString("Append", comment: ""), for: UIControl.State.normal)
            self.appendButton.backgroundColor = myGreen
            self.appendButton.addTarget(self, action: #selector(self.appendBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.editView.addSubview(self.appendButton)
            self.appendButton.isHidden = false
        }
        else if self.state == 5 {
            self.nameButton.center.x = self.editView.frame.width / 2
            self.nameButton.center.y = self.editView.frame.height / 2
            self.nameButton.layer.cornerRadius = 5
            if type == 5 {
                self.nameButton.setTitle(NSLocalizedString("Input text", comment: ""), for: UIControl.State.normal)
            }
            else {
                self.nameButton.setTitle(NSLocalizedString("Choose variable", comment: ""), for: UIControl.State.normal)
            }
            self.nameButton.backgroundColor = UIColor.brown
            self.nameButton.addTarget(self, action: #selector(self.nameBtnAction(_:)), for: UIControl.Event.touchUpInside)
            self.editView.addSubview(self.nameButton)
            self.nameButton.isHidden = false
        }
    }
    
    func deleteSelf() {
        self.body.removeFromSuperview()
        self.deleteButton.removeFromSuperview()
        self.addAboveButton.removeFromSuperview()
        self.addBelowButton.removeFromSuperview()
        
        for chooseButton in chooseButtons {
            chooseButton.removeFromSuperview()
        }
        
        for typeChooseButton in typeChooseButtons {
            typeChooseButton.removeFromSuperview()
        }
        
        self.nameButton.removeFromSuperview()
        self.valueButton.removeFromSuperview()
        self.initButton.removeFromSuperview()
        self.appendButton.removeFromSuperview()
        self.conditionButton.removeFromSuperview()
        self.variableButton.removeFromSuperview()
        self.listButton.removeFromSuperview()
        self.cantEditLabel.removeFromSuperview()
        
        NotificationCenter.default.post(name: .deleteElement, object: nil)
    }
    
    @IBAction func bodyBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.choosenChange(self.index)
    }
    @IBAction func addAboveBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addAboveFunc(self.index)
    }
    @IBAction func addBelowBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.addBelowFunc(self.index, self.indent)
    }
    
    @IBAction func forVariableBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.changeState(state: 1)
    }
    
    @IBAction func forListBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.changeState(state: 2)
        for typeChooseButton in typeChooseButtons {
            typeChooseButton.backgroundColor = myGreen
        }
    }
    
    @IBAction func forConditionalBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.changeState(state: 3)
        if self.pushedAtFirst {
            self.pushedAtFirst = false
            self.addBelowFunc(self.index, self.indent + 1)
        }
    }
    @IBAction func forPathBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.changeState(state: 4)
        //経路設定ビューを作成して表示
        NotificationCenter.default.post(name: .showPathEditor, object: nil)
    }
    @IBAction func forPrintBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.changeState(state: 5)
        
        for typeChooseButton in typeChooseButtons {
            typeChooseButton.backgroundColor = UIColor.brown
        }
        
        self.forText.center.x = self.editView.frame.width * 3 / 4
        self.forText.center.y = self.editView.frame.height * 7 / 10
        self.forText.setTitle(NSLocalizedString("Input text", comment: ""), for: UIControl.State.normal)
        self.forText.addTarget(self, action: #selector(self.forTextBtnAction(_:)), for: UIControl.Event.touchUpInside)
        self.forText.layer.cornerRadius = 10
        self.forText.backgroundColor = UIColor.brown
        self.editView.addSubview(forText)
        
        typeChooseButtons.append(forText)
    }
    
    @IBAction func forBoolBtnAction(_ sender: Any)   {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 0)
    }
    @IBAction func forIntBtnAction(_ sender: Any)    {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 1)
    }
    @IBAction func forFloatBtnAction(_ sender: Any)  { 
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 2)
    }
    @IBAction func forTankBtnAction(_ sender: Any)   {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 3)
    }
    @IBAction func forBulletBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 4)
    }
    @IBAction func forTextBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 5)
        NotificationCenter.default.post(name: .addBtnForTextPrint, object: nil)
    }
    
    @IBAction func forIfBtnAction(_ sender: Any)    {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 5)
    }
    @IBAction func forForBtnAction(_ sender: Any)   {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 6)
    }
    @IBAction func forWhileBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.decideType(type: 7)
    }
    
    @IBAction func nameBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.nameButton.isHidden = true
        self.valueButton.isHidden = true
        self.initButton.isHidden = true
        self.appendButton.isHidden = true
        self.conditionButton.isHidden = true
        self.listButton.isHidden = true
        
        //Bool型変数
        if self.state == 1 && self.elementType == 0 {
            NotificationCenter.default.post(name: .addBtnForBoolVariable, object: nil)
        }
        //Int型変数
        if self.state == 1 && self.elementType == 1 {
            NotificationCenter.default.post(name: .addBtnForIntVariable, object: nil)
        }
        //Float型変数
        if self.state == 1 && self.elementType == 2 {
            NotificationCenter.default.post(name: .addBtnForFloatVariable, object: nil)
        }
        //Tank型変数
        if self.state == 1 && self.elementType == 3 {
            NotificationCenter.default.post(name: .addBtnForTankVariable, object: nil)
        }
        //Bullet型変数
        if self.state == 1 && self.elementType == 4 {
            NotificationCenter.default.post(name: .addBtnForBulletVariable, object: nil)
        }
        
        //Bool型リスト
        if self.state == 2 && self.elementType == 0 {
            NotificationCenter.default.post(name: .addBtnForBoolList, object: nil)
        }
        //Int型リスト
        if self.state == 2 && self.elementType == 1 {
            NotificationCenter.default.post(name: .addBtnForIntList, object: nil)
        }
        //Float型リスト
        if self.state == 2 && self.elementType == 2 {
            NotificationCenter.default.post(name: .addBtnForFloatList, object: nil)
        }
        //Tank型リスト
        if self.state == 2 && self.elementType == 3 {
            NotificationCenter.default.post(name: .addBtnForTankList, object: nil)
        }
        //Bullet型リスト
        if self.state == 2 && self.elementType == 4 {
            NotificationCenter.default.post(name: .addBtnForBulletList, object: nil)
        }
        
        //Bool型プリント
        if self.state == 5 && self.elementType == 0 {
            NotificationCenter.default.post(name: .addBtnForBoolPrint, object: nil)
        }
        //Int型プリント
        if self.state == 5 && self.elementType == 1 {
            NotificationCenter.default.post(name: .addBtnForIntPrint, object: nil)
        }
        //Float型プリント
        if self.state == 5 && self.elementType == 2 {
            NotificationCenter.default.post(name: .addBtnForFloatPrint, object: nil)
        }
        //Tank型プリント
        if self.state == 5 && self.elementType == 3 {
            NotificationCenter.default.post(name: .addBtnForTankPrint, object: nil)
        }
        //Bullet型プリント
        if self.state == 5 && self.elementType == 4 {
            NotificationCenter.default.post(name: .addBtnForBulletPrint, object: nil)
        }
        //テキストプリント
        if self.state == 5 && self.elementType == 5 {
            NotificationCenter.default.post(name: .addBtnForTextPrint, object: nil)
        }
    }
    
    @IBAction func initBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.values = "new"
        self.text = NSLocalizedString("Initialize", comment: "")
        self.listLabel.state = 2
        self.valueChanged()
    }
    
    @IBAction func appendBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.nameButton.isHidden = true
        self.initButton.isHidden = true
        self.appendButton.isHidden = true
        //Bool型リスト
        if self.state == 2 && self.elementType == 0 {
            NotificationCenter.default.post(name: .addBtnForBoolAppend, object: nil)
        }
        //Int型リスト
        if self.state == 2 && self.elementType == 1 {
            NotificationCenter.default.post(name: .addBtnForIntAppend, object: nil)
        }
        //Float型リスト
        if self.state == 2 && self.elementType == 2 {
            NotificationCenter.default.post(name: .addBtnForFloatAppend, object: nil)
        }
        //Tank型リスト
        if self.state == 2 && self.elementType == 3 {
            NotificationCenter.default.post(name: .addBtnForTankAppend, object: nil)
        }
        //Bullet型リスト
        if self.state == 2 && self.elementType == 4 {
            NotificationCenter.default.post(name: .addBtnForBulletAppend, object: nil)
        }
    }
    
    @IBAction func valueBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        //Bool型変数
        if self.state == 1 && self.elementType == 0 {
            NotificationCenter.default.post(name: .addViewForBoolVariable, object: nil)
        }
        //Int型変数
        if self.state == 1 && self.elementType == 1 {
            NotificationCenter.default.post(name: .addViewForIntVariable, object: nil)
        }
        //Float型変数
        if self.state == 1 && self.elementType == 2 {
            NotificationCenter.default.post(name: .addViewForFloatVariable, object: nil)
        }
        //Tank型変数
        if self.state == 1 && self.elementType == 3 {
            NotificationCenter.default.post(name: .addViewForTankVariable, object: nil)
        }
        //Bullet型変数
        if self.state == 1 && self.elementType == 4 {
            NotificationCenter.default.post(name: .addViewForBulletVariable, object: nil)
        }
    }
    
    @IBAction func conditionBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        NotificationCenter.default.post(name: .addViewForBoolVariable, object: nil)
        for chooseButton in chooseButtons {
            chooseButton.isHidden = true
        }
    }
    
    @IBAction func variableBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        NotificationCenter.default.post(name: .variableForRepetition, object: nil)
        for chooseButton in chooseButtons {
            chooseButton.isHidden = true
        }
    }
    
    @IBAction func listBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        NotificationCenter.default.post(name: .listForRepetition, object: nil)
        self.variableButton.isHidden = true
        self.listButton.isHidden = true
        for chooseButton in chooseButtons {
            chooseButton.isHidden = true
        }
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        self.deleteSelf()
        self.deleteFunc(self.index)
    }
}
