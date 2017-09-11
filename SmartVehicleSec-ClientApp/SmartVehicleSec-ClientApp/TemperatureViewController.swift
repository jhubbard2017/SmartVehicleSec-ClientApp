//
//  TemperatureViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/8/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class TemperatureViewController: UIViewController {

    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var convertButton: UIButton!
    
    var timer: Timer!
    
    enum unitTypes: Int {
        case fahrenheit = 0, celcius
    }
    
    var current_unit = unitTypes.fahrenheit.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()

        // Do any additional setup after loading the view.
        self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self,
                                          selector: #selector(TemperatureViewController.getTemperature),
                                          userInfo: nil, repeats: true)
        self.timer.fire()
        self.unit.text = "Fahrenheit"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Stop the background task when user navigates to new view controller
        print("Stopped getting temperature")
        self.timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchUnitAction(_ sender: Any) {
        if self.current_unit == unitTypes.fahrenheit.rawValue {
            // Convert to celcius
            self.current_unit = unitTypes.celcius.rawValue
            self.unit.text = "Celcius"
            self.convertButton.titleLabel?.text = "Show in Fahrenheit"
        } else {
            // Convert to fahrenheit
            self.current_unit = unitTypes.fahrenheit.rawValue
            self.unit.text = "Fahrenheit"
            self.convertButton.titleLabel?.text = "Show in Celcius"
        }
    }
    
    func getTemperature() {
        let url = "/system/temperature"
        let data = ["md_mac_address": device_uuid!] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let data = response.value(forKey: "data") as! NSDictionary
                var temp: Float!
                if self.current_unit == unitTypes.fahrenheit.rawValue {
                    temp = data.value(forKey: "fahrenheit") as! Float
                } else {
                    temp = data.value(forKey: "celcius") as! Float
                }
                print("Got temperature: ")
                // Update UI
                DispatchQueue.main.async {
                    self.temperature.text = String(temp)
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    let alert_title = "Error"
                    let alert_message = "Could not get GPS location. Check connection..."
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
                }
            }
        })
    }
}
