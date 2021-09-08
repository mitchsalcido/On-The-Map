//
//  ViewController+HelperExt.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import UIKit

// MARK: Common networking functions
extension UIViewController {
    
    // common logout function
    @objc func logout() {
        UdacityClient.deleteSession() {
            (success, error) in
            
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showOkAlert(title: "Failed Logout", message: error?.localizedDescription ?? "Unknown failure. Contact Mitch for prompt and courteous customer service !")
            }
        }
    }
    
    // update Students
    func updateStudentsOnTheMap(completion: @escaping (Bool, Error?) -> Void) {
        UdacityClient.getStudents(completion: completion)
    }
}

// MARK: Helpers
extension UIViewController {
    
    // open URL. Show alert if bad URL String
    func openURLString(_ string: String) {
        
        if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showOkAlert(title: "Unable to open", message: "Bad media URL provided")
        }
    }
    
    // simple alert with "OK" dismiss
    func showOkAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
}

// Mark: Common actions for buttons in VCs
extension UIViewController {

    func pinMyLocation() {
        
        // block to handle invoking InformationPostingVC
        let showInfoPostingVCBlock = {
            /*
            let infoVC = self.storyboard?.instantiateViewController(identifier: "InformationPostingViewControllerID") as! InformationPostingViewController
            let navController = UINavigationController(rootViewController: infoVC)
            self.present(navController, animated: true, completion: nil)
 */
            let controller = self.storyboard?.instantiateViewController(identifier: "InfoPostingNavVCID") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
        
        // test for previous location posting (objectId != nil)
        if let _ = UdacityClient.Auth.objectId {
            // show an alert for overwriting location
            let alert = UIAlertController(title: "Overwrite existing location ?", message: "Proceed to overwrite your current location", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let proceedAction = UIAlertAction(title: "Proceed", style: .destructive) {
                (action) in
                showInfoPostingVCBlock()
            }
            alert.addAction(cancelAction)
            alert.addAction(proceedAction)
            present(alert, animated: true, completion: nil)
        } else {
            // no previous location posting....proceed to InformationPostingVC
            showInfoPostingVCBlock()
        }
    }
}
