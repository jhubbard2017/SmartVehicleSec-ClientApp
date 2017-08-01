//
//  DashboardViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/28/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var arm_btn: UIButton!
    @IBOutlet weak var status_img: UIImageView!
    @IBOutlet weak var status: UILabel!
    
    var system_armed: Bool!
    
    let cell_names = ["video_cell", "location_cell", "temperature_cell", "logs_cell", "settings_cell", "help_cell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize dashboard state
        self.set_security_config()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: cell_names[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableview.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func system_toggle_action(_ sender: Any) {
        if self.system_armed {
            // Disarm system
            let url = "/system/arm"
            let data = ["name": server_info.device_name, "data": false] as NSDictionary
            server_api.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
                let code = response.value(forKey: "code") as! Int
                let result = response.value(forKey: "data") as! Bool
                if code == server_api._SUCCESS_REPONSE_CODE && result {
                    DispatchQueue.main.async {
                        self.system_armed = false
                        self.status.text = "Disarmed"
                        self.arm_btn.titleLabel?.text = "Arm System"
                        self.status_img.image = UIImage(named: "unlocked.png")
                    }
                } else {
                    // Alert message
                    let alert_title = "Error"
                    let alert_message = "Could not disarm system. Check connection..."
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
                }
            })
        } else {
            // Arm system
            let url = "/system/arm"
            let data = ["name": server_info.device_name, "data": true] as NSDictionary
            server_api.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
                let code = response.value(forKey: "code") as! Int
                let result = response.value(forKey: "data") as! Bool
                if code == server_api._SUCCESS_REPONSE_CODE && result {
                    DispatchQueue.main.async {
                        self.system_armed = true
                        self.status.text = "Armed"
                        self.arm_btn.titleLabel?.text = "Disarm System"
                        self.status_img.image = UIImage(named: "locked.png")
                    }
                } else {
                    // Alert message
                    let alert_title = "Error"
                    let alert_message = "Could not arm system. Check connection..."
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
                }
            })
        }
    }
    
    func set_security_config() {
        let url = "/system/config/system_armed"
        let data = ["name": server_info.device_name] as NSDictionary
        server_api.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            let system_is_armed = response.value(forKey: "data") as! Bool
            if code == server_api._SUCCESS_REPONSE_CODE && system_is_armed {
                DispatchQueue.main.async {
                    // Update UI
                    self.arm_btn.titleLabel?.text = "Disarm System"
                    self.status_img.image = UIImage(named: "locked.png")
                    self.system_armed = true
                    self.status.text = "Armed"
                }
            } else {
                DispatchQueue.main.async {
                    // Update UI
                    self.arm_btn.titleLabel?.text = "Arm System"
                    self.status_img.image = UIImage(named: "unlocked.png")
                    self.system_armed = false
                    self.status.text = "Disarmed"
                }
            }
        })
    }
}
