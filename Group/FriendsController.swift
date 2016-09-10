//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import SnapKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FriendsController: UITableViewController {
    
    var friends = [User]()
    
    var reuseIdentifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        
        // Setup friends table
        
        tableView.rowHeight = 30
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero

        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        let ref = FIRDatabase.database().reference()
        
        print("...loading friends for user \(userID)...")
        
        ref.child("user-friends/\(userID)").observeEventType(.Value, withBlock: { snapshot in
            print("...returning friends...")
            for item in snapshot.children {
                let uid = item.value["uid"] as! String
                let name = item.value["name"] as! String
                let email = item.value["email"] as! String
                let phone = item.value["phone"] as! String
                let fabric = item.value["fabric"] as! String
                let fb = item.value["fb"] as! String
                let friend = User(uid: uid, name:name, email:email, fabric:fabric, phone:phone, fb:fb)
                self.friends.append(friend)
                
                print("...loading clips for friend \(friend.uid)...")
                ref.child("clips").queryOrderedByChild("uid").queryEqualToValue(friend.uid).observeEventType(.Value, withBlock: { snapshot in
                    
                    var clips = [Clip]()
                    
                    print("...returning clips...")
                    
                    for item in snapshot.children {
                        let clip = Clip(snapshot: item as! FIRDataSnapshot)
                        clips.append(clip)
                    }
                    
                    print("...loaded \(clips.count) clip")
                    
                    friend.clips = clips
                    
                    self.downloadClips(clips)
                })
                
            }
            self.tableView.reloadData()
            print("...loaded \(self.friends.count) friends")
        })
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
        cell?.textLabel?.text = friends[indexPath.row].name
//        cell?.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        cell?.layoutMargins = UIEdgeInsetsZero
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let friend = friends[indexPath.row]
        let cameraPlayback = CameraPlaybackController()
        cameraPlayback.clips = friend.clips!
        self.presentViewController(cameraPlayback, animated: true, completion: nil)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
