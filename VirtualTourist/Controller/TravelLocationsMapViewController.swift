//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 28/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    var longGestureRecognizer: UILongPressGestureRecognizer!
    var tapGestureRegognizer: UITapGestureRecognizer!
    var longitudeString: String!
    var latitudeString: String!
    var currentPin: Pin?
    var deleteEnabled = false
    @IBOutlet weak var editButtonLabel: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        deletePinLabel.isHidden = true
        longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        
        loadMap()
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
            currentPin = Pin(latitude: coordinates.latitude, longitude: coordinates.longitude, context: CoreDataStack.sharedInstance().context)
            
            do {
                try CoreDataStack.sharedInstance().saveContext()
            }
            catch {
                print("errorrrr")
            }
            
            self.mapView.addAnnotation(annotation)
            FlickrClient.sharedInstance().taskForGETMethod(latitude: latitudeString, longitude: longitudeString, currentPin: currentPin!, page: 1, completionHandler: { (success, error) in
                if (error != nil) {
                    print("error getting HTTP method")
                }
            })
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
        do {
            let pinAnnotation = view.annotation!
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pinAnnotation.coordinate.latitude, pinAnnotation.coordinate.longitude])
            fetchRequest.predicate = predicate
            let pins = try CoreDataStack.sharedInstance().context.fetch(fetchRequest) as? [Pin]
            currentPin = pins![0]
            latitudeString = "\((currentPin?.latitude)!)"
            longitudeString = "\((currentPin?.longitude)!)"
        } catch let error as NSError {
            print("failed to get pin by object id")
            print(error.localizedDescription)
            return
        }
        if !deleteEnabled {
            
            performSegue(withIdentifier: "pinSelected", sender: nil)
        }
        else {
            CoreDataStack.sharedInstance().context.delete(currentPin!)
            mapView.removeAnnotation(view.annotation!)
            do {
                try CoreDataStack.sharedInstance().saveContext()
            }
            catch {
                print("error removing object")
            }
            
        }
        
        
            
    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinSelected" {
            let photoVC = segue.destination as! PhotoAlbumViewController
            photoVC.lat = latitudeString
            photoVC.long = longitudeString
            photoVC.currentPin = currentPin
        }
    }
    func loadMap() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        do {
            if let pins = try? CoreDataStack.sharedInstance().context.fetch(fetchRequest) as! [Pin] {
                var annotations = [MKPointAnnotation]()
                
                for pin in pins {
                    let annotation = MKPointAnnotation()
                    let lat = CLLocationDegrees(pin.latitude)
                    let long = CLLocationDegrees(pin.longitude)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    annotation.coordinate = coordinate
                    annotations.append(annotation)
                }
                mapView.addAnnotations(annotations)
            }
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        if editButtonLabel.title == "Edit" {
            editButtonLabel.title = "Done"
            deletePinLabel.isHidden = false
            deleteEnabled = true
        }
        else{
            editButtonLabel.title = "Edit"
            deleteEnabled = false
            deletePinLabel.isHidden = true
        }
    }
}

