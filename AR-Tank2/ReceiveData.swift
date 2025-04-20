//
//  ReceiveData.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/14.
//
//  対戦画面のクラス: BattleViewController
//  データ受信時の動作

import Foundation
import SceneKit
import ARKit
import MultipeerConnectivity

extension BattleViewController {
    //データ受信時
    @IBAction func receivedData(_ data: Data, from peer: MCPeerID) {
        //受信データの文字列化
        let str = String(decoding: data, as: UTF8.self)
        //冒頭4文字で種類をチェック
        //タンク情報受信時
        if String(str.prefix(4)) == "TANK" {
            let list = str.components(separatedBy: "/")[1].components(separatedBy: ",")
            var flag = true
            for tank in tanks {
                //受信したデータのタンクがすでに存在する場合
                if tank.ID == list[0] {
                    //戦車の更新
                    if list[1] == "deleted" {
                        tank.delete()
                        flag = false
                    }
                    else {
                        tank.position.x = Float(list[1])!
                        tank.position.z = Float(list[2])!
                        tank.velocity_x = Float(list[3])!
                        tank.velocity_z = Float(list[4])!
                        tank.alpha = Float(list[5])!
                        tank.theta = Float(list[6])!
                        flag = false
                    }
                    //弾丸の更新
                    let blts = str.components(separatedBy: "/").dropFirst(2)
                    for blt in blts {
                        let b = blt.components(separatedBy: ",")
                        var flagBullet = true
                        for bullet in tank.bullets {
                            //弾丸がすでに存在した場合
                            if Int(b[0]) == bullet.number {
                                if b[1] == "deleted" {
                                    bullet.delete()
                                    flagBullet = false
                                }
                                else {
                                    bullet.position.x = Float(b[1])!
                                    bullet.position.z = Float(b[2])!
                                    bullet.theta = Float(b[3])!
                                    flagBullet = false
                                }
                            }
                        }
                        //受信したデータの弾丸が存在しない場合
                        if flagBullet == true {
                            tank.bullets.append(Bullet(theta: Float(b[3])!, position: tank.position, number: Int(b[0])!, node: self.originNode))
                        }
                    }
                }
            }
            //受信したデータのタンクが存在しない場合
            if flag {
                guard let x = Float(list[1]) else { return }
                guard let z = Float(list[2]) else { return }
                tanks.append(Tank(ID: list[0], teamID: Int(list[7])!, node: self.originNode, position: SCNVector3(x: x, y: 0, z: z), autonomousBehavior: self.noUpdate))
            }
        }
        
        //壁情報受信時
        if String(str.prefix(4)) == "WALL" {
            let list = str.components(separatedBy: "/")
            var flag = true
            for wall in walls {
                if wall.ID == list[1] {
                    flag = false
                }
            }
            //同一IDのwallが存在しない場合
            if flag {
                walls.append(Wall(node: self.originNode, ID: list[1], x: Float(list[2])!, z: Float(list[3])!, n: Int(list[4])!, theta: Float(list[5])!))
            }
        }
        
        //終了情報受信時
        if String(str.prefix(4)) == "FNSH" {
            let list = str.components(separatedBy: "/")
            if list[1] == "red" {
                self.finishMatch(winner: 1)
            }
            else if list[1] == "blue" {
                self.finishMatch(winner: -1)
            }
            else if list[1] == "draw" {
                self.finishMatch(winner: 0)
            }
        }
        
        //メンバー情報受信時
        if String(str.prefix(4)) == "MMBR" {
            self.connectedFlag = true
            DispatchQueue.main.sync {
                membersForBrowser.removeAll()
            }
            let list = str.components(separatedBy: "/").dropFirst()
            if list[1] == "dropout" {
                if list[2] == "advertiser" {
                    if !self.startFlag {
                        NotificationCenter.default.post(name: .advertiserDisappeared, object: nil)
                        DispatchQueue.main.sync {
                            self.tanks = []
                            self.walls = []
                            self.members = []
                            self.membersForBrowser = []
                            self.autonomousTank = [:]
                            
                            mpsession = nil
                            serviceAdvertiser = nil
                            serviceBrowser = nil
                            
                            self.timer?.invalidate()
                            
                            self.dismiss(animated: false, completion: nil)
                            
                            self.sceneView.session.pause()
                            self.sceneView = nil
                            
                            self.configuration = nil
                            
                            NotificationCenter.default.post(name: .finishBattle, object: nil)
                        }
                    }
                }
                else {
                    if self.isAdvertiser {
                        DispatchQueue.main.sync {
                            members.removeAll(where: {$0.ID == list[2]})
                            self.updateShowFunc()
                        }
                    }
                }
            }
            else {
                var n = 0
                for l in list {
                    DispatchQueue.main.sync {
                        membersForBrowser.append(MemberForBrowser(view: self.view, name: l.components(separatedBy: ",")[0], index: n, screenWidth: self.screenWidth, team: l.components(separatedBy: ",")[1] ))
                    }
                    n += 1
                }
            }
        }
        
        //フェーズ進行情報受信時
        if String(str.prefix(4)) == "GOTO" {
            let forWhat = str.components(separatedBy: "/")[1]
            //通信接続終了時
            if forWhat == "battle" {
                DispatchQueue.main.sync {
                    self.background.isHidden = true
                    
                    self.backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    self.backButton.layer.cornerRadius = 20
                    self.backButton.backgroundColor = myBlue
                    self.backButton.setTitle("←", for: UIControl.State.normal)
                    self.backButton.center.x = 50
                    self.backButton.center.y = 100
                    
                    membersForBrowser.removeAll()
                }
                self.needAlert = true
                
                self.serviceBrowser.stopBrowsingForPeers()
                sceneView.session.run(configuration)
                sceneView.scene.rootNode.addChildNode(self.fieldPlaceNode)
                let pointNode = SCNNode()
                pointNode.geometry = SCNSphere(radius: 0.001)
                pointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                self.fieldPlaceNode.addChildNode(pointNode)
                self.fieldPlaceNode.isHidden = true
                
                sceneView.scene.rootNode.addChildNode(self.originNode)
                self.originNode.isHidden = true
                
                self.fieldSize = [Int(str.components(separatedBy: "/")[2])!, Int(str.components(separatedBy: "/")[3])!]
                
                let homeNodeRed = SCNNode()
                homeNodeRed.geometry = SCNBox(width: 0.1, height: 0.0001, length: 0.1, chamferRadius: 0)
                homeNodeRed.position = SCNVector3(0.025 * Float(self.fieldSize[0] - 2), 0, -0.025 * Float(self.fieldSize[1] - 2))
                homeNodeRed.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.9)
                self.originNode.addChildNode(homeNodeRed)
                
                let homeNodeBlue = SCNNode()
                homeNodeBlue.geometry = SCNBox(width: 0.1, height: 0.0001, length: 0.1, chamferRadius: 0)
                homeNodeBlue.position = SCNVector3(-0.025 * Float(self.fieldSize[0] - 2), 0, 0.025 * Float(self.fieldSize[1] - 2))
                homeNodeBlue.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.9)
                self.originNode.addChildNode(homeNodeBlue)
                
                self.fieldPlaceNode.geometry = SCNBox(width: 0.05 * CGFloat(self.fieldSize[0]), height: 0.0001, length: 0.05 * CGFloat(self.fieldSize[1]), chamferRadius: 0.0)
                
                if userDefaults.bool(forKey: "showDetail") {
                    self.addCones()
                }
            }
            //スタンバイ情報
            if forWhat == "standby" {
                let ID = str.components(separatedBy: "/")[2]
                if self.isAdvertiser {
                    self.standby[ID] = true
                    var flag = true
                    for elem in self.standby {
                        if !elem.value {
                            flag = false
                        }
                    }
                    //全てのpeerがstandby状態になった時
                    if flag {
                        if self.canSetField {
                            DispatchQueue.main.sync {
                                //スタートスイッチの追加
                                self.view.addSubview(setFieldButton)
                                //戻るボタン押下時にアラート出現
                                self.needAlert = true
                            }
                        }
                        else {
                            self.canSetField = true
                        }
                    }
                }
            }
            //フィールド設置
            if forWhat == "setfield" {
                self.originNode.isHidden = false
            }
            //バトル開始
            if forWhat == "start" {
                self.startCountFlag = true
            }
        }
    }
}
