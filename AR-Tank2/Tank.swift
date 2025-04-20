//
//  Tank.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/11/28.
//

import Foundation
import SceneKit
import ARKit

//タンク
class Tank{
    var ID: String!
    var state: Bool = false
    var deleteFlag: Bool = false
    var canShootCount: Int = 0
    let node: SCNNode!
    var number: Int = 0
    let teamID: Int
    var legNode = SCNNode()                 //タンクの足
    var bodyNode = SCNNode()                //タンクの胴体
    var velocity: Float = 0.001
    var velocity_x: Float! = nil            //並進速度x
    var velocity_z: Float! = nil            //並進速度z
    var alpha: Float! = nil                 //足の向き
    var theta: Float! = nil                 //胴体の向き
    var position: SCNVector3!               //タンクの位置
    var bullets: [Bullet] = []              //弾丸配列
    
    var deltaAlpha: Float = 0.0
    var thetaRef: Float = 0.0
    
    var counter: Int = 0
    
    var shootFlag: Bool = false
    
    var autonomousBehavior: (String, Int, SCNVector3, Float, Int, String) -> (Float, Bool, String)
    var movePlans: [(x: Int, z: Int, pass: Bool)] = []
    var prePlans: String = ""
    
    init(ID: String!, teamID: Int, node: SCNNode!, position: SCNVector3!, autonomousBehavior: @escaping ((String, Int, SCNVector3, Float, Int, String) -> (Float, Bool, String))) {
        self.ID = ID
        self.teamID = teamID
        self.node = node
        self.position = position
        self.state = true
        self.velocity_x = 0.0
        self.velocity_z = 0.0
        self.alpha = 0.0
        self.theta = 0.0
        self.autonomousBehavior = autonomousBehavior
        
        if teamID == 1{
            guard let tankScene = SCNScene(named: "tank_red.scn") else {return}
            self.legNode = tankScene.rootNode.childNode(withName: "leg", recursively: true)!
            self.bodyNode = tankScene.rootNode.childNode(withName: "body", recursively: true)!
        }
        else {
            guard let tankScene = SCNScene(named: "tank_blue.scn") else {return}
            self.legNode = tankScene.rootNode.childNode(withName: "leg", recursively: true)!
            self.bodyNode = tankScene.rootNode.childNode(withName: "body", recursively: true)!
        }
        self.legNode.position = SCNVector3(position.x, 0, position.z)
        self.legNode.rotation = SCNVector4(0, 1, 0, self.alpha - Float.pi/2)
        self.node.addChildNode(self.legNode)
        self.bodyNode.position = SCNVector3(position.x, 0, position.z)
        self.bodyNode.rotation = SCNVector4(0, 1, 0, self.theta - Float.pi/2)
        self.node.addChildNode(self.bodyNode)
    }
    
    deinit {
        self.bullets = []
    }
    
    func getStringData() -> String!{
        if self.state {
            var str = "TANK/"
            str.append(self.ID)
            str.append(",")
            str.append(String(self.position.x))
            str.append(",")
            str.append(String(self.position.z))
            str.append(",")
            str.append(String(self.velocity_x))
            str.append(",")
            str.append(String(self.velocity_z))
            str.append(",")
            str.append(String(self.alpha))
            str.append(",")
            str.append(String(self.theta))
            str.append(",")
            str.append(String(self.teamID))
            for bullet in bullets {
                if bullet.state {
                    str.append("/")
                    str.append(String(bullet.number))
                    str.append(",")
                    str.append(String(bullet.position.x))
                    str.append(",")
                    str.append(String(bullet.position.z))
                    str.append(",")
                    str.append(String(bullet.theta))
                }
                else {
                    str.append("/")
                    str.append(String(bullet.number))
                    str.append(",deleted")
                }
            }
            return str
        }
        else if self.deleteFlag {
            var str = "TANK/"
            str.append(self.ID)
            str.append(",deleted")
            for bullet in bullets {
                if bullet.state {
                    str.append("/")
                    str.append(String(bullet.number))
                    str.append(",")
                    str.append(String(bullet.position.x))
                    str.append(",")
                    str.append(String(bullet.position.z))
                    str.append(",")
                    str.append(String(bullet.theta))
                }
                else {
                    str.append("/")
                    str.append(String(bullet.number))
                    str.append(",deleted")
                }
            }
            return str
        }
        return ""
    }
    
    //タンク本体の削除(弾丸は生き続けるためインスタンス自体は残す)
    func delete() {
        if !deleteFlag {
            UISelectionFeedbackGenerator().selectionChanged()
            self.legNode.removeFromParentNode()
            self.bodyNode.removeFromParentNode()
            self.state = false
            self.deleteFlag = true
        }
    }
    
    //並進速度の更新(正規化した状態で入力する)
    func updateVelocity(x: Float, z: Float) {
        if self.velocity_x != nil && self.velocity_z != nil {
            self.velocity_x = self.velocity * x
            self.velocity_z = self.velocity * z
        }
    }
    
    //弾丸の射出
    func shoot() {
        if self.state && self.canShootCount <= 0{
            bullets.append(Bullet(theta: self.theta, position: self.position, number: self.number, node: self.node))
            number += 1
            self.canShootCount = 4
        }
    }
    
    //行動計画の配列化
    func makeMovePlans(str: String) {
        if str == "cancel" {
            self.movePlans = []
            self.prePlans = str
            return
        }
        
        var flag = true
        for movePlan in movePlans {
            if !movePlan.pass {
                flag = false
            }
        }
        if flag {
            var plans: [(x: Int, z: Int, pass: Bool)] = []
            if !(str == "") && !(str == "cancel") && str != self.prePlans {
                let list = str.components(separatedBy: "/")
                for l in list {
                    let content = l.components(separatedBy: ",")
                    plans.append((x: Int(content[0])!, z: Int(content[1])!, pass: false))
                }
                self.movePlans = plans
            }
            self.prePlans = str
        }
    }
    
    //タンク, 弾丸の位置情報更新
    func update() {
        if self.state {
            let new = self.autonomousBehavior(self.ID, self.teamID, self.position, self.theta, self.counter, self.prePlans)
            
            thetaRef = new.0
            if self.theta != thetaRef {
                if thetaRef - self.theta > Float.pi {
                    thetaRef -= 2 * Float.pi
                }
                else if thetaRef - self.theta < -Float.pi {
                    thetaRef += 2 * Float.pi
                }
            }
            
            if new.1 {
                self.shootFlag = true
            }
            
            self.makeMovePlans(str: new.2)
            
            counter += 1
        }
        
        if self.canShootCount > 0 {
            self.canShootCount -= 1
        }
    }
    
    //胴体の回転
    func rotateBody(centerx: Float, centerz: Float) {
        let dx = self.bodyNode.position.x - centerx
        let dz = self.bodyNode.position.z - centerz
        self.theta = atan2(dx, dz)
    }
    
    //タンク, 弾丸の描画更新
    func updateShow(canMove: Bool) {
        for n in 0 ..< movePlans.count {
            if !movePlans[n].pass {
                let xRef = Float(movePlans[n].x) * Float(0.05)
                let zRef = Float(movePlans[n].z) * Float(0.05)
                if abs(self.position.x - xRef) < 0.003 && abs(self.position.z - zRef) < 0.003 {
                    self.updateVelocity(x: 0, z: 0)
                    movePlans[n].pass = true
                }
                else {
                    let vx = xRef - self.position.x
                    let vz = zRef - self.position.z
                    
                    var alphaRef = atan2(vx, vz)
                    if alphaRef - self.alpha > Float.pi {
                        alphaRef -= 2 * Float.pi
                    }
                    else if alphaRef - self.alpha < -Float.pi {
                        alphaRef += 2 * Float.pi
                    }
                    
                    if abs(alphaRef - self.alpha) > 0.3 {
                        self.updateVelocity(x: 0.0, z: 0.0)
                        self.deltaAlpha = 0.1 * (alphaRef - self.alpha) / abs(alphaRef - self.alpha)
                    }
                    else {
                        self.updateVelocity(x: vx / sqrt(vx * vx + vz * vz), z: vz / sqrt(vx * vx + vz * vz))
                        self.deltaAlpha = 0.0
                    }
                    break
                }
            }
        }
        if self.prePlans == "cancel" {
            self.updateVelocity(x: 0.0, z: 0.0)
        }
        //タンク
        guard self.position != nil else {return}
        if canMove {
            //並進
            self.position.x += self.velocity_x
            self.position.z += self.velocity_z
            //回転(leg)
            if self.velocity_x != 0 || self.velocity_z != 0{
                self.alpha = atan2(self.velocity_x, self.velocity_z)
            }
            else {
                self.alpha += self.deltaAlpha
            }
            self.theta += 0.1 * (thetaRef - self.theta)
        }
        //弾丸
        for bullet in self.bullets {
            bullet.update()
        }
        //タンク
        guard self.position != nil else {return}
        if !self.deleteFlag {
            self.legNode.position.x = position.x
            self.legNode.position.z = position.z
            self.bodyNode.position.x = position.x
            self.bodyNode.position.z = position.z
            self.legNode.rotation = SCNVector4(0, 1, 0, self.alpha - Float.pi/2)
            self.bodyNode.rotation = SCNVector4(0, 1, 0, self.theta - Float.pi/2)
        }
        
        //弾丸射出
        if self.shootFlag {
            self.shoot()
            self.shootFlag = false
        }
    }
}
