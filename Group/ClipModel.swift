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
    dynamic var flag = false
    dynamic var long: Double = 0
    dynamic var lat: Double = 0
    dynamic var lname: String = "" // location name
    dynamic var city: String = ""
    dynamic var country: String = ""
    dynamic var sublocal: String = ""
    dynamic var subarea: String = ""
    dynamic var thumb: String = ""
    dynamic var trash = false
    dynamic var date: Double = 0.0
    dynamic var updated: Double = 0.0
    
    convenience init(clip: Clip){
        self.init()
        id = clip.id
        uid = clip.uid
        fname = clip.fname
        txt = clip.txt
        y = Float(clip.y)
        flag = clip.flag
        long = clip.long
        lat = clip.lat
        lname = clip.lname
        city = clip.city
        country = clip.country
        sublocal = clip.sublocal
        subarea = clip.subarea
        thumb = clip.thumb
        trash = clip.trash
        date = clip.date
        updated = clip.updated
    }

    convenience init(id: String, uid: String, fname: String, txt: String, y: CGFloat, location: Location) {
        self.init()
        self.id = id
        self.uid = uid
        self.fname =  fname
        self.txt = txt
        self.y = Float(y)
        self.long = location.longitude ?? 0
        self.lat = location.latitude ?? 0
        self.lname = location.name ?? ""
        self.city = location.city ?? ""
        self.country = location.country ?? ""
        self.sublocal = location.sublocal ?? ""
        self.subarea = location.subarea ?? ""
        self.date = NSDate().timeIntervalSince1970
        self.updated = self.date
    }
        
    override static func primaryKey() -> String? {
        return "id"
    }
}

class ClipUpload: Object {
    dynamic var id: String!
    dynamic var clipUploaded: Bool = false
    dynamic var thumbUploaded: Bool = false
    dynamic var uploadRetry: Int = 0
    dynamic var thumb: String = ""
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
