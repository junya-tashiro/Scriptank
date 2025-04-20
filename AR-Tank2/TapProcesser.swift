//
//  TapProcesser.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/14.
//

import Foundation
import SceneKit
import ARKit
import MultipeerConnectivity

extension BattleViewController {
    //画面をタップしたときに呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !standbyFlag && self.fieldCheckBackground.isHidden {
            guard let touch = touches.first else {return}   //最初にタップした座標を取り出す
            let touchPos = touch.location(in: sceneView)    //スクリーン座標に変換する
            let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
            //タップされた位置のARアンカーを探す
            if !hitTest.isEmpty{
                if let hitResult = hitTest.first {
                    let origin = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
                    self.originNode.position = origin
                    self.originFlag = true
                    
                    self.fieldPlaceNode.isHidden = false
                    self.fieldPlaceNode.position = origin
                    self.fieldPlaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
                }
            }
        }
        if !self.originNode.isHidden && touches.count == 2 {
            var flag = true
            for touch in touches {
                if flag {
                    self.touch1 = touch
                    flag = false
                }
                else {
                    self.touch2 = touch
                }
            }
            self.isMoveFieldMode = true
        }
    }
    //画面をタップしている最中に呼ばれる
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !standbyFlag && self.fieldCheckBackground.isHidden {
            guard let touch = touches.first else {return}   //最初にタップした座標を取り出す
            let touchPos = touch.location(in: sceneView)    //スクリーン座標に変換する
            let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
            //タップされた位置のARアンカーを探す
            if !hitTest.isEmpty{
                if let hitResult = hitTest.first {
                    let end = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
                    let a = atan2(end.x - self.fieldPlaceNode.position.x, end.z - self.fieldPlaceNode.position.z)
                    self.fieldPlaceNode.rotation = SCNVector4(0, 1, 0, a)
                    self.fieldPlaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
                }
            }
            else {
                self.fieldPlaceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.7)
            }
        }
        if startFlag {
            guard let touch = touches.first else {return}   //タップした座標を取り出す
            let touchPos = touch.location(in: sceneView)    //スクリーン座標に変換する
            var moveTo = touchPos
            moveTo.x += screenWidth / 2 - controllerCenter.center.x
            moveTo.y += screenHeight / 2 - controllerCenter.center.y
            let center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
            //タップされた位置のARアンカーを探す
            let hitTest = sceneView.hitTest(moveTo, types: .existingPlaneUsingExtent)
            let centerTest = sceneView.hitTest(center, types: .existingPlaneUsingExtent)
            for tank in tanks {
                if tank.ID == UIDevice.current.identifierForVendor!.uuidString {
                    guard let position = tank.position else {return}
                    if !hitTest.isEmpty && !centerTest.isEmpty {
                        if let hitResult = hitTest.first {
                            if let centerResult = centerTest.first {
                                //スティック描画の更新
                                let r = sqrt((touchPos.x - controllerCenter.center.x) * (touchPos.x - controllerCenter.center.x) + (touchPos.y - controllerCenter.center.y) * (touchPos.y - controllerCenter.center.y))
                                if r < 50 {
                                    controller.center.x = touchPos.x
                                    controller.center.y = touchPos.y
                                }
                                else {
                                    controller.center.x = controllerCenter.center.x + (touchPos.x - controllerCenter.center.x) * 50 / r
                                    controller.center.y = controllerCenter.center.y + (touchPos.y - controllerCenter.center.y) * 50 / r
                                }
                                
                                //タンク速度の更新
                                let dx = hitResult.worldTransform.columns.3.x - centerResult.worldTransform.columns.3.x
                                let dz = hitResult.worldTransform.columns.3.z - centerResult.worldTransform.columns.3.z
                                let dxRotated = dx * cos(self.originTheta) - dz * sin(self.originTheta)
                                let dzRotated = dx * sin(self.originTheta) + dz * cos(self.originTheta)
                                tank.updateVelocity(
                                    x: dxRotated / sqrtf(dxRotated * dxRotated + dzRotated * dzRotated),
                                    z: dzRotated / sqrtf(dxRotated * dxRotated + dzRotated * dzRotated))
                            }
                        }
                    }
                }
            }
        }
        if !self.originNode.isHidden && touches.count == 2 {
            var flag = true
            for touch in touches {
                if flag {
                    self.touch1 = touch
                    flag = false
                }
                else {
                    self.touch2 = touch
                }
            }
        }
        self.isMoveFieldMode = (touches.count == 2)
    }
    
    //画面タップが終了したときに呼ばれる
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isMoveFieldMode = false
        self.didNotMoveField = true
        
        if !self.standbyFlag && self.originFlag && self.fieldCheckBackground.isHidden {
            self.fieldPlaceNode.isHidden = true
            self.originFlag = false
            guard let touch = touches.first else {return}   //最初にタップした座標を取り出す
            let touchPos = touch.location(in: sceneView)    //スクリーン座標に変換する
            let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
            //タップされた位置のARアンカーを探す
            if !hitTest.isEmpty{
                if let hitResult = hitTest.first {
                    let end = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
                    self.originTheta = atan2(end.x - self.originNode.position.x, end.z - self.originNode.position.z)
                    self.originNode.rotation = SCNVector4(0, 1, 0, self.originTheta)
                    
                    self.fieldPlaceNode.isHidden = false
                    self.fieldCheckBackground.isHidden = false
                    self.fieldCheckLabel.isHidden = false
                    self.fieldCheckGoButton.isHidden = false
                    self.fieldCheckCancelButton.isHidden = false
                    
                    self.nowFieldChecking = true
                    
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
        }
        else {
            for tank in tanks {
                if tank.ID == UIDevice.current.identifierForVendor!.uuidString {
                    guard let position = tank.position else {return}
                    tank.updateVelocity(x: 0.0, z: 0.0)
                    controller.center = controllerCenter.center
                }
            }
        }
    }
}
