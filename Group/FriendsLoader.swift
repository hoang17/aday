//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import APAddressBook


class FriendsLoader: NSObject {
    
    func loadFacebookFriends() {
        
        var friends = [Friend]()
        
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
        
                    
                    let friend = Friend(fb: fb, name: name)
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
    
}
