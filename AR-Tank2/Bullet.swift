//
//  Bullet.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/11/28.
//

import Foundation
import SceneKit
import ARKit
//弾丸
class Bullet {
    let node: SCNNode!
    var state: Bool = false
    let bulletNode = SCNNode()  //弾丸
    var theta: Float            //向き
    var position: SCNVector3!   //位置
    var number: Int             //通し番号
    var velocity: Float = 0.002
    
    var a: Float
    var b: Float
    var c: Float
    
    //コンストラクタ
    init(theta: Float, position: SCNVector3!, number: Int, node: SCNNode!) {
        self.theta = theta
        self.position = position
        self.number = number
        self.node = node
        self.state = true
        
        //弾丸の追加
        self.bulletNode.geometry = SCNSphere(radius: 0.003)
        self.bulletNode.position = SCNVector3(position.x - 0.01 * sin(self.theta), 0.016, position.z - 0.01 * cos(self.theta))
        self.bulletNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        self.node.addChildNode(self.bulletNode)
        
        self.a = cos(self.theta)
        self.b = -sin(self.theta)
        self.c = position.z * sin(self.theta) - position.x * cos(self.theta)
    }
    
    func delete() {
        self.bulletNode.removeFromParentNode()
        self.state = false
    }
    
    //位置情報, 描画更新
    func update() {
        guard self.position != nil else {return}
        if self.state {
            self.position.x -= self.velocity * sin(self.theta)
            self.position.z -= self.velocity * cos(self.theta)
            
            self.bulletNode.position.x = self.position.x
            self.bulletNode.position.z = self.position.z
        }
    }
}
