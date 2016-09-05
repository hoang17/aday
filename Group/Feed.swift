//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit

class Feed: NSObject {
    
    var id: String
    var message: String?
    var type: String?
    var link: String?
    
    init(id: String, message:String?, type: String?, link: String?) {
        self.id = id
        self.message = message
        self.type = type
        self.link = link
    }
}
