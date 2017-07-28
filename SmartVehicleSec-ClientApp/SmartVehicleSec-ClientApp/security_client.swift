//
//  network_client.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/26/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import Foundation

class SocketClient: Stream, StreamDelegate {
    /* Socket Client class: connects to a network socket, sends and recieves data, and manages connection. */
    
    var device_name = ""
    var password = ""
    var socket_ip = ""
    var fwd_socket_ip = ""
    var socket_port = 0
    var device_set = false
    
    var inStream : InputStream?
    var outStream: OutputStream?
    
    var buffer = [UInt8](repeating: 0, count: 200)
    var sessionStatus = 0
    
    let data_to_send = ["arm_system": "ARMSYSTEM",
                         "disarm_system": "DISARMSYSTEM",
                         "view_camera1": "VIEWCAMERAFEED1",
                         "view_camera2": "VIEWCAMERAFEED2",
                         "false_alarm": "FALSEALARM",
                         "new_device": "NEWDEVICE",
                         "stop_video_stream": "STOPVIDEOSTREAM",
                         "disconnect": "DISCONNECT"]
    
    let data_to_recieve = ["success": "SUCCESS",
                            "failure": "FAILURE",
                            "system_breach": "SYSTEMBREACH",
                            "unknown_request": "UNKNOWNREQUEST",
                            "new_device": "NEWDEVICE"]
    
    init(name: String, password: String, ip: String, fwd_ip: String, port: Int) {
        self.device_name = name
        self.password = password
        self.socket_ip = ip
        self.fwd_socket_ip = fwd_ip
        self.socket_port = port
        self.device_set = true
    }
    
    func start() {
        /* This method starts the socket client connection and connects to the assigned ip address and port
         
         The input and output stream is also set up in this method.
         */
        var ipaddr = ""
        if self.getWiFiAddress() == nil {
            ipaddr = self.fwd_socket_ip
        } else {
            ipaddr = self.socket_ip
        }
        
        if !ipaddr.isEmpty {
            Stream.getStreamsToHost(withName: ipaddr, port: self.socket_port, inputStream: &inStream, outputStream: &outStream)
            self.inStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.outStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.inStream?.open()
            self.outStream?.open()
        } else {
            print("Error: IP Address hasn't been set...")
        }
    }
    
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
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        /* This is a delegate method for the Stream class. This method is used for handling callbacks once
                errors in the sockets occur and controlling the session status code.
         */
        switch eventCode {
            case Stream.Event.errorOccurred, Stream.Event.endEncountered:
                self.sessionStatus = 0
                self.inStream?.close()
                self.inStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                self.outStream?.close()
                self.outStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                break
            case Stream.Event.hasSpaceAvailable:
                self.sessionStatus = 1
                break
            case Stream.Event.openCompleted:
                self.sessionStatus = 1
                break
            default:
                break
        }
    }
    
    func get_data() -> String {
        /* checks and recieves data from the socket server.
         
         returns:
            str
         */
        let data = self.inStream!.read(&self.buffer, maxLength: self.buffer.count)
        return String(data)
    }
    
    func send_data(data: String) {
        /* Sends data to the socket server
         
         args:
            data: str
         */
        let encodedMessage : Data = data.data(using: String.Encoding.utf8)!
        self.outStream?.write((encodedMessage as NSData).bytes.bindMemory(to: UInt8.self, capacity: encodedMessage.count), maxLength: encodedMessage.count)
    }

    /* ------------------------ Getters and setters ------------------------ */
    func get_status() -> Int {
        return self.sessionStatus
    }
    
    func get_ip() -> String {
        return self.socket_ip
    }
    
    func set_ip(ip: String) {
        self.socket_ip = ip
    }
    
    func get_port() -> Int {
        return self.socket_port
    }
    
    func set_port(port: Int) {
        self.socket_port = port
    }
    
    func get_device_name() -> String {
        return self.device_name
    }
    
    func set_device_name(name: String) {
        self.device_name = name
    }
    
    func get_password() -> String {
        return self.password
    }
    
    func set_password(password: String) {
        self.password = password
    }
    
    func get_fwd_ip() -> String {
        return self.fwd_socket_ip
    }
    
    func set_fwd_ip(ip: String) {
        self.fwd_socket_ip = ip
    }
    
    func device_is_set() -> Bool {
        return self.device_set
    }
    
    func set_device_is_set(set: Bool) {
        self.device_set = set
    }
}
