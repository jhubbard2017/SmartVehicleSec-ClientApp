//
//  SetupDeviceViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/6/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SetupDeviceViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var vehicle: UITextField!
    @IBOutlet weak var rd_mac_address: UITextField!
    
    var textfieldList = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()

        // Do any additional setup after loading the view.
        self.textfieldList = [self.name, self.email, self.phone, self.vehicle, self.rd_mac_address]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func nextAction(_ sender: Any) {
        // Action method to setup new device on server
        if app_utils.validateInputs(inputs: self.textfieldList) {
            // Setup device
            app_utils.start_activity_indicator(view: self.view, text: "Adding your device")
            self.checkDeviceExist()
        } else {
            // Inputs not validated. Show alert message
            let alert_title = "Error"
            let alert_message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
    
    func addDevice() {
        // Method to add new device to the server
        // Todo: Check if device already on server
        let url = "/system/add_new_device"
        let data = ["name": self.name.text!, "email": self.email.text!, "phone": self.phone.text!, "vehicle": self.vehicle.text!, "md_mac_address": device_uuid!, "rd_mac_address": self.rd_mac_address.text!] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    DispatchQueue.main.async {
                        // Update UI
                        app_utils.stop_activity_indicator()
                    
                        // go to next step view controller
                        let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "SetupContactsViewController") as! SetupContactsViewController
                        self.present(next_vc, animated: true, completion: nil)
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
    
    func checkDeviceExist() {
        // Method to check if device or system already exist on server
        let url = "/system/get_md_device"
        let data = ["md_mac_address": device_uuid!] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let data = response.value(forKey: "data") as! Bool
                if !data {
                    DispatchQueue.main.async {
                        self.addDevice()
                    }
                } else {
                    DispatchQueue.main.async {
                        // Update UI
                        app_utils.stop_activity_indicator()
                        let message = "Device already exists. Please continue."
                        let alert_title = "Warning"
                        app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                        
                        // go to next step view controller
                        let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "SetupContactsViewController") as! SetupContactsViewController
                        self.present(next_vc, animated: true, completion: nil)
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
