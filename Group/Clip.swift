//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

struct Location {
    var longitude: Double?
    var latitude: Double?
    var name: String?
    var city: String?
    var country: String?
    var sublocal: String?
    var subarea: String?
}

class Clip: NSObject {
    
    var id: String
    var uid: String
    var fname: String // file name
    var txt: String
    var y: CGFloat // text position
    var flag = false
    var date: Double    
    var long: Double
    var lat: Double
    var lname: String // location name
    var city: String
    var country: String
    var sublocal: String
    var subarea: String
    var thumb: String = ""
    
    init(id: String, uid: String, fname: String, txt: String, y: CGFloat, location: Location, thumb: String) {
        self.id = id
        self.uid = uid
        self.fname =  fname
        self.txt = txt
        self.y = y
        self.long = location.longitude ?? 0
        self.lat = location.latitude ?? 0
        self.lname = location.name ?? ""
        self.city = location.city ?? ""
        self.country = location.country ?? ""
        self.sublocal = location.sublocal ?? ""
        self.subarea = location.subarea ?? ""
        self.thumb = thumb
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
        long = (snapshot.value!["long"] as? Double) ?? 0
        lat = (snapshot.value!["lat"] as? Double) ?? 0
        lname = (snapshot.value!["lname"] as? String) ?? ""
        city = (snapshot.value!["city"] as? String) ?? ""
        country = (snapshot.value!["country"] as? String) ?? ""
        sublocal = (snapshot.value!["sublocal"] as? String) ?? ""
        subarea = (snapshot.value!["subarea"] as? String) ?? ""
        thumb = (snapshot.value!["thumb"] as? String) ?? ""
    }
    
    init(data: ClipModel){
        self.id = data.id
        self.uid = data.uid
        self.fname =  data.fname
        self.txt = data.txt
        self.y = CGFloat(data.y)
        self.date = data.date
        self.long = data.long
        self.lat = data.lat
        self.lname = data.lname
        self.city = data.city
        self.country = data.country
        self.sublocal = data.sublocal
        self.subarea = data.subarea
        self.thumb = data.thumb
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "id": id,
            "uid": uid,
            "fname": fname,
            "txt": txt,
            "y": y,
            "flag": flag,
            "long": long,
            "lat": lat,
            "lname": lname,
            "city": city,
            "country": country,
            "sublocal": sublocal,
            "subarea": subarea,
            "thumb": thumb,
            "date": date
        ]
    }

}
