//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class Post: NSObject {
    
    var id: String
    var uid: String
    var uname: String
    var rid: String
    var title: String
    var body: String
    var read = false
    var flag = false
    
    var ref: FIRDatabaseReference?
    
    init(id:String, uid: String, uname: String, rid:String, title:String, body: String) {
        self.id = id
        self.uid = uid
        self.uname = uname
        self.rid = rid
        self.title = title
        self.body = body
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        uid = snapshot.value!["uid"] as! String
        uname = snapshot.value!["uname"] as! String
        rid = snapshot.value!["rid"] as! String
        title = snapshot.value!["title"] as! String
        body = snapshot.value!["body"] as! String
        if (snapshot.value!["read"] as? Bool != nil){
            read = snapshot.value!["read"] as! Bool
        }
        if (snapshot.value!["flag"] as? Bool != nil){
            flag = snapshot.value!["flag"] as! Bool
        }
        ref = snapshot.ref
    }

    
    func toAnyObject() -> AnyObject {
        return [
            "id": id,
            "uid": uid,
            "uname":uname,
            "rid": rid,
            "title": title,
            "body": body,
            "read": read,
            "flag": flag
        ]
    }

}
