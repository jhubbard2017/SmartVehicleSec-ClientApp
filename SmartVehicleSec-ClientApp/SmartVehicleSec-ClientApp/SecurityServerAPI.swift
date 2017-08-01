//
//  SecurityServerAPI.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/28/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import Foundation


func getWiFiAddress() -> String? {
    /* This method fetches the current ip address of the device.
     
     As a whole, this method will return an ip address if the device is connected to a wifi network,
     and will return nil of the device is connected to LTE, 3G, or not connected at all. With this, we can
     determine whether we need to connect to the local ip address of the socket server or the global ip address.
     */
    
    var address : String?
    
    var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                if let name = String(validatingUTF8: (interface?.ifa_name)!), name == "en0" {
                    
                    var addr = interface?.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr!, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
    }
    return address
}


class ServerInformation {
    var ip_address = ""
    var fwd_ip_address = ""
    var http_port = 0
    var udp_port = 0
    var device_name = ""
}


class SecurityServerAPI {
    
    let _SUCCESS_REPONSE_CODE = 201
    let _FAILURE_RESPONSE_CODE = 404
    
    let _DATA_TRUE = 1
    let _DATA_FALSE = 0
    
    func send_request(url: String, data: NSDictionary, method: String, completion: @escaping (_ return_data: NSDictionary) -> Void) {
        let actual_url = "http://" + self.get_server_address() + ":" + String(server_info.http_port) + url
        let nsurl = URL(string: actual_url)
        var urlRequest = URLRequest(url: nsurl!)
        urlRequest.httpMethod = method
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    completion(json)
                    return
                }
            } catch let error {
                print(error.localizedDescription)
                return
            }
            print("I'm done now")
        }).resume()
    }
    
    func get_server_address() -> String {
        if getWiFiAddress() == nil {
            return server_info.fwd_ip_address
        }
        return server_info.ip_address
    }
}
