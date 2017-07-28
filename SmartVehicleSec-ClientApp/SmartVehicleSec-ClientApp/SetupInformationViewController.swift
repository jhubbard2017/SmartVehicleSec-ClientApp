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
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var device_name: UITextField!
    @IBOutlet weak var sys_port: UITextField!
    
    var app_utils = AppUtilities()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func finish_action(_ sender: Any) {
        if (!(self.sys_ip_address.text?.isEmpty)! && !(self.sys_port.text?.isEmpty)! &&
            !(self.password.text?.isEmpty)! && !(self.device_name.text?.isEmpty)! &&
            !(self.sys_fwd_ip_address.text?.isEmpty)!) {
            // All fields are good
            sock_client = SocketClient(name: self.device_name.text!,
                                       password: self.password.text!,
                                       ip: self.sys_ip_address.text!,
                                       fwd_ip: self.sys_fwd_ip_address.text!,
                                       port: Int(self.sys_port.text!)!)
            self.app_utils.start_activity_indicator(view: self.view, text: "Checking connection...")
            let success = self.checkServerConnection()
            if success {
                let data = sock_client.data_to_send["new_device"]
                let name = sock_client.get_device_name()
                let name_data = data! + " " + name
                sock_client.send_data(data: name_data)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    if sock_client.get_data() == sock_client.data_to_recieve["success"] {
                        self.app_utils.stop_activity_indicator()
                        let success_vc = self.storyboard?.instantiateViewController(withIdentifier: "setup_success_view_controller")
                        self.present(success_vc!, animated: true, completion: nil)
                    }
                })
            } else {
                // Alert message
                self.app_utils.stop_activity_indicator()
                let alert_title = "Error"
                let alert_message = "Could not connect to security system. Try again."
                self.app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
            }
        } else {
             let alert_title = "Error"
             let alert_message = "Please complete all fields."
             self.app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
    
    func checkServerConnection() -> Bool {
        var to_return = false
        sock_client.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            let recv_data = sock_client.get_data()
            if recv_data != "" && recv_data == sock_client.data_to_recieve["new_device"] {
                to_return = true
            }
        })
        return to_return
    }

}
