//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import APAddressBook
import Just
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
    
    let ref = FIRDatabase.database().reference()
    
    func loadFacebookFriends(_ completion: ((_ count: Int)->Void)?) {
        
        var friends = [FacebookFriend]()
        
        let request = FBSDKGraphRequest(graphPath:"me/friends", parameters: ["fields": "name", "limit":"200"] )
        request?.start { (connection, result, error) in
            
            if error == nil {
                
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.object(forKey: "data") as! NSArray
                for i in 0 ..< data.count
                {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let fb = valueDict.value(forKey: "id") as! String
                    let name = valueDict.value(forKey: "name") as! String
        
                    
                    let friend = FacebookFriend(fb: fb, name: name)
                    friends.append(friend)
                    self.updateFriends(fb, name: name)
                }
                print("Found \(friends.count) friends")
                completion?(friends.count)
            } else {
                print("Error Getting Friends \(error)")
            }
        }
    }
    
    func updateFriends(_ fb: String, name: String) {
        
        ref.child("users").queryOrdered(byChild: "fb").queryEqual(toValue: fb).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let friendId : String = (snapshot.value as! NSDictionary).allKeys.first as! String
            
            self.addFriend(friendId)
        })
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
    
    func loadAddressBook(_ completion: (()->Void)?){
        
        // Load contacts friends
        let addressBook = APAddressBook()
        
        addressBook.requestAccess { granted, error in
            addressBook.loadContacts({(contacts, error) in
                if error != nil {
                    print(error!)
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
                                
                                self.ref.child("users").queryOrdered(byChild: "phone").queryEqual(toValue: number).observeSingleEvent(of: .value, with: { (snapshot) in
                                    
                                    if let snap = snapshot.children.allObjects.first as? FIRDataSnapshot {
                                        let user = User(snapshot: snap)
                                        self.addFriend(user.uid)
                                    }
                                })
                            }
                        }
                        
                    }
                }
            })
            completion?()
        }
        
    }
   
    func addFriend(_ friendId: String) {

        let userID : String! = AppDelegate.uid
        let friend = Friend(uid: userID, fuid: friendId)
        let refriend = Friend(uid: friendId, fuid: userID, following: false, follower: true)
        let key = ref.child("followers").childByAutoId().key
        
        var follow = friend.toAnyObject()
        follow["name"] = AppDelegate.name
        
        var update = [String: Any]()
        update["/friends/\(userID!)/\(friendId)"] = friend.toAnyObject()
        update["/friends/\(friendId)/\(userID!)"] = refriend.toAnyObject()
        update["/follows/\(key)"] = follow
        ref.updateChildValues(update)
    }
        
    func report(_ uid: String) {
        self.unfollow(uid)
    }
    
    func unfollow(_ friendId: String) {
        let userID: String = AppDelegate.uid
        let realm = AppDelegate.realm
        let user = realm?.object(ofType: UserModel.self, forPrimaryKey: friendId)!
        
        try! realm?.write {
            user?.following = false
        }
        
        var update = [String:Any]()
        update["/friends/\(userID)/\(friendId)/following"] = false
        ref.updateChildValues(update)

        print("unfollowed " + friendId)
    }
    
    func reportClip(_ clip: ClipModel) {
        let userID: String = AppDelegate.uid
        let update = ["/pins/\(clip.uid)/\(clip.id)/flag": true,
                      "/users/\(userID)/flags/\(clip.id)": true]
        ref.updateChildValues(update)
        
        let realm = AppDelegate.realm
        try! realm?.write {
            clip.flag = true
            clip.trash = true
        }
    }
    
    func deleteClip(_ clip: ClipModel) {
        let updated = Date().timeIntervalSince1970
        let update : [String: AnyObject] = ["/pins/\(clip.uid)/\(clip.id)/trash": true as AnyObject,
                                            "/pins/\(clip.uid)/\(clip.id)/updated": updated as AnyObject,
                                            "/clips/\(clip.id)/trash": true as AnyObject]
        ref.updateChildValues(update)
        
        let realm = AppDelegate.realm
        try! realm?.write {
            clip.trash = true
            clip.updated = updated
        }
    }
    
    func comment(_ clip: ClipModel, text: String) {
        let id = ref.child("comments").childByAutoId().key
        let uid : String! = AppDelegate.uid
        let name = AppDelegate.name
        let cm = Comment(id: id, uid: uid, pid: clip.id, name: name, text: text)
        
        var update = [String:Any]()
        let cmo = cm.toAnyObject()
        update["/threads/\(clip.id)/follows/\(cm.uid)"] = true
        update["/threads/\(clip.id)/comments/\(cm.id)"] = cmo
        update["/comments/\(cm.id)"] = cmo
        
        if clip.uid != cm.uid {
            update["/threads/\(clip.id)/follows/\(clip.uid)"] = true as AnyObject?
        }
        
        ref.updateChildValues(update)
        
//        let data = ["pid": clip.id,
//                    "uid": userID,
//                    "name": AppDelegate.currentUser.name,
//                    "txt": cmt.txt]
        
//        Just.post("http://192.168.100.8:5005/pins/comment", json: data) { r in
//            print(r)
//        }
        
//        let realm = AppDelegate.realm
//        try! realm.write {
//            // add comment
//        }
    }
    
    func saveDevice(_ id: String) {
        let uid : String! = AppDelegate.uid
        let device = Device(id: id, uid: uid, device: UIDevice.current)
        let update = ["/devices/\(id)": device.toAnyObject()]
        ref.updateChildValues(update)
    }
}
