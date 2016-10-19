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
import Crashlytics
import DigitsKit
import FBSDKCoreKit
import FBSDKLoginKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var uid: String!
    static var currentUser: UserModel!
    static var realm: Realm!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Setup Firebase
        FIRApp.configure()
        // FIRDatabase.database().persistenceEnabled = true

        // Setup Fabric
        Fabric.with([Crashlytics.self, Answers.self, Digits.self])
        
        // Facebook setup
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        do {
            AppDelegate.realm = try Realm()
        } catch {
            print(error)
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.URLByAppendingPathExtension("lock"),
                realmURL.URLByAppendingPathExtension("log_a"),
                realmURL.URLByAppendingPathExtension("log_b"),
                realmURL.URLByAppendingPathExtension("note")
            ]
            let manager = NSFileManager.defaultManager()
            for URL in realmURLs {
                do {
                    try manager.removeItemAtURL(URL!)
                } catch {
                    print(error)
                }
            }
            AppDelegate.realm = try! Realm()
        }
        
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
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.backgroundColor = UIColor.whiteColor()
        
        if FIRAuth.auth()?.currentUser != nil && FBSDKAccessToken.currentAccessToken() != nil {
            self.logUser()
            self.window!.rootViewController = MainController()
        } else {
            window!.rootViewController = LoginController()
        }
        
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func showLogin() {
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromLeft, animations: {
            self.window!.rootViewController = LoginController()
            }, completion: nil)
    }
    
    func showMain() {
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromRight, animations: {
            self.window!.rootViewController = MainController()
            }, completion: nil)
    }

    // Handling open login url
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Facebook setup
        FBSDKAppEvents.activateApp()
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func logUser() {
        let u = FIRAuth.auth()!.currentUser!
        Crashlytics.sharedInstance().setUserEmail(u.email)
        Crashlytics.sharedInstance().setUserIdentifier(u.uid)
        Crashlytics.sharedInstance().setUserName(u.displayName)
    }
}

