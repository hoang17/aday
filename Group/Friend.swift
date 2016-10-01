//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import RealmSwift
class Friend: NSObject {
    
    var fb: String
    var name: String
    
    
    init(fb: String, name:String) {
        self.fb = fb
        self.name = name
       
    }
}



class FollowingFriend: Object {
    
   dynamic var uid: String!
   
}
