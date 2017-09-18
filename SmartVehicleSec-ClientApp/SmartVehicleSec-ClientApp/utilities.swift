//
//  utilities.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/25/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import Foundation
import UIKit

class AppUtilities {
    /* A collection of utilities used throughout the application */
    
    var blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    var blurEffectView:UIVisualEffectView = UIVisualEffectView()
    var indicatorText:UILabel = UILabel()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    func start_activity_indicator(view: UIView, text: String) {
        /* Starts an activity indicator on the view passed to the method 
         
         args:
            view: UIView
            text: str (text to show while loading)
         */
        blurEffectView.effect = self.blurEffect
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        indicatorText.frame = CGRect(x: 100, y: 100, width: 200, height: 400)
        indicatorText.textAlignment = .center
        indicatorText.text = text
        indicatorText.textColor=UIColor.orange
        indicatorText.font=UIFont(name: "Avenir", size: 13.0)
        indicatorText.backgroundColor=UIColor.clear
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(blurEffectView)
        view.addSubview(indicatorText)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stop_activity_indicator() {
        /* Stops an activity indicator on the view passed to the method */
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        indicatorText.removeFromSuperview()
        blurEffectView.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func showDefaultAlert(controller: UIViewController, title: String, message: String) {
        /* Shows alert box with passed in title and text. 
         
         The alert actions for this method are only default action 
         */
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func validateInputs(inputs: [UITextField]) -> Bool {
        /*
         Method to validate a list of inputs
         
         args:
            inputs: [UITextField]
         
         returns:
            bool
         */
        var validated = true
        for textfield in inputs {
            if (textfield.text?.isEmpty)! {
                validated = false
                break
            }
        }
        return validated
    }
}

struct Contact {
    var name = ""
    var email = ""
    var phone = ""
    
    func convertToDict() -> NSDictionary {
        return ["name": self.name, "email": self.email, "phone": self.phone] as NSDictionary
    }
}

// Enums
enum contactTextfieldTypes: Int {
    case name = 0, email, phone
}

enum speedUnitTypes: Int {
    case mph = 0, kmh
}
