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
    var clipIndex:Int = 0
    var clips: [Clip]!
    
    init(uid: String, name:String, email: String, fabric: String, phone: String, fb:String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.fabric = fabric
        self.phone = phone
        self.fb = fb
    }
    
    init(data: UserModel) {
        self.uid = data.uid
        self.name = data.name
        self.email = data.email
        self.fabric = data.fabric
        self.phone = data.phone
        self.fb = data.fb
        self.clipIndex = data.clipIndex
        self.clips = [Clip]()
        for c in data.clips{
            let clip = Clip(data: c)
            clips.append(clip)
        }
    }
}
