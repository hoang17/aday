//
//  MainController.swift
//  Group
//
//  Created by Hoang Le on 9/11/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import ESTabBarController
import UIColor_HexString
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import LNNotificationsUI
import UserNotifications

class MainController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*** 🍺🍺🍺 Setup status bar 🍺🍺🍺 ***/
        
        let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView
        statusBar?.backgroundColor = UIColor(red: (247.0 / 255.0), green: (247.0 / 255.0), blue: (247.0 / 255.0), alpha: 1)
        
        
        /*** 📢📢📢 Register for push notification 📢📢📢***/
        
        let application = UIApplication.shared
        
        // New API (iOS 10-)
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
                if granted {
                    application.registerForRemoteNotifications()
                } else {
                    print("notification request error: \(error)")
                }
            }
            
        } else {
            // Old APIs (-iOS 8-9)
            // depricated: iOS 10.0
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
            application.registerForRemoteNotifications()
        }
                        
        //📍Init db ref
        
        let realm = AppDelegate.realm
        let ref = FIRDatabase.database().reference()

        //📍Init current user
        
        AppDelegate.uid = (FIRAuth.auth()?.currentUser?.uid)!
        AppDelegate.name = (FIRAuth.auth()?.currentUser?.displayName)!
        
        //📍Init upload queue
        UploadHelper.sharedInstance.start()
        
        //📍Load current user from disk
        if let user = realm?.object(ofType: UserModel.self, forPrimaryKey: AppDelegate.uid) {
            AppDelegate.currentUser = user
        }
        
        //📍Update current user from cloud
        ref.child("users").child(AppDelegate.uid).observe(.value, with: { snapshot in
            
            let user = User(snapshot: snapshot)
            
            if user.updated == AppDelegate.currentUser?.updated {
                return
            }
            
            AppDelegate.currentUser = UserModel(user: user)
            
            try! AppDelegate.realm.write {
                AppDelegate.realm.add(AppDelegate.currentUser, update: true)
            }
        })
        
        /*** ⭐️⭐️⭐️ Loading following friends ⭐️⭐️⭐️***/
        
        ref.child("friends/\(AppDelegate.uid)").queryOrdered(byChild: "following").queryEqual(toValue: true).observe(.childAdded, with: { snapshot in
        
            let friend = Friend(snapshot: snapshot)
            
            ref.child("users").child(friend.fuid).observeSingleEvent(of: .value, with: { snapshot in
                
                let user = User(snapshot: snapshot)
                
                //print(user.name)
                
                var uploaded: Double = 0
                
                var friend = realm?.object(ofType: UserModel.self, forPrimaryKey: user.uid)
                
                if friend != nil {
                    uploaded = friend!.uploaded
                }
                
                // Update friend
                
                if user.uploaded != uploaded {
                    
                    friend = UserModel(user: user)
                    
                    try! realm?.write {
                        realm?.add(friend!, update: true)
                    }
                    print("updated \(friend!.name)")
                }
                
                ref.child("pins/\(user.uid)").queryOrdered(byChild: "date").queryStarting(atValue: AppDelegate.startdate).observe(.childAdded, with: { snapshot in
                    
                    let data = Clip(snapshot: snapshot)
                    
                    // Initial load - Check if pin has been modified
                    if let clip = realm?.object(ofType: ClipModel.self, forPrimaryKey: data.id) {
                        if clip.updated == data.updated {
                            return
                        }
                    }
                    
                    UploadHelper.sharedInstance.downloadClip(data.fname)
                    
                    let clip = ClipModel(clip: data)
                    try! realm?.write {
                        realm?.add(clip, update: true)
                        friend!.uploaded = clip.date
                    }
                })
                
                ref.child("pins/\(user.uid)").queryOrdered(byChild: "date").queryStarting(atValue: AppDelegate.startdate).observe(.childChanged, with: { snapshot in
                    
                    let data = Clip(snapshot: snapshot)
                    
                    // Initial load - Check if pin has been modified
                    if let clip = realm?.object(ofType: ClipModel.self, forPrimaryKey: data.id) {
                        if clip.updated == data.updated {
                            return
                        }
                    }
                    
                    let clip = ClipModel(clip: data)
                    try! realm?.write {
                        realm?.add(clip, update: true)
                    }
                })
                
            })
        })
        
        //📍Init tab bar
        let tabBarController = ESTabBarController(tabIconNames: ["clock", "globe", "record", "map", "archive"])

        self.addChildViewController(tabBarController!)
        self.view.addSubview((tabBarController?.view)!)
        tabBarController?.view.frame = self.view.bounds
        tabBarController?.didMove(toParentViewController: self)
        tabBarController?.selectionIndicatorHeight = 3
        tabBarController?.selectedColor = UIColor(hexString: "#CD5B45")
        tabBarController?.buttonsBackgroundColor = UIColor(red: (247.0 / 255.0), green: (247.0 / 255.0), blue: (247.0 / 255.0), alpha: 1)//UIColor(hexString: "#F6EBE0")
        // tabBarController.buttonsBackgroundColor = UIColor(hexString: "#FFF")
        
        //📍Adding tab screens
        tabBarController?.setView(UINavigationController(rootViewController: FriendsController()), at: 0)
        tabBarController?.setView(UINavigationController(rootViewController: SearchController()), at: 1)
        tabBarController?.setView(UINavigationController(rootViewController: MapController()), at: 3)
        tabBarController?.setView(UINavigationController(rootViewController: ProfileController()), at: 4)
        
        let cam = NCameraViewController()
        
        tabBarController?.setAction({
            self.present(cam, animated: true, completion: nil)
        }, at: 2)

        // tabBarController.highlightButtonAtIndex(1)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

