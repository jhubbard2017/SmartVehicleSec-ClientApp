//
//  EditDeviceInformationViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/14/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class AccountInformationViewController: UIViewController {
    
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var vehicle: UITextField!
    @IBOutlet weak var system_id: UITextField!
    
    var textfieldList = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getDeviceInformation()
        self.textfieldList = [self.firstname, self.lastname, self.email, self.phone, self.vehicle, self.system_id]
        self.email.isEnabled = false
        
        app_utils.start_activity_indicator(view: self.view, text: "")
        api.get_user() { error, user in
            app_utils.stop_activity_indicator()
            if (error == nil) {
                self.firstname.text = user.value(forKey: "firstname") as String
                self.lastname.text = user.value(forKey: "lastname") as String
                self.email.text = user.value(forKey: "email") as String
                self.phone.text = user.value(forKey: "phone") as String
                self.vehicle.text = user.value(forKey: "vehicle") as String
                self.system_id.text = user.value(forKey: "system_id") as String
            } else {
                let title = "Error (\(String(describing: error?.code)))"
                let message = error?.domain
                app_utils.showDefaultAlert(controller: self, title: title, message: message!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: Any) {
        // Action method to update the new device information
        var title = "Error"
        var message = ""
        if app_utils.validateInputs(inputs: self.textfieldList) {
            // Update fields
            app_utils.start_activity_indicator(view: self.view, text: "")
            api.update_user(firstname: self.firstname.text, lastname: self.lastname.text, email: self.email.text, phone: self.phone.text, vehicle: self.vehicle.text, system_id: self.system_id.text) { error in
                app_utils.stop_activity_indicator()
                if (error == nil) {
                    let title = "Success"
                    let message = "Account information updated!"
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let title = "Error (\(String(describing: error?.code)))"
                    let message = error?.domain
                }
            }
        } else {
            // Inputs not validated. Show alert message
            let message = "Please complete all fields."
        }
        app_utils.showDefaultAlert(controller: self, title: title, message: message!)
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        // Action method to change user account password
        let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        self.present(next_vc, animated: true, completion: nil)
    }
}
