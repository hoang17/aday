//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase

class User: NSObject {
    
    var uid: String
    var name: String
    var email: String
    var fabric: String
    var phone: String
    var fb: String
    var city: String
    var country: String
    var username: String = ""
    var password: String = ""
    var uploaded: Double = 0.0 // last uploaded time
    var clips = [Clip]()
    var friends = [String:Bool]()
    
    init(uid: String, name:String, email: String, fabric: String, phone: String, fb:String, city: String, country: String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.fabric = fabric
        self.phone = phone
        self.fb = fb
        self.city = city
        self.country = country
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.uid = snapshot.key
        self.name = snapshot.value!["name"] as! String
        self.email = snapshot.value!["email"] as! String
        self.phone = (snapshot.value!["phone"] as? String) ?? ""
        self.fabric = (snapshot.value!["fabric"] as? String) ?? ""
        self.fb = snapshot.value!["fb"] as! String
        self.city = (snapshot.value!["city"] as? String) ?? ""
        self.country = (snapshot.value!["country"] as? String) ?? ""
        self.uploaded = (snapshot.value!["uploaded"] as? Double) ?? 0
        for clipSnapshot in snapshot.childSnapshotForPath("clips").children {
            let clip = Clip(snapshot: clipSnapshot as! FIRDataSnapshot)
            self.clips.insert(clip, atIndex: 0)
        }
        self.friends = snapshot.value!["friends"] as? [String : Bool] ?? [String:Bool]()
        self.username = (snapshot.value!["username"] as? String) ?? ""
        self.password = (snapshot.value!["password"] as? String) ?? ""
    }
    
    init(data: UserModel) {
        self.uid = data.uid
        self.name = data.name
        self.email = data.email
        self.fabric = data.fabric
        self.phone = data.phone
        self.fb = data.fb
        self.city = data.city
        self.country = data.country
        self.uploaded = data.uploaded
        self.username = data.username
        self.password = data.password
        self.clips = [Clip]()
        for c in data.clips{
            let clip = Clip(data: c)
            clips.append(clip)
        }
    }
}
