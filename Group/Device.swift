//
//  Comment.swift
//  Pinly
//
//  Created by Hoang Le on 10/24/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class Device: NSObject {
    
    var id: String
    var uid: String
    var type: String
    var name: String
    var model: String
    var system: String
    var systemVer: String
    var trash = false
    var updated: Double = 0
    
    init(id: String, uid: String, device: UIDevice) {
        self.id = id
        self.uid = uid
        self.type = "apn"
        self.name = device.name
        self.model = device.model
        self.system = device.systemName
        self.systemVer = device.systemVersion
        updated = NSDate().timeIntervalSince1970
    }
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        uid = snapshot.value!["uid"] as? String ?? ""
        type = snapshot.value!["type"] as? String ?? ""
        name = snapshot.value!["name"] as? String ?? ""
        model = snapshot.value!["model"] as? String ?? ""
        system = snapshot.value!["system"] as? String ?? ""
        systemVer = snapshot.value!["systemVer"] as? String ?? ""
        trash = snapshot.value!["trash"] as? Bool ?? false
        updated = snapshot.value!["updated"] as? Double ?? 0
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "id": id,
            "uid": uid,
            "type": type,
            "name": name,
            "model": model,
            "system": system,
            "systemVer": systemVer,
            "trash": trash,
            "updated": updated
        ]
    }
}
