//
//  Notification.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/15.
//

import Foundation

extension Notification.Name {
    static let canNotConnect           = Notification.Name("canNotConnect")
    static let advertiserDisappeared   = Notification.Name("advertiserDisappeared")
    
    static let finishBattle            = Notification.Name("finishBattle")
    
    static let addBtnForBoolVariable   = Notification.Name("addBtnForBoolVariable")
    static let addBtnForIntVariable    = Notification.Name("addBtnForIntVariable")
    static let addBtnForFloatVariable  = Notification.Name("addBtnForFloatVariable")
    static let addBtnForTankVariable   = Notification.Name("addBtnForTankVariable")
    static let addBtnForBulletVariable = Notification.Name("addBtnForBulletVariable")
    
    static let addBtnForBoolList        = Notification.Name("addBtnForBoolList")
    static let addBtnForIntList         = Notification.Name("addBtnForIntList")
    static let addBtnForFloatList       = Notification.Name("addBtnForFloatList")
    static let addBtnForTankList        = Notification.Name("addBtnForTankList")
    static let addBtnForBulletList      = Notification.Name("addBtnForBulletList")
    
    static let addBtnForBoolAppend      = Notification.Name("addBtnForBoolAppend")
    static let addBtnForIntAppend       = Notification.Name("addBtnForIntAppend")
    static let addBtnForFloatAppend     = Notification.Name("addBtnForFloatAppend")
    static let addBtnForTankAppend      = Notification.Name("addBtnForTankAppend")
    static let addBtnForBulletAppend    = Notification.Name("addBtnForBulletAppend")
    
    static let addBtnForBoolPrint       = Notification.Name("addBtnForBoolPrint")
    static let addBtnForIntPrint        = Notification.Name("addBtnForIntPrint")
    static let addBtnForFloatPrint      = Notification.Name("addBtnForFloatPrint")
    static let addBtnForTankPrint       = Notification.Name("addBtnForTankPrint")
    static let addBtnForBulletPrint     = Notification.Name("addBtnForBulletPrint")
    static let addBtnForTextPrint       = Notification.Name("addBtnForTextPrint")
    
    static let addViewForBoolVariable   = Notification.Name("addViewForBoolVariable")
    static let addViewForIntVariable    = Notification.Name("addViewForIntVariable")
    static let addViewForFloatVariable  = Notification.Name("addViewForFloatVariable")
    static let addViewForTankVariable   = Notification.Name("addViewForTankVariable")
    static let addViewForBulletVariable = Notification.Name("addViewForBulletVariable")
     
    static let variableForRepetition    = Notification.Name("variableForRepetition")
    static let listForRepetition        = Notification.Name("listForRepetition")
    
    static let deleteElement            = Notification.Name("deleteElement")
    
    static let saveValue                = Notification.Name("saveValue")
    
    static let fromEditToBattle         = Notification.Name("fromEditToBattle")
    
    static let showPathEditor           = Notification.Name("showPathEditor")
    static let deletePathEditor         = Notification.Name("deletePathEditor")
}
