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
    
    var myGroup = dispatch_group_create()

    override func viewDidLoad() {
        super.viewDidLoad()

        // try to initialize Realm, clean all if error
        let realm: Realm
        do {
            realm = try Realm()
        }
        catch {
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
                    try manager.removeItemAtURL(URL)
                } catch {
                    // handle error
                }
            }
            realm = try! Realm()
        }
        
        
        let list = realm.objects(UserModel.self).sorted("uploaded")
        for data in list {
            let friend = User(data: data)
            self.friends.insert(friend, atIndex: 0)
        }
        
//        try! realm.write {
//            realm.deleteAll()
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
        
        let ref = FIRDatabase.database().reference()
        
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        print("...loading friends for user \(userID)...")
        
        ref.child("users").queryOrderedByChild("friends/\(userID)").queryEqualToValue(true).observeEventType(.Value, withBlock: { snapshot in
            
            self.friends = [User]()
            
            for item in snapshot.children {
                
                let friend = User(snapshot: item as! FIRDataSnapshot)
                self.friends.insert(friend, atIndex: 0)
                self.downloadClips(friend.clips)
                
                let data = UserModel()
                data.load(friend)
                try! realm.write {
                    realm.add(data, update: true)
                }
                
            }
            
            self.friends.sortInPlace({ $0.uploaded > $1.uploaded })
            
            print("...loaded \(self.friends.count) friends")
            
            self.tableView.reloadData()
        })
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = TableViewCell()
        cell.controller = self
        cell.nameLabel.text = friends[indexPath.row].name
        cell.locationLabel.text = friends[indexPath.row].city + " · " + friends[indexPath.row].country
        cell.profileImg.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(friends[indexPath.row].fb)/picture?type=large&return_ssl_resources=1"))
        cell.clips = friends[indexPath.row].clips
        cell.friend = friends[indexPath.row]
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
            } else {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
