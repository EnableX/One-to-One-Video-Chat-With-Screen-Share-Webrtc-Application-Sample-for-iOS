//
//  VCXConfrenceViewController.swift
//  sampleTextApp
//
//  Created by Hemraj on 16/11/18.
//  Copyright © 2018 VideoChat. All rights reserved.
//

import UIKit
import EnxRTCiOS
import SVProgressHUD
import ReplayKit

class VCXConfrenceViewController: UIViewController {

    
    @IBOutlet weak var sendLogBtn: UIButton!
    
    @IBOutlet weak var publisherNameLBL: UILabel!
    @IBOutlet weak var subscriberNameLBL: UILabel!
    @IBOutlet weak var messageLBL: UILabel!
    @IBOutlet weak var localPlayerView: EnxPlayerView!
    @IBOutlet weak var cameraBTN: UIButton!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionsContainerView: UIView!
    @IBOutlet weak var screenShare : UIButton!
    
    @IBOutlet weak var optionViewButtonlayout: NSLayoutConstraint!
    var roomInfo : VCXRoomInfoModel!
    var param : [String : Any] = [:]
    var remoteRoom : EnxRoom!
    var objectJoin : EnxRtc!
    var localStream : EnxStream!
    var listOfParticipantInRoom  = [Any]()
    var screenRecorder = RPScreenRecorder.shared()
    var activeTalkerView :UIView!
    var isScreenShareRunning : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        localPlayerView.layer.cornerRadius = 8.0
        localPlayerView.layer.borderWidth = 2.0
        localPlayerView.layer.borderColor = UIColor.lightGray.cgColor
        localPlayerView.layer.masksToBounds = true
        optionsView.layer.cornerRadius = 8.0
        //optionViewButtonlayout.constant = -100
//        let tapGuester = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
//        tapGuester.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tapGuester)
    
        // Adding Pan Gesture for localPlayerView
        let localViewGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didChangePosition))
        localPlayerView.addGestureRecognizer(localViewGestureRecognizer)
        if(roomInfo.room_id != nil){
            let defau = UserDefaults(suiteName: "group.com.enx.Videocall")
            defau?.set(roomInfo.room_id, forKey: "RoomId")
        }
        
        
        objectJoin = EnxRtc()
        self.createToken()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    // MARK: - didChangePosition
    /**
        This method will change the position of localPlayerView
     Input parameter :- UIPanGestureRecognizer
     **/
   @objc func didChangePosition(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        if sender.state == .began {
        } else if sender.state == .changed {
            if(location.x <= (UIScreen.main.bounds.width - (self.localPlayerView.bounds.width/2)) && location.x >= self.localPlayerView.bounds.width/2) {
                self.localPlayerView.frame.origin.x = location.x
                localPlayerView.center.x = location.x
            }
            if(location.y <= (UIScreen.main.bounds.height - (self.localPlayerView.bounds.height + 40)) && location.y >= (self.localPlayerView.bounds.height/2)+20){
                self.localPlayerView.frame.origin.y = location.y
                localPlayerView.center.y = location.y
            }
           
        } else if sender.state == .ended {
            print("Gesture ended")
        }
    }
    // MARK: - sendLogtoServerEvent
    /**
     input parameter - Any
     Return  - Nil
     This method will Save all Socket Event logs to server
     **/
    @IBAction func sendLogtoServerEvent(_ sender: Any) {
        guard remoteRoom != nil else {
            return
        }
        remoteRoom.postClientLogs()
        print("Send Logs")
    }
    
    // MARK: - createTokrn
    /**
     input parameter - Nil
     Return  - Nil
     This method will initiate the Room for stream
     **/
    private func createToken(){
        guard VCXNetworkManager.isReachable() else {
            self.showAleartView(message:"Kindly check your Network Connection", andTitles: "OK")
            return
        }
        let inputParam : [String : String] = ["name" :roomInfo.participantName , "role" :  roomInfo.role ,"roomId" : roomInfo.room_id, "user_ref" : "2236"]
        SVProgressHUD.show()
        VCXServicesClass.featchToken(requestParam: inputParam, completion:{tokenInfo  in
            DispatchQueue.main.async {
              //  Success Response from server
                if let token = tokenInfo.token {
                    
                    let videoSize : NSDictionary =  ["minWidth" : 480 , "minHeight" : 320 , "maxWidth" : 640, "maxHeight" :480]
                    
                    let localStreamInfo : NSDictionary = ["video" : self.param["video"]! ,"audio" : self.param["audio"]! ,"data" :self.param["chat"]! ,"name" :self.roomInfo.participantName!,"type" : "public","audio_only": false ,"maxVideoBW" : 120 ,"minVideoBW" : 300 , "videoSize" : videoSize]
                    
                   let roomInfo : NSDictionary  = ["allow_reconnect" : true , "number_of_attempts" : 3, "timeout_interval" : 20,"activeviews" : "view"]
                    guard let steam = self.objectJoin.joinRoom(token, delegate: self, publishStreamInfo: (localStreamInfo as! [AnyHashable : Any]), roomInfo: (roomInfo as! [AnyHashable : Any]), advanceOptions: nil) else{
                        SVProgressHUD.dismiss()
                        return
                    }
                    self.localStream = steam
                    self.localStream.delegate = self as EnxStreamDelegate
                }
                //Handel if Room is full
                else if (tokenInfo.token == nil && tokenInfo.error == nil){
                    self.showAleartView(message:"Token Denied. Room is full.", andTitles: "OK")
                }
                //Handeling server error
                else{
                    print(tokenInfo.error)
                    self.showAleartView(message:tokenInfo.error, andTitles: "OK")
                }
                SVProgressHUD.dismiss()
            }
        })
        
    }
    // MARK: - Show Alert
    /**
     Show Alert Based in requirement.
     Input parameter :- Message and Event name for Alert
     **/
    private func showAleartView(message : String, andTitles : String){
        let alert = UIAlertController(title: " ", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: andTitles, style: .default) { (action:UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
  /*  // MARK: - View Tap Event
    /**
     Its method will hide/unhide option View
     **/
  @objc func handleSingleTap(sender : UITapGestureRecognizer){
    if optionViewButtonlayout.constant >= 0{
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.optionViewButtonlayout.constant = -100
        }, completion: nil)
    }
    else{
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.optionViewButtonlayout.constant = 10
        }, completion: nil)
        }
    }*/
    // MARK: - Mute/Unmute
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will Mute/Unmute sound and change Button Property.
     **/
    @IBAction func muteUnMuteEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if sender.isSelected {
            localStream.muteSelfAudio(false)
            sender.isSelected = false
        }
        else{
            localStream.muteSelfAudio(true)
            sender.isSelected = true
        }
    }
    // MARK: - Camera On/Off
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will On/Off Camera and change Button Property.
     **/
    @IBAction func cameraOnOffEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if sender.isSelected {
            localStream.muteSelfVideo(false)
            sender.isSelected = false
            cameraBTN.isEnabled = true
        }
        else{
            localStream.muteSelfVideo(true)
            sender.isSelected = true
            cameraBTN.isEnabled = false
        }
    }
    // MARK: - Camera Angle
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will change Camera Angle and change Button Property.
     **/
    @IBAction func changeCameraAngle(_ sender: UIButton) {
        localStream.switchCamera()
    }
    @IBAction func startChatEvent(_ sender: UIButton) {
    }
    // MARK: - Speaker On/Off
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will On/Off Speaker and change Button Property.
     **/
    @IBAction func speakerOnOffEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if sender.isSelected {
            remoteRoom.switchMediaDevice("Speaker")
            sender.isSelected = false
        }
        else{
           remoteRoom.switchMediaDevice("EARPIECE")
            sender.isSelected = true
        }
    }
    // MARK: - Screen Share
    /**
     Input parameter : - Nil
     OutPut : - Nil
     Its method will used to start/Stop Screen share.
     **/
    @IBAction func startScreenShare(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if(!isScreenShareRunning){
            broadCastScreen()
        }
        else{
            //Screen Share all ready running
        }
    }

    private func broadCastScreen(){
        if #available(iOS 12.0, *) {
            
            if(localStream.streamId != nil){
                let defau = UserDefaults(suiteName: "group.com.enx.Videocall")
                defau?.set(localStream.streamId, forKey: "ClientID")
                EnxUtilityManager.shareInstance()?.setAppGroupsName("group.com.enx.Videocall", withUserKey: "ClientID")
            }
            let broadCast = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            broadCast.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
            
            if let url = Bundle.main.url(forResource: "BroadcastExtension", withExtension: "appex", subdirectory: "PlugIns") {
                if let bundle = Bundle(url: url) {
                    broadCast.preferredExtension = bundle.bundleIdentifier
                }
            }
            
           // broadCast.preferredExtension = "com.enx.Videocall.BroadcastExtension"
            broadCast.isHidden = true
            broadCast.showsMicrophoneButton = false
            let buttonPress = NSSelectorFromString("buttonPressed:")
             if broadCast.responds(to: buttonPress) {
                broadCast.perform(buttonPress, with: nil)
            }
            self.view.addSubview(broadCast)
            self.view.bringSubviewToFront(broadCast)
            broadCast.center = self.view.center
            broadCast.setNeedsLayout()
        }
    }
    // MARK: - End Call
    /**
     Input parameter : - Any
     OutPut : - Nil
     Its method will Closed Call and exist from Room
     **/
    @IBAction func endCallEvent(_ sender: Any) {
        self.leaveRoom()
        
    }
    // MARK: - Leave Room
    /**
     Input parameter : - Nil
     OutPut : - Nil
     Its method will exist from Room
     **/
    private func leaveRoom(){
        UIApplication.shared.isIdleTimerDisabled = false
        remoteRoom?.disconnect()
        //self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
/*
 // MARK: - Extension
 Delegates Methods
 */

extension VCXConfrenceViewController : EnxRoomDelegate, EnxStreamDelegate {
    //Mark - EnxRoom Delegates
    /*
     This Delegate will notify to User Once he got succes full join Room
     */
    func room(_ room: EnxRoom?, didConnect roomMetadata: [AnyHashable : Any]?){
        remoteRoom = room
        remoteRoom.publish(localStream)
        if remoteRoom.isRoomActiveTalker{
            if let name = remoteRoom.whoami()!["name"] {
                publisherNameLBL.text = (name as! String)
                localPlayerView.bringSubviewToFront(publisherNameLBL)
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.localPlayerView.frame = UIScreen.main.bounds
//                })
                
            }
            localStream.attachRenderer(localPlayerView)
            localPlayerView.contentMode = UIView.ContentMode.scaleAspectFill
        }
        if listOfParticipantInRoom.count >= 1 {
            listOfParticipantInRoom.removeAll()
        }
        listOfParticipantInRoom.append(roomMetadata!["userList"] as! [Any])
        print(listOfParticipantInRoom);
    }
    /*
     This Delegate will notify to User Once he Getting error in joining room
     */
    func room(_ room: EnxRoom?, didError reason: [Any]?) {
        self.showAleartView(message:"Room error", andTitles: "OK")
    }
    /*
     This Delegate will notify to  User Once he/she Publisg Stream
     */
    func room(_ room: EnxRoom?, didPublishStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to  User Once he/she will Unpublisg Stream
     */
    func room(_ room: EnxRoom?, didUnpublishStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if any new person added to room
     */
    func room(_ room: EnxRoom?, didAddedStream stream: EnxStream?) {
        room!.subscribe(stream!)
    }
    /*
     This Delegate will notify to User if any person Romove from room
     */
    func room(_ room: EnxRoom?, didRemovedStream stream: EnxStream?) {
        //To Do
        if stream == nil{
            subscriberNameLBL.isHidden = true
        }
    }
    /*
     This Delegate will notify to User to subscribe other user stream
     */
    func room(_ room: EnxRoom?, didSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User to Unsubscribe other user stream
     */
    func room(_ room: EnxRoom?, didUnSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if Room Got discunnected
     */
    func didRoomDisconnect(_ response: [Any]?) {
       self.navigationController?.popViewController(animated: true)
    }
    /*
     This Delegate will notify to User if any person join room
     */
    func room(_ room: EnxRoom?, userDidJoined Data: [Any]?) {
        //listOfParticipantInRoom.append(Data!)
    }
    /*
     This Delegate will notify to User if any person got discunnected
     */
    func room(_ room: EnxRoom?, userDidDisconnected Data: [Any]?) {
        //self.leaveRoom()
    }
    /*
     This Delegate will notify to end User if Room connecton status changed
     */
    func room(_ room: EnxRoom?, didChange status: EnxRoomStatus) {
        //To Do
    }
    /*
     This Delegate will notify to User if any participant will send chat data
     */
    func room(_ room: EnxRoom, didMessageReceived data: [Any]?) {
        //TO DO
    }
    /*
    This Delegate will notify to User if any participant will send message over custome signaling
    */
    func room(_ room: EnxRoom, didUserDataReceived data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to User if any participant will start sharing files
    */
    func room(_ room: EnxRoom, didFileUploadStarted data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to self  if he/she will start sharing files
    */
    func room(_ room: EnxRoom, didInitFileUpload data: [Any]?) {
        //To Do
    }
    /*
    This Delegate will notify to self  if file sharing success
    */
    func room(_ room: EnxRoom, didFileUploaded data: [Any]?) {
        //To DO
    }
    /*
    This Delegate will notify to self  if file sharing failed
    */
    func room(_ room: EnxRoom, didFileUploadFailed data: [Any]?) {
        //To DO
    }
    /*
    This Delegate will notify to end user  if file available
    */
    func room(_ room: EnxRoom, didFileAvailable data: [Any]?) {
        //TO DO
    }
    /*
    This Delegate will notify to self  if file download failed
    */
    func room(_ room: EnxRoom, didFileDownloadFailed data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to self  if file download success
    */
    func room(_ room: EnxRoom, didFileDownloaded data: String?) {
        //TO DO
    }
    /*
     This Delegate will notify to User to get updated attributes of particular Stream
     */
    func room(_ room: EnxRoom?, didUpdateAttributesOf stream: EnxStream?) {
        //To Do
    }
    
    /*
     This Delegate will notify when internet connection lost.
     */
    func room(_ room: EnxRoom, didConnectionLost data: [Any]) {
      
    }
    
    /*
     This Delegate will notify on connection interuption example switching from Wifi to 4g.
     */
    func room(_ room: EnxRoom, didConnectionInterrupted data: [Any]) {
      
    }
    
    /*
     This Delegate will notify reconnect success.
     */
    func room(_ room: EnxRoom, didUserReconnectSuccess data: [AnyHashable : Any]) {
       
    }
    
    /*
     This Delegate will notify to User if any new User Reconnect the room
     */
    func room(_ room:EnxRoom?, didReconnect reason: String?){
        
    }
    /*
     This Delegate will notify to User with active talker list
     */
    func room(_ room: EnxRoom?, didActiveTalkerList Data: [Any]?) {
        // Handle individual stream and there player
    }
    func room(_ room: EnxRoom?, didActiveTalkerView view: UIView?) {
        activeTalkerView = view!
        self.view.addSubview(activeTalkerView)
        bringSubViewToFront()
    }
    private func bringSubViewToFront(){
         if(activeTalkerView != nil){
         self.view.bringSubviewToFront(activeTalkerView)
        }
        self.view.bringSubviewToFront(localPlayerView)
        self.view.bringSubviewToFront(optionsContainerView)
        self.view.bringSubviewToFront(sendLogBtn)
         self.view.bringSubviewToFront(screenShare)
    }
    private func handleViewOnScreenShare(isScreenShre : Bool){
        if(activeTalkerView != nil){
        var rect = activeTalkerView.frame;
        if(isScreenShre){
            rect.origin.y = rect.height - 140
            rect.size.width = 100
            rect.size.height = 130
        }
        else{
            rect.origin.y = 0
            rect.size.width = self.view.frame.width
            rect.size.height = self.view.frame.height
        }
        activeTalkerView.frame = rect
        }
    }
    
    func room(_ room: EnxRoom?, didEventError reason: [Any]?) {
        let resDict = reason![0] as! [String : Any]
        self.showAleartView(message:resDict["msg"] as! String, andTitles: "OK")
    }
    
    /* To Ack. moderator on switch user role.
   */
    func room(_ room: EnxRoom?, didSwitchUserRole data: [Any]?) {
        
    }
    
    /* To all participants that user role has chnaged.
    */
    func room(_ room: EnxRoom?, didUserRoleChanged data: [Any]?) {
        
    }
    
    /*
     This Delegate will Acknowledge setting advance options.
     */
    func room(_ room: EnxRoom?, didAcknowledgementAdvanceOption data: [AnyHashable : Any]?) {
        
    }
    
    /*
     This Delegate will notify battery updates.
     */
    func room(_ room: EnxRoom?, didBatteryUpdates data: [AnyHashable : Any]?) {
        
    }
    
    /*
     This Delegate will notify change on stream aspect ratio.
     */
    func room(_ room: EnxRoom?, didAspectRatioUpdates data: [Any]?) {
        
    }
    
    /*
     This Delegate will notify change video resolution.
     */
    func room(_ room: EnxRoom?, didVideoResolutionUpdates data: [Any]?) {
        
    }
    
    //Mark- EnxStreamDelegate Delegate
    /*
        This Delegate will notify to current User If User will do Self Stop Video
     */
    func stream(_ stream: EnxStream?, didSelfMuteVideo data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If User will do Self Start Video
     */
    func stream(_ stream: EnxStream?, didSelfUnmuteVideo data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If User will do Self Mute Audio
     */
    func stream(_ stream: EnxStream?, didSelfMuteAudio data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If User will do Self UnMute Audio
     */
    func stream(_ stream: EnxStream?, didSelfUnmuteAudio data: [Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If any user has stoped There Video or current user Video
     */
    func didVideoEvents(_ data: [AnyHashable : Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If any user has stoped There Audio or current user Video
     */
    func didAudioEvents(_ data: [AnyHashable : Any]?) {
        //To Do
    }
    func room(_ room: EnxRoom?, didStartScreenShareACK data: [Any]?) {
        print("Streen scare started");
        isScreenShareRunning = true
    }
    func room(_ room: EnxRoom?, didStoppedScreenShareACK Data: [Any]?) {
        print("Streen scare stoped");
        isScreenShareRunning = false
    }
    func room(_ room: EnxRoom?, didScreenShareStarted stream: EnxStream?) {
         print("Streen scare started");
        self.handleViewOnScreenShare(isScreenShre: true)
        if(stream?.enxPlayerView != nil){
            let player = stream?.enxPlayerView!
            player!.frame = self.view.bounds
            self.view.addSubview(player!)
            self.bringSubViewToFront()
        }
    }
    func room(_ room: EnxRoom?, didScreenShareStopped stream: EnxStream?) {
         print("Streen scare stoped");
        self.handleViewOnScreenShare(isScreenShre: false)
        if(stream?.enxPlayerView != nil){
            let player = stream?.enxPlayerView!
            player!.removeFromSuperview()
        }
    }
}
