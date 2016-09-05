//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit

class Friend: NSObject {
    
    var uid: String
    var name: String
    
    init(uid: String, name:String) {
        self.uid = uid
        self.name = name
    }
}
