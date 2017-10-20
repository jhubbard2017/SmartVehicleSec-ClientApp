//
//  LoginViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 10/12/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var touchIDBtn: UIButton!
    
    var textfieldList = [UITextField]()
    let password_min_count = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textfieldList = [self.email, self.password]
        self.email.delegate = self
        self.password.delegate = self
        
        if is_first_authentication {
            self.touchIDBtn.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signupAction(_ sender: Any) {
        let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        self.present(next_vc, animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        self.present(next_vc, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        // Action method to authenticate user
        if app_utils.validateInputs(inputs: self.textfieldList) {
            if self.password.text!.count < self.password_min_count {
                let alert_title = "Error"
                let alert_message = "Password should be at least 8 characters."
                app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
            } else {
                // Authenticate user
                app_utils.start_activity_indicator(view: self.view, text: "")
                self.loginUser(email: self.email.text!, password: self.password.text!)
            }
        } else {
            // Inputs not validated
            let alert_title = "Error"
            let alert_message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
    
    func loginUser(email: String, password: String) {
        api.login(email: email, password: password) { error in
            app_utils.stop_activity_indicator()
            if (error == nil) {
                user_authenticated = true
                is_first_authentication = false
                let sb = UIStoryboard(name: "dashboard", bundle: nil)
                let next_vc = sb.instantiateViewController(withIdentifier: "DashboardNavigationController") as! UINavigationController
                self.present(next_vc, animated: true, completion: nil)
            } else {
                let title = "Error (\(String(describing: error?.code)))"
                let message = error?.domain
                app_utils.showDefaultAlert(controller: self, title: title, message: message!)
            }
        }
    }
    
    @IBAction func useTouchIDAction(_ sender: Any) {
        // Use touch ID
        let authenticationContext = LAContext()
        var error:NSError?
        
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Alert with passcode incorrect error
            let message = "Touch ID not available on this Device."
            let alert_title = "Error"
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
            return
        }
        
        // 3. Check the fingerprint
        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your SVS Account.", reply: { [unowned self] (success, error) -> Void in
            if success {
                // Fingerprint recognized
                app_utils.start_activity_indicator(view: self.view, text: "")
                self.loginUser(email: auth_info.email, password: auth_info.password)
            } else {
                // Check if there is an error
                if let auth_error = error {
                    let message = self.errorMessageForLAErrorCode(errorCode: (auth_error as NSError).code)
                    let alert_title = "Error"
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                }
            }
        })
    }
    
    func errorMessageForLAErrorCode(errorCode: Int) -> String{
        var message = ""
        switch errorCode {
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
        case LAError.touchIDLockout.rawValue:
            message = "Too many failed attempts."
        case LAError.touchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
        default:
            message = "Did not find error code on LAError object"
        }
        
        return message
    }
}
