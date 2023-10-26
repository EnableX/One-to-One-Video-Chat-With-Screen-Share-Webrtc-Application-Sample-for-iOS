# Building a 1-to-1 RTC iOS App with EnableX iOS Toolkit: A Sample Application Guide

Introduction: 1-to-1 Real-Time Communication with EnableX on iOS

This 1-to-1-Video-Chat-With-Screen-Share-Webrtc-Application-Sample-for-iOS demonstrate the use of EnableX platform Video APIs (https://www.enablex.io/developer/video-api/server-api) and iOS Toolkit (https://www.enablex.io/developer/video-api/client-api/ios-toolkit/).  

Key Features:

Dynamic Virtual Room Creation: Experience the power of real-time communication as this app dynamically crafts a virtual room on the EnableX platform via REST API calls.
Role-Based Access: Whether you're a Moderator or a Participant, you can enter the virtual room using the same Room ID credentials.
Speedy Deployment: With pre-configured settings for the EnableX-hosted Application Server, you can start testing the app instantly.

EnableX Developer Center: https://developer.enablex.io/

## 1. How to get started

### 1.1 Prerequisites

#### 1.1.1 App Id and App Key 

* Register with EnableX [https://portal.enablex.io/cpaas/trial-sign-up/] 
* Create your Application
* Get your App ID and App Key delivered to your email



#### 1.1.2 Sample iOS Client 

* Clone or download this Repository [https://github.com/EnableX/One-to-One-Video-Chat-With-Screen-Share-Webrtc-Application-Sample-for-iOS.git] 

#### 1.1.3 Test Application Server

You need to set up an Application Server to provision Web Service API for your iOS Application to enable Video Session. 

To help you to try our iOS Application quickly, without having to set up Application Server, this Application is shipped pre-configured to work in a "try" mode with EnableX hosted Application Server i.e. https://demo.enablex.io. 

Our Application Server restricts a single Session Duations to 10 minutes, and allows 1 moderator and not more than 1 participant in a Session.

Once you tried EnableX iOS Sample Application, you may need to set up your own  Application Server and verify your Application to work with your Application Server.  Refer to point 2 for more details on this.

#### 1.1.4 Configure iOS Client 


* Open the App
* Go to VCXConstant.swift and change the following:
``` 
 /* To try the App with Enablex Hosted Service you need to set the kTry = true
 When you setup your own Application Service, set kTry = false */
 let kTry = true

 /* Your Web Service Host URL. Keet the defined host when kTry = true */
 let kBasedURL = "https://demo.enablex.io/"
     
 /* Your Application Credential required to try with EnableX Hosted Service
 When you setup your own Application Service, remove these */
 let kAppId    = ""
 let kAppkey   = ""
 ```
 
 Note: The distributable comes with demo username and password for the Service. 

### 1.2 Test

#### 1.2.1 Open the App

* Open the App in your Device. You get a form to enter Credentials i.e. Name & Room Id.
* You need to create a Room by clicking the "Create Room" button.
* Once the Room Id is created, you can use it and share with others to connect to the Virtual Room to carry out an RTC Session either as a Moderator or a Participant (Choose applicable Role in the Form).

Note: Only one user with Moderator Role allowed to connect to a Virtual Room while trying with EnableX Hosted Service. Your Own Application Server can allow upto 5 Moderators.
 
Note:- In case of emulator/simulator your local stream will not create. It will create only on real device.

## 2. Set up Your Own Application Server

You may need to setup your own Application Server after you tried the Sample Application with EnableX hosted Server. We have differnt variants of Appliciation Server Sample Code. Pick the one in your preferred language and follow instructions given in respective README.md file.

*NodeJS: [https://github.com/EnableX/Video-Conferencing-Open-Source-Web-Application-Sample.git]
*PHP: [https://github.com/EnableX/Group-Video-Call-Conferencing-Sample-Application-in-PHP]

Note the following:

* You need to use App ID and App Key to run this Service.
* Your iOS Client End Point needs to connect to this Service to create Virtual Room and Create Token to join the session.
* Application Server is created using EnableX Server API while Rest API Service helps in provisioning, session access and post-session reporting.  

To know more about Server API, go to:
https://www.enablex.io/developer/video-api/server-api



## 3. iOS Toolkit

This Sample Application uses EnableX iOS Toolkit to communicate with EnableX Servers to initiate and manage Real-Time Communications. Please update your Application with latest version of EnableX IOS Toolkit as and when a new release is available. 

* Documentation: https://www.enablex.io/developer/video-api/client-api/ios-toolkit/
* Download Toolkit: https://www.enablex.io/developer/video-api/client-api/ios-toolkit/

## 4. Application Walk-through

### 4.1 Create Token

We create a Token for a Room Id to get connected to EnableX Platform to connect to the Virtual Room to carry out a RTC Session.

To create Token, we make use of Server API. Refer following documentation:
https://www.enablex.io/developer/video-api/server-api/rooms-route/#create-token


### 4.2 Connect to a Room, Initiate & Publish Stream

We use the Token to get connected to the Virtual Room. Once connected, we intiate local stream and publish into the room. Refer following documentation for this process:
https://www.enablex.io/developer/video-api/client-api/ios-toolkit/room-connection/#connect-room


### 4.3 Play Stream

We play the Stream into EnxPlayerView Object.
``` 
let streamView = EnxPlayerView(frame: CGRect) 
self.view.addSubview(streamView) 
localStream.attachRenderer(streamView) 
  ```
More on Player: https://www.enablex.io/developer/video-api/client-api/ios-toolkit/play-stream/

### 4.4 Handle Server Events

EnableX Platform will emit back many events related to the ongoing RTC Session as and when they occur implicitly or explicitly as a result of user interaction. We use delegates of handle all such events.

``` 
/* Example of Delegates */

/* Delegate: didConnect 
Handles successful connection to the Virtual Room */ 

func room(_ room: EnxRoom?, didConnect roomMetadata: [AnyHashable : Any]?) { 
    /* You may initiate and publish your stream here */
} 


/* Delegate: didError
 Error handler when room connection fails */
 
func room(_ room: EnxRoom?, didError reason: String?) { 

} 

 
/* Delegate: didAddedStream
 To handle any new stream added to the Virtual Room */
 
func room(_ room: EnxRoom?, didAddedStream stream: EnxStream?) { 
    /* Subscribe Remote Stream */
} 

/* Delegate: activeTalkerList
 To handle any time Active Talker list is updated */
  
func room(_ room: EnxRoom?, activeTalkerList Data: [Any]?) { 
    /* Handle Stream Players */
}
func didRoomDisconnect(_ response: [Any]?) {
    /* Handel UI once you disconnected with enablex room */
}

```
### 4.5 Screen Share Warm Up
## Note:- Screen share feature will once compile and run on real device, Simulatore will not work
    
The screen sharing feature is a little bit tricky in iOS due to the strict screen capturing policies from Apple. 
To Start screen share follow these steps :-
#### Step 1 Add Screen Share Trage
``` 
    Go To -> Project -> File -> Traget -> Broadcast Upload Extension
    Set the bundle ID for Broadcast traget Exm:- com.companyName.Appname.Broadcast.extension
    
```
![Broadcast](./Broadcast.png)  

#### Step 2 Add App Gorups
 ```
 Add app groups to your project traget and extension traget. 
 Here app group required to exchanges required data from app to extension or vice versa.
 ```       
![group1](./group1.png) 

![group2](./group2.png)
       
#### Step 3 Set the stream ID of screen share owner, before start screen share to Enablex SDK

#### In Objective- c
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.enx.Videocall"];
            [userDefault setObject:_localStream.streamId forKey:@"ClientID"];
                [userDefault synchronize];
                [[EnxUtilityManager shareInstance] setAppGroupsName:@"group.com.enx.Videocall" withUserKey:@"ClientID"];

#### In Swift
            let defau = UserDefaults(suiteName: "group.com.enx.Videocall")
            defau?.set(localStream.streamId, forKey: "ClientID")
            EnxUtilityManager.shareInstance()?.setAppGroupsName("group.com.enx.Videocall", withUserKey: "ClientID")

    
#### Step 4 How to broadcast Screen :- Here in this example we are using RPSystemBroadcastPickerView
#### In Objective- c
        RPSystemBroadcastPickerView *pickerView = [[RPSystemBroadcastPickerView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        pickerView.translatesAutoresizingMaskIntoConstraints = false;
        pickerView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin);
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"BroadCastExtension" withExtension:@"appex" subdirectory:@"PlugIns"];
        if(url != nil){
            NSBundle *bundle = [NSBundle bundleWithURL:url];
            if(bundle != nil){
                pickerView.preferredExtension= bundle.bundleIdentifier;
            }
        }
        pickerView.hidden = true;
        pickerView.showsMicrophoneButton = false;
        SEL buttonPress = NSSelectorFromString(@"buttonPressed:");
        if ([pickerView respondsToSelector:buttonPress]){
            [pickerView performSelector:buttonPress withObject:nil];
        }
        [self.view addSubview:pickerView];
        [self.view bringSubviewToFront:pickerView];
        pickerView.center = self.view.center;

#### In Swift
            let broadCast = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            broadCast.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
            
            if let url = Bundle.main.url(forResource: "BroadcastExtension", withExtension: "appex", subdirectory: "PlugIns") {
                if let bundle = Bundle(url: url) {
                    broadCast.preferredExtension = bundle.bundleIdentifier
                }
            }
            broadCast.isHidden = true
            broadCast.showsMicrophoneButton = false
            let buttonPress = NSSelectorFromString("buttonPressed:")
             if broadCast.responds(to: buttonPress) {
                broadCast.perform(buttonPress, with: nil)
            }
            self.view.addSubview(broadCast)
            self.view.bringSubviewToFront(broadCast)
            broadCast.center = self.view.center

#### Step 5 Handle screen share Dalegate methods
        
#### Objective - c
            // Strat screen share acknowledgment 
        -(void)room:(EnxRoom *)room didStartScreenShareACK:(NSArray * _Nullable)Data{
            // Owner of the start screen share will receive this delegate method
        }
        // Stop screen share acknowledgment 
        -(void)room:(EnxRoom *)room didStoppedScreenShareACK:(NSArray * _Nullable)Data{
            // Owner of the stop screen share will receive this delegate method
        }
        // Screen share started 
        -(void)room:(EnxRoom *)room didScreenShareStarted:(EnxStream *)stream{
        // Other participant in same room will receive delegate method for with strat screen share details. 
        }
        // Screen share Stoped 
        -(void)room:(EnxRoom *)room didScreenShareStopped:(EnxStream *)stream{
           // Other participant in same room will receive delegate method for with stop screen share details.
        }
#### In Swift
    // Strat screen share acknowledgment 
        func room(_ room: EnxRoom?, didStartScreenShareACK data: [Any]?) {
            // Owner of the start screen share will receive this delegate method
        }
    // Stop screen share acknowledgment
        func room(_ room: EnxRoom?, didStoppedScreenShareACK Data: [Any]?) {
            // Owner of the stop screen share will receive this delegate method
        }
    // Screen share started
        func room(_ room: EnxRoom?, didScreenShareStarted stream: EnxStream?) {
            // Other participant in same room will receive delegate method for with strat screen share details.
        }
    // Screen share Stoped
        func room(_ room: EnxRoom?, didScreenShareStopped stream: EnxStream?) {
            // Other participant in same room will receive delegate method for with stop screen share details.
        }
## 5. Demo

EnableX provides hosted Demo Application Server of different use-case for you to try out.

1. Try a quick Video Call: https://try.enablex.io
2. Sign up for a free trial https://portal.enablex.io/cpaas/trial-sign-up/
