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
    @IBOutlet weak var sys_fwd_ip_address: UITextField!
    @IBOutlet weak var device_name: UITextField!
    @IBOutlet weak var http_port: UITextField!
    @IBOutlet weak var udp_port: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func finish_action(_ sender: Any) {
        if (!(self.sys_ip_address.text?.isEmpty)! && !(self.http_port.text?.isEmpty)! &&
            !(self.device_name.text?.isEmpty)! && !(self.sys_fwd_ip_address.text?.isEmpty)!
            && !(self.udp_port.text?.isEmpty)!) {
            // All fields are good
            server_info.ip_address = self.sys_ip_address.text!
            server_info.fwd_ip_address = self.sys_fwd_ip_address.text!
            server_info.http_port = Int(self.http_port.text!)!
            server_info.udp_port = Int(self.udp_port.text!)!
            server_info.device_name = self.device_name.text!
            app_utils.start_activity_indicator(view: self.view, text: "Checking connection...")
            self.checkServerConnection()
        } else {
             let alert_title = "Error"
             let alert_message = "Please complete all fields."
             app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
    
    func checkServerConnection() {
        let url = "/system/devices"
        let data = ["name": server_info.device_name] as NSDictionary
        server_api.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            let success = response.value(forKey: "data") as! Bool
            if code == server_api._SUCCESS_REPONSE_CODE && success {
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    let success_vc = self.storyboard?.instantiateViewController(withIdentifier: "setup_success_view_controller")
                    self.present(success_vc!, animated: true, completion: nil)
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    let alert_title = "Error"
                    let alert_message = "Could not connect to security system. Try again."
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
                }
            }
        })
    }

}
