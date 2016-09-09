//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class Clip: NSObject {
    
    var id: String
    var uid: String
    var fname: String
    var flag = false
    
    init(id: String, uid: String, fname: String) {
        self.id = id
        self.uid = uid
        self.fname =  fname
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "id": id,
            "uid": uid,
            "fname": fname,
            "flag": flag
        ]
    }

}
