//
//  SettingsViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 10/13/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    enum settings_tableview_rows: Int {
        case account_information = 0, emergency_contacts, logout
    }
    
    let data = ["Account Information", "Emergency Contacts", "Logout"]
    let SECTION_COUNT = 1
    let CELL_ID = "settings_cell"
    let ROW_HEIGHT = CGFloat(50.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.SECTION_COUNT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: self.CELL_ID)
        cell?.textLabel?.text = self.data[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableview.deselectRow(at: indexPath, animated: true)
        var next_vc: UIViewController!
        switch indexPath.row {
        case settings_tableview_rows.account_information.rawValue:
            next_vc = self.storyboard?.instantiateViewController(withIdentifier: "AccountInformationViewController") as! AccountInformationViewController
            self.navigationController?.pushViewController(next_vc, animated: true)
            break
        case settings_tableview_rows.emergency_contacts.rawValue:
            next_vc = self.storyboard?.instantiateViewController(withIdentifier: "EditContactsViewController") as! EditContactsViewController
            self.navigationController?.pushViewController(next_vc, animated: true)
            break
        case settings_tableview_rows.logout.rawValue:
            var title = "Error"
            var message = ""
            let alert = UIAlertController(title: "Are you sure?", message: "Logout?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(action) in
                app_utils.start_activity_indicator(view: self.view, text: "")
                api.logout(email: auth_info.email) { error in
                    if (error == nil) {
                        title = "Success!"
                        message = "Logged out of account."
                        let sb = UIStoryboard(name: "authentication", bundle: nil)
                        next_vc = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        self.present(next_vc, animated: true, completion: nil)
                    } else {
                        title = "Error (\(String(describing: error?.code)))"
                        message = error?.domain
                    }
                }
                app_utils.showDefaultAlert(controller: self, title: title, message: message)
            }))
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.ROW_HEIGHT
    }
}
