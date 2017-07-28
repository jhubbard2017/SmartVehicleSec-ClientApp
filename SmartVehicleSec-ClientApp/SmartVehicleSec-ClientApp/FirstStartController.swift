//
//  ViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/25/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class FirstStartController: UIViewController {
    /* View controller class for first time app use
     
        This class is nothing but a display of information about the Smart Vehicle Security 
        System, and a link to the set up view controller
     */

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func get_started_action(_ sender: Any) {
        let setup_sb = UIStoryboard(name: "setup", bundle: nil)
        let setup_vc = setup_sb.instantiateViewController(withIdentifier: "setup_information_view_controller") as! SetupInformationViewController
        self.present(setup_vc, animated: true, completion: nil)
    }
}

