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
import Kingfisher
import AVFoundation

class FriendsController: UITableViewController {
    
    var friends = [User]()
    
    var cells = [Int:TableViewCell]()
    
    var myGroup = dispatch_group_create()

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm: Realm
        do {
            realm = try Realm()
        }
        catch {
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
                    try manager.removeItemAtURL(URL)
                } catch {
                    // handle error
                }
            }
            realm = try! Realm()
        }
        
        view.backgroundColor = .whiteColor()
        
        // Setup friends table
        
        tableView.rowHeight = 345
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        tableView.separatorStyle = .None

        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        let ref = FIRDatabase.database().reference()
        
//        try! realm.write {
//            realm.deleteAll()
//        }

        let list = realm.objects(UserModel.self)
        for data in list {
            let friend = User(data: data)
            self.friends.append(friend)
        }
        
        var change = false
        
        print("...loading friends for user \(userID)...")
        
//        ref.child("user-friends/\(userID)").observeEventType(.Value, withBlock: { snapshot in
        ref.child("users").observeEventType(.Value, withBlock: { snapshot in
            
            print("...returning friends...")
            for item in snapshot.children {
                
                // check if friend has been saved to local
                let cache = realm.objectForPrimaryKey(UserModel.self, key: item.key)
                
                if (cache == nil){
                    
                    change = true
                    
                    let uid = item.key!
                    let name = item.value["name"] as! String
                    let email = item.value["email"] as! String
                    let phone = item.value["phone"] as! String
                    let fabric = item.value["fabric"] as! String
                    let fb = item.value["fb"] as! String
                    let friend = User(uid: uid, name:name, email:email, fabric:fabric, phone:phone, fb:fb)
                    self.friends.append(friend)
                    
                    let data = UserModel()
                    data.load(friend)
                    try! realm.write {
                        realm.add(data, update: true)
                    }
                }
            }
            
            print("...loaded \(self.friends.count) friends")
            
            // Load clips
            for friend in self.friends{
                
                dispatch_group_enter(self.myGroup)
                
                print("...loading clips for friend \(friend.uid)...")
                ref.child("clips").queryOrderedByChild("uid").queryEqualToValue(friend.uid).queryLimitedToLast(20).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    print("...returning clips...")

                    for item in snapshot.children {
                        
//                        // Generate thumb image
//                        do {
//                            let clip = Clip(snapshot: item as! FIRDataSnapshot)
//                            let asset = AVURLAsset(URL: NSURL(fileURLWithPath: NSTemporaryDirectory() + clip.fname), options: nil)
//                            let imgGenerator = AVAssetImageGenerator(asset: asset)
//                            imgGenerator.appliesPreferredTrackTransform = true
//                            let cgimg = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
//                            let uiimg = UIImage(CGImage: cgimg)
//                            let data = UIImageJPEGRepresentation(uiimg, 0.5)
//                            let filename = NSTemporaryDirectory() + clip.fname + ".jpg"
//                            
//                            let fileManager = NSFileManager.defaultManager()
//                            if fileManager.fileExistsAtPath(filename) {
//                                try fileManager.removeItemAtPath(filename)
//                            }
//                            data!.writeToFile(filename, atomically: true)
//                            
//                        } catch {
//                            print(error)
//                        }
                        
                        // check if clip has been saved to local
                        let cache = realm.objectForPrimaryKey(ClipModel.self, key: item.key)
                        
                        if (cache == nil){
                            
                            change = true
                            
                            let clip = Clip(snapshot: item as! FIRDataSnapshot)
                            
                            friend.clips.insert(clip, atIndex: 0)
                        }
                    }
                    
                    print("...loaded \(friend.clips.count) clips")
                    
                    let data = UserModel()
                    data.load(friend)
                    try! realm.write {
                        realm.create(UserModel.self, value: ["uid": data.uid, "clips": data.clips], update: true)
                    }
                    
                    self.downloadClips(friend.clips)
                    
                    dispatch_group_leave(self.myGroup)
                    
                })
                
            }
            
            dispatch_group_notify(self.myGroup, dispatch_get_main_queue(), {
                if (change){
                    self.tableView.reloadData()
                }
            })            

        })
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if cells[indexPath.row] == nil {
            let cell = TableViewCell()
            cell.controller = self
            cell.nameLabel.text = friends[indexPath.row].name
            cell.profileImg.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(friends[indexPath.row].fb)/picture?type=large&return_ssl_resources=1"))
            cell.clips = friends[indexPath.row].clips
            cell.friend = friends[indexPath.row]
//            cell.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: cell.friend.clipIndex, inSection: 0) , atScrollPosition: .CenteredHorizontally, animated: false)
            cells[indexPath.row] = cell
        }
        return cells[indexPath.row]!
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
            } else {
                print("Downloading file \(fileName)...")
                // File not existed then download
                let localURL = NSURL(fileURLWithPath: filePath)
                gs.child(fileName).writeToFile(localURL) { (URL, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        print("File downloaded " + fileName)
                        
                        // Generate thumb image
                        do {
                            let asset = AVURLAsset(URL: NSURL(fileURLWithPath: NSTemporaryDirectory() + clip.fname), options: nil)
                            let imgGenerator = AVAssetImageGenerator(asset: asset)
                            imgGenerator.appliesPreferredTrackTransform = true
                            let cgimg = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
                            let uiimg = UIImage(CGImage: cgimg)
                            let data = UIImageJPEGRepresentation(uiimg, 0.5)
                            let filename = NSTemporaryDirectory() + clip.fname + ".jpg"
                            data!.writeToFile(filename, atomically: true)
                            
                        } catch {
                            print(error)
                        }
                        
                        
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
