//
//  VideoViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/29/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var stream_frame: UIImageView!
    @IBOutlet weak var play_pause_btn: UIButton!
    @IBOutlet weak var rewind_btn: UIButton!
    @IBOutlet weak var export_btn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.set_security_config()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func set_security_config() {
        let url = "/system/config/all"
        let data = ["name": server_info.device_name] as NSDictionary
        server_api.send_request(url: url, data: data, method: "GET", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            let status = response.value(forKeyPath: "data.system_armed") as! Int
            if code == server_api._SUCCESS_REPONSE_CODE && status == server_api._DATA_FALSE {
                DispatchQueue.main.async {
                    // Update UI
                    self.status.text = "Disarmed"
                }
            } else {
                DispatchQueue.main.async {
                    // Update UI
                    self.status.text = "Armed"
                }
            }
        })
    }
}
