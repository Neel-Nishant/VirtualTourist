//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 28/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    var longGestureRecognizer: UILongPressGestureRecognizer!
    var tapGestureRegognizer: UITapGestureRecognizer!
    var longitudeString: String!
    var latitudeString: String!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        
        
        longGestureRecognizer.minimumPressDuration = 2.0
//        longGestureRecognizer.cancelsTouchesInView = false
        mapView.addGestureRecognizer(longGestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func addAnnotation (gesture: UIGestureRecognizer){
        if gesture.state == .began {
            var touchPoint = gesture.location(in: mapView)
            var coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            latitudeString = "\(coordinates.latitude)"
            longitudeString = "\(coordinates.longitude)"
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            self.mapView.addAnnotation(annotation)
        }
        else {
            return
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
            pinView!.pinColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if control == view.rightCalloutAccessoryView{
//            performSegue(withIdentifier: "pinSelected", sender: nil)
//        }
//    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegue(withIdentifier: "pinSelected", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinSelected" {
            let photoVC = segue.destination as! PhotoAlbumViewController
            photoVC.lat = latitudeString
            photoVC.long = longitudeString
        }
    }
    
}

