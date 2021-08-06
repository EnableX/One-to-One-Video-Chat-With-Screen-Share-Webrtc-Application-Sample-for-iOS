//
//  SampleHandler.swift
//  BroadcastExtension
//
//  Created by VCX-LP-11 on 14/09/20.
//  Copyright © 2020 Jay Kumar. All rights reserved.
//

import ReplayKit


class SampleHandler: RPBroadcastSampleHandler {
        var screensgareClass = VCXScreenShareClass()
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
       // DispatchQueue.main.async {
            self.screensgareClass.joinRoom()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedBroadCast(_:)), name: NSNotification.Name(rawValue: "Disconnect"), object: nil)
        //}
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional. 
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        //DispatchQueue.main.async {
            self.screensgareClass.stopScreenShare()
        //}
        
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            //DispatchQueue.main.async {
                self.screensgareClass.processSampleBuffer(sampleBuffer)
            //}
            // Handle video sample buffer
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    @objc func finishedBroadCast(_ notification: Notification) {
        
        let userInfo = [NSLocalizedDescriptionKey : "Owner Disconnected",
                            NSLocalizedRecoverySuggestionErrorKey : "Owner Disconnected",
                            NSLocalizedFailureErrorKey : "Owner Disconnected"]
            let error = NSError(domain: "RPBroadcastErrorDomain", code: 1, userInfo: userInfo)
            finishBroadcastWithError(error)
    }
}

