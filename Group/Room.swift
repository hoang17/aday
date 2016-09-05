//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit

class Room: NSObject {
    var id: String
    var name: String
    
    init(id: String, name:String) {
        self.id = id
        self.name = name
    }
}