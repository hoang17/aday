//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import RealmSwift

class UserModel: Object {
    dynamic var uid: String!
    dynamic var name: String!
    dynamic var email: String!
    dynamic var fb: String!
    dynamic var fb_token: String = ""
    dynamic var phone: String!
    dynamic var fabric: String!
    dynamic var city: String!
    dynamic var country: String!
    dynamic var uploaded: Double = 0.0
    dynamic var username: String = ""
    dynamic var password: String = ""
    dynamic var follow: Bool = true
    let clips = List<ClipModel>()
    let following = List<FollowingFriend>()
        
    func load(user: User){
        uid = user.uid
        name = user.name
        email = user.email
        fb = user.fb
        fb_token = user.fb_token
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
        
        for friendUid in user.following.keys {
            let friend = FollowingFriend()
            friend.uid = friendUid
            following.append(friend)
        }
    }
    
    override static func primaryKey() -> String? {
        return "uid"
    }

}

class FollowingFriend: Object {
    
    dynamic var uid: String!
}
