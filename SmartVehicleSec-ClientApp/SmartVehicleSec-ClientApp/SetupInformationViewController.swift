//
//  NewDeviceViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/25/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SetupInformationViewController: UIViewController {
    /*Class to setup connection to security server, and store user data
    
     Attributes:
        sys_ip_address: ip address of the security server
        sys_port: port number of the security server
        password: password user will use to reconnect to server if disconnected after a fixed
            length of time
        device_name: unique name to store as the device in the server device manager
    */
    
    @IBOutlet weak var sys_ip_address: UITextField!
    @IBOutlet weak var sys_port: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var device_name: UITextField!
    
    var app_utils = AppUtilities()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func finish_action(_ sender: Any) {
        // Validate inputs, check connection to server
        if (!(self.sys_ip_address.text?.isEmpty)! && !(self.sys_port.text?.isEmpty)! &&
            !(self.password.text?.isEmpty)! && !(self.device_name.text?.isEmpty)!) {
            // All fields are good
            self.app_utils.start_activity_indicator(view: self.view, text: "Checking connection...")
            /* Todo: Check connection to server
                if successful, save data to server Device Manager, and route to next page
                if not successful, show alert view
             */
            
            // Alert message
            self.app_utils.stop_activity_indicator()
            let alert_title = "Error"
            let alert_message = "Could not connect to security system. Try again."
            self.app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
            
            // Show success view controller
            let success_vc = self.storyboard?.instantiateViewController(withIdentifier: "setup_success_view_controller")
            self.present(success_vc!, animated: true, completion: nil)
        } else {
             let alert_title = "Error"
             let alert_message = "Please complete all fields."
             self.app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }

}
