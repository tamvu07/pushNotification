//
//  AppDelegate.swift
//  Mediage
//
//  Created by Vu Minh Tam on 2/22/21.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var firebaseToken: String = ""
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    // start add facebook
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
        return GIDSignIn.sharedInstance().handle(url)
    }
    // end facebook
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print("didReceiveRemoteNotification fetchCompletionHandler", userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // handle data
    func directWhenReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        if let type = userInfo["type"] as? String {
            switch type {
            case "event":
//                if let eventId = userInfo["type_id"] as? String {
//                    let eventItem = EventItem.init(from: ["id": Int(eventId) ?? -1])
//
//                    self.onAppDelegateDirectToEventDetail(eventItem: eventItem)
//                } else if let eventId = userInfo["type_id"] as? Int {
//                    let eventItem = EventItem.init(from: ["id": eventId])
//
//                    self.onAppDelegateDirectToEventDetail(eventItem: eventItem)
//                }
            break
            case "timeline":
//                if let activityId = userInfo["type_id"] as? String {
//                    self.onAppDelegateDirectToActivity(with: Int(activityId))
//                } else if let activityId = userInfo["type_id"] as? Int {
//                    self.onAppDelegateDirectToActivity(with: activityId)
//                }
            break
            case "follow":
//                if let accountId = userInfo["type_id"] as? String {
//                    self.onAppDelegateDirectToFollowingFollower(with: Int(accountId), type: type)
//                } else if let accountId = userInfo["type_id"] as? Int {
//                    self.onAppDelegateDirectToFollowingFollower(with: accountId, type: type)
//                }
            break
            default:
                break
            }
        }
    }
}
extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("fcmToken", token)
        self.firebaseToken = token
        UserDefaults.standard.set(token, forKey: "fcmToken")
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print("willPresent notification", userInfo)
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
//        self.directWhenReceiveRemoteNotification(userInfo: userInfo)
        if let aps = userInfo["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: Any] {
                if let message = alert["body"] as? NSString {
                    print(message)
                    // move viewcontroller
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                       let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                       let vc = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    vc.message = message as String
                       rootViewController.pushViewController(vc, animated: true)
                    
                }
            }
        }
        completionHandler()
    }
}

extension AppDelegate: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Did sign in with Google: \(user)")
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
            return
        }
        
        UserDefaults.standard.setValue(email, forKey: "email")
        
        DatabaseManager.shared.userExists(with: email, completion: { exists in
            
            let chatUser = ChatAppUser(firstName: email,
                                       lastName: firstName,
                                       emailAddress: lastName)
            if !exists {
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        // upload image
                        
                        if user.profile.hasImage {
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    return
                                }
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, success: { downloadUrl in
                                    UserDefaults.standard.setValue(downloadUrl, forKey: "Profile_picture_url")
                                    print(downloadUrl)
                                }, failured: { error in
                                    print("Storage manager error: \(error)")
                                })
                            }).resume()
                        }
                    }
                })
            }
        })
        
        guard let authentication = user.authentication else {
            print("Missing auth object off of google user")
            return
            
        }
          let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                         accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
            
            guard self != nil else {
                return
            }
            
            guard authResult != nil, error == nil else {
                print("Failed to log in with google credential")
                return
            }
            print("Successfully signed in with Google credential")
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        })
    }
 
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google uer was disconnected")
    }
    
}
