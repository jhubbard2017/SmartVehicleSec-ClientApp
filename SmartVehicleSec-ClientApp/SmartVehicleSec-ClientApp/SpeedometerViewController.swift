//
//  SpeedometerViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/15/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class SpeedometerViewController: UIViewController {

    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var climb: UILabel!
    @IBOutlet weak var convertBtn: UIButton!
    
    var timer: Timer!
    var current_unit = speedUnitTypes.mph.rawValue
    
    let kmh_multiplier = Float(1.60934)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self,
                                          selector: #selector(SpeedometerViewController.getSpeedometerData),
                                          userInfo: nil, repeats: true)
        self.timer.fire()
        self.unit.text = "MPH"
        self.speed.text = "0.0"
        self.altitude.text = "0.0 ft"
        self.heading.text = "0.0 ft"
        self.climb.text = "0.0 ft"
        self.convertBtn.titleLabel?.text = "Show in KMH"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Stop the background task when user navigates to new view controller
        print("Stopped getting temperature")
        self.timer.invalidate()
    }
    
    @IBAction func convertAction(_ sender: Any) {
        // Action Method to convert speend between MPH and KM/H
        if self.current_unit == speedUnitTypes.mph.rawValue {
            // Convert to kmh
            self.current_unit = speedUnitTypes.kmh.rawValue
            self.unit.text = "KMH"
            self.convertBtn.titleLabel?.text = "Show in MPH"
        } else {
            // Convert to mph
            self.current_unit = speedUnitTypes.mph.rawValue
            self.unit.text = "MPH"
            self.convertBtn.titleLabel?.text = "Show in KMH"
        }
    }
    
    func getSpeedometerData() {
        let url = "/system/speedometer"
        let data = ["md_mac_address": device_uuid!] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let data = response.value(forKey: "data") as! NSDictionary
                let altitude_data = data.value(forKey: "altitude") as! Float
                let heading_data = data.value(forKey: "heading") as! Float
                let climb_data = data.value(forKey: "climb") as! Float
                
                var speed_data = data.value(forKey: "speed") as! Float
                if self.current_unit == speedUnitTypes.mph.rawValue {
                    speed_data = speed_data * self.kmh_multiplier
                }
                print("Got temperature: ")
                // Update UI
                DispatchQueue.main.async {
                    self.speed.text = String(speed_data)
                    self.altitude.text = String("\(altitude_data) ft")
                    self.heading.text = String("\(heading_data) deg")
                    self.climb.text = String("\(climb_data) ft/min")
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    self.timer.invalidate()
                    let alert_title = "Error"
                    let alert_message = "Could not get GPS location. Check connection..."
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }

}
