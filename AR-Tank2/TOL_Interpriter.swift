//
//  TOL_Interpriter.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/22.
//

import Foundation
import SceneKit
import ARKit
import MultipeerConnectivity

extension BattleViewController {
    func devideCmd(str: String) -> [String] {
        var e = ""
        var cmd: [String] = []
        var num: Int = 0

        for c in str {
            if c == "(" {
                num += 1
            }
            else if c == ")" {
                num -= 1
            }
            if c == " " && num == 0 {
                cmd.append(e)
                e = ""
            }
            else {
                if (num == 1 && c == "(") || (num == 0 && c == ")") {
                    
                }
                else {
                    e.append(c)
                }
            }
        }
        if e != "" {
            cmd.append(e)
        }
        return cmd
    }

    func calcBool(ID: String, cmd: [String], n: Int) -> Bool {
        let element = cpuMember[ID]
        var stack: [Bool] = []
        for n in 0 ..< cmd.count {
            let c = devideCmd(str: cmd[n])
            if c.count == 1 {
                //and, or
                if cmd[n] == "&&" || cmd[n] == "||"  {
                    if stack.count >= 2 {
                        let a = stack[stack.count - 2]
                        let b = stack[stack.count - 1]
                        stack.removeLast(2)
                        if cmd[n] == "&&" {
                            stack.append(a && b)
                        }
                        else if cmd[n] == "||" {
                            stack.append(a || b)
                        }
                    }
                    else {
                        addError(n: n, txt: "Incorrect [Bool] formula")
                    }
                }
                //not
                else if cmd[n] == "!" {
                    if stack.count >= 1 {
                        stack[stack.count - 1] = !stack[stack.count - 1]
                    }
                    else {
                        addError(n: n, txt: "Incorrect [Bool] formula")
                    }
                }
                else {
                    let e = cmd[n].components(separatedBy: ":")
                    if e.count == 2 {
                        //Boolリストより
                        if element!.listBool.keys.contains(e[0]) {
                            if let num = Int(e[1]) {
                                if element!.listBool[e[0]]!.count > num {
                                    stack.append(element!.listBool[e[0]]![Int(e[1])!])
                                }
                                else {
                                    addError(n: n, txt: "Index exceeds list size")
                                }
                            }
                            else {
                                addError(n: n, txt: "Index must be an integer value greater than or equal to 0")
                            }
                        }
                        else {
                            addError(n: n, txt: "Non-existent [Bool] list")
                        }
                    }
                    else {
                        //宣言済み変数より
                        if element!.variableBool.keys.contains(cmd[n]) {
                            stack.append(element!.variableBool[cmd[n]]!)
                        }
                        //直接代入
                        else {
                            if cmd[n] == "t" {
                                stack.append(true)
                            }
                            else if cmd[n] == "f" {
                                stack.append(false)
                            }
                            else {
                                addError(n: n, txt: "Incorrect [Bool] formula")
                            }
                        }
                    }
                }
            }
            else if c.count == 4 {
                if c[0] == "Int" {
                    let a = calcInt(ID: ID, cmd: devideCmd(str: c[1]), n: n)
                    let b = calcInt(ID: ID, cmd: devideCmd(str: c[2]), n: n)
                    if c[3] == "==" { if a == b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == "!=" { if a != b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == ">" { if a > b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == "<" { if a < b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == ">=" { if a >= b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == "<=" { if a <= b { stack.append(true) } else { stack.append(false) } }
                }
                else if c[0] == "Float" {
                    let a = calcFloat(ID: ID, cmd: devideCmd(str: c[1]), n: n)
                    let b = calcFloat(ID: ID, cmd: devideCmd(str: c[2]), n: n)
                    if c[3] == "==" { if a == b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == "!=" { if a != b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == ">" { if a > b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == "<" { if a < b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == ">=" { if a >= b { stack.append(true) } else { stack.append(false) } }
                    else if c[3] == "<=" { if a <= b { stack.append(true) } else { stack.append(false) } }
                }
            }
            else {
                addError(n: n, txt: "Incorrect [Bool] formula")
            }
        }
        if stack.count == 0 {
            addError(n: n, txt: "[Bool] formula not entered")
            return true
        }
        else if stack.count > 1 {
            addError(n: n, txt: "Incorrect [Bool] formula")
            return stack[0]
        }
        else {
            return stack[0]
        }
    }

    func calcInt(ID: String, cmd: [String], n: Int) -> Int {
        let element = cpuMember[ID]
        var stack: [Int] = []
        for n in 0 ..< cmd.count {
            //+, -, *, /, %
            if cmd[n] == "+" || cmd[n] == "-" || cmd[n] == "*" || cmd[n] == "/" || cmd[n] == "%" {
                if cmd[n] == "-" && stack.count == 0 {
                    stack[0] = -1 * stack[0]
                }
                else {
                    if stack.count >= 2 {
                        let a = stack[stack.count - 2]
                        let b = stack[stack.count - 1]
                        stack.removeLast(2)
                        if cmd[n] == "+" {
                            stack.append(a + b)
                        }
                        else if cmd[n] == "-" {
                            stack.append(a - b)
                        }
                        else if cmd[n] == "*" {
                            stack.append(a * b)
                        }
                        else if cmd[n] == "/" {
                            stack.append(a / b)
                        }
                        else if cmd[n] == "%" {
                            stack.append(a % b)
                        }
                    }
                    else {
                        addError(n: n, txt: "Incorrect [Int] formula")
                    }
                }
            }
            else {
                let e = cmd[n].components(separatedBy: ":")
                if e.count == 2 {
                    //リスト長さ
                    if e[1] == "len" {
                        if element!.listBool.keys.contains(e[0]) {
                            stack.append(element!.listBool[e[0]]!.count)
                        }
                        else if element!.listInt.keys.contains(e[0]) {
                            stack.append(element!.listInt[e[0]]!.count)
                        }
                        else if element!.listFloat.keys.contains(e[0]) {
                            stack.append(element!.listFloat[e[0]]!.count)
                        }
                        else if element!.listTank.keys.contains(e[0]) {
                            stack.append(element!.listTank[e[0]]!.count)
                        }
                        else if element!.listBullet.keys.contains(e[0]) {
                            stack.append(element!.listBullet[e[0]]!.count)
                        }
                        else {
                            addError(n: n, txt: "Non-existent list")
                        }
                    }
                    //Intリストより
                    else if element!.listInt.keys.contains(e[0]) {
                        if let num = Int(e[1]) {
                            if element!.listInt[e[0]]!.count > num {
                                stack.append(element!.listInt[e[0]]![Int(e[1])!])
                            }
                            else {
                                addError(n: n, txt: "Index exceeds list size")
                            }
                        }
                        else {
                            addError(n: n, txt: "Index must be an integer value greater than or equal to 0")
                        }
                    }
                }
                else {
                    //宣言済み変数より
                    if element!.variableInt.keys.contains(cmd[n]) {
                        stack.append(element!.variableInt[cmd[n]]!)
                    }
                    //直接代入
                    else {
                        if let num = Int(cmd[n]) {
                            stack.append(num)
                        }
                        else {
                            addError(n: n, txt: "Incorrect [Int] formula")
                        }
                    }
                }
            }
        }
        if stack.count == 0 {
            addError(n: n, txt: "Incorrect [Int] formula")
            return 0
        }
        else if stack.count > 1 {
            addError(n: n, txt: "Incorrect [Int] formula")
            return stack[0]
        }
        else {
            return stack[0]
        }
    }

    func calcFloat(ID: String, cmd: [String], n: Int) -> Float {
        let element = cpuMember[ID]
        var stack: [Float] = []
        for n in 0 ..< cmd.count {
            //+, -, *, /
            if cmd[n] == "+" || cmd[n] == "-" || cmd[n] == "*" || cmd[n] == "/" {
                if cmd[n] == "-" && stack.count == 1 {
                    stack[0] = -1.0 * stack[0]
                }
                else {
                    if stack.count >= 2 {
                        let a = stack[stack.count - 2]
                        let b = stack[stack.count - 1]
                        stack.removeLast(2)
                        if cmd[n] == "+" {
                            stack.append(a + b)
                        }
                        else if cmd[n] == "-" {
                            stack.append(a - b)
                        }
                        else if cmd[n] == "*" {
                            stack.append(a * b)
                        }
                        else if cmd[n] == "/" {
                            stack.append(a / b)
                        }
                    }
                    else {
                        addError(n: n, txt: "Incorrect [Float] formula")
                    }
                }
            }
            //sin, cos, sqrt, abs
            else if cmd[n] == "sin" {
                stack[stack.count - 1] = sin(stack[stack.count - 1])
            }
            else if cmd[n] == "cos" {
                stack[stack.count - 1] = cos(stack[stack.count - 1])
            }
            else if cmd[n] == "sqrt" {
                stack[stack.count - 1] = sqrt(stack[stack.count - 1])
            }
            else if cmd[n] == "abs" {
                stack[stack.count - 1] = abs(stack[stack.count - 1])
            }
            else {
                let e = cmd[n].components(separatedBy: ":")
                if e.count == 2 {
                    //Tank型変数の要素
                    if element!.variableTank.keys.contains(e[0]) {
                        if e[1] == "x" {
                            stack.append(element!.variableTank[e[0]]!.x)
                        }
                        else if e[1] == "y" {
                            stack.append(element!.variableTank[e[0]]!.y)
                        }
                        else {
                            addError(n: n, txt: "Non-existent [Float] variable")
                        }
                    }
                    //Bullet型変数の要素
                    else if element!.variableBullet.keys.contains(e[0]) {
                        if e[1] == "x" {
                            stack.append(element!.variableBullet[e[0]]!.x)
                        }
                        else if e[1] == "y" {
                            stack.append(element!.variableBullet[e[0]]!.y)
                        }
                        else if e[1] == "theta" {
                            stack.append(element!.variableBullet[e[0]]!.theta)
                        }
                        else {
                            addError(n: n, txt: "Non-existent [Float] variable")
                        }
                    }
                    //Floatリストより
                    else if element!.listFloat.keys.contains(e[0]) {
                        if let num = Int(e[1]) {
                            if element!.listFloat[e[0]]!.count > num {
                                stack.append(element!.listFloat[e[0]]![num])
                            }
                            else {
                                addError(n: n, txt: "Index exceeds list size")
                            }
                        }
                        else {
                            addError(n: n, txt: "Index must be an integer value greater than or equal to 0")
                        }
                    }
                }
                else {
                    //宣言済み変数より
                    if element!.variableFloat.keys.contains(cmd[n]) {
                        stack.append(element!.variableFloat[cmd[n]]!)
                    }
                    //直接代入
                    else {
                        if let num = Float(cmd[n]) {
                            stack.append(num)
                        }
                        else {
                            addError(n: n, txt: "Incorrect [Float] formula")
                        }
                    }
                }
            }
        }
        if stack.count == 0 {
            addError(n: n, txt: "Incorrect [Float] formula")
            return 0.0
        }
        else if stack.count > 1 {
            addError(n: n, txt: "Incorrect [Float] formula")
            return stack[0]
        }
        else {
            return stack[0]
        }
    }

    func calcTank(ID: String, cmd: [String], n: Int) -> (x: Float, y: Float) {
        let element = cpuMember[ID]
        let e = cmd[0].components(separatedBy: ":")
        if e.count == 2 {
            //Tankリストより
            if element!.listTank.keys.contains(e[0]) {
                if let num = Int(e[1]) {
                    if element!.listTank[e[0]]!.count > num {
                        return element!.listTank[e[0]]![Int(e[1])!]
                    }
                    else {
                        addError(n: n, txt: "Index exceeds list size")
                    }
                }
                else {
                    addError(n: n, txt: "Index must be an integer value greater than or equal to 0")
                }
            }
        }
        else {
            //宣言済み変数より
            if element!.variableTank.keys.contains(cmd[0]) {
                return element!.variableTank[cmd[0]]!
            }
            //直接代入
            else {
                if cmd.count == 2 {
                    if let num1 = Float(cmd[0]) {
                        if let num2 = Float(cmd[1]) {
                            return (x: num1, y: num2)
                        }
                        else {
                            addError(n: n, txt: "Argument type must be [Float]")
                        }
                    }
                    else {
                        addError(n: n, txt: "Argument type must be [Float]")

                    }
                }
                else {
                    addError(n: n, txt: "Incorrect number of arguments")
                }
            }
        }
        return (x: 0.0, y: 0.0)
    }

    func calcBullet(ID: String, cmd: [String], n: Int) -> (x: Float, y: Float, theta: Float) {
        let element = cpuMember[ID]
        let e = cmd[0].components(separatedBy: ":")
        if e.count == 2 {
            //Bulletリストより
            if element!.listBullet.keys.contains(e[0]) {
                if let num = Int(e[0]) {
                    if element!.listBullet[e[0]]!.count > num {
                        return element!.listBullet[e[0]]![num]
                    }
                    else {
                        addError(n: n, txt: "Index exceeds list size")
                    }
                }
                else {
                    addError(n: n, txt: "Index must be an integer value greater than or equal to 0")
                }
            }
        }
        else {
            //宣言済み変数より
            if element!.variableBullet.keys.contains(cmd[0]) {
                return element!.variableBullet[cmd[0]]!
            }
            //直接代入
            else {
                if cmd.count == 2 {
                    if let num1 = Float(cmd[0]) {
                        if let num2 = Float(cmd[1]) {
                            if let num3 = Float(cmd[2]) {
                                return (x: num1, y: num2, theta: num3)
                            }
                            else {
                                addError(n: n, txt: "Argument type must be [Float]")
                            }
                        }
                        else {
                            addError(n: n, txt: "Argument type must be [Float]")
                        }
                    }
                    else {
                        addError(n: n, txt: "Argument type must be [Float]")
                    }
                }
                else {
                    addError(n: n, txt: "Incorrect number of arguments")
                }
            }
        }
        return (x: 0.0, y: 0.0, theta: 0.0)
    }

    func readFrom(ID: String, n: Int, indent: Int) {
        var element = cpuMember[ID]
        for i in n ..< element!.commands.count {
            if element!.commands[i].0 == indent - 1 {
                return
            }
            else if element!.commands[i].0 == indent {
                let cmd = devideCmd(str: element!.commands[i].1)
                if cmd.count == 0 {
                    return
                }
                if cmd.count >= 3 {
                    //Bool型変数の宣言, 更新
                    if cmd[0] == "Bool" {
                        element!.variableBool[cmd[1]] = calcBool(ID: ID, cmd: Array(cmd[2 ..< cmd.count]), n: n)
                        cpuMember[ID] = element
                    }
                    //Int型変数の宣言, 更新
                    else if cmd[0] == "Int" {
                        element!.variableInt[cmd[1]] = calcInt(ID: ID, cmd: Array(cmd[2 ..< cmd.count]), n: n)
                        cpuMember[ID] = element
                    }
                    //Float型変数の宣言, 更新
                    else if cmd[0] == "Float" {
                        element!.variableFloat[cmd[1]] = calcFloat(ID: ID, cmd: Array(cmd[2 ..< cmd.count]), n: n)
                        cpuMember[ID] = element
                    }
                    //Tank型変数の宣言, 更新
                    else if cmd[0] == "Tank" {
                        element!.variableTank[cmd[1]] = calcTank(ID: ID, cmd: Array(cmd[2 ..< cmd.count]), n: n)
                        cpuMember[ID] = element
                    }
                    //Bullet型変数の宣言, 更新
                    else if cmd[0] == "Bullet" {
                        element!.variableBullet[cmd[1]] = calcBullet(ID: ID, cmd: Array(cmd[2 ..< cmd.count]), n: n)
                        cpuMember[ID] = element
                    }
                    //Bool型リストの宣言, 更新
                    else if cmd[0] == "lBool" {
                        if cmd[2] == "new" {
                            element!.listBool[cmd[1]] = []
                            cpuMember[ID] = element
                        }
                        else if cmd[2] == "append" {
                            if element!.listBool.keys.contains(cmd[1]) {
                                if cmd.count >= 4 {
                                    element!.listBool[cmd[1]]!.append(calcBool(ID: ID, cmd: Array(cmd[3 ..< cmd.count]), n: n))
                                    cpuMember[ID] = element
                                }
                                else {
                                    addError(n: n, txt: "Incorrect number of arguments")
                                }
                            }
                            else {
                                addError(n: n, txt: "Non-existent list")
                            }
                        }
                    }
                    //Int型リストの宣言, 更新
                    else if cmd[0] == "lInt" {
                        if cmd[2] == "new" {
                            element!.listInt[cmd[1]] = []
                            cpuMember[ID] = element
                        }
                        else if cmd[2] == "append" {
                            if element!.listInt.keys.contains(cmd[1]) {
                                if cmd.count >= 4 {
                                    element!.listInt[cmd[1]]!.append(calcInt(ID: ID, cmd: Array(cmd[3 ..< cmd.count]), n: n))
                                    cpuMember[ID] = element
                                }
                                else {
                                    addError(n: n, txt: "Incorrect number of arguments")
                                }
                            }
                            else {
                                addError(n: n, txt: "Non-existent list")
                            }
                        }
                    }
                    //Float型リストの宣言, 更新
                    else if cmd[0] == "lFloat" {
                        if cmd[2] == "new" {
                            element!.listFloat[cmd[1]] = []
                            cpuMember[ID] = element
                        }
                        else if cmd[2] == "append" {
                            if element!.listFloat.keys.contains(cmd[1]) {
                                if cmd.count >= 4 {
                                    element!.listFloat[cmd[1]]!.append(calcFloat(ID: ID, cmd: Array(cmd[3 ..< cmd.count]), n: n))
                                    cpuMember[ID] = element
                                }
                                else {
                                    addError(n: n, txt: "Incorrect number of arguments")
                                }
                            }
                            else {
                                addError(n: n, txt: "Non-existent list")
                            }
                        }
                    }
                    //Tank型リストの宣言, 更新
                    else if cmd[0] == "lTank" {
                        if cmd[2] == "new" {
                            element!.listTank[cmd[1]] = []
                            cpuMember[ID] = element
                        }
                        else if cmd[2] == "append" {
                            if element!.listTank.keys.contains(cmd[1]) {
                                if cmd.count >= 4 {
                                    element!.listTank[cmd[1]]!.append(element!.variableTank[cmd[3]]!)
                                    cpuMember[ID] = element
                                }
                                else {
                                    addError(n: n, txt: "Incorrect number of arguments")
                                }
                            }
                            else {
                                addError(n: n, txt: "Non-existent list")
                            }
                        }
                    }
                    //Bullet型リストの宣言, 更新
                    else if cmd[0] == "lBullet" {
                        if cmd[2] == "new" {
                            element!.listBullet[cmd[1]] = []
                            cpuMember[ID] = element
                        }
                        else if cmd[2] == "append" {
                            if element!.listBullet.keys.contains(cmd[1]) {
                                if cmd.count >= 4 {
                                    element!.listBullet[cmd[1]]!.append(element!.variableBullet[cmd[3]]!)
                                    cpuMember[ID] = element
                                }
                                else {
                                    addError(n: n, txt: "Incorrect number of arguments")
                                }
                            }
                            else {
                                addError(n: n, txt: "Non-existent list")
                            }
                        }
                    }
                }                
                //if文
                if cmd[0] == "if" {
                    if cmd.count >= 2 {
                        if calcBool(ID: ID, cmd: Array(cmd[1 ..< cmd.count]), n: n) {
                            cpuMember[ID] = element
                            readFrom(ID: ID, n: i + 1, indent: indent + 1)
                            element = cpuMember[ID]
                        }
                    }
                    else {
                        addError(n: n, txt: "Incorrect number of arguments")
                    }
                }
                
                //while文
                else if cmd[0] == "while" {
                    if cmd.count >= 2 {
                        while calcBool(ID: ID, cmd: Array(cmd[1 ..< cmd.count]), n: n) {
                            cpuMember[ID] = element
                            readFrom(ID: ID, n: i + 1, indent: indent + 1)
                            element = cpuMember[ID]
                        }
                    }
                    else {
                        addError(n: n, txt: "Incorrect number of arguments")
                    }
                }
                
                //for文
                else if cmd[0] == "for" {
                    if cmd.count >= 5 {
                        if cmd[3] == "lBool" && element!.listBool.keys.contains(cmd[4]) {
                            for idx in 0 ..< (element!.listBool[cmd[4]]?.count)! {
                                element!.variableBool[cmd[1]] = element!.listBool[cmd[4]]![idx]
                                cpuMember[ID] = element
                                readFrom(ID: ID, n: i + 1, indent: indent + 1)
                                element = cpuMember[ID]
                            }
                        }
                        else if cmd[3] == "lInt" && element!.listInt.keys.contains(cmd[4]) {
                            for idx in 0 ..< (element!.listInt[cmd[4]]?.count)! {
                                element!.variableInt[cmd[1]] = element!.listInt[cmd[4]]![idx]
                                cpuMember[ID] = element
                                readFrom(ID: ID, n: i + 1, indent: indent + 1)
                                element = cpuMember[ID]
                            }
                        }
                        else if cmd[3] == "lFloat" && element!.listFloat.keys.contains(cmd[4]) {
                            for idx in 0 ..< (element!.listFloat[cmd[4]]?.count)! {
                                element!.variableFloat[cmd[1]] = element!.listFloat[cmd[4]]![idx]
                                cpuMember[ID] = element
                                readFrom(ID: ID, n: i + 1, indent: indent + 1)
                                element = cpuMember[ID]
                            }
                        }
                        else if cmd[3] == "lTank" && element!.listTank.keys.contains(cmd[4]) {
                            for idx in 0 ..< (element!.listTank[cmd[4]]?.count)! {
                                element!.variableTank[cmd[1]] = element!.listTank[cmd[4]]![idx]
                                cpuMember[ID] = element
                                readFrom(ID: ID, n: i + 1, indent: indent + 1)
                                element = cpuMember[ID]
                            }
                        }
                        else if cmd[3] == "lBullet" && element!.listBullet.keys.contains(cmd[4]) {
                            for idx in 0 ..< (element!.listBullet[cmd[4]]?.count)! {
                                element!.variableBullet[cmd[1]] = element!.listBullet[cmd[4]]![idx]
                                cpuMember[ID] = element
                                readFrom(ID: ID, n: i + 1, indent: indent + 1)
                                element = cpuMember[ID]
                            }
                        }
                        else {
                            addError(n: n, txt: "Incorrect [For] statement format of non-existent list")
                        }
                    }
                    else {
                        addError(n: n, txt: "Incorrect number of arguments")
                    }
                }
                
                //経路生成
                else if cmd[0] == "path" {
                    if cmd.count >= 2 {
                        element?.path = cmd[1]
                        cpuMember[ID] = element
                    }
                    else {
                        addError(n: n, txt: "Incorrect number of arguments")
                    }
                }
                
                //print文
                else if cmd[0] == "print" {
                    if cmd.count >= 2 {
                        if cmd[1] == "Bool" {
                            if element!.variableBool.keys.contains(cmd[2]) {
                                if element!.variableBool[cmd[2]]! {
                                    addToConsole(txt: "True")
                                }
                                else {
                                    addToConsole(txt: "False")
                                }
                            }
                            else {
                                addError(n: n, txt: "Non-existent [Bool] variable")
                            }
                        }
                        else if cmd[1] == "Int" {
                            if element!.variableInt.keys.contains(cmd[2]) {
                                addToConsole(txt: String(element!.variableInt[cmd[2]]!))
                            }
                            else {
                                addError(n: n, txt: "Non-existent [Int] variable")
                            }
                        }
                        else if cmd[1] == "Float" {
                            if element!.variableFloat.keys.contains(cmd[2]) {
                                var max: Int = 4
                                if element!.variableFloat[cmd[2]]! < 0.0 { max = 5 }
                                var v = String(element!.variableFloat[cmd[2]]!)
                                if v.count > max { v = String(v.prefix(max)) }
                                addToConsole(txt: v)
                            }
                            else {
                                addError(n: n, txt: "Non-existent [Float] variable")
                            }
                        }
                        else if cmd[1] == "Tank" {
                            if element!.variableTank.keys.contains(cmd[2]) {
                                var maxx: Int = 4
                                var maxy: Int = 4
                                if element!.variableTank[cmd[2]]!.x < 0.0 { maxx = 5 }
                                if element!.variableTank[cmd[2]]!.y < 0.0 { maxy = 5 }
                                var x = String(element!.variableTank[cmd[2]]!.x)
                                var y = String(element!.variableTank[cmd[2]]!.y)
                                if x.count > maxx { x = String(x.prefix(maxx)) }
                                if y.count > maxy { y = String(y.prefix(maxy)) }
                                let str = "x: " + x + ", y: " + y
                                addToConsole(txt: str)
                            }
                            else {
                                addError(n: n, txt: "Non-existent [Tank] variable")
                            }
                        }
                        else if cmd[1] == "Bullet" {
                            if element!.variableBullet.keys.contains(cmd[2]) {
                                var maxx: Int = 4
                                var maxy: Int = 4
                                var maxtheta: Int = 4
                                if element!.variableBullet[cmd[2]]!.x < 0.0     { maxx = 5 }
                                if element!.variableBullet[cmd[2]]!.y < 0.0     { maxy = 5 }
                                if element!.variableBullet[cmd[2]]!.theta < 0.0 { maxtheta = 5 }
                                var x     = String(element!.variableBullet[cmd[2]]!.x)
                                var y     = String(element!.variableBullet[cmd[2]]!.y)
                                var theta = String(element!.variableBullet[cmd[2]]!.theta)
                                if x.count > maxx         { x     = String(x.prefix(maxx)) }
                                if y.count > maxy         { y     = String(y.prefix(maxy)) }
                                if theta.count > maxtheta { theta = String(y.prefix(maxtheta)) }
                                let str = "x: " + x + ", y: " + y + ", θ: " + theta
                                addToConsole(txt: str)
                            }
                            else {
                                addError(n: n, txt: "Non-existent [Bullet] variable")
                            }
                        }
                        else if cmd.count == 2 {
                            addToConsole(txt: cmd[1])
                        }
                    }
                    else {
                        addError(n: n, txt: "Incorrect number of arguments")
                    }
                }
            }
            cpuMember[ID] = element
        }
    }
    
    
    func addError(n: Int, txt: String) {
        self.addToConsole(txt: "error in line " + String(n + 1) + ": " + NSLocalizedString(txt, comment: ""))
    }

    func Interpriter(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        
        let scale: Float = 0.05
        
        if counter == 0 {
            cpuMember[ID]?.variableFloat["ref_x"] = position.x / scale
            cpuMember[ID]?.variableFloat["ref_y"] = position.z / scale
        }
        
        //予約語
        cpuMember[ID]?.variableTank["self"] = (x: position.x / scale, y: position.z / scale)
        cpuMember[ID]?.variableInt["count"] = counter
        cpuMember[ID]?.variableBool["shoot"] = false
        
        var enemy: [(x: Float, y: Float)] = []
        var ally: [(x: Float, y: Float)] = []
        var buls: [(x: Float, y: Float, theta: Float)] = []
        for tank in self.tanks {
            if tank.teamID != teamID && tank.state {
                enemy.append((x: tank.position.x / scale, y: tank.position.z / scale))
            }
            else if tank.teamID == teamID && tank.state {
                ally.append((x: tank.position.x / scale, y: tank.position.z / scale))
            }
            if tank.ID != ID {
                for bullet in tank.bullets {
                    if bullet.state {
                        var a = -Float.pi / 2 - bullet.theta
                        if a > 2 * Float.pi {
                            a -= 2 * Float.pi
                        }
                        else if a < 0 {
                            a += 2 * Float.pi
                        }
                        buls.append((x: bullet.position.x / scale, y: bullet.position.z / scale, theta: a))
                    }
                }
            }
        }
        cpuMember[ID]?.listTank["enemys"] = enemy
        cpuMember[ID]?.listTank["allys"] = ally
        cpuMember[ID]?.listBullet["bullets"] = buls
        cpuMember[ID]?.path = ""
        
        readFrom(ID: ID, n: 0, indent: 0)
        
        let t = atan2((position.x / scale) - (cpuMember[ID]?.variableFloat["ref_x"])!, (position.z / scale) - (cpuMember[ID]?.variableFloat["ref_y"])!)
        let s = (cpuMember[ID]?.variableBool["shoot"])!
        let p = (cpuMember[ID]?.path)!
        
        return (t, s, p)
    }
}
