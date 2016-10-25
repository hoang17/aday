//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import APAddressBook
//import Permission

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
    
    func loadFacebookFriends(completion: ((count: Int)->Void)?) {
        
        var friends = [FacebookFriend]()
        
        let request = FBSDKGraphRequest(graphPath:"me/friends", parameters: ["fields": "name", "limit":"200"] )
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
                completion?(count: friends.count)
            } else {
                print("Error Getting Friends \(error)")
            }
        }
    }
    
    func updateFriends(fb: String, name: String) {
        
        // Save friend
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByChild("fb").queryEqualToValue(fb).observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            let friendId : String = (snapshot.value as! NSDictionary).allKeys.first as! String
            let userID : String! = AppDelegate.uid
            let friend = Friend(uid: userID, fuid: friendId)
            
            // Create new friend at /friends/$userid/$friendid
            let update = ["/friends/\(userID)/\(friendId)": friend.toAnyObject()]
            ref.updateChildValues(update)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    func loadAddressBook(completion: (()->Void)?){
//        let permission: Permission
//        
//        if #available(iOS 9.0, *) {
//            permission = .Contacts
//        } else {
//            permission = .AddressBook
//        }
//        
//        print(permission.status)
//        
//        permission.request { status in
//            switch status {
//            case .Authorized:
//                print("authorized")
//                self.loadAB()
//                completion?()
//            case .Denied:        print("denied")
//                completion?()
//            case .Disabled:      print("disabled")
//                completion?()
//            case .NotDetermined: print("not determined")
//                completion?()
//            }
//        }
//        
//    }
    
    func loadAddressBook(completion: (()->Void)?){
        
        let ref = FIRDatabase.database().reference()
        
        // Load contacts friends
        let addressBook = APAddressBook()
        
        addressBook.requestAccess { granted, error in
            addressBook.loadContacts({(contacts, error) in
                if error != nil {
                    print(error)
                } else if contacts != nil {
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
                                        let user = User(snapshot: snap)
                                        let friendId = user.uid
                                        let userID : String! = AppDelegate.uid
                                        let friend = Friend(uid: userID, fuid: friendId)
                                        
                                        // Create new friend at /friends/$userid/$friendid
                                        let update = ["/friends/\(userID)/\(friendId)": friend.toAnyObject()]
                                        ref.updateChildValues(update)
                                    }
                                    
                                }) { (error) in
                                    print(error)
                                }
                            }
                        }
                        
                    }
                }
            })
            completion?()
        }
        
    }
    
    func report(uid: String) {
        self.unfollow(uid)
    }
    
    func unfollow(friendId: String) {
        
        let userID : String! = AppDelegate.uid
        
        let realm = AppDelegate.realm
        
        let user = realm.objectForPrimaryKey(UserModel.self, key: friendId)!
        
        try! realm.write {
            user.following = false
        }
        
        let ref = FIRDatabase.database().reference()
        
        let update:[String:AnyObject] = ["/friends/\(userID)/\(friendId)/following": false]
        ref.updateChildValues(update)

        print("unfollowed " + friendId)
    }
    
    func reportClip(clip: ClipModel) {
        let ref = FIRDatabase.database().reference()
        let userID : String! = AppDelegate.uid
        let update = ["/pins/\(clip.uid)/\(clip.id)/flag": true,
                      "/users/\(userID)/flags/\(clip.id)": true]
        ref.updateChildValues(update)
        
        let realm = AppDelegate.realm
        try! realm.write {
            clip.flag = true
            clip.trash = true
        }
    }
    
    func deleteClip(clip: ClipModel) {
        let ref = FIRDatabase.database().reference()
        let updated = NSDate().timeIntervalSince1970
        let update : [String: AnyObject] = ["/pins/\(clip.uid)/\(clip.id)/trash": true,
                                            "/pins/\(clip.uid)/\(clip.id)/updated": updated,
                                            "/clips/\(clip.id)/trash": true]
        ref.updateChildValues(update)
        
        let realm = AppDelegate.realm
        try! realm.write {
            clip.trash = true
            clip.updated = updated
        }
    }
    
    func comment(clip: ClipModel, text: String) {
        let ref = FIRDatabase.database().reference()
        let id = ref.child("comments").childByAutoId().key
        let userID : String! = AppDelegate.uid
        let cmt = Comment(id: id, uid: userID, pid: clip.id, text: text)
        let update = ["/comments/\(clip.id)/\(cmt.id)": cmt.toAnyObject()]
        ref.updateChildValues(update)
        
//        let realm = AppDelegate.realm
//        try! realm.write {
//            clip.flag = true
//            clip.trash = true
//        }
    }
}
