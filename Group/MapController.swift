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
import AVKit
import AVFoundation

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapView = MKMapView()
    
    let regionRadius: CLLocationDistance = 5000
    
    var clipAnnotations = [ClipAnnotation]()
    
    let locationManager = CLLocationManager()
    
    var myLocation:CLLocationCoordinate2D?
    
    var calloutView: PlayerCalloutView!
    
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
                    
                    let point = CLLocationCoordinate2D(latitude: clipdata.lat, longitude: clipdata.long)
                    
                    // check if clip location is new
                    var isnew = true
                    for ca in clipAnnotations {
                        if self.isPointInsideCircle(point, circleCentre: ca.coordinate, radius: 50){
                            isnew = false
                            let clip = Clip(data: clipdata)
                            ca.clips.append(clip)
                            break
                        }
                    }
                    
                    if isnew {
                        let clip = Clip(data: clipdata)
                        let ca = ClipAnnotation(clip: clip)
                        clipAnnotations.append(ca)
                        // self.addCircle(ca.coordinate, radius: 50)
                    }
                }
            }
            mapView.addAnnotations(clipAnnotations)
        }
        catch {
            print(error)
        }
        
    }
    
    func addCircle(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle = MKCircle(centerCoordinate: coordinate, radius: radius)
        mapView.addOverlay(circle)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        // If you want to include other shapes, then this check is needed. If you only want circles, then remove it.
        // if overlay is MKCircle { }
        
        let circle = MKCircleRenderer(overlay: overlay)
        circle.alpha = 0.1
        circle.lineWidth = 1
        circle.strokeColor = UIColor.redColor()
        circle.fillColor = UIColor.blackColor()
        // circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
        return circle
    }
    
    func isPointInsideCircle(point: CLLocationCoordinate2D, circleCentre centre: CLLocationCoordinate2D, radius: Double) -> Bool {
        let pointALocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let pointBLocation = CLLocation(latitude: centre.latitude, longitude: centre.longitude)
        let distanceMeters: Double = pointALocation.distanceFromLocation(pointBLocation)
        if distanceMeters > radius {
            return false
        }
        else {
            return true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, regionRadius, regionRadius)
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
        
        calloutView = PlayerCalloutView(clips: clipAnnotation.clips, frame: CGRect(x: 0,y: 0, width: 108,height: 222))
        calloutView.locationName.text = clipAnnotation.title
        calloutView.locationSub.text = clipAnnotation.subtitle
        
        calloutView.center = CGPoint(x: view.bounds.size.width/3, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
      
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)
        
//        mapView.setCenterCoordinate((view.annotation?.coordinate)!, animated: true)
    }
    
    func tapGesture(sender:UITapGestureRecognizer){
        calloutView.pause()
        calloutView.playNextClip()
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
                annotationView!.animatesDrop = true
                
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
    var clips = [Clip]()
    
    init(clip: Clip) {
        self.clip = clip
        self.clips.append(clip)
        self.title = clip.lname
        self.coordinate = CLLocationCoordinate2D(latitude: clip.lat, longitude: clip.long)
        super.init()
    }
    
    var subtitle: String? {
        return clips.first!.sublocal
    }
    
    func pinColor() -> MKPinAnnotationColor {
        return .Red
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
