//
//  EditDeviceInformationViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/14/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class EditDeviceInformationViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var vehicle: UITextField!
    
    var textfieldList = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getDeviceInformation()
        self.textfieldList = [self.name, self.email, self.phone, self.vehicle]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDeviceInformation() {
        // method to get current device information and update UI
        app_utils.start_activity_indicator(view: self.view, text: "Getting Device Information")
        let url = "/system/get_device_info"
        let data = ["md_mac_address": device_uuid!] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let data = response.value(forKey: "data") as! NSDictionary
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    self.name.text = data.value(forKey: "name") as? String
                    self.email.text = data.value(forKey: "email") as? String
                    self.phone.text = data.value(forKey: "phone") as? String
                    self.vehicle.text = data.value(forKey: "vehicle") as? String
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    let message = response.value(forKey: "message") as! String
                    let alert_title = "Error"
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                }
            }
        })
    }
    
    @IBAction func saveAction(_ sender: Any) {
        // Action method to update the new device information
        if app_utils.validateInputs(inputs: self.textfieldList) {
            // Update fields
        } else {
            // Inputs not validated. Show alert message
            let alert_title = "Error"
            let alert_message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
    
    func updateDeviceInformation() {
        // method to update current device information
        app_utils.start_activity_indicator(view: self.view, text: "Updating Device Information")
        let url = "/system/update_device_info"
        let data = ["md_mac_address": device_uuid!, "rd_mac_address": server_info.rd_mac_address] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let data = response.value(forKey: "data") as! Bool
                if data {
                    DispatchQueue.main.async {
                        // Update UI
                        app_utils.stop_activity_indicator()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    let message = response.value(forKey: "message") as! String
                    let alert_title = "Error"
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                }
            }
        })
    }
    
}
