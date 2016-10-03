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
    
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Begin setting location
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        /// End location
        
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
        
        let realm = AppDelegate.realm
        let clips = realm.objects(ClipModel.self).filter("follow = true").sorted("date", ascending: false)
        
        for clip in clips {
            
            let point = CLLocationCoordinate2D(latitude: clip.lat, longitude: clip.long)
            
            // check if clip location is new
            var isnew = true
            for ca in self.clipAnnotations {
                if self.isPointInsideCircle(point, circleCentre: ca.coordinate, radius: 50){
                    isnew = false
                    ca.addClip(clip)
                    break
                }
            }
            if isnew {
                let ca = ClipAnnotation(clip: clip)
                self.clipAnnotations.append(ca)
                // self.addCircle(ca.coordinate, radius: 50)
            }
        }
        self.mapView.addAnnotations(self.clipAnnotations)
        
        notificationToken = clips.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .Initial:
                // Results are now populated and can be accessed without blocking the UI
                break
            case .Update(_, let deletions, let insertions, let modifications):
                
//                print(insertions)
//                print(modifications)
//                print(deletions)
                
                if insertions.count > 0 {
                    
                    let inserts = insertions.map { clips[$0] }
                    
                    for clip in inserts {
                        
                        let point = CLLocationCoordinate2D(latitude: clip.lat, longitude: clip.long)
                        
                        // check if clip location is new
                        var isnew = true
                        for ca in self!.clipAnnotations {
                            if self!.isPointInsideCircle(point, circleCentre: ca.coordinate, radius: 50){
                                self?.mapView.removeAnnotation(ca)
                                isnew = false
                                ca.addClip(clip)
                                self?.mapView.addAnnotation(ca)
                                break
                            }
                        }
                        
                        if isnew {
                            let ca = ClipAnnotation(clip: clip)
                            self!.clipAnnotations.append(ca)
                            self?.mapView.addAnnotation(ca)
                            // self.addCircle(ca.coordinate, radius: 50)
                        }
                    }
                    
                } else if modifications.count > 0 || deletions.count > 0 {
                
                    self?.mapView.removeAnnotations((self?.clipAnnotations)!)
                    self?.clipAnnotations = [ClipAnnotation]()
                    for clip in clips {
                        
                        let point = CLLocationCoordinate2D(latitude: clip.lat, longitude: clip.long)
                        
                        // check if clip location is new
                        var isnew = true
                        for ca in self!.clipAnnotations {
                            if self!.isPointInsideCircle(point, circleCentre: ca.coordinate, radius: 50){
                                isnew = false
                                ca.addClip(clip)
                                break
                            }
                        }
                        
                        if isnew {
                            let ca = ClipAnnotation(clip: clip)
                            self!.clipAnnotations.append(ca)
                            // self.addCircle(ca.coordinate, radius: 50)
                        }
                    }
                    self!.mapView.addAnnotations(self!.clipAnnotations)
                    
                }
                
                break
            case .Error(let error):
                print(error)
                break
            }
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
        
        if let location = manager.location {
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
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
        
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            // Don't proceed with custom callout
            return
        }
        
        mapView.showsUserLocation = false
        
        let clipAnnotation = view.annotation as! ClipAnnotation
        
        calloutView = PlayerCalloutView(clips: clipAnnotation.clips, frame: CGRect(x: 0,y: 0, width: 108,height: 222))
        calloutView.locationName.text = clipAnnotation.title
        calloutView.locationSub.text = clipAnnotation.subtitle
        
        calloutView.center = CGPoint(x: view.bounds.size.width/3, y: -calloutView.bounds.size.height*0.52-2)
        
        view.subviews.forEach({ $0.hidden = true })
        view.addSubview(calloutView)
      
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)
        
//        mapView.setCenterCoordinate((view.annotation?.coordinate)!, animated: true)
        
        
//        let ca = ClipAnnotation(clip: clipAnnotations[0].clip)
//        mapView.addAnnotation(ca)
        
        
    }
    
    func tapGesture(sender:UITapGestureRecognizer){
        calloutView.pause()
        calloutView.playNextClip()
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if calloutView != nil {
            calloutView.pause()
            calloutView.removeFromSuperview()
        }
        
        view.subviews.forEach({ $0.hidden = false })
        
        mapView.showsUserLocation = true
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
            
            annotationView?.subviews.forEach({ $0.removeFromSuperview() })
            
            annotationView!.pinColor = annotation.pinColor()
            
            let cellwidth: CGFloat = 18
            let width : CGFloat = (CGFloat(annotation.users.count) * cellwidth) + 4
            
            let container = UIView(frame: CGRect(x: -(width/2)+7.5, y: -4, width: width, height: 22))
            container.backgroundColor = UIColor.whiteColor()
            container.layer.cornerRadius = container.height/2
            container.layer.masksToBounds = true
            container.clipsToBounds = true
            container.layer.borderColor = UIColor.lightGrayColor().CGColor;
            container.layer.borderWidth = 0.5
            annotationView?.addSubview(container)
            
            var i : CGFloat = 3
            for user in annotation.users.values {
                let profileImg = UIImageView()
                profileImg.origin = CGPoint(x: i, y: 3)
                profileImg.size = CGSize(width: 16, height: 16)
                profileImg.layer.cornerRadius = profileImg.height/2
                profileImg.layer.masksToBounds = false
                profileImg.clipsToBounds = true
                profileImg.layer.borderWidth = 0.5
                profileImg.layer.borderColor = UIColor.lightGrayColor().CGColor
                profileImg.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(user.fb)/picture?type=large&return_ssl_resources=1"))
                container.addSubview(profileImg)
                i += cellwidth
            }
            
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! ClipAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
    deinit {
        notificationToken?.stop()
    }
    
}

class ClipAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let clip: ClipModel
    var clips = [ClipModel]()
    var users = [String:UserModel]()
    
    init(clip: ClipModel) {
        let user = AppDelegate.realm.objectForPrimaryKey(UserModel.self, key: clip.uid)
        self.users[clip.uid] = user
        self.clip = clip
        self.clips.append(clip)
        self.title = clip.lname
        self.coordinate = CLLocationCoordinate2D(latitude: clip.lat, longitude: clip.long)
        super.init()
    }
    
    func addClip(clip: ClipModel) {
        if self.users[clip.uid] == nil {
            let user = AppDelegate.realm.objectForPrimaryKey(UserModel.self, key: clip.uid)
            self.users[clip.uid] = user
        }
        self.clips.append(clip)
        self.clips.sortInPlace({ $0.date > $1.date })
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
