//
//  AppDelegate.swift
//  Group
//
//  Created by Hoang Le on 6/15/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import DigitsKit
//import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit
import RealmSwift
import LNNotificationsUI
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var uid: String!
    static var name: String!
    static var currentUser: UserModel!
    static var realm: Realm!
    static var dayago = -14
    static var startdate: Double = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Setup Firebase
        FIRApp.configure()
        // FIRDatabase.database().persistenceEnabled = true

        // Setup Fabric
        Fabric.with([Digits.self])
        //Fabric.with([Crashlytics.self, Digits.self])
        
        // Facebook setup
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        do {
            AppDelegate.realm = try Realm()
        } catch {
            print(error)
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("log_a"),
                realmURL.appendingPathExtension("log_b"),
                realmURL.appendingPathExtension("note")
            ]
            let manager = FileManager.default
            for URL in realmURLs {
                do {
                    try manager.removeItemAtURL(URL!)
                } catch {
                    print(error)
                }
            }
            AppDelegate.realm = try! Realm()
        }
        
        let today = Date()
        let dayago = (Calendar.current as NSCalendar)
            .date(
                byAdding: .day,
                value: AppDelegate.dayago,
                to: today,
                options: []
        )
        AppDelegate.startdate = dayago?.timeIntervalSince1970 ?? 0
        
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [
            //NSForegroundColorAttributeName : UIColor.darkGrayColor(),
            NSFontAttributeName : UIFont(name: "OpenSans", size: 20.0)!
        ]
        
//        try! AppDelegate.realm.write {
//            AppDelegate.realm.deleteAll()
//        }
        
//        // Setup font
//        UITextField.appearance().font = UIFont(name: "OpenSans", size: 13.0)
//        UITextView.appearance().font = UIFont(name: "OpenSans", size: 13.0)
//        UILabel.appearance().font = UIFont(name: "OpenSans", size: 13.0)

        // Register push notification
//        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
//        application.registerUserNotificationSettings(notificationSettings)
//        application.registerForRemoteNotifications()
        
        
        /*** 🔥🔥🔥 Setup notification 🔥🔥🔥 ***/

        application.applicationIconBadgeNumber = 0
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            let replyAction = UNNotificationAction(
                identifier: "replyPin",
                title: "Reply",
                options: [])
            
            let remindAction = UNNotificationAction(
                identifier: "remindLater",
                title: "Remind me later",
                options: [])
            
            let category = UNNotificationCategory(
                identifier: "newPin",
                actions: [replyAction, remindAction],
                intentIdentifiers: [],
                options: [])
            
            center.setNotificationCategories([category])
            
        } else {
            LNNotificationCenter.default().notificationsBannerStyle = .light
            LNNotificationCenter.default().registerApplication(
                withIdentifier: "Pinly",
                name: "Pinly",
                icon: UIImage(named: "pin")!,
                defaultSettings: LNNotificationAppSettings.default())
        }
        
        /*** 🔥🔥🔥 End setup notification 🔥🔥🔥 ***/
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        
        if FIRAuth.auth()?.currentUser != nil && FBSDKAccessToken.current() != nil {
            self.window!.rootViewController = MainController()
            self.logUser()
        } else {
            do {
                try FIRAuth.auth()?.signOut()
            } catch {
                print(error)
            }
            FBSDKLoginManager().logOut()
            window!.rootViewController = LoginController()
        }
        
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if AppDelegate.uid != nil {
            
            //let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            
            let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
            var tokenString = ""
            for i in 0..<deviceToken.count {
                tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
            }
            print("Device Token:", tokenString)

            FriendsLoader.sharedInstance.saveDevice(tokenString)
        }
    }

    // depricated: iOS 10.0
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register push notification: ", error)
    }
    
    // depricated: iOS 10.0
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        if #available(iOS 10.0, *) {
            //
        }
        else {
            NotificationHelper.sharedInstance.present(userInfo)
        }
    }
    
    // depricated: iOS 10.0
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
//        if notificationSettings.types != .None {
//            application.registerForRemoteNotifications()
//        }
    }
    
    // depricated: iOS 10.0
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        print("action for local notification")
    }
    
    // depricated: iOS 10.0
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        print("action for remote notification")
    }
    
    func showLogin() {
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.window!.rootViewController = LoginController()
            }, completion: nil)
    }
    
    func showMain() {
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromRight, animations: {
            self.window!.rootViewController = MainController()
            }, completion: nil)
    }

    // Handling open fb login url
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Facebook setup
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func logUser() {
        let u = FIRAuth.auth()!.currentUser!
//        Crashlytics.sharedInstance().setUserEmail(u.email)
//        Crashlytics.sharedInstance().setUserIdentifier(u.uid)
//        Crashlytics.sharedInstance().setUserName(u.displayName)
    }
}

/*** 📢📢📢 Notification Delegate 📢📢📢***/

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Called when the application is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        
        print("notification: \(notification)")
        
        if let trigger = notification.request.trigger {
            switch trigger {
            case let n as UNPushNotificationTrigger:
                print("UNPushNotificationTrigger: \(n)")
            case let n as  UNTimeIntervalNotificationTrigger:
                print("UNTimeIntervalNotificationTrigger: \(n)")
            case let n as  UNCalendarNotificationTrigger:
                print("UNCalendarNotificationTrigger: \(n)")
            case let n as  UNLocationNotificationTrigger:
                print("UNLocationNotificationTrigger: \(n)")
            default:
                print(trigger)
                assert(false)
                break
            }
        }
        completionHandler([.badge, .alert, .sound])
    }
    
    // Called when the application is opened by notification
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        
        print("center: \(center)\nresponse: \(response)")
        let actionIdentifier = response.actionIdentifier
        print("actionIdentifier: \(actionIdentifier)")
        
        // TODO: Snooze notification to remind me later
        if response.actionIdentifier == "remindLater" {
            let newDate = Date(timeIntervalSinceNow: 900) // fire after 900 seconds
            //let pastdate = NSDate(timeIntervalSinceNow: -100) // fire immediately
            //let newDate = NSDate(timeInterval: 900, sinceDate: somedate)
            //scheduleNotification(at: newDate)
        }
        
        completionHandler()
    }
}
