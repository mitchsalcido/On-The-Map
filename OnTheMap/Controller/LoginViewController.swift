//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Button Actions
extension LoginViewController {
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        activityIndicator.startAnimating()
        enableUI(false)
        
        UdacityClient.postSession(username: userNameTextField.text ?? "", password: passwordTextField.text ?? "") {
            (success, error) in
            if success {
                UdacityClient.getPublicUserData() {
                    (success, error) in
                    if success {
                        self.performSegue(withIdentifier: "TabBarControllerSegueID", sender: nil)
                    } else {
                        self.showOkAlert(title: "Bad user info", message: "Unable to retrieve user data info")
                    }
                }
            } else {
                self.showOkAlert(title: "Login Fail", message: error?.localizedDescription ?? "Unknown login failure")
            }
            
            self.enableUI(true)
            self.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://www.udacity.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: Helpers
extension LoginViewController {
    func enableUI(_ enable: Bool) {
        userNameTextField.isEnabled = enable
        passwordTextField.isEnabled = enable
        loginButton.isEnabled = enable
        signupButton.isEnabled = enable
    }
}

// MARK: TextField Delegates
extension LoginViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        loginButton.isEnabled = false
        signupButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        loginButton.isEnabled = true
        signupButton.isEnabled = true
    }
}
