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

class MainController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Init current user
        
        AppDelegate.uid = FIRAuth.auth()?.currentUser?.uid
        
        if let user = AppDelegate.realm.objectForPrimaryKey(UserModel.self, key: AppDelegate.uid) {
            // AppDelegate.currentUser = User(data: user)
            
            AppDelegate.currentUser = user
            print("loaded currentUser from local " + AppDelegate.currentUser.name)
            
        } else {
            let ref = FIRDatabase.database().reference()
            ref.child("users").child(AppDelegate.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                //            AppDelegate.currentUser = User(snapshot: snapshot)
                //            let data = UserModel(user: AppDelegate.currentUser)
                
                let user = User(snapshot: snapshot)
                AppDelegate.currentUser = UserModel(user: user)
                
                try! AppDelegate.realm.write {
                    AppDelegate.realm.add(AppDelegate.currentUser, update: true)
                }
                print("loaded current user from remote " + AppDelegate.currentUser.name)
            })
        }
        
        
        // Init upload queue
        
        UploadHelper.sharedInstance.start()
        
        // Init tab bar
        
        let tabBarController = ESTabBarController(tabIconNames: ["clock", "globe", "record", "map", "archive"])
        
        self.addChildViewController(tabBarController)
        self.view.addSubview(tabBarController.view)
        tabBarController.view.frame = self.view.bounds
        tabBarController.didMoveToParentViewController(self)
        tabBarController.selectionIndicatorHeight = 3;
        tabBarController.selectedColor = UIColor(hexString: "#CD5B45")
        tabBarController.buttonsBackgroundColor = UIColor(hexString: "#F6EBE0")
//        tabBarController.buttonsBackgroundColor = UIColor(hexString: "#FFF")
        
        // View controllers.
        tabBarController.setViewController(FriendsController(), atIndex: 0)
        tabBarController.setViewController(SearchController(), atIndex: 1)
        tabBarController.setViewController(MapController(), atIndex: 3)
        tabBarController.setViewController(ProfileController(), atIndex: 4)
        
        let cam = CameraViewController()
        
        tabBarController.setAction({
            self.presentViewController(cam, animated: true, completion: nil)
        }, atIndex: 2)

//        tabBarController.highlightButtonAtIndex(1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

