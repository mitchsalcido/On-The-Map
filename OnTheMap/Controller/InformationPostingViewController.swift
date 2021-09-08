//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/7/21.
//

import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaTextField: UITextField!
    
    var location: CLLocation?
    var mapString: String?
    var mediaURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = UdacityClient.Auth.objectId {
            button.setTitle("Update Location", for: .normal)
            locationTextField.placeholder = "Update new location"
            mediaTextField.placeholder = "Update new media URL"
            
            let student = UdacityClient.userStudentLocation
            let location = CLLocation(latitude: student.latitude, longitude: student.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = student.mapString
            zoomToNewAnnotation(annotation: annotation, animated: false)
        } else {
            button.setTitle("Post Location", for: .normal)
            locationTextField.placeholder = "Enter location"
            mediaTextField.placeholder = "Enter media URL"
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if let _ = UdacityClient.Auth.objectId {
            UdacityClient.updateStudentLocation(studentLocation: UdacityClient.userStudentLocation) {
                (success, error) in
                if success {
                    print("good location update")
                } else {
                    print("bad location update")
                }
            }
        } else {
            UdacityClient.postStudentLocation(studentLocation: UdacityClient.userStudentLocation) {
                (success, error) in
                if success {
                    print("good location posting")
                } else {
                    print("bad location posting")
                }
            }
        }
    }
}

// MARK: TextField Delegate functions
extension InformationPostingViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == locationTextField, let text = locationTextField.text {
            geoCodeString(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Geocoding
extension InformationPostingViewController {
    
    func geoCodeString(_ string: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(string) {
            (placemarks, error) in
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                return
            }

            var annotationTitle = "New Location"
            if let locality = placemark.locality {
                annotationTitle = locality
            } else if let administrativeArea = placemark.administrativeArea {
                annotationTitle = administrativeArea
            } else if let country = placemark.country {
                annotationTitle = country
            } else if let name = placemark.name {
                annotationTitle = name
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = annotationTitle
            annotation.coordinate = location.coordinate
            self.zoomToNewAnnotation(annotation: annotation, animated: true)
        }
    }
}

// MARK: Helpers
extension InformationPostingViewController {
    
    func zoomToNewAnnotation(annotation: MKPointAnnotation, animated: Bool) {
        
        if let previousAnnotation = mapView.annotations.first {
            mapView.removeAnnotation(previousAnnotation)
        }
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
        mapView.setRegion(region, animated: animated)
    }
}
