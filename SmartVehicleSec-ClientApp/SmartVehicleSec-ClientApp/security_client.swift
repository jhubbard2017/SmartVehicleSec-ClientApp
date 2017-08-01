//
//  network_client.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/26/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import Foundation
import UIKit

class UDPSocketStreamer: Stream, StreamDelegate {
    /* Socket Client class: connects to a network socket, sends and recieves data, and manages connection. */
    
    var inStream : InputStream?
    var outStream: OutputStream?
    
    var buffer = [UInt8](repeating: 0, count: 200)
    
    var current_image: UIImage!
    
    func start() {
        /* This method starts the socket client connection and connects to the assigned ip address and port
         
         The input and output stream is also set up in this method.
         */
        let ipaddr = server_api.get_server_address()
        
        if !ipaddr.isEmpty {
            Stream.getStreamsToHost(withName: ipaddr, port: server_info.udp_port, inputStream: &inStream, outputStream: &outStream)
            self.inStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.outStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.inStream?.open()
            self.outStream?.open()
        } else {
            print("Error: IP Address hasn't been set...")
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        /* This is a delegate method for the Stream class. This method is used for handling callbacks once
                errors in the sockets occur and controlling the session status code.
         */
        switch eventCode {
            case Stream.Event.errorOccurred, Stream.Event.endEncountered:
                self.inStream?.close()
                self.inStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                self.outStream?.close()
                self.outStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                break
            case Stream.Event.hasSpaceAvailable:
                if aStream == self.inStream {
                    let byte_string = String(describing: self.inStream?.read(&self.buffer, maxLength: self.buffer.count))
                    let dataDecoded = byte_string.data(using: String.Encoding.utf8)
                    let decodedimage = UIImage(data: dataDecoded!)
                    self.current_image = decodedimage
                }
                break
            case Stream.Event.openCompleted:
                break
            default:
                break
        }
    }
    
    func get_current_frame() -> UIImage {
        /* checks and recieves data from the socket server.
         
         returns:
            str
         */
        return self.current_image
    }
    
    func send_data(data: String) {
        /* Sends data to the socket server
         
         args:
            data: str
         */
        let encodedMessage : Data = data.data(using: String.Encoding.utf8)!
        self.outStream?.write((encodedMessage as NSData).bytes.bindMemory(to: UInt8.self, capacity: encodedMessage.count), maxLength: encodedMessage.count)
    }
}
