//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase

class User: NSObject {
    
    var uid: String
    var name: String
    var email: String
    var fb: String
    var fabric: String = ""
    var phone: String = ""
    var fbtoken: String = ""
    var city: String = ""
    var country: String = ""
    var username: String = ""
    var password: String = ""
    var flag: Bool = false
    var trash: Bool = false

    var flags = [String:Bool]()
    
    var created: Double = 0
    var updated: Double = 0
    var uploaded: Double = 0 // last uploaded time
    
    init(uid: String, name:String, email: String, fb:String, fbtoken:String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.fb = fb
        self.fbtoken = fbtoken
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.uid = snapshot.key
        self.name = snapshot.value!["name"] as? String ?? ""
        self.email = snapshot.value!["email"] as? String ?? ""
        self.phone = snapshot.value!["phone"] as? String ?? ""
        self.fabric = snapshot.value!["fabric"] as? String ?? ""
        self.fb = snapshot.value!["fb"] as? String ?? ""
        self.fbtoken = snapshot.value!["fbtoken"] as? String ?? ""
        self.city = snapshot.value!["city"] as? String ?? ""
        self.country = snapshot.value!["country"] as? String ?? ""
        self.username = snapshot.value!["username"] as? String ?? ""
        self.password = snapshot.value!["password"] as? String ?? ""
        self.flag = snapshot.value!["flag"] as? Bool ?? false
        self.trash = snapshot.value!["trash"] as? Bool ?? false
        
        self.uploaded = snapshot.value!["uploaded"] as? Double ?? 0
        self.created = snapshot.value!["created"] as? Double ?? 0
        self.updated = snapshot.value!["updated"] as? Double ?? 0
        
        self.flags = snapshot.value!["flags"] as? [String : Bool] ?? [String:Bool]()
    }
    
    init(data: UserModel) {
        self.uid = data.uid
        self.name = data.name
        self.email = data.email
        self.fabric = data.fabric
        self.phone = data.phone
        self.fb = data.fb
        self.fbtoken = data.fbtoken
        self.city = data.city
        self.country = data.country
        self.username = data.username
        self.password = data.password
        self.flag = data.flag
        self.trash = data.trash
        self.uploaded = data.uploaded
        
        self.flags = data.flags
    }
}
