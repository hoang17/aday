//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import FirebaseDatabase

class Clip: NSObject {
    
    var id: String
    var uid: String
    var uname: String // user name
    var fname: String // file name
    var txt: String
    var y: Float // text position
    var flag = false
    var long: Double
    var lat: Double
    var altitude: Double
    var course: Double
    var speed: Double
    var lname: String // location name
    var city: String
    var country: String
    var sublocal: String
    var subarea: String
    var thumb: String = ""
    var trash = false
    var date: Double = 0
    var updated: Double = 0
    var furl: String = ""
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        let value = snapshot.value as? NSDictionary
        uid = value?["uid"] as? String ?? ""
        uname = value?["uname"] as? String ?? ""
        fname = value?["fname"] as? String ?? ""
        txt = value?["txt"] as? String ?? ""
        y = value?["y"] as? Float ?? 0
        flag = value?["flag"] as? Bool ?? false
        long = value?["long"] as? Double ?? 0
        lat = value?["lat"] as? Double ?? 0
        altitude = value?["altitude"] as? Double ?? 0
        course = value?["course"] as? Double ?? 0
        speed = value?["speed"] as? Double ?? 0
        lname = value?["lname"] as? String ?? ""
        city = value?["city"] as? String ?? ""
        country = value?["country"] as? String ?? ""
        sublocal = value?["sublocal"] as? String ?? ""
        subarea = value?["subarea"] as? String ?? ""
        thumb = value?["thumb"] as? String ?? ""
        trash = value?["trash"] as? Bool ?? false
        date = value?["date"] as? Double ?? 0
        updated = value?["updated"] as? Double ?? 0
        furl = value?["furl"] as? String ?? ""
    }
    
    init(data: ClipModel){
        self.id = data.id
        self.uid = data.uid
        self.uname =  data.uname
        self.fname =  data.fname
        self.txt = data.txt
        self.y = data.y
        self.long = data.long
        self.lat = data.lat
        self.altitude = data.altitude
        self.course = data.course
        self.speed = data.speed
        self.lname = data.lname
        self.city = data.city
        self.country = data.country
        self.sublocal = data.sublocal
        self.subarea = data.subarea
        self.thumb = data.thumb
        self.flag = data.flag
        self.trash = data.trash
        self.date = data.date
        self.updated = data.updated
        self.furl = data.furl
    }
    
    func toAnyObject() -> [String: Any] {
        var r = [String: Any]()
        r["id"] = id
        r["uid"] = uid
        r["uname"] = uname
        r["fname"] = fname
        r["txt"] = txt
        r["y"] = y
        r["flag"] = flag
        r["long"] = long
        r["lat"] = lat
        r["altitude"] = altitude
        r["course"] = course
        r["speed"] = speed
        r["lname"] = lname
        r["city"] = city
        r["country"] = country
        r["sublocal"] = sublocal
        r["subarea"] = subarea
        r["thumb"] = thumb
        r["trash"] = trash
        r["date"] = date
        r["updated"] = updated
        r["furl"] = furl
        return r
    }
}
