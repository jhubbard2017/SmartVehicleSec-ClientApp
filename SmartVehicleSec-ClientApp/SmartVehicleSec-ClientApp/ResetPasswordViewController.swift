//
//  ResetPasswordViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 10/19/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var email: UITextField!
    
    var textfieldList = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textfieldList = [self.email]
        self.email.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resetPasswordAction(_ sender: Any) {
        if app_utils.validateInputs(inputs: self.textfieldList) {
            app_utils.start_activity_indicator(view: self.view, text: "")
            api.forgot_password(email: self.email.text!) { error in
                if (error == nil) {
                    let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    self.present(next_vc, animated: true, completion: nil)
                } else {
                    let title = "Error (\(String(describing: error?.code)))"
                    let message = error?.domain
                    app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                }
            }
        } else {
            // Inputs not validated. Show alert message
            let alert_title = "Error"
            let alert_message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(next_vc, animated: true, completion: nil)
    }
    
}
