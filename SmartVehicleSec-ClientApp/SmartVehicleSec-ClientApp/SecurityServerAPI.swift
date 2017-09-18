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


struct ServerInformation {
    /* Object to store informatino about the server
     
        Attributes:
            - ip_address: local hostname of the server
            - http_port: port number to send request to server API
     */
    var ip_address = ""
    var port = 0
    var rd_mac_address = ""
}


class SecurityServerAPI {
    /* Central class to control sending request and recieve responses
     
        - As of right now, only post requests are made to the REST API on the server, due to json not being sent/read correctly when using a GET request.
          In regards to the server, a `201` code means that the request action was successful, and a `404` code means that the request action was a failure due
          to some issues.
        - The server returns json as a data response object, which is then converted to Swift's NSDictionary, making iterations through the data much easier (using methods of the NSDictionary class.)
     */
    
    let _SUCCESS_REPONSE_CODE = 201
    let _FAILURE_RESPONSE_CODE = 404
    
    func send_request(url: String, data: NSDictionary, method: String, completion: @escaping (_ return_data: NSDictionary) -> Void) {
        // The current address of the server may change, since we don't have a static IP address, and the options for the client is either the same wifi network or a different wifi network. To solve this issue, we check to see if we are on wifi or LTE (client side.)
        let actual_url = "http://" + server_info.ip_address + ":" + String(server_info.port) + url
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
}
