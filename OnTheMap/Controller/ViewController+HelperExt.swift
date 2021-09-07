//
//  ViewController+HelperExt.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import UIKit

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
    
    // simple alert with "OK" dismiss
    func showOkAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    // update Students
    func updateStudentsOnTheMap(completion: @escaping (Bool, Error?) -> Void) {
        UdacityClient.getStudents(completion: completion)
    }
}
