//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import RealmSwift

class UserModel: Object {
    dynamic var uid: String = ""
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var fb: String = ""
    dynamic var fbtoken: String = ""
    dynamic var phone: String = ""
    dynamic var fabric: String = ""
    dynamic var city: String = ""
    dynamic var country: String = ""
    dynamic var username: String = ""
    dynamic var password: String = ""
    dynamic var following: Bool = true
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
    }
    
    fileprivate dynamic var flagsData: Data?
    
    var flags: [String: Bool] {
        get {
            guard let flagsData = flagsData else {
                return [String: Bool]()
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: flagsData, options: []) as? [String: Bool]
                return dict!
            } catch {
                return [String: Bool]()
            }
        }
        
        set {
            do {
                let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
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
