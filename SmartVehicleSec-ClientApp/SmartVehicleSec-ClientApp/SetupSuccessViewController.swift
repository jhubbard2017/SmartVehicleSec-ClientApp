//
//  SetupSuccessViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/25/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SetupSuccessViewController: UIViewController {
    /* Class to display success message and allow routing to dashboard on button click */

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func go_to_dashboard_action(_ sender: Any) {
        let dashboard_sb = UIStoryboard(name: "dashboard", bundle: nil)
        let dashboard_vc = dashboard_sb.instantiateViewController(withIdentifier: "dashboard_navigation_controller") as! UINavigationController
        self.present(dashboard_vc, animated: true, completion: nil)
    }
}
