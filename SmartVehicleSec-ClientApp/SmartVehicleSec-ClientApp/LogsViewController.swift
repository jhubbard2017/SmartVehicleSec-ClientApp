//
//  LogsViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/8/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    // Constants
    let SECTION_COUNT = 1
    let LOG_CELL_ID = "log_cell"
    let LOG_CELL_HEIGHT = CGFloat(73.0)
    
    var logs = [NSDictionary]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()

        // Do any additional setup after loading the view.
        self.tableview.tableFooterView = UIView()
        app_utils.start_activity_indicator(view: self.view, text: "Loading Logs")
        api.get_logs(email: auth_info.email) { error, data_logs in
            app_utils.stop_activity_indicator()
            if (error == nil) {
                self.logs = data_logs!
                self.tableview.reloadData()
            } else {
                let title = "Error (\(String(describing: error?.code)))"
                let message = error?.domain
                app_utils.showDefaultAlert(controller: self, title: title, message: message!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.SECTION_COUNT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = self.logs[indexPath.row].value(forKey: "date") as! String
        let time = self.logs[indexPath.row].value(forKey: "time") as! String
        let info = self.logs[indexPath.row].value(forKey: "info") as! String
        let cell = self.tableview.dequeueReusableCell(withIdentifier: self.LOG_CELL_ID)
        cell?.textLabel?.text = info
        cell?.detailTextLabel?.text = "\(date) \(time)"
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.LOG_CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableview.deselectRow(at: indexPath, animated: true)
    }
}
