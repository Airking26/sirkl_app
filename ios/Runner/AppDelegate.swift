import UIKit
import Flutter
import FirebaseCore
import PushKit
import flutter_callkit_incoming
import CoinbaseWalletSDK
import restart

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
           UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
         }
      let mainQueue = DispatchQueue.main
      let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
      voipRegistry.delegate = self
      voipRegistry.desiredPushTypes = [PKPushType.voIP]
      
      RestartPlugin.generatedPluginRegistrantRegisterCallback = { [weak self] in
          GeneratedPluginRegistrant.register(with: self!)
      }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if #available(iOS 13.0, *) {
            if (CoinbaseWalletSDK.isConfigured == true) {
                if (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
                    return true
                }
            }
        }
        
        return super.application(app, open: url, options: options)
    }
    
    // Call back from Recent history
    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if #available(iOS 13.0, *) {
                 if (CoinbaseWalletSDK.isConfigured == true) {
                     if let url = userActivity.webpageURL,
                        (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
                         return true
                     }
                 }
             }
        
        guard let handleObj = userActivity.handle else {
            return false
        }
        
        guard let isVideo = userActivity.isVideo else {
            return false
        }
        let nameCaller = handleObj.getDecryptHandle()["nameCaller"] as? String ?? ""
        let handle = handleObj.getDecryptHandle()["handle"] as? String ?? ""
        let data = flutter_callkit_incoming.Data(id: UUID().uuidString, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
        //set more data...
        data.nameCaller = "Johnny"
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.startCall(data, fromPushKit: true)
        
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print(deviceToken)
        //Save deviceToken to your server
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith")
        guard type == .voIP else { return }
        
        let id = payload.dictionaryPayload["id"] as? String ?? ""
        let nameCaller = payload.dictionaryPayload["caller_name"] as? String ?? ""
        let handle = payload.dictionaryPayload["handle"] as? String ?? ""
        let callerId = payload.dictionaryPayload["caller_id"] as? String ?? ""
        let userCalled = payload.dictionaryPayload["called_id"] as? String ?? ""
        let callId = payload.dictionaryPayload["call_id"] as? String ?? ""
        let channel = payload.dictionaryPayload["channel"] as? String ?? ""

        
        let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller, handle: handle, type: 0)
        data.extra = ["userCalling": callerId, "userCalled": userCalled, "callId": callerId, "channel": channel]
        //if(UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive){
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
        
    }
}
