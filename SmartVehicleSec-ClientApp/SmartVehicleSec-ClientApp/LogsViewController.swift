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
        self.loadLogs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadLogs() {
        // Method to add contacts to the server
        let url = "/system/logs"
        let data = ["email": auth.email, "password": auth.password] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let data = response.value(forKey: "data") as! [NSDictionary]
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    self.logs = data
                    self.tableview.reloadData()
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    let message = response.value(forKey: "message") as! String
                    let alert_title = "Error"
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                }
            }
        })
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
