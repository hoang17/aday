//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import RealmSwift

class ClipModel: Object {
    dynamic var id: String!
    dynamic var uid: String!
    dynamic var uname: String!
    dynamic var fname: String!
    dynamic var txt: String!
    dynamic var y: Float = 0.0
    dynamic var flag = false
    dynamic var long: Double = 0
    dynamic var lat: Double = 0
    dynamic var altitude: Double = 0
    dynamic var course: Double = 0
    dynamic var speed: Double = 0
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
        uname = clip.uname
        fname = clip.fname
        txt = clip.txt
        y = Float(clip.y)
        flag = clip.flag
        long = clip.long
        lat = clip.lat
        altitude = clip.altitude
        course = clip.course
        speed = clip.speed
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

    convenience init(id: String, uid: String, uname: String, fname: String, txt: String, y: CGFloat, locationInfo: LocationInfo) {
        self.init()
        self.id = id
        self.uid = uid
        self.uname = uname
        self.fname = fname
        self.txt = txt
        self.y = Float(y)
        
        self.long = locationInfo.location?.coordinate.longitude ?? 0
        self.lat = locationInfo.location?.coordinate.latitude ?? 0
        self.altitude = locationInfo.location?.altitude ?? 0
        self.course = locationInfo.location?.course ?? 0
        self.speed = locationInfo.location?.speed ?? 0
        
        self.lname = locationInfo.name
        self.city = locationInfo.city
        self.country = locationInfo.country
        self.sublocal = locationInfo.sublocal
        self.subarea = locationInfo.subarea
        
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
    dynamic var liloaded = true
    
    convenience init(id: String, liloaded: Bool = true) {
        self.init()
        self.id = id
        self.liloaded = liloaded
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
