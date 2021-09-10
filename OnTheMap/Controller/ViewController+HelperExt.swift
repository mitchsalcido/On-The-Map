//
//  ViewController+HelperExt.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//
/*
 About ViewController+HelperExt:
 ViewController extension. Implement functions common to VCs across app
 */

import UIKit

// MARK: Common networking functions
extension UIViewController {
    
    // common logout function
    @objc func logout() {
        
        // logout (delete session
        UdacityAPI.deleteSession() {
            (success, error) in
            
            if success {
                // good logout. Dismiss
                self.dismiss(animated: true, completion: nil)
            } else {
                // bad logout. Show error alert
                self.showOkAlert(title: "Failed Logout", message: error?.localizedDescription ?? "Unknown failure. Contact Mitch for prompt and courteous customer service !")
            }
        }
    }
    
    // update Students
    func updateStudentsOnTheMap(completion: @escaping (Bool, Error?) -> Void) {
        // retrieve students on the map
        UdacityAPI.getStudents(completion: completion)
    }
}

// MARK: Helpers
extension UIViewController {
    
    // open URL
    func openURLString(_ string: String) {
        /*
         Open URL. If bad URL, present an error alert
         */
        if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showOkAlert(title: "Unable to open", message: "Bad media URL provided")
        }
    }
    
    // create/show an alert
    func showOkAlert(title: String, message: String) {
        /*
         Create and show an alert with an "OK" action to dismiss alert
         */
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    // common alert for getStudents failure
    func failedGetStudents(_ error: Error?) {
        showOkAlert(title: "Unable to retrieve students", message: error?.localizedDescription ?? "Cannot access Udacity student database")
    }
}

// Mark: Common actions for buttons in VCs
extension UIViewController {
    
    // post student location
    func pinMyLocation() {
        /*
         Invoke InformationPostingVC to allow user to post/update their location. Function
         presents an alert if location has already been posted..warning about overwrite
         */
        
        // block to handle invoking InformationPostingVC
        let showInfoPostingVCBlock = {
            let controller = self.storyboard?.instantiateViewController(identifier: "InfoPostingNavVCID") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
        
        // test for previous location posting (objectId != nil)
        if let _ = UdacityAPI.Auth.objectId {
            /*
             Location was presviously posted. Present an alert to warn user about possible overwrite
             */
            let alert = UIAlertController(title: "Overwrite existing location ?", message: "Proceed to overwrite your current location", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let proceedAction = UIAlertAction(title: "Proceed", style: .destructive) {
                (action) in
                // proceed action. OK to proceed and overwrite previously posted location
                showInfoPostingVCBlock()
            }
            alert.addAction(cancelAction)
            alert.addAction(proceedAction)
            present(alert, animated: true, completion: nil)
        } else {
            // no previous location posting....proceed to InformationPostingVC without alert
            showInfoPostingVCBlock()
        }
    }
}
