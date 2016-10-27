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
    var y: Float // text position
    var flag = false
    var long: Double
    var lat: Double
    var lname: String // location name
    var city: String
    var country: String
    var sublocal: String
    var subarea: String
    var thumb: String = ""
    var trash = false
    var date: Double = 0
    var updated: Double = 0
    
    var follows = [String:Bool]()
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        uid = snapshot.value!["uid"] as? String ?? ""
        fname = snapshot.value!["fname"] as? String ?? ""
        txt = snapshot.value!["txt"] as? String ?? ""
        y = snapshot.value!["y"] as? Float ?? 0
        flag = snapshot.value!["flag"] as? Bool ?? false
        long = snapshot.value!["long"] as? Double ?? 0
        lat = snapshot.value!["lat"] as? Double ?? 0
        lname = snapshot.value!["lname"] as? String ?? ""
        city = snapshot.value!["city"] as? String ?? ""
        country = snapshot.value!["country"] as? String ?? ""
        sublocal = snapshot.value!["sublocal"] as? String ?? ""
        subarea = snapshot.value!["subarea"] as? String ?? ""
        thumb = snapshot.value!["thumb"] as? String ?? ""
        trash = snapshot.value!["trash"] as? Bool ?? false
        date = snapshot.value!["date"] as? Double ?? 0
        updated = snapshot.value!["updated"] as? Double ?? 0
        
        self.follows = snapshot.value!["follows"] as? [String : Bool] ?? [String:Bool]()
    }
    
    init(data: ClipModel){
        self.id = data.id
        self.uid = data.uid
        self.fname =  data.fname
        self.txt = data.txt
        self.y = data.y
        self.long = data.long
        self.lat = data.lat
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
        
        self.follows = data.follows
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "id": id,
            "uid": uid,
            "fname": fname,
            "txt": txt,
            "y": y,
            "flag": flag,
            "trash": trash,
            "long": long,
            "lat": lat,
            "lname": lname,
            "city": city,
            "country": country,
            "sublocal": sublocal,
            "subarea": subarea,
            "thumb": thumb,
            "date": date,
            "updated": updated,
            "follows": follows
        ]
    }
}
