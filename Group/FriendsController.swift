//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import RealmSwift

class FriendsController: UITableViewController {
    
    var friends = [User]()
    var keys = [String:User]()
    
    var reuseIdentifier = "cell"
    
    var myGroup = dispatch_group_create()


    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
//        let realmURLs = [
//            realmURL,
//            realmURL.URLByAppendingPathExtension("lock"),
//            realmURL.URLByAppendingPathExtension("log_a"),
//            realmURL.URLByAppendingPathExtension("log_b"),
//            realmURL.URLByAppendingPathExtension("note")
//        ]
//        let manager = NSFileManager.defaultManager()
//        for URL in realmURLs {
//            do {
//                try manager.removeItemAtURL(URL)
//            } catch {
//                // handle error
//            }
//        }
        
        
        view.backgroundColor = .whiteColor()
        
        // Setup friends table
        
        tableView.rowHeight = 345
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        tableView.separatorStyle = .None

        tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        let ref = FIRDatabase.database().reference()
        
        print("...loading friends for user \(userID)...")
        
        let realm = try! Realm()
        let list = realm.objects(UserModel.self)
        for data in list {
            let friend = User(data: data)
            self.friends.append(friend)
            self.keys[friend.uid] = friend
        }
        
        
//        ref.child("user-friends/\(userID)").observeEventType(.Value, withBlock: { snapshot in
        ref.child("users").observeEventType(.Value, withBlock: { snapshot in
            
            print("...returning friends...")
            for item in snapshot.children {
                
                if (self.keys[item.key] == nil){
                    
                    dispatch_group_enter(self.myGroup)
                
                    let uid = item.key!
                    let name = item.value["name"] as! String
                    let email = item.value["email"] as! String
                    let phone = item.value["phone"] as! String
                    let fabric = item.value["fabric"] as! String
                    let fb = item.value["fb"] as! String
                    let friend = User(uid: uid, name:name, email:email, fabric:fabric, phone:phone, fb:fb)
                    self.friends.append(friend)
                    
                
                    // Load clips
                    print("...loading clips for friend \(friend.uid)...")
                    ref.child("clips").queryOrderedByChild("uid").queryEqualToValue(friend.uid).observeEventType(.Value, withBlock: { snapshot in
                        
                        var clips = [Clip]()
                        
                        print("...returning clips...")
                        
                        for item in snapshot.children {
                            let clip = Clip(snapshot: item as! FIRDataSnapshot)
                            clips.append(clip)
                        }
                        
                        print("...loaded \(clips.count) clips")
                        
                        friend.clips = clips
                        
                        let data = UserModel()
                        data.load(friend)
                        try! realm.write {
                            realm.add(data)
                        }
                        
                        self.downloadClips(clips)
                        
                        dispatch_group_leave(self.myGroup)
                        
                    })
                }
            }
            
            dispatch_group_notify(self.myGroup, dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })

            print("...loaded \(self.friends.count) friends")
        })
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! TableViewCell
        cell.controller = self
        cell.nameLabel.text = friends[indexPath.row].name
        let url = NSURL(string: "https://graph.facebook.com/\(friends[indexPath.row].fb)/picture?type=large&return_ssl_resources=1")
        cell.profileImg.image = UIImage(data: NSData(contentsOfURL: url!)!)
        cell.clips = friends[indexPath.row].clips
        cell.friend = friends[indexPath.row]
//        cell.backgroundColor = UIColor.groupTableViewBackgroundColor()

        cell.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 2, inSection: 0) , atScrollPosition: .CenteredHorizontally, animated: false)
        
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func downloadClips(clips: [Clip]){
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
        
        for clip in clips {
            
            let fileName = clip.fname
            
            // Check if file not existed then download
            let filePath = NSTemporaryDirectory() + fileName;
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                
                print("File existed " + fileName)
                
            } else{
                print("Downloading file \(fileName)...")
                // File not existed then download
                let localURL = NSURL(fileURLWithPath: filePath)
                gs.child(fileName).writeToFile(localURL) { (URL, error) -> Void in
                    if (error != nil) {
                        print(error)
                    } else {
                        print("File downloaded " + fileName)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
