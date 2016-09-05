//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit

class Page: NSObject {
    
    var id: String
    var name: String
    var category: String
    
    init(id: String, name:String, category: String) {
        self.id = id
        self.name = name
        self.category = category
    }
}
