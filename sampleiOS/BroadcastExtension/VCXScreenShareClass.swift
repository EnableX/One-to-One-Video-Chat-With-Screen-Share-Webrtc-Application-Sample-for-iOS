//
//  VCXScreenShareClass.swift
//  BroadcastExtension
//
//  Created by VCX-LP-11 on 18/09/20.
//  Copyright © 2020 Jay Kumar. All rights reserved.
//

import UIKit
import EnxRTCiOS
import SVProgressHUD
import ReplayKit

class VCXScreenShareClass: NSObject {
    var roomId : String!
    var remoteRoom : EnxRoom!
    var objectJoin : EnxRtc!
    override init() {
        super.init()
    }
    // MARK: - createTokrn
    /**
     input parameter - Nil
     Return  - Nil
     This method will initiate the Room for stream
     **/
    private func createToken(){
        guard VCXNetworkManager.isReachable() else {
            //self.showAleartView(message:"Kindly check your Network Connection", andTitles: "OK")
            return
        }
        let inputParam : [String : String] = ["name" :"Enx Screen" , "role" :  "participant" ,"roomId" : roomId ,"user_ref" : "2236"]
        SVProgressHUD.show()
        VCXServicesClass.featchToken(requestParam: inputParam, completion:{tokenInfo  in
            DispatchQueue.main.async {
              //  Success Response from server
                if let token = tokenInfo.token {
                    let videoSize : NSDictionary =  ["minWidth" : 480 , "minHeight" : 320 , "maxWidth" : 640, "maxHeight" :480]
                    
                    let localStreamInfo : NSDictionary = ["video" :true ,"audio" : true ,"data" :true ,"name" :"Enx Screen","type" : "public","maxVideoBW" : 300 ,"minVideoBW" : 120 , "videoSize" : videoSize]
                    
                   let roomInfo : NSDictionary  = ["allow_reconnect" : true , "number_of_attempts" : 3, "timeout_interval" : 20]
                    
                    guard self.objectJoin.joinRoom(token, delegate: self, publishStreamInfo: (localStreamInfo as! [AnyHashable : Any]), roomInfo: (roomInfo as! [AnyHashable : Any]), advanceOptions: nil) != nil else{
                        SVProgressHUD.dismiss()
                        return
                    }
                }
                //Handel if Room is full
                else if (tokenInfo.token == nil && tokenInfo.error == nil){
                   // self.showAleartView(message:"Token Denied. Room is full.", andTitles: "OK")
                }
                //Handeling server error
                else{
                   // print(tokenInfo.error)
                   // self.showAleartView(message:tokenInfo.error, andTitles: "OK")
                }
                SVProgressHUD.dismiss()
            }
        })
    }
    public func joinRoom(){
        let defau = UserDefaults(suiteName: "group.com.enx.Videocall")
        roomId = (defau?.object(forKey: "RoomId") as! String)
        objectJoin = EnxRtc()
        self.createToken()
    }
    public func stopScreenShare(){
        guard remoteRoom != nil else {
            return
        }
        remoteRoom.stopScreenShare()
         remoteRoom.disconnect()
    }
    public func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard remoteRoom != nil else {
            return
        }
        remoteRoom.sendVideoBuffer(sampleBuffer)
    }
}
extension VCXScreenShareClass : EnxRoomDelegate {
    func room(_ room: EnxRoom?, didConnect roomMetadata: [AnyHashable : Any]?){
        remoteRoom = room
        remoteRoom.startScreenShare()
       
    }
    func room(_ room: EnxRoom?, didError reason: [Any]?) {
        //self.showAleartView(message:"Room error", andTitles: "OK")
    }
    /*
     This Delegate will notify to User if Room Got discunnected
     */
    func didRoomDisconnect(_ response: [Any]?) {
        remoteRoom = nil
        objectJoin = nil
        
    }
}
