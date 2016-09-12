//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import RealmSwift

class ClipModel: Object {
    dynamic var id: String!
    dynamic var uid: String!
    dynamic var fname: String!
    dynamic var txt: String!
    dynamic var y: Float = 0.0
    dynamic var date: Double = 0.0
    dynamic var flag = false
    
    func load(clip: Clip){
        id = clip.id
        uid = clip.uid
        fname = clip.fname
        txt = clip.txt
        y = Float(clip.y)
        flag = clip.flag
        date = clip.date
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
