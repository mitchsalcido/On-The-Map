//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/7/21.
//
/*
 About InformationPostingViewController:
 Handle posting/updating student location. Includes fields for user to update a location (geocode) and
 also provide a medialURL to share with other students
 */

import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    // view objects
    @IBOutlet weak var mapView: MKMapView!  // mapp
    @IBOutlet weak var button: UIButton!    // post location button
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!  // busy
    @IBOutlet weak var locationTextField: UITextField!  // location to be geocoded
    @IBOutlet weak var mediaTextField: UITextField!     // medial URL
    
    // data that can be updated
    var location: CLLocation?   // assigned during geocoding. Must be non-nil to post location
    var mapString: String?      // map(location) string, retrieved during geocoding
    var mediaURL: String?       // medial URL
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIState
        enableUI(true)
        
        // steer UI datat based on previous post
        if let _ = UdacityAPI.Auth.objectId {
            //previous post. Updating location
            
            // placehold text to indicate location update
            locationTextField.placeholder = "Update new location"
            mediaTextField.placeholder = "Update new media URL(optional)"
            
            // place pin on map and zoom to last posted location
            let student = UdacityAPI.userStudentLocation
            let location = CLLocation(latitude: student.latitude, longitude: student.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = student.mapString
            zoomToNewAnnotation(annotation: annotation, animated: false)
        } else {
            
            // placeholder text to indicate posting new location
            locationTextField.placeholder = "Enter location"
            mediaTextField.placeholder = "Enter media URL(optional)"
        }
    }
    
    // cancel operation
    @IBAction func cancelButtonPressed(_ sender: Any) {
        // cancel posting/updating
        dismiss(animated: true, completion: nil)
    }
    
    // post/update button pressed
    @IBAction func buttonPressed(_ sender: Any) {
        /*
         Handle posting/updating student location
         */
        
        // UIstate, busy
        enableUI(false)
        activityIndicator.startAnimating()
        
        // assign new data to userStudentLocation
        if let newMapString = mapString {
            // mapString
            UdacityAPI.userStudentLocation.mapString = newMapString
        }
        if let newMediaURL = mediaURL {
            // Media URL
            UdacityAPI.userStudentLocation.mediaURL = newMediaURL
        }
        if let newLocation = location {
            // new/updated location
            UdacityAPI.userStudentLocation.latitude = newLocation.coordinate.latitude
            UdacityAPI.userStudentLocation.longitude = newLocation.coordinate.longitude
        }
        
        // test if update or new posting
        if let _ = UdacityAPI.Auth.objectId {
            /*
             update (PUT) student location
             */
            UdacityAPI.putLocation(studentLocation: UdacityAPI.userStudentLocation) {
                (success, error) in
                if success {
                    // good update, dismiss
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // bad update, show error alert and enable UI
                    self.showOkAlert(title: "Bad location update", message: error?.localizedDescription ?? "Unable to update student location. Try again later.")
                    self.enableUI(true)
                    self.activityIndicator.stopAnimating()
                }
            }
        } else {
            /*
             post(POST) new location
             */
            UdacityAPI.postLocation(studentLocation: UdacityAPI.userStudentLocation) {
                (success, error) in
                if success {
                    // good new posting, dismiss
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // bad new posting, show error alert and enable UI
                    self.showOkAlert(title: "Bad location posting", message: error?.localizedDescription ?? "Unable to post student location. Try again later.")
                    self.enableUI(true)
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}

// MARK: Mapview Delegates
extension InformationPostingViewController {
    
    // map is changed
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // update UI when zooming complete
        self.locationTextField.text = nil
        activityIndicator.stopAnimating()
        enableUI(!locationTextField.isEditing && !mediaTextField.isEditing)
    }
}

// MARK: TextField Delegate functions
extension InformationPostingViewController {
    
    // begin editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // disable UI button while editing in a textField
        enableUI(false)
    }
    
    // end editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // geocode new location if good text in textField
        if textField == locationTextField {
            if let text = locationTextField.text, !text.isEmpty {
                // good text, geocode
                geoCodeString(text)
            } else {
                // bad text, enable UI
                enableUI(true)
            }
        }

        // check media URL
        if textField == mediaTextField {
            if let text = mediaTextField.text, !text.isEmpty {
                // good media URL text, update
                mediaURL = text
            }
            enableUI(true)
        }
    }
    
    // enter button on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // remove keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // characters in textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // force initial char to be non-whitespace
        if let text = textField.text, text.isEmpty && (string == " ") {
            return false
        }

        return true
    }
}

// MARK: Geocoding
extension InformationPostingViewController {
    
    // geocode a string
    func geoCodeString(_ string: String) {
        
        // disable submit button while geocoding
        button.isEnabled = false
        
        // create a geocoder and geocode string
        CLGeocoder().geocodeAddressString(string) {
            (placemarks, error) in
            
            // nil location and mapString.. set at end of geocoding
            self.location = nil
            self.mapString = nil
            
            // test error. Show error alert if an error
            guard error == nil else {
                self.showOkAlert(title: "Geocoding Error", message: error?.localizedDescription ?? "Unable to identify location.")
                return
            }
            
            // test good placemark returned. Show error alert if no placemark
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                self.showOkAlert(title: "Unable to identify location", message: "Unknown, possibly too remote location.")
                return
            }

            // sift out pertinent placemark data for annotation
            // ..want a string that most identifies location, from city outwards
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
            
            // create annotation for new location
            let annotation = MKPointAnnotation()
            annotation.title = annotationTitle
            annotation.coordinate = location.coordinate
            
            // update location and mapString
            self.location = location
            self.mapString = annotationTitle
            
            // zoom map to new location (show pin), set busy while zooming
            self.zoomToNewAnnotation(annotation: annotation, animated: true)
            self.activityIndicator.startAnimating()
        }
    }
}

// MARK: Helpers
extension InformationPostingViewController {
    
    // zoom to annotation
    func zoomToNewAnnotation(annotation: MKPointAnnotation, animated: Bool) {
        /*
         Handle setting new annotation on map
         */
        
        // remove existing annotation
        if let previousAnnotation = mapView.annotations.first {
            mapView.removeAnnotation(previousAnnotation)
        }

        // add new annotation and set region on map..animate for zoomin effect
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
        mapView.setRegion(region, animated: animated)
    }

    // UI state
    func enableUI(_ enable: Bool) {
        button.isEnabled = enable && (location != nil)
    }
}
