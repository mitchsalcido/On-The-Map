//
//  MapViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateMap()
    }
    
    @IBAction func logoutBbiPressed(_ sender: Any) {
        logout()
    }
}

// MARK: MapView Delegates
extension MapViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pinId"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            markerView.canShowCallout = true
            markerView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView = markerView

        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!, let url = URL(string: toOpen) {
                //app.openURL(URL(string: toOpen)!)
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: Helpers
extension MapViewController {
    
    func updateMap() {
        updateStudentsOnTheMap() {
            (success, error) in
            if success {
                var annotations = [MKPointAnnotation]()
                for student in UdacityClient.Auth.students {
                    let annotation = MKPointAnnotation()
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    annotation.title = "\(student.lastName), \(student.firstName)"
                    annotation.subtitle = student.mediaURL
                    annotations.append(annotation)
                }
                self.mapView.addAnnotations(annotations)
            } else {
                
            }
        }
    }
}
