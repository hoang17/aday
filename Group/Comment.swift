//
//  Comment.swift
//  Pinly
//
//  Created by Hoang Le on 10/24/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class Comment: NSObject {
    
    var id: String
    var uid: String
    var pid: String
    var name: String
    var txt: String
    var trash = false
    var created: Double = 0
    var updated: Double = 0
    
    var user: UserModel?
    
    init(id: String, uid: String, pid: String, name: String, text: String) {
        self.id = id
        self.uid = uid      // user id
        self.pid = pid      // pin id
        self.name = name    // user name
        self.txt = text
        created = Date().timeIntervalSince1970
        updated = created
    }
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        let value = snapshot.value as? NSDictionary
        uid = value?["uid"] as? String ?? ""
        pid = value?["pid"] as? String ?? ""
        name = value?["name"] as? String ?? ""
        txt = value?["txt"] as? String ?? ""
        trash = value?["trash"] as? Bool ?? false
        created = value?["created"] as? Double ?? 0
        updated = value?["updated"] as? Double ?? 0
    }
    
//    init(data: CommentModel){
//        self.id = data.id
//        self.uid = data.uid
//        self.pid = data.pid
//        self.name = data.name
//        self.txt = data.txt
//        self.trash = data.trash
//        self.created = data.created
//        self.updated = data.updated
//    }
    
    func toAnyObject() -> AnyObject {
        return [
            "id": id,
            "uid": uid,
            "pid": pid,
            "name": name,
            "txt": txt,
            "trash": trash,
            "created": created,
            "updated": updated
        ] as AnyObject
    }
}
