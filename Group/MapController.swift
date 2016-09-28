//
//  MapController.swift
//  Group
//
//  Created by Hoang Le on 9/20/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import RealmSwift
import FirebaseDatabase
import FirebaseAuth

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapView = MKMapView()
    
    let regionRadius: CLLocationDistance = 1000
    
    var clipAnnotations = [ClipAnnotation]()
    
    var points = [MKPointAnnotation]()
    
    let locationManager = CLLocationManager()
    
    var myLocation:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.frame = view.bounds
        mapView.mapType = .Standard
        mapView.height -= 50
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenterCoordinate(coor, animated: false)
        }
        
        do {
            let realm = try Realm()
            let list = realm.objects(UserModel.self)
            for data in list {
                for clipdata in data.clips {
                    let clip = Clip(data: clipdata)
                    clipAnnotations.append(ClipAnnotation(clip: clip))
                }
            }
            mapView.addAnnotations(clipAnnotations)
        }
        catch {
            print(error)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
        locationManager.stopUpdatingLocation()
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            
            let placeMark: CLPlacemark! = placemarks?[0]
            if (placeMark == nil){
                return
            }
            let city = (placeMark.addressDictionary!["City"] as? String) ?? ""
            let country = (placeMark.addressDictionary!["CountryCode"] as? String) ?? ""
            let uid : String! = FIRAuth.auth()?.currentUser?.uid
            let update = ["city": city, "country": country]
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            ref.updateChildValues(update)
            
        })
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            // Don't proceed with custom callout
            return
        }
        
        let clipAnnotation = view.annotation as! ClipAnnotation
        
        let calloutView = ClipCalloutView(clip: clipAnnotation.clip, frame: CGRect(x: 0,y: 0, width: 90,height: 160))
        calloutView.locationName.text = clipAnnotation.title
        calloutView.locationSub.text = clipAnnotation.subtitle
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("CallPhoneNumber:")))
//        calloutView.starbucksPhone.addGestureRecognizer(tapGesture)
//        calloutView.starbucksPhone.isUserInteractionEnabled = true
//        calloutView.starbucksImage.image = clipAnnotation.image
        
        calloutView.center = CGPoint(x: view.bounds.size.width/3, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
//        mapView.setCenterCoordinate((view.annotation?.coordinate)!, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? ClipAnnotation {
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
            
            if annotationView == nil {
                
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                annotationView!.canShowCallout = false
                
//                annotationView.calloutOffset = CGPoint(x: -5, y: 5)
//                annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
//                let imageView = UIImageView(frame:CGRectMake(0, 0, 32, 32))
//                imageView.kf_setImageWithURL(NSURL(string: annotation.clip.thumb))
//                annotationView.leftCalloutAccessoryView = imageView
                
            } else {
                annotationView!.annotation = annotation
            }
            
            annotationView!.pinColor = annotation.pinColor()
            
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! ClipAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
}

class ClipAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let clip: Clip
    
    init(clip: Clip) {
        self.clip = clip
        self.title = clip.lname
        self.coordinate = CLLocationCoordinate2D(latitude: clip.lat, longitude: clip.long)
        super.init()
    }

    var subtitle: String? {
        return clip.sublocal
    }
    
    func pinColor() -> MKPinAnnotationColor  {
        switch clip.city {
        case "Sculpture", "Plaque":
            return .Purple
        case "Mural", "Monument":
            return .Green
        default:
            return .Red
        }
    }
    
    // annotation callout opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [String(kABPersonAddressStreetKey): self.subtitle as! AnyObject]
        let placemark = MKPlacemark(coordinate: self.coordinate, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        
        return mapItem
    }
    
}
