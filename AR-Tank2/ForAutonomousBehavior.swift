//
//  ForAutonomousBehavior.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/15.
//
//  対戦画面のクラス: BattleViewController
//  タンクの自律行動生成関数

import Foundation
import SceneKit
import ARKit
import MultipeerConnectivity

extension BattleViewController {
    func getEnemyPositions(ID: String) -> [SCNVector3] {
        var positionList: [SCNVector3] = []
        var teamID: Int = 0
        for tank in tanks {
            if tank.ID == ID {
                teamID = tank.teamID
                break
            }
        }
        for tank in tanks {
            if tank.teamID != teamID && tank.state {
                positionList.append(tank.position)
            }
        }
        return positionList
    }
    
    func getAllyPositions(ID: String) -> [SCNVector3] {
        var positionList: [SCNVector3] = []
        var teamID: Int = 0
        for tank in tanks {
            if tank.ID == ID {
                teamID = tank.teamID
                break
            }
        }
        for tank in tanks {
            if tank.teamID == teamID && tank.state && tank.ID != ID {
                positionList.append(tank.position)
            }
        }
        return positionList
    }
    
    func getBulletPositions(ID: String) -> [(position: SCNVector3, theta: Float)] {
        var positionList: [(position: SCNVector3, theta: Float)] = []
        var tankPosition = SCNVector3(0, 0, 0)
        for tank in self.tanks {
            if tank.ID == ID {
                tankPosition = tank.position
            }
        }
        for tank in self.tanks {
            if tank.ID != ID {
                for bullet in tank.bullets {
                    if bullet.state {
                        let distance = abs(bullet.a * tankPosition.x + bullet.b * tankPosition.z + bullet.c)
                        if distance < 0.0135 {
                            positionList.append((bullet.position, bullet.theta))
                        }
                    }
                }
            }
        }
        return positionList
    }
    
    func calcPositionToShoot(tankPosition: SCNVector3, bulletposition: SCNVector3, bulletTheta: Float) -> (x: Float, z: Float) {
        let x0 = tankPosition.x - bulletposition.x
        let z0 = tankPosition.z - bulletposition.z
        let a = (x0 * x0 + z0 * z0) / (2.0 * (x0 * sin(bulletTheta) + z0 * cos(bulletTheta)))
        return (x: bulletposition.x + a * sin(bulletTheta), z: bulletposition.z + a * cos(bulletTheta))
    }
    
    func isNotDevidedWithWall(position1: SCNVector3, position2: SCNVector3, len: Float) -> Bool {
        let max_n = 100
        for n in 0 ..< max_n {
            let x = (position1.x * Float(n) + position2.x * Float(max_n - n)) / Float(max_n)
            let z = (position1.z * Float(n) + position2.z * Float(max_n - n)) / Float(max_n)
            for wall in self.walls {
                let distance = wall.calcDistance(x: x, z: z)
                if distance < len {
                    return false
                }
            }
        }
        return true
    }
    
    func positionToPoint(position: SCNVector3) -> (x: Int, z: Int) {
        var x: Int = 0
        var z: Int = 0
        while true {
            if 0.05 * Float(x) - 0.025 < position.x && position.x < 0.05 * Float(x) + 0.025 { break }
            else if 0.05 * Float(x) + 0.025 < position.x { x += 1 }
            else if 0.05 * Float(x) - 0.025 > position.x { x -= 1 }
        }
        while true {
            if 0.05 * Float(z) - 0.025 < position.z && position.z < 0.05 * Float(z) + 0.025 { break }
            else if 0.05 * Float(z) + 0.025 < position.z { z += 1 }
            else if 0.05 * Float(z) - 0.025 > position.z { z -= 1 }
        }
        return (x: x, z: z)
    }
    
    func pointToIndex(point: (x: Int, z: Int)) -> Int {
        return (point.x + (self.fieldSize[0] - 1) / 2) * fieldSize[1] + (point.z + (self.fieldSize[1] - 1) / 2)
    }
    
    func isValidPath(pathList: [(x: Int, z: Int)]) -> (String, Float) {
        var str = ""
        var flag = true
        var length: Float = 0.0
        for n in 0 ..< pathList.count - 1 {
            if !self.canMove[pointToIndex(point: pathList[n])][pointToIndex(point: pathList[n+1])] {
                flag = false
            }
        }
        if flag {
            for n in 0 ..< pathList.count - 1 {
                str.append(String(pathList[n+1].x) + "," + String(pathList[n+1].z) + "/")
                length += sqrt(pow(Float(pathList[n+1].x - pathList[n].x), 2) + pow(Float(pathList[n+1].z - pathList[n].z), 2))
            }
            str.removeLast(1)
        }
        return (str, length)
    }
    
    func makePath(start: SCNVector3, goal: SCNVector3) -> String {
        let startPoint = self.positionToPoint(position: start)
        let goalPoint = self.positionToPoint(position: goal)
        //中継点なし
        var string = isValidPath(pathList: [startPoint, goalPoint]).0
        if string != "" {
            return string
        }
        
        var minLength: Float = 1000.0
        //中継点1つ
        for i in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
            let x: Int = i / fieldSize[1] - (fieldSize[0] - 1) / 2
            let z: Int = i % fieldSize[1] - (fieldSize[1] - 1) / 2
            let (str, len) = isValidPath(pathList: [startPoint, (x: x, z: z), goalPoint])
            if str != "" {
                if len < minLength {
                    string = str
                    minLength = len
                }
            }
        }
        
        //中継点2つ
        for i in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
            for j in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
                let x1: Int = i / fieldSize[1] - (fieldSize[0] - 1) / 2
                let z1: Int = i % fieldSize[1] - (fieldSize[1] - 1) / 2
                let x2: Int = j / fieldSize[1] - (fieldSize[0] - 1) / 2
                let z2: Int = j % fieldSize[1] - (fieldSize[1] - 1) / 2
                let (str, len) = isValidPath(pathList: [startPoint, (x: x1, z: z1), (x: x2, z: z2), goalPoint])
                if str != "" {
                    if len < minLength {
                        string = str
                        minLength = len
                    }
                }
            }
        }
        
        //中継点3つ
        for i in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
            for j in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
                for k in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
                    let x1: Int = i / fieldSize[1] - (fieldSize[0] - 1) / 2
                    let z1: Int = i % fieldSize[1] - (fieldSize[1] - 1) / 2
                    let x2: Int = j / fieldSize[1] - (fieldSize[0] - 1) / 2
                    let z2: Int = j % fieldSize[1] - (fieldSize[1] - 1) / 2
                    let x3: Int = k / fieldSize[1] - (fieldSize[0] - 1) / 2
                    let z3: Int = k % fieldSize[1] - (fieldSize[1] - 1) / 2
                    let (str, len) = isValidPath(pathList: [startPoint, (x: x1, z: z1), (x: x2, z: z2), (x: x3, z: z3), goalPoint])
                    if str != "" {
                        if len < minLength {
                            string = str
                            minLength = len
                        }
                    }
                }
            }
        }
        
        if string != "" {
            return string
        }
        
        //中継点4つ
        for i in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
            for j in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
                for k in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
                    for l in 0 ..< self.fieldSize[0] * self.fieldSize[1] {
                        let x1: Int = i / fieldSize[1] - (fieldSize[0] - 1) / 2
                        let z1: Int = i % fieldSize[1] - (fieldSize[1] - 1) / 2
                        let x2: Int = j / fieldSize[1] - (fieldSize[0] - 1) / 2
                        let z2: Int = j % fieldSize[1] - (fieldSize[1] - 1) / 2
                        let x3: Int = k / fieldSize[1] - (fieldSize[0] - 1) / 2
                        let z3: Int = k % fieldSize[1] - (fieldSize[1] - 1) / 2
                        let x4: Int = l / fieldSize[1] - (fieldSize[0] - 1) / 2
                        let z4: Int = l % fieldSize[1] - (fieldSize[1] - 1) / 2
                        let (str, len) = isValidPath(pathList: [startPoint, (x: x1, z: z1), (x: x2, z: z2), (x: x3, z: z3), (x: x4, z: z4), goalPoint])
                        if str != "" {
                            if len < minLength {
                                string = str
                                minLength = len
                            }
                        }
                    }
                }
            }
        }
        
        return string
    }
    
    func toGoal(ID: String) -> String {
        var path: String = ""
        if ID == "CPU-stage1-0" || ID == "CPU-stage2-0" {
            path = "-2,1"
        }
        else if ID == "CPU-stage3-0" || ID == "CPU-stage18-0" {
            path = "-3,0/-3,2"
        }
        else if ID == "CPU-stage4-0" {
            path = "-2,-1/-2,1"
        }
        else if ID == "CPU-stage4-1" {
            path = "0,-1/-2,-1/-2,1"
        }
        else if ID == "CPU-stage4-2" {
            path = "2,1/0,1/0,-1/-2,-1/-2,1"
        }
        else if ID == "CPU-stage5-0" || ID == "CPU-stage5-1" || ID == "CPU-stage6-0" || ID == "CPU-stage6-1" || ID == "CPU-stage7-1" || ID == "CPU-stage7-2" || ID == "CPU-stage14-0" || ID == "CPU-stage14-1" || ID == "CPU-stage17-0" || ID == "CPU-stage17-1" || ID == "CPU-stage20-1" || ID == "CPU-stage20-2" || ID == "CPU-stage20-0" {
            path = "-3,2"
        }
        else if ID == "CPU-stage10-0" || ID == "CPU-stage19-0" {
            path = "-4,3"
        }
        else if ID == "CPU-stage10-1" {
            path = "-1,-2/-2,-2/-4,3"
        }
        else if ID == "CPU-stage10-2" {
            path = "2,2/1,2/-1,-2/-2,-2/-4,3"
        }
        else if ID == "CPU-stage12-0" {
            path = "2,1/1,1/-1,-1/-2,-1/-3,2"
        }
        else if ID == "CPU-stage13-0" {
            path = "1,1/0,1/0,-1/-1,-1/-2,1"
        }
        else if ID == "CPU-stage15-0" {
            path = "-4,1"
        }
        else if ID == "CPU-stage16-0" {
            path = "0,-1/4,-1/0,-1/4,-1/-4,-1/-4,0"
        }
        else if ID == "CPU-stage16-1" {
            path = "0,0/4,0/0,0/4,0/-4,0"
        }
        else if ID == "CPU-stage19-0" {
            for tank in self.tanks {
                if tank.ID == ID && tank.state {
                    path = makePath(start: tank.position, goal: SCNVector3(-0.2, 0.0, 0.15))
                }
            }
        }
        else if ID == "CPU-stage19-1" {
            path = "0,3/-4,3"
        }
        else if ID == "CPU-stage19-2" {
            path = "-4,-1/-4,3"
        }
        else if ID.suffix(4) == "Lv.1" || ID.suffix(4) == "Lv.2" || ID.suffix(4) == "Lv.3" || ID.suffix(4) == "Lv.4" {
            //ステージ, チームIDに応じてpathを変更
            for tank in self.tanks {
                if tank.ID == ID && tank.state {
                    //ステージ1
                    if self.fieldChoosen == 0 {
                        if tank.teamID == 1 { path = "-2,1" } //red
                        else { path = "2,-1" }                //blue
                    }
                    //ステージ2
                    else if self.fieldChoosen == 1 {
                        if tank.teamID == 1 { path = "-3,2" } //red
                        else { path = "3,-2" }                //blue
                    }
                    //ステージ3
                    else if self.fieldChoosen == 2 {
                        if tank.teamID == 1 { path = "-4,3" } //red
                        else { path = "4,-3" }                //blue
                    }
                    //ステージ4
                    else if self.fieldChoosen == 3 {
                        if tank.teamID == 1 { path = "2,1/1,1/-1,-1/-2,-1/-3,2" } //red
                        else { path = "-2,-1/-1,-1/1,1/2,1/3,-2" }                //blue
                    }
                    //ステージ5
                    else if self.fieldChoosen == 4 {
                        if tank.teamID == 1 { path = "3,-1/3,0/-3,0/-3,2" } //red
                        else { path = "-3,1/-3,0/3,0/3,-2" }                //blue
                    }
                    //ステージ6
                    else if self.fieldChoosen == 5 {
                        if tank.teamID == 1 { path = "3,-1/-3,1/-4,3" } //red
                        else { path = "-3,1/3,-1/4,-3" }                //blue
                    }
                }
            }
        }
        return path
    }
    
    func setCpuForSolo() {
        self.autonomousTank["CPU-stage1-0"] = noMoveRandomShoot
        self.autonomousTank["CPU-stage2-0"] = noMoveSemiRandomShoot
        self.autonomousTank["CPU-stage3-0"] = enemy2
        self.autonomousTank["CPU-stage4-0"] = noMoveSemiRandomShoot
        self.autonomousTank["CPU-stage4-1"] = noMoveSemiRandomShoot
        self.autonomousTank["CPU-stage4-2"] = noMoveSemiRandomShoot
        self.autonomousTank["CPU-stage5-0"] = randomMoveSemiRandomShoot
        self.autonomousTank["CPU-stage5-1"] = randomMoveSemiRandomShoot
        self.autonomousTank["CPU-stage6-0"] = toGoalSemiRandomShoot
        self.autonomousTank["CPU-stage6-1"] = toGoalSemiRandomShoot
        self.autonomousTank["CPU-stage7-0"] = randomMoveSemiStrongShoot
        self.autonomousTank["CPU-stage7-1"] = randomMoveSemiStrongShoot
        self.autonomousTank["CPU-stage8-0"] = toGoalSemiStrongShoot
        self.autonomousTank["CPU-stage9-0"] = toGoalSemiStrongShoot
        self.autonomousTank["CPU-stage10-0"] = noMoveStrongShoot
        self.autonomousTank["CPU-stage10-1"] = noMoveStrongShoot
        self.autonomousTank["CPU-stage10-2"] = noMoveStrongShoot
        self.autonomousTank["CPU-stage11-0"] = noUpdate
        self.autonomousTank["CPU-stage12-0"] = noMoveRandomShoot
        self.autonomousTank["CPU-stage13-0"] = toGoalNoShoot
        self.autonomousTank["CPU-stage14-0"] = toGoalNoShoot
        self.autonomousTank["CPU-stage14-1"] = toGoalNoShoot
        self.autonomousTank["CPU-stage15-0"] = forStage15
        self.autonomousTank["CPU-stage16-0"] = toGoalSemiRandomShoot
        self.autonomousTank["CPU-stage16-1"] = toGoalSemiRandomShoot
        self.autonomousTank["CPU-stage16-2"] = toGoalSemiRandomShoot
        self.autonomousTank["CPU-stage17-0"] = toGoalSemiRandomShoot
        self.autonomousTank["CPU-stage17-1"] = toEnemySemiRandomShoot
        self.autonomousTank["CPU-stage18-0"] = enemy2
        self.autonomousTank["CPU-stage19-0"] = randomMoveSemiRandomShoot
        self.autonomousTank["CPU-stage19-1"] = forStage19_1
        self.autonomousTank["CPU-stage19-2"] = forStage19_2
        self.autonomousTank["CPU-stage20-0"] = enemy2
        self.autonomousTank["CPU-stage20-1"] = toGoalSemiRandomShoot
        self.autonomousTank["CPU-stage20-2"] = toGoalSemiRandomShoot
        
        self.autonomousTank["myCPU"] = Interpriter
        
        self.autonomousTank["Lv.0"] = noUpdate
        self.autonomousTank["Lv.1"] = enemy1
        self.autonomousTank["Lv.2"] = toGoalSemiStrongShoot
        self.autonomousTank["Lv.3"] = noMoveStrongShoot
        self.autonomousTank["Lv.4"] = toGoalStrongShoot
    }
    
    //手動操作用
    func noUpdate(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        return (theta, false, "")
    }
    
    func enemy1(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        var flag = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            let x = -1 * (self.fieldSize[0] - 1) / 2 * (2 * teamID - 1)
            let z = (self.fieldSize[1] - 1) / 2 * (2 * teamID - 1)
            movePlans = self.makePath(start: position, goal: SCNVector3(0.05 * Float(x), 0, 0.05 * Float(z)))
        }
        
        //最も近い敵Tankの位置を取得
        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        if counter % 20 == 19  && flag {
           shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func enemy2(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = "3,0"
        var shoot = false
        var flag = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }
        
        //最も近い敵Tankの位置を取得
        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        //最も近いBulletの位置を取得
        let bulletPositions = self.getBulletPositions(ID: ID)
        var distanceBullet: Float = 10
        for bulletPosition in bulletPositions {
            let d = sqrt(pow(bulletPosition.position.x - position.x, 2) + pow(bulletPosition.position.z - position.z, 2))
            if d < distanceBullet {
                distanceBullet = d
            }
        }
        
        if counter % 14 == 13  && flag {
            shoot = true
        }
        if counter % 2 == 0 && distanceBullet < 0.1 {
            shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func toGoalSemiStrongShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        var flag = false
        
        if counter == 0 {
            let x = -1 * (self.fieldSize[0] - 1) / 2 * (2 * teamID - 1)
            let z = (self.fieldSize[1] - 1) / 2 * (2 * teamID - 1)
            movePlans = self.makePath(start: position, goal: SCNVector3(0.05 * Float(x), 0, 0.05 * Float(z)))
        }
        else {
            movePlans = prePlans
        }
        //最も近い敵Tankの位置を取得
        let enemyPositions = self.getEnemyPositions(ID: ID)
        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        //最も近いBulletの位置を取得
        let bulletPositions = self.getBulletPositions(ID: ID)
        var nearestPointBullet = (position: SCNVector3(1, 1, 1), theta: Float(0.0))
        var distanceBullet: Float = 10
        for bulletPosition in bulletPositions {
            let d = sqrt(pow(bulletPosition.position.x - position.x, 2) + pow(bulletPosition.position.z - position.z, 2))
            if d < distanceBullet {
                nearestPointBullet = bulletPosition
                distanceBullet = d
            }
        }
        if distanceBullet < 0.1 {
            let posRef = nearestPointBullet.position
            thetaRef = atan2(position.x - posRef.x, position.z - posRef.z)
            if distanceBullet < 0.07 {
                shoot = true
            }
        }
        else if distance < 0.1 {
            shoot = true
        }
        else {
            if counter % 14 == 13  && flag {
               shoot = true
            }
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func cpu1(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        //return -> (θ, shoot?, move-plans)
        let enemyPositions = self.getEnemyPositions(ID: ID)
        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance {
                nearestPoint = enemyPosition
                distance = d
            }
        }
        let thetaNew = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
        var shoot = false
        if counter % 14 == 13  && self.isNotDevidedWithWall(position1: nearestPoint, position2: position, len: 0.005){
           shoot = true
        }
        return (thetaNew, shoot, "")
    }
    
    func cpu2(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        var flag = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            let x = -1 * (self.fieldSize[0] - 1) / 2 * (2 * teamID - 1)
            let z = (self.fieldSize[1] - 1) / 2 * (2 * teamID - 1)
            movePlans = self.makePath(start: position, goal: SCNVector3(0.05 * Float(x), 0, 0.05 * Float(z)))
        }
        
        //最も近い敵Tankの位置を取得
        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        //最も近いBulletの位置を取得
        let bulletPositions = self.getBulletPositions(ID: ID)
        var nearestPointBullet = (position: SCNVector3(1, 1, 1), theta: Float(0.0))
        var distanceBullet: Float = 10
        for bulletPosition in bulletPositions {
            let d = sqrt(pow(bulletPosition.position.x - position.x, 2) + pow(bulletPosition.position.z - position.z, 2))
            if d < distanceBullet {
                nearestPointBullet = bulletPosition
                distanceBullet = d
            }
        }
        if distanceBullet < 0.1 {
            let posRef = self.calcPositionToShoot(tankPosition: position, bulletposition: nearestPointBullet.position, bulletTheta: nearestPointBullet.theta)
            thetaRef = atan2(position.x - posRef.x, position.z - posRef.z)
            if distanceBullet < 0.07 {
                shoot = true
            }
        }
        else if distance < 0.1 {
            shoot = true
        }
        else {
            if counter % 14 == 13  && flag {
               shoot = true
            }
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func toGoalNoShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var movePlans = ""

        //ゴールへ
        movePlans = toGoal(ID: ID)
        
        return (theta, false, movePlans)
    }
    
    func toGoalSemiRandomShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        
        let enemyPositions = self.getEnemyPositions(ID: ID)
        //ゴールへ
        movePlans = toGoal(ID: ID)

        for enemyPosition in enemyPositions {
            thetaRef = atan2(position.x - enemyPosition.x, position.z - enemyPosition.z) + pow(Float.random(in: -0.5 ..< 0.5), 3) / pow(0.5, 2)
        }
        
        if counter % 20 == 19 {
            shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func noMoveRandomShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }

        if count % 2 == 1 {
            thetaRef = theta + pow(Float.random(in: -2.5 ..< 2.5), 5) / pow(2.5, 4)
        }
        
        if counter % 20 == 19 {
            shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func noMoveSemiRandomShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }

        for enemyPosition in enemyPositions {
            thetaRef = atan2(position.x - enemyPosition.x, position.z - enemyPosition.z) + pow(Float.random(in: -0.5 ..< 0.5), 3) / pow(0.5, 2)
        }
        
        if counter % 20 == 19 {
            shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func randomMoveSemiRandomShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }
        else {
            let x = Int.random(in: -(self.fieldSize[0] - 1) / 2 ..< (self.fieldSize[0] + 1) / 2)
            let y = Int.random(in: -(self.fieldSize[1] - 1) / 2 ..< (self.fieldSize[1] + 1) / 2)
            movePlans = String(x) + "," + String(y)
        }
        
        if prePlans == "cancel" {
            let x = Int.random(in: -(self.fieldSize[0] - 1) / 2 ..< (self.fieldSize[0] + 1) / 2)
            let y = Int.random(in: -(self.fieldSize[1] - 1) / 2 ..< (self.fieldSize[1] + 1) / 2)
            movePlans = String(x) + "," + String(y)
        }
        else {
            let allyPositions = self.getAllyPositions(ID: ID)
            for allyPosition in allyPositions {
                if sqrt(pow(position.x - allyPosition.x, 2) + pow(position.z - allyPosition.z, 2)) < 0.05 {
                    movePlans = "cancel"
                }
            }
        }

        for enemyPosition in enemyPositions {
            thetaRef = atan2(position.x - enemyPosition.x, position.z - enemyPosition.z) + pow(Float.random(in: -0.5 ..< 0.5), 3) / pow(0.5, 2)
        }
        
        if counter % 20 == 19 {
            shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func randomMoveSemiStrongShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        var flag = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }
        else {
            let x = Int.random(in: -(self.fieldSize[0] - 1) / 2 ..< (self.fieldSize[0] + 1) / 2)
            let y = Int.random(in: -(self.fieldSize[1] - 1) / 2 ..< (self.fieldSize[1] + 1) / 2)
            movePlans = String(x) + "," + String(y)
        }
        
        if prePlans == "cancel" {
            let x = Int.random(in: -(self.fieldSize[0] - 1) / 2 ..< (self.fieldSize[0] + 1) / 2)
            let y = Int.random(in: -(self.fieldSize[1] - 1) / 2 ..< (self.fieldSize[1] + 1) / 2)
            movePlans = String(x) + "," + String(y)
        }
        else {
            let allyPositions = self.getAllyPositions(ID: ID)
            for allyPosition in allyPositions {
                if sqrt(pow(position.x - allyPosition.x, 2) + pow(position.z - allyPosition.z, 2)) < 0.05 {
                    movePlans = "cancel"
                }
            }
        }

        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        //最も近いBulletの位置を取得
        let bulletPositions = self.getBulletPositions(ID: ID)
        var nearestPointBullet = (position: SCNVector3(1, 1, 1), theta: Float(0.0))
        var distanceBullet: Float = 10
        for bulletPosition in bulletPositions {
            let d = sqrt(pow(bulletPosition.position.x - position.x, 2) + pow(bulletPosition.position.z - position.z, 2))
            if d < distanceBullet {
                nearestPointBullet = bulletPosition
                distanceBullet = d
            }
        }
        if distanceBullet < 0.1 {
            let posRef = nearestPointBullet.position
            thetaRef = atan2(position.x - posRef.x, position.z - posRef.z)
            if distanceBullet < 0.07 {
                shoot = true
            }
        }
        else if distance < 0.1 {
            shoot = true
        }
        else {
            if counter % 7 == 6  && flag {
               shoot = true
            }
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func noMoveStrongShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        var flag = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }

        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        //最も近いBulletの位置を取得
        let bulletPositions = self.getBulletPositions(ID: ID)
        var nearestPointBullet = (position: SCNVector3(1, 1, 1), theta: Float(0.0))
        var distanceBullet: Float = 10
        for bulletPosition in bulletPositions {
            let d = sqrt(pow(bulletPosition.position.x - position.x, 2) + pow(bulletPosition.position.z - position.z, 2))
            if d < distanceBullet {
                nearestPointBullet = bulletPosition
                distanceBullet = d
            }
        }
        if distanceBullet < 0.1 {
            let posRef = nearestPointBullet.position
            thetaRef = atan2(position.x - posRef.x, position.z - posRef.z)
            if distanceBullet < 0.07 {
                shoot = true
            }
        }
        else if distance < 0.1 {
            shoot = true
        }
        else {
            if flag {
               shoot = true
            }
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func toGoalStrongShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        var flag = false
        
        //ゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        movePlans = toGoal(ID: ID)

        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        //最も近いBulletの位置を取得
        let bulletPositions = self.getBulletPositions(ID: ID)
        var nearestPointBullet = (position: SCNVector3(1, 1, 1), theta: Float(0.0))
        var distanceBullet: Float = 10
        for bulletPosition in bulletPositions {
            let d = sqrt(pow(bulletPosition.position.x - position.x, 2) + pow(bulletPosition.position.z - position.z, 2))
            if d < distanceBullet {
                nearestPointBullet = bulletPosition
                distanceBullet = d
            }
        }
        if distanceBullet < 0.1 {
            let posRef = nearestPointBullet.position
            thetaRef = atan2(position.x - posRef.x, position.z - posRef.z)
            if distanceBullet < 0.07 {
                shoot = true
            }
        }
        else if distance < 0.1 {
            shoot = true
        }
        else {
            if flag {
               shoot = true
            }
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func forStage15(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        var flag = false
        
        let enemyPositions = self.getEnemyPositions(ID: ID)
        
        movePlans = "3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1/3,1/3,-1"
        if enemyPositions.isEmpty && prePlans != toGoal(ID: ID) {
            movePlans = "cancel"
        }
        if prePlans == "cancel" {
            movePlans = toGoal(ID: ID)
        }

        var nearestPoint = SCNVector3(1, 1, 1)
        var distance: Float = 10
        for enemyPosition in enemyPositions {
            let d = sqrt(pow(enemyPosition.x - position.x, 2) + pow(enemyPosition.z - position.z, 2))
            if d < distance && self.isNotDevidedWithWall(position1: enemyPosition, position2: position, len: 0.005) {
                nearestPoint = enemyPosition
                distance = d
                thetaRef = atan2(position.x - nearestPoint.x, position.z - nearestPoint.z)
                flag = true
            }
        }
        
        if counter % 20 == 19 && flag {
            shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func toEnemySemiRandomShoot(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var thetaRef: Float = theta
        var movePlans = ""
        var shoot = false
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }
        else {
            let (x, y) = self.positionToPoint(position: enemyPositions[0])
            movePlans = String(x) + "," + String(y)
            if movePlans != prePlans && prePlans != "cancel"{
                movePlans = "cancel"
            }
        }

        for enemyPosition in enemyPositions {
            thetaRef = atan2(position.x - enemyPosition.x, position.z - enemyPosition.z) + pow(Float.random(in: -0.5 ..< 0.5), 3) / pow(0.5, 2)
        }
        
        if counter % 20 == 19 {
            shoot = true
        }
        
        return (thetaRef, shoot, movePlans)
    }
    
    func forStage19_1(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var movePlans = ""
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }
        else if enemyPositions[0].x > -0.1 {
            movePlans = toGoal(ID: ID)
        }
        
        return (theta, false, movePlans)
    }
    
    func forStage19_2(ID: String, teamID: Int, position: SCNVector3, theta: Float, counter: Int, prePlans: String) -> (Float, Bool, String) {
        var movePlans = ""
        
        //敵がいなくなったらゴールへ
        let enemyPositions = self.getEnemyPositions(ID: ID)
        if enemyPositions.isEmpty {
            movePlans = toGoal(ID: ID)
        }
        else if enemyPositions[0].z < 0.05 {
            movePlans = toGoal(ID: ID)
        }
        
        return (theta, false, movePlans)
    }
}
