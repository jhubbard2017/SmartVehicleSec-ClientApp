//
//  DashboardViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/28/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /* This class houses the main menu and controls (hence, the dashboard).
     
        Attributes:
            - tableview: a list of routes the user can navigate to
            - arm_btn: a button to arm or disarm the system, depending on the current security configuration on the server.
            - status_img: UIImage that shows either a green unlock png or a red locked png, depending on the current security config of the system.
            - status: label text that shows `Armed` or `Disarmed`
     */
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var arm_btn: UIButton!
    @IBOutlet weak var status_img: UIImageView!
    @IBOutlet weak var status: UILabel!
    
    var system_armed = false
    
    // Constants for tableview cell identifiers
    let cell_names = ["video_cell", "location_cell", "temperature_cell", "logs_cell", "settings_cell", "help_cell"]
    
    let _NUMBER_OF_SECTIONS = 1
    let _NUMBER_OF_ROWS_IN_SECTION = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize dashboard state
        self.tableview.tableFooterView = UIView()
        self.set_security_config()
        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self._NUMBER_OF_SECTIONS
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._NUMBER_OF_ROWS_IN_SECTION
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: cell_names[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableview.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func system_toggle_action(_ sender: Any) {
        /* Action method to arm the system or disarm the system, depending on the current security configuration of the system.
         
            - Here, in the callbacks, we need to update the UI to show some form of representation that the system security config has changed.
                To do that, we change the button and status text, and we also update the status image to reflect the change.
         */
        let data = ["md_mac_address": device_uuid!] as NSDictionary
        if self.system_armed {
            // Disarm system
            let url = "/system/disarm"
            server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
                let code = response.value(forKey: "code") as! Int
                if code == server_client._SUCCESS_REPONSE_CODE {
                    let result = response.value(forKey: "data") as! Bool
                    if result {
                        DispatchQueue.main.async {
                            self.system_armed = false
                            self.status.text = "Disarmed"
                            self.arm_btn.titleLabel?.text = "Arm System"
                            self.status_img.image = UIImage(named: "unlocked.png")
                        }
                    } else {
                        // Alert message
                        DispatchQueue.main.async {
                            // Update UI
                            self.status.text = "Unknown"
                            let message = "Failed to arm system"
                            let alert_title = "Error"
                            app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                        }
                    }
                } else {
                    // Alert message
                    DispatchQueue.main.async {
                        // Update UI
                        let message = response.value(forKey: "message") as! String
                        let alert_title = "Error"
                        app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                    }
                }
            })
        } else {
            // Arm system
            let url = "/system/arm"
            server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
                let code = response.value(forKey: "code") as! Int
                if code == server_client._SUCCESS_REPONSE_CODE {
                    let result = response.value(forKey: "data") as! Bool
                    if result {
                        DispatchQueue.main.async {
                            self.system_armed = true
                            self.status.text = "Armed"
                            self.arm_btn.titleLabel?.text = "Disarm System"
                            self.status_img.image = UIImage(named: "locked.png")
                        }
                    } else {
                        // Alert message
                        DispatchQueue.main.async {
                            // Update UI
                            let message = "Failed to arm system"
                            let alert_title = "Error"
                            app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                        }
                    }
                } else {
                    // Alert message
                    DispatchQueue.main.async {
                        // Update UI
                        let message = response.value(forKey: "message") as! String
                        let alert_title = "Error"
                        app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                    }
                }
            })
        }
    }
    
    func set_security_config() {
        /* Action to sync the dashboard state with the current security configuration of the system.
         
            - Send a request to get data about the system being armed or not.
                Show UI reflections of that current state.
         */
        let url = "/system/security_config"
        let data = ["md_mac_address": device_uuid!] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let data = response.value(forKey: "data") as! NSDictionary
                let system_armed = data.value(forKey: "system_armed") as! Bool
                if system_armed {
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
            } else {
                // Alert message
                DispatchQueue.main.async {
                    // Update UI
                    let message = response.value(forKey: "message") as! String
                    let alert_title = "Error"
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                }
            }
        })
    }
}
