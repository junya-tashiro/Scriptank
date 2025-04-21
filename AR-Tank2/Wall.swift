//
//  Wall.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/07.
//

import Foundation
import SceneKit
import ARKit

class Wall{
    let userDefaults = UserDefaults.standard
    
    var node: SCNNode!
    let ID: String
    let x1: Float
    let z1: Float
    let x2: Float
    let z2: Float
    var length: Float! = nil
    var a: Float! = nil
    var b: Float! = nil
    var c: Float! = nil
    let centerx: Float
    let centerz: Float
    let n: Int
    let theta: Float
    
    init(node: SCNNode!, ID: String, x: Float, z: Float, n: Int, theta: Float) {
        self.node = node
        self.ID = ID
        self.centerx = x
        self.centerz = z
        self.n = n
        self.theta = theta
        let l: Float = 0.025 + 0.05 * Float(n)
        
        self.x1 = x + l * cos(theta)
        self.z1 = z + l * sin(theta)
        self.x2 = x - l * cos(theta)
        self.z2 = z - l * sin(theta)

        self.a = z2 - z1
        self.b = x1 - x2
        self.c = x2 * z1 - x1 * z2
        self.length = sqrt(self.a * self.a + self.b * self.b)
        
        if userDefaults.bool(forKey: "showDetail") {
            guard let wallScene = SCNScene(named: "wall.scn") else {return}
            let wallNode = wallScene.rootNode.childNode(withName: "wall", recursively: true)
            wallNode?.position = SCNVector3(x, 0, z)
            wallNode?.rotation = SCNVector4(0, 1, 0, theta)
            self.node.addChildNode(wallNode!)
            for i in 0 ..< n {
                let posx: Float = (0.05 + 0.05 * Float(i)) * cos(theta)
                let posz: Float = (0.05 + 0.05 * Float(i)) * sin(theta)
                guard let wallScene1 = SCNScene(named: "wall.scn") else {return}
                let wallNode1 = wallScene1.rootNode.childNode(withName: "wall", recursively: true)
                wallNode1?.position = SCNVector3(x + posx, 0, z + posz)
                wallNode1?.rotation = SCNVector4(0, 1, 0, theta)
                self.node.addChildNode(wallNode1!)
                guard let wallScene2 = SCNScene(named: "wall.scn") else {return}
                let wallNode2 = wallScene2.rootNode.childNode(withName: "wall", recursively: true)
                wallNode2?.position = SCNVector3(x - posx, 0, z - posz)
                wallNode2?.rotation = SCNVector4(0, 1, 0, theta)
                self.node.addChildNode(wallNode2!)
            }
        }
        
        else {
            let wallNode = SCNNode()
            wallNode.geometry = SCNBox(width: 0.001, height: 0.018, length: CGFloat(self.length), chamferRadius: 0.0)
            wallNode.position = SCNVector3(x, 0.012, z)
            wallNode.rotation = SCNVector4(0, 1, 0, theta + Float.pi/2)
            wallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            self.node.addChildNode(wallNode)
            let poleUpNode = SCNNode()
            poleUpNode.geometry = SCNCylinder(radius: 0.0015, height: CGFloat(self.length))
            poleUpNode.position = SCNVector3(0, 0.009, 0)
            poleUpNode.rotation = SCNVector4(1, 0, 0, Float.pi/2)
            poleUpNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            wallNode.addChildNode(poleUpNode)
            let poleDownNode = SCNNode()
            poleDownNode.geometry = SCNCylinder(radius: 0.0015, height: CGFloat(self.length))
            poleDownNode.position = SCNVector3(0, -0.009, 0)
            poleDownNode.rotation = SCNVector4(1, 0, 0, Float.pi/2)
            poleDownNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            wallNode.addChildNode(poleDownNode)
            for i in 0 ..< n + 1 {
                let posx: Float = (0.025 + 0.05 * Float(i)) * cos(theta)
                let posz: Float = (0.025 + 0.05 * Float(i)) * sin(theta)
                let poleNode1 = SCNNode()
                poleNode1.geometry = SCNCylinder(radius: 0.0015, height: 0.024)
                poleNode1.position = SCNVector3(x + posx, 0.012, z + posz)
                poleNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                self.node.addChildNode(poleNode1)
                let poleNode2 = SCNNode()
                poleNode2.geometry = SCNCylinder(radius: 0.0015, height: 0.024)
                poleNode2.position = SCNVector3(x - posx, 0.012, z - posz)
                poleNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                self.node.addChildNode(poleNode2)
            }
        }
    }
    
    func calcDistance(x: Float, z: Float) -> Float {
        //点(x1, z1)が最近傍点の場合
        if (x - self.x1) * (self.x2 - self.x1) + (z - self.z1) * (self.z2 - self.z1) < 0 {
            return sqrt((x - self.x1) * (x - self.x1) + (z - self.z1) * (z - self.z1))
        }
        //点(x2, z2)が最近傍点の場合
        else if (x - self.x2) * (self.x1 - self.x2) + (z - self.z2) * (self.z1 - self.z2) < 0 {
            return sqrt((x - self.x2) * (x - self.x2) + (z - self.z2) * (z - self.z2))
        }
        else {
            return abs(self.a * x + self.b * z + self.c) / self.length
        }
    }
    
    func getStringData() -> String!{
        var str = "WALL/"
        str.append(self.ID)
        str.append("/")
        str.append(String(self.centerx))
        str.append("/")
        str.append(String(self.centerz))
        str.append("/")
        str.append(String(self.n))
        str.append("/")
        str.append(String(self.theta))
        return str
    }
}
