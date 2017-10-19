//
//  SetupServerViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/6/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SetupServerViewController: UIViewController {
    
    @IBOutlet weak var host: UITextField!
    @IBOutlet weak var port: UITextField!
    
    var textfieldList = [UITextField]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.textfieldList = [self.host, self.port]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextAction(_ sender: Any) {
        // Action method to store the server information for access.
        
        if app_utils.validateInputs(inputs: self.textfieldList) {
            // Store server information
            auth_info.host = self.host.text!
            auth_info.port = Int(self.port.text!)!
            
            // Go to next step view controller
            let auth_sb = UIStoryboard(name: "authentication", bundle: nil)
            let next_vc = auth_sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(next_vc, animated: true, completion: nil)
        } else {
            // All fields aren't complete. Show error alert message
            let alert_title = "Error"
            let alert_message = "Please complete all fields."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
}
