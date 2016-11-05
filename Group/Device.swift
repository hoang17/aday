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
        updated = Date().timeIntervalSince1970
    }
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        let value = snapshot.value as? NSDictionary
        uid = value?["uid"] as? String ?? ""
        type = value?["type"] as? String ?? ""
        name = value?["name"] as? String ?? ""
        model = value?["model"] as? String ?? ""
        system = value?["system"] as? String ?? ""
        systemVer = value?["systemVer"] as? String ?? ""
        trash = value?["trash"] as? Bool ?? false
        updated = value?["updated"] as? Double ?? 0
    }
    
    func toAnyObject() -> NSDictionary {
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
