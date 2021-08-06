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
import Accelerate



class VCXScreenShareClass: NSObject {
    
    static let kDownScaledFrameWidth = 540
    static let kDownScaledFrameHeight = 960
    
    var roomId : String!
    var remoteRoom : EnxRoom! = EnxRoom()
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
        let inputParam : [String : String] = ["name" :"Enx Screen Share" , "role" :  "participant" ,"roomId" : roomId ,"user_ref" : "2236"]
        SVProgressHUD.show()
        VCXServicesClass.featchToken(requestParam: inputParam, completion:{tokenInfo  in
            DispatchQueue.main.async {
              //  Success Response from server
                if let token = tokenInfo.token {
                    self.remoteRoom.connect(withScreenshare: token, withScreenDelegate: self)
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
        EnxUtilityManager.shareInstance()?.setAppGroupsName("group.com.enx.Videocall", withUserKey: "ClientID")
        let defau = UserDefaults(suiteName: "group.com.enx.Videocall")
        roomId = (defau?.object(forKey: "RoomId") as! String)
        self.createToken()
    }
    public func stopScreenShare(){
        guard remoteRoom != nil else {
            return
        }
        remoteRoom.stopScreenShare()
    }
    public func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard remoteRoom != nil else {
            return
        }
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            var outPixelBuffer: CVPixelBuffer? = nil
            CVPixelBufferLockBaseAddress(pixelBuffer, []);
            let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
            if (pixelFormat != kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                    //Frame type issue
            }
            let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                             VCXScreenShareClass.kDownScaledFrameWidth,
                                             VCXScreenShareClass.kDownScaledFrameHeight,
                                             pixelFormat,
                                             nil,
                                             &outPixelBuffer);
            if (status != kCVReturnSuccess) {
                print("Failed to create pixel buffer");
            }
            CVPixelBufferLockBaseAddress(outPixelBuffer!, []);
            // Prepare source pointers.
            var sourceImageY = vImage_Buffer(data: CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0),
                                             height: vImagePixelCount(CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)),
                                             width: vImagePixelCount(CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)),
                                             rowBytes: CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0))
            
            var sourceImageUV = vImage_Buffer(data: CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1),
                                              height: vImagePixelCount(CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)),
                                              width: vImagePixelCount(CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)),
                                              rowBytes: CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1))
            
            // Prepare out pointers.
            var outImageY = vImage_Buffer(data: CVPixelBufferGetBaseAddressOfPlane(outPixelBuffer!, 0),
                                          height: vImagePixelCount(CVPixelBufferGetHeightOfPlane(outPixelBuffer!, 0)),
                                          width: vImagePixelCount(CVPixelBufferGetWidthOfPlane(outPixelBuffer!, 0)),
                                          rowBytes: CVPixelBufferGetBytesPerRowOfPlane(outPixelBuffer!, 0))
            
            var outImageUV = vImage_Buffer(data: CVPixelBufferGetBaseAddressOfPlane(outPixelBuffer!, 1),
                                           height: vImagePixelCount(CVPixelBufferGetHeightOfPlane(outPixelBuffer!, 1)),
                                           width: vImagePixelCount( CVPixelBufferGetWidthOfPlane(outPixelBuffer!, 1)),
                                           rowBytes: CVPixelBufferGetBytesPerRowOfPlane(outPixelBuffer!, 1))
            
            
            var error = vImageScale_Planar8(&sourceImageY,
                                            &outImageY,
                                            nil,
                                            vImage_Flags(0));
            if (error != kvImageNoError) {
                print("Failed to down scale luma plane ")
                return;
            }
            
            error = vImageScale_CbCr8(&sourceImageUV,
                                      &outImageUV,
                                      nil,
                                      vImage_Flags(0));
            if (error != kvImageNoError) {
                print("Failed to down scale chroma plane")
                return;
            }
            CVPixelBufferUnlockBaseAddress(outPixelBuffer!, []);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, []);
        let time  = Int64(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * 1000000000)
        remoteRoom.sendVideoBuffer(outPixelBuffer!, withTimeStamp: time)
        
                
                //CMSampleBufferGetPresentationTimeStamp(sampleBuffer)*1000000000
            
        
       // remoteRoom.sendVideoBuffer(sampleBuffer)
    }
}
extension VCXScreenShareClass : EnxBroadCastDelegate {
    func broadCastConnected() {
        guard remoteRoom != nil else {
            return
        }
        remoteRoom.startScreenShare()
    }
    func failedToConnect(withBroadCast reason: [Any]) {
        //To Do
    }
    func didStartBroadCast(_ data: [Any]?) {
        //Handle Strat Screen share
    }
    func didStoppedBroadCast(_ data: [Any]?) {
        guard remoteRoom != nil else {
            return
        }
        remoteRoom.disconnect()
    }
    func broadCastDisconnected() {
        remoteRoom = nil
    }
    func disconnectedByOwner() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Disconnect"), object: nil, userInfo: nil)
    }
}
