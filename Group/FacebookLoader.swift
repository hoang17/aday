//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase

class LoadFriends: NSObject {
    
    func loadFacebookFriends(completionHandler:(friends:[Friend]?)->()) {
        
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
            print(snapshot)

            let key : String = (snapshot.value as! NSDictionary).allKeys.first as! String
            // Create new friend at /users/$userid/friends/$friendid
            let userID : String! = FIRAuth.auth()?.currentUser?.uid
            
            let update = ["/users/\(userID)/friends/\(key)/": true]
            ref.updateChildValues(update)
            
//            let u = ((snapshot.value as! NSDictionary).allValues.first) as! NSDictionary
//            let key : String = (snapshot.value as! NSDictionary).allKeys.first as! String
//            // Create new friend at /friends/$userid/$friendid
//            let userID : String! = FIRAuth.auth()?.currentUser?.uid
//            
//            let friend = ["uid": key,
//                "name": name,
//                "email": u["email"] as! String,
//                "phone": u["phone"] as! String,
//                "fabric": u["fabric"] as! String,
//                "fb": fb]
//            let update = ["/friends/\(userID)/\(key)/": friend]
//            ref.updateChildValues(update)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
