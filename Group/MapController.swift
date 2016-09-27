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

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapView = MKMapView()
    
    let regionRadius: CLLocationDistance = 1000
    
    var artworks = [Artwork]()
    
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
                if data.clips.count > 0 {
                    let clip = Clip(data: data.clips.last!)
                    artworks.append(Artwork(clip: clip))
                    
//                    let point = MKPointAnnotation()
//                    point.coordinate = CLLocationCoordinate2D(latitude: clip.lat, longitude: clip.long)
//                    point.title = clip.lname
//                    point.subtitle = clip.sublocal
//                    points.append(point)
                    
                }
            }
            mapView.addAnnotations(artworks)
        }
        catch {
            print(error)
        }
        
        

    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Artwork {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                
                let url = NSURL(string: annotation.clip.thumb)
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                view.image = UIImage(data: data!)
            }
            
            view.pinColor = annotation.pinColor()
            
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
}

class Artwork: NSObject, MKAnnotation {
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
            return .Red
        case "Mural", "Monument":
            return .Purple
        default:
            return .Green
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
