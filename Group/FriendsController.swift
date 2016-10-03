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
    
//    var friends = [User]()
    
    var friends: Results<UserModel>!
    
    var myGroup = dispatch_group_create()
    
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = AppDelegate.realm
        
        let ref = FIRDatabase.database().reference()
        
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        friends = realm.objects(UserModel.self).filter("follow = true").sorted("uploaded", ascending: false)
        
        notificationToken = friends.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard (self?.tableView) != nil else { return }
            switch changes {
            case .Initial:
                // tableView.reloadData()
                break
            case .Update(_, let deletions, let insertions, let modifications):
                self!.tableView.beginUpdates()
                self!.tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self!.tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self!.tableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self!.tableView.endUpdates()
                break
            case .Error(let error):
                print(error)
                break
            }
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
        
        print("loading friends for \(userID)...")
        
        ref.child("users").queryOrderedByChild("friends/\(userID)").queryEqualToValue(true).observeEventType(.Value, withBlock: { snapshot in
            
            for item in snapshot.children {
                
                let friend = User(snapshot: item as! FIRDataSnapshot)
                self.downloadClips(friend.clips)
                
                let data = UserModel()
                data.load(friend)
                try! realm.write {
                    realm.add(data, update: true)
                }
            }
            
            print("loaded friends")
            
        })
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = TableViewCell()
        cell.controller = self
        cell.nameLabel.text = friends[indexPath.row].name
        cell.locationLabel.text = friends[indexPath.row].city + " · " + friends[indexPath.row].country
        cell.profileImg.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(friends[indexPath.row].fb)/picture?type=large&return_ssl_resources=1"))
        cell.clips = Array(friends[indexPath.row].clips)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        notificationToken?.stop()
    }
}
