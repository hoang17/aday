//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import RealmSwift

class UserModel: Object {
    dynamic var uid: String!
    dynamic var name: String!
    dynamic var email: String!
    dynamic var fb: String!
    dynamic var phone: String!
    dynamic var fabric: String!
    dynamic var city: String!
    dynamic var country: String!
    dynamic var uploaded: Double = 0.0
    dynamic var username: String = ""
    dynamic var password: String = ""
    let clips = List<ClipModel>()
    
    func load(user: User){
        uid = user.uid
        name = user.name
        email = user.email
        fb = user.fb
        phone = user.phone
        fabric = user.fabric
        city = user.city
        country = user.country
        uploaded = user.uploaded
        username = user.username
        password = user.password
        for clip in user.clips{
            let data = ClipModel()
            data.load(clip)
            clips.append(data)
        }
    }
    
    override static func primaryKey() -> String? {
        return "uid"
    }

}
