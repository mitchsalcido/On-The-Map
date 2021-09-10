//
//  MapViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//
/*
 About MapViewController:
 Handle presentation of student locations on a mapView. Includes logout, refresh functionality
 */
import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {

    // view object
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update data
        refreshStudentData()
    }
    
    // log out of app
    @IBAction func logoutBbiPressed(_ sender: Any) {
        logout()
    }
    
    // refresh studend location data
    @IBAction func refreshButtonPressed(_ sender: Any) {
        refreshStudentData()
    }
    
    // invoke pin location...post user location
    @IBAction func pinButtonPressed(_ sender: Any) {
        pinMyLocation()
    }
}

// MARK: MapView Delegates
extension MapViewController {
    
    // annotation views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        /*
         Retreive annotations and place on mapView
         */
        let reuseId = "pinId"
        
        // test for valid existing annot
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        // create new annot view in needed
        if pinView == nil {
            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            // include callout (media URL) and button in open URL
            markerView.canShowCallout = true
            markerView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView = markerView

        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // handle callout tapped on map
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        /*
         Open media URL in callout
         */
        if control == view.rightCalloutAccessoryView {
            if let urlString = view.annotation?.subtitle!{
                openURLString(urlString)
            }
        }
    }
}

// MARK: Helpers
extension MapViewController {
    
    // refresh map
    func refreshStudentData() {
        /*
         Retrieve(upadate) students on the map, update map
         */
        
        // get updated students
        updateStudentsOnTheMap() {
            (success, error) in
            if success {
                // good update. Update annotations
                
                // create new annotaions array
                var annotations = [MKPointAnnotation]()
                for student in UdacityAPI.students {
                    let annotation = MKPointAnnotation()
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    annotation.title = "\(student.lastName), \(student.firstName)"
                    annotation.subtitle = student.mediaURL
                    annotations.append(annotation)
                }
                
                // remove previous annotaions, update with refresh annotaions
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
            } else {
                // bad update. Present error with alert
                self.failedGetStudents(error)
            }
        }
    }
}
