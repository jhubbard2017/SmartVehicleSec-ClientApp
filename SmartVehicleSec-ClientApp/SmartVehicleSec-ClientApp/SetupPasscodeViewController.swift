//
//  PasscodeViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/18/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit
import LocalAuthentication

class SetupPasscodeViewController: UIViewController {
    
    @IBOutlet weak var passcode: UITextField!
    
    let PASSCODE_LENGTH = 6

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func touchIDAction(_ sender: Any) {
        // Action method for checking touchID authentication validation
        self.authenticateWithTouchID()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        // Action method to store passcode
        if self.passcode.text?.characters.count != self.PASSCODE_LENGTH {
            // Alert message for passcode length
            let message = "Passcode must be 6 digits."
            let alert_title = "Error"
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
        } else if (self.passcode.text?.isEmpty)! {
            // Alert message for Passcode field required
            let message = "Passcode field is required."
            let alert_title = "Error"
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
        } else {
            // Store passcode and move to next step view controller
            UserDefaults.standard.set(self.passcode.text, forKey: _PASSCODE_KEY)
            current_auth_type = authenticationType.passcode.rawValue
            
            let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "SetupFinishViewController") as! SetupFinishViewController
            self.present(next_vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        // Action method to go back to previous step view controller
        let prev_vc = self.storyboard?.instantiateViewController(withIdentifier: "SetupContactsViewController") as! SetupContactsViewController
        self.present(prev_vc, animated: true, completion: nil)
    }
    
    func authenticateWithTouchID() {
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
        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to arm your vehicle.", reply: { [unowned self] (success, error) -> Void in
            if success {
                // Fingerprint recognized
                current_auth_type = authenticationType.touchID.rawValue
                let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "SetupFinishViewController") as! SetupFinishViewController
                self.present(next_vc, animated: true, completion: nil)
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
