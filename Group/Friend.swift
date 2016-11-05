//
//  Friend.swift
//  Pinly
//
//  Created by Hoang Le on 10/17/16.
//  Copyright © 2016 ping. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Friend: NSObject {
    var uid: String
    var fuid: String
    var following: Bool = false
    var follower: Bool = false
    var flag: Bool = false
    var created: Double = 0
    var updated: Double = 0
    
    init(uid: String, fuid: String, following: Bool = true, follower: Bool = true) {
        self.uid = uid
        self.fuid = fuid
        self.following = following
        self.follower = follower
        self.flag = false
        self.created = Date().timeIntervalSince1970
        self.updated = self.created
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.uid = snapshot.value!["uid"] as? String ?? ""
        self.fuid = snapshot.value!["fuid"] as? String ?? ""
        self.following = snapshot.value!["following"] as? Bool ?? false
        self.follower = snapshot.value!["follower"] as? Bool ?? false
        self.flag = snapshot.value!["flag"] as? Bool ?? false
        self.created = snapshot.value!["created"] as? Double ?? 0
        self.updated = snapshot.value!["updated"] as? Double ?? 0
    }
    
    func toAnyObject() -> [String:AnyObject] {
        return [
            "uid": uid as AnyObject,
            "fuid": fuid as AnyObject,
            "following": following as AnyObject,
            "follower": follower as AnyObject,
            "flag": flag as AnyObject,
            "created": created as AnyObject,
            "updated": updated as AnyObject
        ]
    }
}
