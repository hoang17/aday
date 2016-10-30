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

class MainController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*** 🍺🍺🍺 Setup status bar 🍺🍺🍺 ***/
        
        let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView
        statusBar?.backgroundColor = UIColor(red: (247.0 / 255.0), green: (247.0 / 255.0), blue: (247.0 / 255.0), alpha: 1)
        
        
        /*** ⭐️⭐️⭐️ Register for push notificaiton ⭐️⭐️⭐️***/
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        
        //📍Init current user
        
        let realm = AppDelegate.realm
        
        let ref = FIRDatabase.database().reference()
        
        AppDelegate.uid = FIRAuth.auth()?.currentUser?.uid
        AppDelegate.name = FIRAuth.auth()?.currentUser?.displayName
        
        // Init upload queue
        UploadHelper.sharedInstance.start()
        
        // Load current user from disk
        if let user = realm.objectForPrimaryKey(UserModel.self, key: AppDelegate.uid) {
            AppDelegate.currentUser = user
        }
        
        // Update current user from cloud
        ref.child("users").child(AppDelegate.uid).observeEventType(.Value, withBlock: { snapshot in
            
            let user = User(snapshot: snapshot)
            
            if user.updated == AppDelegate.currentUser?.updated {
                return
            }
            
            AppDelegate.currentUser = UserModel(user: user)
            
            try! AppDelegate.realm.write {
                AppDelegate.realm.add(AppDelegate.currentUser, update: true)
            }
        })
        
        ref.child("friends/\(AppDelegate.uid)").queryOrderedByChild("following").queryEqualToValue(true).observeEventType(.ChildAdded, withBlock: { snapshot in
        
            let friend = Friend(snapshot: snapshot)
            
            ref.child("users").child(friend.fuid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                let user = User(snapshot: snapshot)
                
                //print(user.name)
                
                var uploaded: Double = 0
                
                var friend = realm.objectForPrimaryKey(UserModel.self, key: user.uid)
                
                if friend != nil {
                    uploaded = friend!.uploaded
                }
                
                // Update friend
                
                if user.uploaded != uploaded {
                    
                    friend = UserModel(user: user)
                    
                    try! realm.write {
                        realm.add(friend!, update: true)
                    }
                    print("updated \(friend!.name)")
                }
                
                ref.child("pins/\(user.uid)").queryOrderedByChild("date").queryStartingAtValue(AppDelegate.startdate).observeEventType(.ChildAdded, withBlock: { snapshot in
                    
                    let data = Clip(snapshot: snapshot)
                    
                    // Initial load - Check if pin has been modified
                    if let clip = realm.objectForPrimaryKey(ClipModel.self, key: data.id) {
                        if clip.updated == data.updated {
                            return
                        }
                    }
                    
                    UploadHelper.sharedInstance.downloadClip(data.fname)
                    
                    let clip = ClipModel(clip: data)
                    try! realm.write {
                        realm.add(clip, update: true)
                        friend!.uploaded = clip.date
                    }
                })
                
                ref.child("pins/\(user.uid)").queryOrderedByChild("date").queryStartingAtValue(AppDelegate.startdate).observeEventType(.ChildChanged, withBlock: { snapshot in
                    
                    let data = Clip(snapshot: snapshot)
                    
                    // Initial load - Check if pin has been modified
                    if let clip = realm.objectForPrimaryKey(ClipModel.self, key: data.id) {
                        if clip.updated == data.updated {
                            return
                        }
                    }
                    
                    let clip = ClipModel(clip: data)
                    try! realm.write {
                        realm.add(clip, update: true)
                    }
                })
                
            })
        })
        
        // Init tab bar
        let tabBarController = ESTabBarController(tabIconNames: ["clock", "globe", "record", "map", "archive"])

        self.addChildViewController(tabBarController)
        self.view.addSubview(tabBarController.view)
        tabBarController.view.frame = self.view.bounds
        tabBarController.didMoveToParentViewController(self)
        tabBarController.selectionIndicatorHeight = 3
        tabBarController.selectedColor = UIColor(hexString: "#CD5B45")
        tabBarController.buttonsBackgroundColor = UIColor(red: (247.0 / 255.0), green: (247.0 / 255.0), blue: (247.0 / 255.0), alpha: 1)//UIColor(hexString: "#F6EBE0")
        // tabBarController.buttonsBackgroundColor = UIColor(hexString: "#FFF")
        
        // View controllers.
        tabBarController.setViewController(UINavigationController(rootViewController: FriendsController()), atIndex: 0)
        tabBarController.setViewController(UINavigationController(rootViewController: SearchController()), atIndex: 1)
        tabBarController.setViewController(UINavigationController(rootViewController: MapController()), atIndex: 3)
        tabBarController.setViewController(UINavigationController(rootViewController: ProfileController()), atIndex: 4)
        
        let cam = CameraViewController()
        
        tabBarController.setAction({
            self.presentViewController(cam, animated: true, completion: nil)
        }, atIndex: 2)

        // tabBarController.highlightButtonAtIndex(1)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

