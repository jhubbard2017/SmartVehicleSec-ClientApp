//
//  EditContactsViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Developer on 9/15/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

class EditContactsViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var contacts = [Contact]()
    
    // Constants
    let SECTION_COUNT = 1
    let ADD_CONTACT_CELL_ID = "add_contact_cell"
    let CONTACT_CELL_ID = "contact_cell"
    let ADD_CONTACT_CELL_HEIGHT = CGFloat(50.0)
    let CONTACT_CELL_HEIGHT = CGFloat(133.0)
    let MAX_CONTACTS = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Do any additional setup after loading the view.
        self.tableview.tableFooterView = UIView()
        self.getContactsFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.SECTION_COUNT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case self.contacts.count:
            let cell = self.tableview.dequeueReusableCell(withIdentifier: self.ADD_CONTACT_CELL_ID)
            return cell!
        default:
            let cell = self.tableview.dequeueReusableCell(withIdentifier: self.CONTACT_CELL_ID) as! ContactTableViewCell
            cell.name.tag = contactTextfieldTypes.name.rawValue
            cell.email.tag = contactTextfieldTypes.email.rawValue
            cell.phone.tag = contactTextfieldTypes.phone.rawValue
            cell.name.text = self.contacts[indexPath.row].name
            cell.email.text = self.contacts[indexPath.row].email
            cell.phone.text = self.contacts[indexPath.row].phone
            cell.name.addTarget(self, action: #selector(EditContactsViewController.textFieldValueChanged), for: .editingChanged)
            cell.email.addTarget(self, action: #selector(EditContactsViewController.textFieldValueChanged), for: .editingChanged)
            cell.phone.addTarget(self, action: #selector(EditContactsViewController.textFieldValueChanged), for: .editingChanged)
            cell.remove_button.addTarget(self, action: #selector(EditContactsViewController.removeAction), for: UIControlEvents.touchUpInside)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableview.deselectRow(at: indexPath, animated: true)
        if indexPath.row == self.contacts.count && self.contacts.count < self.MAX_CONTACTS {
            self.contacts.insert(Contact(), at: indexPath.row)
            self.tableview.insertRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade)
        } else {
            // Show alert message
            let alert_title = "Warning"
            let alert_message = "Max amount of contacts reached."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
    
    func removeAction(sender: AnyObject) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableview)
        let indexPath = self.tableview.indexPathForRow(at: buttonPosition)
        self.contacts.remove(at: (indexPath?.row)!)
        self.tableview.deleteRows(at: [indexPath!], with: .left)
    }
    
    func textFieldValueChanged(_ textField: UITextField) {
        let position:CGPoint = textField.convert(CGPoint.zero, to: self.tableview)
        let indexpath = self.tableview.indexPathForRow(at: position)
        switch textField.tag {
        case contactTextfieldTypes.name.rawValue:
            self.contacts[(indexpath?.row)!].name = textField.text!
        case contactTextfieldTypes.email.rawValue:
            self.contacts[(indexpath?.row)!].email = textField.text!
        case contactTextfieldTypes.phone.rawValue:
            self.contacts[(indexpath?.row)!].phone = textField.text!
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.contacts.count {
            return self.ADD_CONTACT_CELL_HEIGHT
        }
        return self.CONTACT_CELL_HEIGHT
    }
    
    func validateContacts() -> Bool {
        for contact in self.contacts {
            if contact.name.isEmpty && contact.email.isEmpty && contact.phone.isEmpty {
                return false
            }
        }
        return true
    }
    
    func convertResponseToContacts(data: [NSDictionary]) {
        // Method to convert Contacts to list of dictionary
        for contact in data {
            var new_contact = Contact()
            new_contact.name = contact.value(forKey: "name") as! String
            new_contact.email = contact.value(forKey: "email") as! String
            new_contact.phone = contact.value(forKey: "phone") as! String
            self.contacts.append(new_contact)
        }
    }
    
    func convertcontactsForServer() -> [NSDictionary] {
        // Method to convert Contacts to list of dictionary
        var contacts_dict = [NSDictionary]()
        for contact in self.contacts {
            contacts_dict.append(contact.convertToDict())
        }
        return contacts_dict
    }
    
    func getContactsFromServer() {
        // Method to get current contacts on the server
        let url = "/system/get_contacts"
        let data = ["md_mac_address": device_uuid!] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let contacts = response.value(forKey: "data") as! [NSDictionary]
                DispatchQueue.main.async {
                    // Update UI
                    self.convertResponseToContacts(data: contacts)
                    self.tableview.reloadData()
                    app_utils.stop_activity_indicator()
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    let message = response.value(forKey: "message") as! String
                    let alert_title = "Error"
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    func updateContactsOnServer() {
        // Method to update contacts on the server
        let url = "/system/update_contacts"
        let data = ["md_mac_address": device_uuid!, "contacts": self.convertcontactsForServer()] as NSDictionary
        server_client.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            if code == server_client._SUCCESS_REPONSE_CODE {
                let success = response.value(forKey: "data") as! Bool
                if success {
                    DispatchQueue.main.async {
                        // Update UI
                        app_utils.stop_activity_indicator()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                // Alert message
                DispatchQueue.main.async {
                    // Update UI
                    app_utils.stop_activity_indicator()
                    let message = response.value(forKey: "message") as! String
                    let alert_title = "Error"
                    app_utils.showDefaultAlert(controller: self, title: alert_title, message: message)
                }
            }
        })
    }

    @IBAction func saveAction(_ sender: Any) {
        // Action nmethod to save updates to contacts
        if self.validateContacts() {
            // Update contacts on the server
            app_utils.start_activity_indicator(view: self.view, text: "Updating contacts")
            self.updateContactsOnServer()
        } else {
            // Inputs not validated. Show alert message
            let alert_title = "Error"
            let alert_message = "Please complete all fields for each contact."
            app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
        }
    }
}