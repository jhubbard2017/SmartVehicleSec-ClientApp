//
//  SetupFinishViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/6/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SetupFinishViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishAction(_ sender: Any) {
        // Action method to finish process and go to dashboard
        let dashboard_sb = UIStoryboard(name: "dashboard", bundle: nil)
        let dashboard_vc = dashboard_sb.instantiateViewController(withIdentifier: "dashboard_navigation_controller") as! UINavigationController
        self.present(dashboard_vc, animated: true, completion: nil)
    }
}
