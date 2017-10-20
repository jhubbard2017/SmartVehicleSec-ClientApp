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
    
    let kmh_multiplier = Float(1.6)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self,
                                          selector: #selector(SpeedometerViewController.getSpeedometerData),
                                          userInfo: nil, repeats: true)
        self.current_unit = speedUnitTypes.mph.rawValue
        self.unit.text = "MPH"
        self.speed.text = "0.0"
        self.altitude.text = "0.0 ft"
        self.heading.text = "0.0 ft"
        self.climb.text = "0.0 ft"
        self.convertBtn.setTitle("Show in KMH", for: UIControlState.normal)
        self.timer.fire()
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
            self.convertBtn.setTitle("Show in MPH", for: UIControlState.normal)
        } else {
            // Convert to mph
            self.current_unit = speedUnitTypes.mph.rawValue
            self.unit.text = "MPH"
            self.convertBtn.setTitle("Show in KMH", for: UIControlState.normal)
        }
    }
    
    func getSpeedometerData() {
        api.get_speedometer(email: auth_info.email) { error, speedometer_data in
            if (error == nil) {
                let altitude_data = speedometer_data?.value(forKey: "altitude") as! Float
                let heading_data = speedometer_data?.value(forKey: "heading") as! Float
                let climb_data = speedometer_data?.value(forKey: "climb") as! Float
                
                var speed_data = speedometer_data?.value(forKey: "speed") as! Float
                if self.current_unit == speedUnitTypes.kmh.rawValue {
                    speed_data = speed_data * self.kmh_multiplier
                }
                
                self.speed.text = String(Int(speed_data))
                self.altitude.text = String("\(altitude_data) ft")
                self.heading.text = String("\(heading_data) deg")
                self.climb.text = String("\(climb_data) ft/min")
            } else {
                let title = "Error (\(String(describing: error?.code)))"
                let message = error?.domain
                app_utils.showDefaultAlert(controller: self, title: title, message: message!)
            }
        }
    }
}
