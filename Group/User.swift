//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var uid: String
    var name: String
    var email: String
    var fabric: String
    var phone: String
    var fb: String
    
    init(uid: String, name:String, email: String, fabric: String, phone: String, fb:String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.fabric = fabric
        self.phone = phone
        self.fb = fb
    }
    
}
