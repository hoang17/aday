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
        let value = snapshot.value as? NSDictionary
        self.uid = value?["uid"] as? String ?? ""
        self.fuid = value?["fuid"] as? String ?? ""
        self.following = value?["following"] as? Bool ?? false
        self.follower = value?["follower"] as? Bool ?? false
        self.flag = value?["flag"] as? Bool ?? false
        self.created = value?["created"] as? Double ?? 0
        self.updated = value?["updated"] as? Double ?? 0
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
        ] as AnyObject
    }
}
