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

class MainController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Init current user
        
        let realm = AppDelegate.realm
        
        let ref = FIRDatabase.database().reference()
        
        AppDelegate.uid = FIRAuth.auth()?.currentUser?.uid
        
        if let user = realm.objectForPrimaryKey(UserModel.self, key: AppDelegate.uid) {
            AppDelegate.currentUser = user
        } else {
            ref.child("users").child(AppDelegate.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                let user = User(snapshot: snapshot)
                AppDelegate.currentUser = UserModel(user: user)
                
                try! AppDelegate.realm.write {
                    AppDelegate.realm.add(AppDelegate.currentUser, update: true)
                }
            })
        }

        let today = NSDate()
        let date = NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Day,
                value: -7,
                toDate: today,
                options: []
        )
        let dayago : Double = date!.timeIntervalSince1970
        
        ref.child("users").queryOrderedByChild("friends/\(AppDelegate.uid)").queryEqualToValue(true).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            for item in snapshot.children {
                
                let user = User(snapshot: item as! FIRDataSnapshot)
                
                var uploaded: Double = 0
                
                var friend = realm.objectForPrimaryKey(UserModel.self, key: user.uid)
                
                if friend != nil {
                    uploaded = friend!.uploaded
                }
                
                // Update friend
                
                if user.uploaded != uploaded {
                    
                    // self.downloadClips(user.clips)
                    
                    friend = UserModel(user: user)
                    
                    try! realm.write {
                        realm.add(friend!, update: true)
                    }
                    print("updated \(friend!.name)")
                }
                
                let startdate = dayago
                
                ref.child("pins/\(user.uid)").queryOrderedByChild("date").queryStartingAtValue(startdate).observeEventType(.ChildAdded, withBlock: { snapshot in
                    
                    let data = Clip(snapshot: snapshot)
                    
                    // Initial load - Check if pin has been modified
                    if let clip = realm.objectForPrimaryKey(ClipModel.self, key: data.id) {
                        if clip.updated == data.updated {
                            return
                        }
                    }
                    
                    self.downloadClip(data)
                    
                    let clip = ClipModel(clip: data)
                    try! realm.write {
                        realm.add(clip, update: true)
                        friend!.uploaded = clip.date
                    }
                    print("added pin \(user.name) \(clip.id)")
                })
                
                ref.child("pins/\(user.uid)").queryOrderedByChild("date").queryStartingAtValue(startdate).observeEventType(.ChildChanged, withBlock: { snapshot in
                    
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
                        friend!.updated = clip.updated
                    }
                    print("updated pin \(user.name) \(clip.id)")
                })
                
            }
            
        })
        
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
        // tabBarController.buttonsBackgroundColor = UIColor(hexString: "#FFF")
        
        // View controllers.
        tabBarController.setViewController(FriendsController(), atIndex: 0)
        tabBarController.setViewController(SearchController(), atIndex: 1)
        tabBarController.setViewController(MapController(), atIndex: 3)
        tabBarController.setViewController(ProfileController(), atIndex: 4)
        
        let cam = CameraViewController()
        
        tabBarController.setAction({
            self.presentViewController(cam, animated: true, completion: nil)
        }, atIndex: 2)

        // tabBarController.highlightButtonAtIndex(1)
    }
    
    func downloadClips(clips: [Clip]){
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
        
        for clip in clips {
            
            let fileName = clip.fname
            
            // Check if file not existed then download
            let filePath = NSTemporaryDirectory() + fileName;
            if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                
                print("Downloading file \(fileName)...")
                // File not existed then download
                let localURL = NSURL(fileURLWithPath: filePath)
                gs.child(fileName).writeToFile(localURL) { (URL, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        print("File downloaded " + fileName)
                    }
                }
            }
        }
    }
    
    func downloadClip(clip: Clip) {
        let fileName = clip.fname
        // Check if file not existed then download
        let filePath = NSTemporaryDirectory() + fileName;
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            print("Downloading file \(fileName)...")
            let storage = FIRStorage.storage()
            let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
            let localURL = NSURL(fileURLWithPath: filePath)
            gs.child(fileName).writeToFile(localURL) { (URL, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    print("File downloaded " + fileName)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

