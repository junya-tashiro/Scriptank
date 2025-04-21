//
//  ForConnection.swift
//  AR-Tank
//
//  Created by 田代純也 on 2023/12/14.
//
//  対戦画面のクラス: BattleViewController
//  接続用のクラス拡張

import Foundation
import SceneKit
import ARKit
import MultipeerConnectivity

extension BattleViewController: MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate{
    //初期化
    func initMultipeerSession(isAdvertiser: Bool, receivedDataHandler: @escaping (Data, MCPeerID) -> Void ) {
        mpsession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mpsession.delegate = self
        //adveiriser
        if isAdvertiser {
            serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: BattleViewController.serviceType)
            serviceAdvertiser.delegate = self
            serviceAdvertiser.startAdvertisingPeer()
        }
        //browser
        else {
            serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: BattleViewController.serviceType)
            serviceBrowser.delegate = self
            serviceBrowser.startBrowsingForPeers()
        }
    }
            
    //データ送信
    func sendToAllPeers(_ data: Data) {
        do {
            try mpsession.send(data, toPeers: mpsession.connectedPeers, with: .reliable)
        } catch {}
    }
    
    var connectedPeers: [MCPeerID] {
        return mpsession.connectedPeers
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedData(data, from: peerID)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    
    //advertiserへ接続要求
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        //ルーム名, 自身のUUID, ユーザー名を送信
        let str: String = self.roomName + "/" + UIDevice.current.identifierForVendor!.uuidString + "/" + self.myName
        let data: Data = Data(str.utf8)
        browser.invitePeer(peerID, to: mpsession, withContext: data, timeout: 5)
    }
    
    //browserから接続要求を受信
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let str = String(decoding: context!, as: UTF8.self)
        let list = str.components(separatedBy: "/")
        //ルーム名が一致し, 人数が8人未満, かつ同一IDのメンバーがいなかったら
        if list[0] == self.roomName {
            if self.members.count < 8 {
                var flag = true
                for member in self.members {
                    if member.ID == list[1] {
                        flag = false
                    }
                }
                if flag && self.canJoin {
                    //参加を許可
                    invitationHandler(true, self.mpsession)
                    
                    //メンバーに追加
                    members.append(Member(view: self.view, name: list[2], ID: list[1], index: self.members.count, screenWidth: self.screenWidth, isCpu: false, updateShowFunc: updateShowFunc))
                    self.standby[list[1]] = false
                    //1秒後にメンバー情報を送信
                    self.perform(#selector(actionAfterConnect), with: nil, afterDelay: 1.0)
                    self.updateShowFunc()
                }
            }
        }
    }
    
    @objc func actionAfterConnect() {
        self.updateShowFunc()
    }
}
