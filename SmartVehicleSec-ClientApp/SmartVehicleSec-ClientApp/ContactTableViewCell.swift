//
//  ContactTableViewCell.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/6/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    /*
     Tableview Cell to represent a person's contact information
     
     The cell includes textfields (name, email, phone) and a trash button to remove that cell row
     */
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var remove_button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
