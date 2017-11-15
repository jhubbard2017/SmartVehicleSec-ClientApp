//
//  DashboardViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/28/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit
import LocalAuthentication

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
    let cell_names = ["video_cell", "location_cell", "temperature_cell", "speedometer_cell", "logs_cell", "settings_cell", "help_cell"]
    let _NUMBER_OF_SECTIONS = 1
    let _NUMBER_OF_ROWS_IN_SECTION = 6
    let _PASSCODE_LENGTH = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize dashboard state
        self.tableview.tableFooterView = UIView()
        self.view.layoutIfNeeded()
        self.view.snapshotView(afterScreenUpdates: true)
        app_utils.start_activity_indicator(view: self.view, text: "")
        api.get_config(email: auth_info.email) { error, config in
            DispatchQueue.main.async {
                app_utils.stop_activity_indicator()
                if (error == nil) {
                    let system_armed = config?.value(forKey: "system_armed") as! Bool
                    if system_armed {
                        self.updateUI(armed: true)
                    } else {
                        self.updateUI(armed: false)
                    }
                } else {
                    let title = "Error (\(String(describing: error?.code)))"
                    let message = error?.domain
                    app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                }
            }
        }
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
        if indexPath.row == 5 {
            let sb = UIStoryboard(name: "settings", bundle: nil)
            let next_vc = sb.instantiateViewController(withIdentifier: "SettingsNavigationController") as! UINavigationController
            self.navigationController?.present(next_vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func system_toggle_action(_ sender: Any) {
        /* Action method to arm the system or disarm the system, depending on the current security configuration of the system.
         
            - Here, in the callbacks, we need to update the UI to show some form of representation that the system security config has changed.
                To do that, we change the button and status text, and we also update the status image to reflect the change.
         */
        if self.system_armed {
            // Disarm system
            api.disarm_system(email: auth_info.email) { error in
                DispatchQueue.main.async {
                    if (error == nil) {
                        self.updateUI(armed: false)
                    } else {
                        let title = "Error (\(String(describing: error?.code)))"
                        let message = error?.domain
                        app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                    }
                }
            }
        } else {
            // Arm sysem
            api.arm_system(email: auth_info.email) { error in
                DispatchQueue.main.async {
                    if (error == nil) {
                        self.updateUI(armed: true)
                    } else {
                        let title = "Error (\(String(describing: error?.code)))"
                        let message = error?.domain
                        app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                    }
                }
            }
        }
    }
    
    func updateUI(armed: Bool) {
        if armed {
            self.arm_btn.setTitle("Disarm System", for: UIControlState.normal)
            self.status_img.image = UIImage(named: "locked.png")
            self.system_armed = true
            self.status.text = "Armed"
        } else {
            self.arm_btn.setTitle("Arm System", for: UIControlState.normal)
            self.status_img.image = UIImage(named: "unlocked.png")
            self.system_armed = false
            self.status.text = "Disarmed"
        }
    }
}
