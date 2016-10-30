//
//  LocationInfo.swift
//  Pinly
//
//  Created by Hoang Le on 10/30/16.
//  Copyright © 2016 ping. All rights reserved.
//

import MapKit

class LocationInfo {
    var location: CLLocation?
    var loaded = false
    var name = ""
    var city = ""
    var country = ""
    var sublocal = ""
    var subarea = ""
    
    func load(location: CLLocation, completion: ((LocationInfo)->())?){
        self.location = location
        self.loaded = false
        self.name = ""
        self.city = ""
        self.country = ""
        self.sublocal = ""
        self.subarea = ""
        loadInfo(completion)
    }
    
    func loadInfo(completion: ((LocationInfo)->())?){
        guard let location = self.location else {
            completion?(self)
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            guard error == nil else {
                print(error)
                completion?(self)
                return
            }
            
            if let placeMark = placemarks?.first {
                // print(placeMark.addressDictionary)                
                
                self.loaded = true
                self.name = placeMark.addressDictionary!["Name"] as? String ?? ""
                self.city = placeMark.addressDictionary!["City"] as? String ?? ""
                self.country = placeMark.addressDictionary!["CountryCode"] as? String ?? ""
                self.sublocal = placeMark.addressDictionary!["SubLocality"] as? String ?? ""
                self.subarea = placeMark.addressDictionary!["SubAdministrativeArea"] as? String ?? ""
            }
            completion?(self)
        })
    }
}
