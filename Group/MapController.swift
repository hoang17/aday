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

class MapController: UIViewController, MKMapViewDelegate {

    var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    
    var artworks = [Artwork]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let mapView = MKMapView()
        
        mapView.mapType = .Standard
        mapView.frame = view.bounds
        mapView.height -= 50
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
//        centerMapOnLocation(initialLocation)
        
//        mapView.addAnnotations(artworks)
        
    }
        
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }

    var subtitle: String? {
        return locationName
    }
    
    // MARK: - MapKit related methods
    
    // pinColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    func pinColor() -> MKPinAnnotationColor  {
        switch discipline {
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
