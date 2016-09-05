//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import SnapKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase

class FriendsController: UITableViewController {
    
    var friends = [User]()
    
    var reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        
        // Setup add friend button
        
//        let button = UIButton(type: .System)
//        button.setTitle("Add Friend", forState: .Normal)
//        button.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
//        button.backgroundColor = view.tintColor
//        button.addTarget(self, action: #selector(addFriend), forControlEvents: .TouchUpInside)
//        self.view.addSubview(button)
//        button.snp_makeConstraints { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//            make.left.equalTo(self.view).offset(0)
//            make.right.equalTo(self.view).offset(0)
//        }
        
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
            }
            self.tableView.reloadData()
            print("...loaded \(self.friends.count) friends")
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    func addFriend(){
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
        cell?.textLabel?.text = friends[indexPath.row].name
        cell?.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        cell?.layoutMargins = UIEdgeInsetsZero
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Query room id
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        let friend = friends[indexPath.row]
        let ref = FIRDatabase.database().reference()
        ref.child("user-friends/\(userID)/\(friend.uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var key : String
            if ((snapshot.value?["rid"] as? String) == nil){
                key = ref.child("rooms").childByAutoId().key
                let room = ["id":key, "name": friend.name]
                
                let update = ["/rooms/\(key)": room,
                    "/user-rooms/\(userID)/\(key)": room,
                    "/user-friends/\(userID)/\(friend.uid)/rid": key,
                    "/user-friends/\(friend.uid)/\(userID)/rid": key]
                ref.updateChildValues(update as [NSObject : AnyObject])
            }
            else{
                key = snapshot.value!["rid"] as! String
            }
            
            // Open room
            let navViewController = self.parentViewController as! UINavigationController;
            let room = Room(id:key, name:friend.name)
            let r = RoomController()
            r.room = room
            navViewController.pushViewController(r, animated: true)
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}