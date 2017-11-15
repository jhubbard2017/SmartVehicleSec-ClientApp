//
//  ChangePasswordViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 10/16/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var old_password: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var verify_password: UITextField!
    
    var textfieldList = [UITextField]()
    let password_min_count = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textfieldList = [self.old_password, self.password, self.verify_password]
        for textfield in self.textfieldList {
            textfield.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changePasswordAction(_ sender: Any) {
        // Action method to update user password
        var title = "Error"
        var message = ""
        if app_utils.validateInputs(inputs: self.textfieldList) {
            if (self.password.text?.count)! < self.password_min_count {
                message = "Password should be at least 8 characters."
                app_utils.showDefaultAlert(controller: self, title: title, message: message)
            } else if self.password.text == self.old_password.text {
                message = "Password can't be the same as the old password."
                app_utils.showDefaultAlert(controller: self, title: title, message: message)
            } else if self.password.text != self.verify_password.text {
                message = "Please verify correct password."
                app_utils.showDefaultAlert(controller: self, title: title, message: message)
            } else {
                // Change password
                app_utils.start_activity_indicator(view: self.view, text: "")
                api.change_user_password(email: auth_info.email, old_password: self.old_password.text!, new_password: self.password.text!) { error in
                    DispatchQueue.main.async {
                        app_utils.stop_activity_indicator()
                        if (error == nil) {
                            let alert = UIAlertController(title: "Success", message: "Account Password Updated!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {(action) in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            title = "Error (\(String(describing: error?.code)))"
                            message = (error?.domain)!
                        }
                        app_utils.showDefaultAlert(controller: self, title: title, message: message)
                    }
                }
            }
        } else {
            // Inputs not validated. Show alert message
            message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: title, message: message)
        }
    }
}
