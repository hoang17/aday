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
        
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        if let user = AppDelegate.realm.objectForPrimaryKey(UserModel.self, key: userID) {
            AppDelegate.currentUser = User(data: user)
            print("loaded currentUser from local: " + AppDelegate.currentUser.name)
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(userID).observeEventType(.Value, withBlock: { snapshot in
            AppDelegate.currentUser = User(snapshot: snapshot)
            let data = UserModel()
            data.load(AppDelegate.currentUser)
            try! AppDelegate.realm.write {
                AppDelegate.realm.add(data, update: true)
            }
            print("loaded currentUser from remote & save to local: " + AppDelegate.currentUser.name)
        })
        
        
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
        
        tabBarController.setAction({
            self.presentViewController(CameraViewController(), animated: true, completion: nil)
        }, atIndex: 2)

//        tabBarController.highlightButtonAtIndex(1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

