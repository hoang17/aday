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
    
    init(uid: String, fuid: String) {
        self.uid = uid
        self.fuid = fuid
        self.following = true
        self.follower = true
        self.flag = false
        self.created = NSDate().timeIntervalSince1970
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
    
    func toAnyObject() -> AnyObject {
        return [
            "uid": uid,
            "fuid": fuid,
            "following": following,
            "follower": follower,
            "flag": flag,
            "created": created,
            "updated": updated
        ]
    }
}
