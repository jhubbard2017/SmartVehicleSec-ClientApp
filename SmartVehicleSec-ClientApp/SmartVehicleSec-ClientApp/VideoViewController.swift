//
//  VideoViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/29/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var stream_frame: UIImageView!
    @IBOutlet weak var play_pause_btn: UIButton!
    @IBOutlet weak var rewind_btn: UIButton!
    @IBOutlet weak var export_btn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
