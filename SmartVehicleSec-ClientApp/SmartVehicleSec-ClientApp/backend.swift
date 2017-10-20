//
//  auth_methods.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 10/18/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import Foundation
import UIKit

struct AuthInfo {
    var host = ""
    var port = 0
    var email = ""
    var password = ""
}

class APIHelperMethods {
    
    let _SUCCESS_REPONSE_CODE = 201
    let _FAILURE_RESPONSE_CODE = 404
    
    func send_request(url: String, data: NSDictionary, method: String, completion: @escaping (_ return_data: NSDictionary) -> Void) {
        // The current address of the server may change, since we don't have a static IP address, and the options for the client is either the same wifi network or a different wifi network. To solve this issue, we check to see if we are on wifi or LTE (client side.)
        let actual_url = "http://" + auth_info.host + ":" + String(auth_info.port) + url
        let nsurl = URL(string: actual_url)
        var urlRequest = URLRequest(url: nsurl!)
        urlRequest.httpMethod = method
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        // Set the content and acceptance types to json, so the server can recieve it as json.
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                // Try to convert json to NSDictionary
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    // Callback
                    completion(json)
                    return
                }
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }).resume()
    }
    
    func login(email: String, password: String, completion: @escaping (_ error: NSError?) -> Void) {
        // Method to authenticate user
        let url = "/authentication/login"
        let data = ["email": email, "password": password] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let authenticated = response.value(forKey: "data") as! Bool
                if authenticated {
                    auth_info.email = email
                    auth_info.password = password
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func create_account(firstname: String, lastname: String, email: String, password: String, phone: String, vehicle: String, system_id: String, completion: @escaping (_ error: NSError?) -> Void) {
        // Method to create user account
        let url = "/users/add"
        let data = ["firstname": firstname, "lastname": lastname, "email": email, "phone": phone, "vehicle": vehicle, "system_id": system_id, "password": password] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    auth_info.email = email
                    auth_info.password = password
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func logout(email: String, completion: @escaping (_ error: NSError?) -> Void) {
        // Method to logout user
        let url = "/authentication/logout"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func forgot_password(email: String, completion: @escaping (_ error: NSError?) -> Void) {
        let url = "/authentication/forgot_password"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func add_contacts(email: String, contacts: [NSDictionary], completion: @escaping (_ error: NSError?) -> Void) {
        let url = "/emergency_contacts/add"
        let data = ["email": email, "contacts": contacts] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func get_contacts(email: String, completion: @escaping (_ error: NSError?, _ contacts: [NSDictionary]?) -> Void) {
        let url = "/emergency_contacts/get"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let contacts = response.value(forKey: "data") as! [NSDictionary]
                completion(nil, contacts)
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error, nil)
            }
        })
    }
    
    func update_contacts(email: String, contacts: [NSDictionary], completion: @escaping (_ error: NSError?) -> Void) {
        let url = "/emergency_contacts/update"
        let data = ["email": email, "contacts": contacts] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func get_user(email: String, completion: @escaping (_ error: NSError?, _ user: NSDictionary?) -> Void) {
        // Method to retrieve user information
        let url = "/users/get"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let user = response.value(forKey: "data") as! NSDictionary
                completion(nil, user)
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error, nil)
            }
        })
    }
    
    func update_user(firstname: String, lastname: String, email: String, phone: String, vehicle: String, system_id: String, completion: @escaping (_ error: NSError?) -> Void) {
        // Method to update user information
        let url = "/users/update"
        let data = ["firstname": firstname, "lastname": lastname, "email": email, "phone": phone, "vehicle": vehicle, "system_id": system_id] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func change_user_password(email: String, old_password: String, new_password: String, completion: @escaping (_ error: NSError?) -> Void) {
        let url = "/users/change_password"
        let data = ["email": email, "old_password": old_password, "new_password": new_password] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func get_config(email: String, completion: @escaping (_ error: NSError?, _ config: NSDictionary?) -> Void) {
        let url = "/security/get_config"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let config = response.value(forKey: "data") as! NSDictionary
                completion(nil, config)
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error, nil)
            }
        })
    }
    
    func arm_system(email: String, completion: @escaping (_ error: NSError?) -> Void) {
        let url = "/security/arm"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func disarm_system(email: String, completion: @escaping (_ error: NSError?) -> Void) {
        let url = "/security/disarm"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    completion(nil)
                }
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error)
            }
        })
    }
    
    func get_logs(email: String, completion: @escaping (_ error: NSError?, _ logs: [NSDictionary]?) -> Void) {
        let url = "/security/get_logs"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let logs = response.value(forKey: "data") as! [NSDictionary]
                completion(nil, logs)
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error, nil)
            }
        })
    }
    
    func get_temperature(email: String, completion: @escaping (_ error: NSError?, _ temperature: NSDictionary?) -> Void) {
        let url = "/systems/temperature"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let temperature = response.value(forKey: "data") as! NSDictionary
                completion(nil, temperature)
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error, nil)
            }
        })
    }
    
    func get_location(email: String, completion: @escaping (_ error: NSError?, _ location: NSDictionary?) -> Void) {
        let url = "/systems/location"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let location = response.value(forKey: "data") as! NSDictionary
                completion(nil, location)
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error, nil)
            }
        })
    }
    
    func get_speedometer(email: String, completion: @escaping (_ error: NSError?, _ speedometer: NSDictionary?) -> Void) {
        let url = "/systems/speedometer"
        let data = ["email": email] as NSDictionary
        self.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == self._SUCCESS_REPONSE_CODE {
                let speedometer = response.value(forKey: "data") as! NSDictionary
                completion(nil, speedometer)
            } else {
                let error = NSError(domain: response.value(forKey: "message") as! String, code: self._FAILURE_RESPONSE_CODE, userInfo: nil)
                completion(error, nil)
            }
        })
    }
}
