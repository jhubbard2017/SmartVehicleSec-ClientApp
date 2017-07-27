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
    
    var socket_ip:String = String()
    var fwd_socket_ip:String = String()
    var socket_port:Int = Int()
    
    var inStream : InputStream?
    var outStream: OutputStream?
    
    var buffer = [UInt8](repeating: 0, count: 200)
    var sessionStatus = 0
    var sessionLogs = [String()]
    
    func start() {
        /* This method starts the socket client connection and connects to the assigned ip address and port
         
         The input and output stream is also set up in this method.
         */
        var ipaddr = String()
        if self.getWiFiAddress() == nil {
            ipaddr = self.fwd_socket_ip
        } else {
            ipaddr = self.socket_ip
        }
        
        Stream.getStreamsToHost(withName: ipaddr, port: self.socket_port, inputStream: &inStream, outputStream: &outStream)
        self.inStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.outStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.inStream?.open()
        self.outStream?.open()
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
    
    func set_ip(ip: String) {
        self.socket_ip = ip
    }
    
    func set_port(port: Int) {
        self.socket_port = port
    }
    
    func get_ip() -> String {
        return self.socket_ip
    }
    
    func get_port() -> Int {
        return self.socket_port
    }
}
