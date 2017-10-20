//
//  CreateAccountViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 10/18/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var vehicle: UITextField!
    @IBOutlet weak var system_id: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var verify_password: UITextField!
    
    var textfieldList = [UITextField]()
    let password_min_count = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textfieldList = [self.firstname, self.lastname, self.email, self.phone, self.vehicle, self.system_id, self.password, self.verify_password]
        for textfield in self.textfieldList {
            textfield.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(next_vc, animated: true, completion: nil)
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        // Create account
        if app_utils.validateInputs(inputs: self.textfieldList) {
            if self.password.text!.count < self.password_min_count {
                let alert_title = "Error"
                let alert_message = "Password should be at least 8 characters."
                app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
            } else if self.password.text != self.verify_password.text {
                let alert_title = "Error"
                let alert_message = "Please verify correct password."
                app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
            } else {
                // Add user
                app_utils.start_activity_indicator(view: self.view, text: "")
                api.create_account(firstname: self.firstname.text!, lastname: self.lastname.text!, email: self.email.text!, password: self.password.text!, phone: self.phone.text!, vehicle: self.vehicle.text!, system_id: self.system_id.text!) { error in
                    if (error == nil) {
                        // Login
                        api.login(email: auth_info.email, password: auth_info.password) { error in
                            if (error == nil) {
                                user_authenticated = true
                                is_first_authentication = false
                                let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "SetupContactsViewController") as! SetupContactsViewController
                                self.present(next_vc, animated: true, completion: nil)
                            } else {
                                let title = "Error (\(String(describing: error?.code)))"
                                let message = error?.domain
                                app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                            }
                        }
                    } else {
                        let title = "Error (\(String(describing: error?.code)))"
                        let message = error?.domain
                        app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                    }
                }
            }
        } else {
            // Inputs not validated. Show alert message
            let alert_title = "Error"
            let alert_message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
}
