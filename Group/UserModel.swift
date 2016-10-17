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
    dynamic var username: String = ""
    dynamic var password: String = ""
    dynamic var follow: Bool = true
    dynamic var flag: Bool = false
    dynamic var trash: Bool = false
    
    dynamic var uploaded: Double = 0
    dynamic var updated: Double = 0
    dynamic var created: Double = 0
    
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
        username = user.username
        password = user.password
        flag = user.flag
        trash = user.trash
        
        uploaded = user.uploaded
        updated = user.updated
        created = user.created

        flags = user.flags
        
//        following = user.following
//        followers = user.friends
    }
    
    private dynamic var followingData: NSData?
    private dynamic var followersData: NSData?
    private dynamic var flagsData: NSData?
    
//    var following: [String: Bool] {
//        get {
//            guard let followingData = followingData else {
//                return [String: Bool]()
//            }
//            do {
//                let dict = try NSJSONSerialization.JSONObjectWithData(followingData, options: []) as? [String: Bool]
//                return dict!
//            } catch {
//                return [String: Bool]()
//            }
//        }
//        
//        set {
//            do {
//                let data = try NSJSONSerialization.dataWithJSONObject(newValue, options: [])
//                followingData = data
//            } catch {
//                followingData = nil
//            }
//        }
//    }
//    
//    var followers: [String: Bool] {
//        get {
//            guard let followersData = followersData else {
//                return [String: Bool]()
//            }
//            do {
//                let dict = try NSJSONSerialization.JSONObjectWithData(followersData, options: []) as? [String: Bool]
//                return dict!
//            } catch {
//                return [String: Bool]()
//            }
//        }
//        
//        set {
//            do {
//                let data = try NSJSONSerialization.dataWithJSONObject(newValue, options: [])
//                followersData = data
//            } catch {
//                followersData = nil
//            }
//        }
//    }

    var flags: [String: Bool] {
        get {
            guard let flagsData = flagsData else {
                return [String: Bool]()
            }
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(flagsData, options: []) as? [String: Bool]
                return dict!
            } catch {
                return [String: Bool]()
            }
        }
        
        set {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(newValue, options: [])
                flagsData = data
            } catch {
                flagsData = nil
            }
        }
    }
    
    override static func primaryKey() -> String? {
        return "uid"
    }

    override static func ignoredProperties() -> [String] {
        return ["flags"]
    }
}
