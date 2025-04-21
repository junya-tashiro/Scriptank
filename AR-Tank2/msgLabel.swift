//
//  msgLabel.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/31.
//

import Foundation

class VariableLabel {
    var type: String = NSLocalizedString("Type", comment: "")
    var name: String = NSLocalizedString("Name", comment: "")
    var value: String = NSLocalizedString("Value", comment: "")
    
    func makeLabelMsg() -> String {
        return "  " + self.type + " : " + self.name + " = " + self.value + "  "
    }
}

class ListLabel {
    var type: String = NSLocalizedString("Type", comment: "")
    var name: String = NSLocalizedString("Name", comment: "")
    var operation: String = NSLocalizedString("Order", comment: "")
    var state: Int = 0
    
    func makeLabelMsg() -> String {
        let language = Locale.preferredLanguages.first?.prefix(2)
        if self.state == 1 {
            if language == "ja" {
                return "  " + self.type + " : " + self.name + " の末尾に " + self.operation + "  "
            }
            else if language == "zh" {
                return "  " + self.type + " : 在" + self.name + " 的末尾" + self.operation + "  "
            }
            else {
                return "  " + self.type + " : " + self.operation + " to the end of " + self.name + "  "
            }
        }
        else if self.state == 2 {
            if language == "ja" {
                return "  " + self.type + " : " + self.name + " を" + self.operation + "  "
            }
            else if language == "zh" {
                return "  " + self.type + " : " + self.operation + " " + self.name + "  "
            }
            else {
                return "  " + self.type + " : " + self.operation + " " + self.name + "  "
            }
        }
        else {
            return "  " + self.type + " : " + self.name + " : " + self.operation + "  "
        }
    }
}

class ConditionalLabel {
    var type: String = NSLocalizedString("Type", comment: "")
    var condition: String = NSLocalizedString("Condition", comment: "")
    var variable: String = NSLocalizedString("VarName", comment: "")
    var listType: String = ""
    var list: String = NSLocalizedString("ListName", comment: "")
    var state: Int = 0
    
    func makeLabelMsg() -> String {
        //for
        if self.state == 1 {
            return "  " + self.type + " " + self.variable + " in " + self.listType + " " + self.list + "  "
        }
        //if, while
        else {
            return "  " + self.type + " " + self.condition + "  "
        }
    }
}

class PrintLabel {
    var type: String = NSLocalizedString("Type", comment: "")
    var value: String = NSLocalizedString("Value", comment: "")
    
    func makeLabelMsg() -> String {
        return NSLocalizedString("  Print ", comment: "") + self.type + " : " +  self.value + "  "
    }
}
