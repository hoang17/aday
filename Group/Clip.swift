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
    var txt: String
    var y: CGFloat // text position
    var flag = false
    var date: Double    
    var player: MiniPlayer?
    
    init(id: String, uid: String, fname: String, txt: String, y: CGFloat) {
        self.id = id
        self.uid = uid
        self.fname =  fname
        self.txt = txt
        self.y = y
        self.date = NSDate().timeIntervalSince1970
    }
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        uid = snapshot.value!["uid"] as! String
        fname = snapshot.value!["fname"] as! String
        txt = snapshot.value!["txt"] as! String
        y = snapshot.value!["y"] as! CGFloat
        if (snapshot.value!["flag"] as? Bool != nil){
            flag = snapshot.value!["flag"] as! Bool
        }
        date = snapshot.value!["date"] as! Double
    }
    
    init(data: ClipModel){
        self.id = data.id
        self.uid = data.uid
        self.fname =  data.fname
        self.txt = data.txt
        self.y = CGFloat(data.y)
        self.date = data.date
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "id": id,
            "uid": uid,
            "fname": fname,
            "txt": txt,
            "y": y,
            "flag": flag,
            "date": date
        ]
    }

}
