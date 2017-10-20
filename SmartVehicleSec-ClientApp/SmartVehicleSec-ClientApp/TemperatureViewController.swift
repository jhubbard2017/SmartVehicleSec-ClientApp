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
        self.convertButton.setTitle("Show in Celcius", for: UIControlState.normal)
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
            self.convertButton.setTitle("Show in Fahrenheit", for: UIControlState.normal)
        } else {
            // Convert to fahrenheit
            self.current_unit = unitTypes.fahrenheit.rawValue
            self.unit.text = "Fahrenheit"
            self.convertButton.setTitle("Show in Celcius", for: UIControlState.normal)
        }
    }
    
    func getTemperature() {
        api.get_temperature(email: auth_info.email) { error, temperature_data in
            if (error == nil) {
                if self.current_unit == unitTypes.fahrenheit.rawValue {
                    self.temperature.text = String(describing: temperature_data?.value(forKey: "fahrenheit") as! Float)
                } else {
                    self.temperature.text = String(describing: temperature_data?.value(forKey: "celcius") as! Float)
                }
            } else {
                let title = "Error (\(String(describing: error?.code)))"
                let message = error?.domain
                app_utils.showDefaultAlert(controller: self, title: title, message: message!)
            }
        }
    }
}
