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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Setup Firebase
        FIRApp.configure()
        
        // Setup Fabric
        Fabric.with([Crashlytics.self, Answers.self, Digits.self])
        
        // Facebook setup
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

//        for name in UIFont.familyNames() {
//            print(name)
//            print(UIFont.fontNamesForFamilyName(name))
//        }
        
        // Setup font
//        UITextField.appearance().font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
//        UITextView.appearance().font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
//        UILabel.appearance().font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        
        // Setup nav controller        
        //let loginController: LoginController = LoginController()
//        let navigationController = UINavigationController()
//        navigationController.navigationBarHidden = false
//        navigationController.hidesBarsOnSwipe = true
        
//        if (FBSDKAccessToken.currentAccessToken() != nil && Digits.sharedInstance().session() != nil)
//        {
//            // Setup FirebaseAuth
//            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
//            FIRAuth.auth()?.signInWithCredential(credential){(currentUser, error) in
//                if (error == nil){
//                    // User already logged in
//                    self.logUser()
////                    navigationController.pushViewController(LoginController(), animated: false)
////                    navigationController.pushViewController(HomeController(), animated: false)
////                    navigationController.pushViewController(FriendsController(), animated: false)
//                }
//                else{
////                    navigationController.pushViewController(LoginController(), animated: false)
//                }
//            }
//        } else{
////            navigationController.pushViewController(LoginController(), animated: false)
//        }
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = MainController()
        window!.backgroundColor = UIColor.whiteColor()
        window!.makeKeyAndVisible()
        
        return true
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

