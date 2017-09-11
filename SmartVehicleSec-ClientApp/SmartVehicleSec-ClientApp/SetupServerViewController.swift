//
//  SetupServerViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/6/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SetupServerViewController: UIViewController {
    
    /*
     Setup view controller to get server information. This step is for development purposes only. 
     If the ip address or port of the server changes (during development), then we need to make that change
     on the mobile app. In production, this setup step will be removed.
     */
    
    @IBOutlet weak var ip_address: UITextField!
    @IBOutlet weak var port: UITextField!
    
    var textfieldList = [UITextField]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()

        self.textfieldList = [self.ip_address, self.port]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextAction(_ sender: Any) {
        // Action method to store the server information for access.
        
        if app_utils.validateInputs(inputs: self.textfieldList) {
            // Store server information
            server_info.ip_address = self.ip_address.text!
            server_info.port = Int(self.port.text!)!
            
            // Go to next step view controller
            let next_vc = self.storyboard?.instantiateViewController(withIdentifier: "SetupDeviceViewController") as! SetupDeviceViewController
            self.present(next_vc, animated: true, completion: nil)
        } else {
            // All fields aren't complete. Show error alert message
            let alert_title = "Error"
            let alert_message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }

}
