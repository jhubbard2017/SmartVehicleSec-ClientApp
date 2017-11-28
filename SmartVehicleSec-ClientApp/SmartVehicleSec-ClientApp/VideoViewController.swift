//
//  VideoViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/29/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet weak var play_pause_btn: UIButton!
    @IBOutlet weak var rewind_btn: UIButton!
    @IBOutlet weak var export_btn: UIButton!
    @IBOutlet weak var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        app_utils.start_activity_indicator(view: self.view, text: "")
        api.get_connection(email: auth_info.email) { error, connection in
            DispatchQueue.main.async {
                app_utils.stop_activity_indicator()
                if (error == nil) {
                    let host = connection?.value(forKey: "host") as! String
                    let url_string = "http://\(host):8081"
                    print(url_string)
                    let url = NSURL(string: url_string)
                    let requestObj = NSURLRequest(url: url! as URL)
                    self.webview.loadRequest(requestObj as URLRequest)
                } else {
                    let title = "Error (\(String(describing: error?.code)))"
                    let message = error?.domain
                    app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                    // self.navigationController?.popViewController(animated: true)
                }
            }
        }        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
