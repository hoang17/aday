//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import APAddressBook

class FacebookFriend: NSObject {
    
    var fb: String
    var name: String
    
    
    init(fb: String, name:String) {
        self.fb = fb
        self.name = name
    }
}

class FriendsLoader: NSObject {
    
    static let sharedInstance = FriendsLoader()
    
    func loadFacebookFriends() {
        
        var friends = [FacebookFriend]()
        
        let request = FBSDKGraphRequest(graphPath:"me/friends", parameters: ["fields": "name", "limit":"200"] );
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error == nil {
                
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                for i in 0 ..< data.count
                {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let fb = valueDict.valueForKey("id") as! String
                    let name = valueDict.valueForKey("name") as! String
        
                    
                    let friend = FacebookFriend(fb: fb, name: name)
                    friends.append(friend)
                    self.updateFriends(fb, name: name)
                }
                print("Found \(friends.count) friends")
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
    func updateFriends(fb: String, name: String) {
        
        // Save friend
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByChild("fb").queryEqualToValue(fb).observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            let friendId : String = (snapshot.value as! NSDictionary).allKeys.first as! String
            // Create new friend at /users/$userid/friends/$friendid
            let userID : String! = FIRAuth.auth()?.currentUser?.uid
            
            let update = ["/users/\(userID)/friends/\(friendId)/": true,
                          "/users/\(friendId)/friends/\(userID)/": true,
                          "/users/\(friendId)/following/\(userID)/": true,
                          "/users/\(userID)/following/\(friendId)/": true]
            ref.updateChildValues(update)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadAddressBook() {
        
        let ref = FIRDatabase.database().reference()
        
        // Load contacts friends
        let addressBook = APAddressBook()
        addressBook.loadContacts({(contacts, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            for contact in contacts! {
                
                if let phones = contact.phones {
                    for phone in phones {
                        var number = phone.number!.removeWhitespace()
                        if number.hasPrefix("0"){
                            number = "+84" + String(number.characters.dropFirst())
                        }
                        
                        if AppDelegate.currentUser != nil && number == AppDelegate.currentUser.phone {
                            continue
                        }
                        
                        ref.child("users").queryOrderedByChild("phone").queryEqualToValue(number).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let snap = snapshot.children.allObjects.first as? FIRDataSnapshot {
                                let friend = User(snapshot: snap)
                                
                                // Create new friend at /users/$userid/friends/$friendid
                                let userID : String! = FIRAuth.auth()?.currentUser?.uid
                                
                                let update = ["/users/\(userID)/friends/\(friend.uid)/": true,
                                    "/users/\(friend.uid)/friends/\(userID)/": true,
                                    "/users/\(friend.uid)/following/\(userID)/": true,
                                    "/users/\(userID)/following/\(friend.uid)/": true]
                                ref.updateChildValues(update)
                                
                            }
                            
                        }) { (error) in
                            print(error)
                        }
                        
                    }
                }
                
            }
        })
        
    }
    
    func report(uid: String) {
        self.unfollow(uid)
    }
    
    func follow(friendId: String) {
        let ref = FIRDatabase.database().reference()
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        let update = ["/users/\(userID)/following/\(friendId)/": true,
                      "/users/\(friendId)/friends/\(userID)/": true]
        ref.updateChildValues(update)
    }
    
    func unfollow(friendId: String) {
        let ref = FIRDatabase.database().reference()
        let realm = AppDelegate.realm
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        let update = ["/users/\(userID)/following/\(friendId)/": false,
                      "/users/\(friendId)/friends/\(userID)/": false]
        ref.updateChildValues(update)
        
        // Update realm: follow = false
        
        let predicate = NSPredicate(format: "uid = %@", friendId)
        let clips = realm.objects(ClipModel.self).filter(predicate)
        
        try! realm.write {
            realm.create(UserModel.self, value: ["uid": friendId, "follow": false], update: true)
            clips.setValue(false, forKeyPath: "follow")
        }
        
        print("unfollowed " + friendId)
    }
    
    func reportClip(clip: ClipModel) {
        let ref = FIRDatabase.database().reference()
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        let update = [
            "/users/\(clip.uid)/clips/\(clip.id)/flag": true,
            "/users/\(userID)/flags/\(clip.id)": true]
        ref.updateChildValues(update)
        
        let realm = AppDelegate.realm
        try! realm.write {
            clip.flag = true
            clip.follow = false
        }
    }
    
    func deleteClip(clip: ClipModel) {
        let ref = FIRDatabase.database().reference()
        
        let update = ["/users/\(clip.uid)/clips/\(clip.id)/trash": true]
        ref.updateChildValues(update)
        
        let realm = AppDelegate.realm
        try! realm.write {
            clip.trash = true
        }
    }
}
