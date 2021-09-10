//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//
/*
 About LoginViewController:
 Handle loggin in to App. User supplies username(email) and password. App is successfully logged
 into upon successful sesion post and retrieval of user data.
 */

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // view objects
    @IBOutlet weak var userNameTextField: UITextField!  // student username(email)
    @IBOutlet weak var passwordTextField: UITextField!  // student password
    @IBOutlet weak var loginButton: UIButton!           // log in to app
    @IBOutlet weak var signupButton: UIButton!          // sign up to Udacity training
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!  // busy
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // enable button and textFields
        enableUI(true)
    }
}

// MARK: UI Button Actions
extension LoginViewController {
    
    // log in to app
    @IBAction func loginButtonPressed(_ sender: Any) {
        /*
         Login: Handle login to app by Posting a new session and retrieving user data.
         */
        
        // UI state. Show activity busy while login process is active
        enableUI(false)
        
        // Post session (login) using username, password info
        UdacityAPI.postSession(username: userNameTextField.text ?? "", password: passwordTextField.text ?? "") {
            (success, error) in
            if success {
                // good session. Get simuluated user data (populate userStudentLocation)
                UdacityAPI.getPublicUserData() {
                    (success, error) in
                    if success {
                        // good user data. Enter app
                        self.performSegue(withIdentifier: "TabBarControllerSegueID", sender: nil)
                    } else {
                        // bad user data. Error info for user
                        self.showOkAlert(title: "Bad user info", message: "Unable to retrieve user data info")
                        self.enableUI(true)
                    }
                }
            } else {
                // bad session. Error info for user
                self.showOkAlert(title: "Login Fail", message: error?.localizedDescription ?? "Unknown login failure")
                self.enableUI(true)
            }
        }
    }
    
    // sign up for Udacity training
    @IBAction func signupButtonPressed(_ sender: Any) {
        /*
         button to allow non Udacity user the opportunity to sign up. Launched Udacity URL in web brouser
         */
        if let url = URL(string: "https://www.udacity.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: TextField Delegates
extension LoginViewController {
    
    // return button pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide active keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // start editing in a textField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // disable login and signup buttons while editing textField
        loginButton.isEnabled = false
        signupButton.isEnabled = false
    }
    
    // done editing in a textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        // enable login and signup buttons when textField editing ends
        loginButton.isEnabled = validTextInTextFields()
        signupButton.isEnabled = true
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

// MARK: Helpers
extension LoginViewController {
    
    // set UI enable state
    func enableUI(_ enable: Bool) {
        /*
         Helper to set UI state of view objects
         */
        userNameTextField.isEnabled = enable
        passwordTextField.isEnabled = enable
        loginButton.isEnabled = enable && validTextInTextFields()
        signupButton.isEnabled = enable
        if enable {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    // test for valid text in username and password textFields
    func validTextInTextFields() -> Bool {
        
        // return true if good text in both textFields
        if let userNameText = userNameTextField.text, let passwordText = passwordTextField.text {
            return !userNameText.isEmpty && !passwordText.isEmpty
        }
        return false
    }
}
