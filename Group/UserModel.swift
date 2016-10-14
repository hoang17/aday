//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import RealmSwift

class UserModel: Object {
    dynamic var uid: String!
    dynamic var name: String!
    dynamic var email: String!
    dynamic var fb: String!
    dynamic var fbtoken: String = ""
    dynamic var phone: String!
    dynamic var fabric: String!
    dynamic var city: String!
    dynamic var country: String!
    dynamic var uploaded: Double = 0.0
    dynamic var username: String = ""
    dynamic var password: String = ""
    dynamic var follow: Bool = true
    dynamic var flag: Bool = false
    dynamic var trash: Bool = false
    let clips = List<ClipModel>()
    
    var friends = [String:Bool]()
    var following = [String:Bool]()
    var flags = [String:Bool]()
    
//    let following = List<Following>()
//    let followers = List<Follower>()
//    let flags = List<Flag>()
    
    convenience init(user: User){
        self.init()
        uid = user.uid
        name = user.name
        email = user.email
        fb = user.fb
        fbtoken = user.fbtoken
        phone = user.phone
        fabric = user.fabric
        city = user.city
        country = user.country
        uploaded = user.uploaded
        username = user.username
        password = user.password
        flag = user.flag
        trash = user.trash
        for clip in user.clips{
            let data = ClipModel(clip: clip)
            clips.append(data)
        }
        
        following = user.following
        friends = user.friends
        flags = user.flags
        
//        for uid in user.following.keys {
//            following.append(Following(uid: uid))
//        }
//        
//        for uid in user.following.keys {
//            followers.append(Follower(uid: uid))
//        }
//
//        for id in user.flags.keys {
//            flags.append(Flag(id: id))
//        }
    }
    
    override static func primaryKey() -> String? {
        return "uid"
    }

    override static func ignoredProperties() -> [String] {
        return ["following", "friends", "flags"]
    }
}

//class Flag: Object {
//    dynamic var id: String!
//    
//    convenience init(id: String) {
//        self.init()
//        self.id = id
//    }
//    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
//}
//
//class Following: Object {
//    dynamic var uid: String!
//
//    convenience init(uid: String) {
//        self.init()
//        self.uid = uid
//    }
//    
//    override static func primaryKey() -> String? {
//        return "uid"
//    }
//}
//
//class Follower: Object {
//    dynamic var uid: String!
//    
//    convenience init(uid: String) {
//        self.init()
//        self.uid = uid
//    }
//    
//    override static func primaryKey() -> String? {
//        return "uid"
//    }
//}
