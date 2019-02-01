//
//  SettingsViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/28/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    // Get our firebase path references.
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    let storage = Storage.storage().reference()
    let userID = Auth.auth().currentUser?.uid

    // UI References
    @IBOutlet weak var label_tableCount: UILabel!
    @IBOutlet weak var button_changePassword: UIButton!
    @IBOutlet weak var button_deleteRestaurant: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tablesTableView: UITableView!
    
    //Array for our tableView
    var waiters = [WaiterObject]()
    // Array for our tables
    var tables = [TableClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // customizing our ui buttons
        
        button_changePassword.layer.cornerRadius = 10
        button_changePassword.layer.borderWidth = 2
        button_changePassword.layer.borderColor = button_changePassword.titleColor(for: .normal)?.cgColor
        
        button_deleteRestaurant.layer.cornerRadius = 10
        button_deleteRestaurant.layer.borderWidth = 2
        button_deleteRestaurant.layer.borderColor = button_deleteRestaurant.titleColor(for: .normal)?.cgColor
        
        // observe method

        restaurantRef.child(self.userID!).child("accounts").observe(.value) { (snapshot) in
            if let accounts = snapshot.value as? NSDictionary{
                self.refreshAccounts(snapshot: accounts)
            }
        }
        restaurantRef.child(self.userID!).child("tables").observe(.value) { (snapshot) in
            if let loadedTables = snapshot.value as? NSDictionary{
                self.refreshTables(snapshot: loadedTables)
            }
        }
    }
    // update our tablesTableView
    func refreshTables(snapshot: NSDictionary){
        tables.removeAll()
        for (key,values) in snapshot{
            let newValues = values as! NSDictionary
            let tableName = newValues["tableName"] as! String
            tables.append(TableClass(tableName: tableName, waiter: ""))
        }
        print("reloading data")
        tablesTableView.reloadData()
    }
    
    // update our tableview and reload data from firebase database
    func refreshAccounts( snapshot: NSDictionary){
        waiters.removeAll()
        
        for (key,values) in snapshot {
            let newValues = values as! NSDictionary
            let userName = newValues["username"] as! String
            let password = newValues["password"] as! String
            let displayName = newValues["displayname"] as! String
            waiters.append(WaiterObject(name: userName, password: password, display: displayName))
            
        }
        tableView.reloadData()
    }
    
    
    // Going to Delete the restaurant
    @IBAction func deleteRestaurant(_ sender: UIButton) {
        // First lets do a popup to verify
        let alert = UIAlertController(title: "Delete Restaurant", message: "Are you sure you want to delete the restaurant?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "DELETE", style: .destructive) { (UIAlertAction) in
            // Handle ALl of our deletion here!
            
            // Delete Storage first
            // Delete real time database footprint
            self.restaurantRef.child(self.userID!).removeValue()
            
            // Segue back to create restaurant.
            self.performSegue(withIdentifier: "segue_CreateRestaurant", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    

    // Change Password
    
    @IBAction func changePassword(_ sender: UIButton) {
        let notifyAlert = UIAlertController(title: "Password Changed", message: "Your password has been changed successfully!", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default)
        notifyAlert.addAction(continueAction)
        
        let alert = UIAlertController(title: "Change Password", message: "Enter your new password", preferredStyle: .alert)
        alert.addTextField { (textField) in
        }
        let action = UIAlertAction(title: "Confirm", style: .default) { (UIAlertAction) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text?.count)! > 0{
                Auth.auth().currentUser?.updatePassword(to: textField.text!)
                self.present(notifyAlert, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Creating waiter accounts
    
    @IBAction func createAccount(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create account", message: "Enter the fields to create the waiters account", preferredStyle: .alert)
        alert.addTextField{(textField) in
            textField.placeholder = "Display name"
        }
        alert.addTextField{(textField) in
            textField.placeholder = "Username"
        }
        alert.addTextField{(textField) in
            textField.placeholder = "Password"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let create = UIAlertAction(title: "Create", style: .default) { (UIAlertAction) in
            let displayName = alert.textFields![0]
            let userText = alert.textFields![1]
            let passwordText = alert.textFields![2]
            if ((userText.text?.count)! > 0) && ((passwordText.text?.count)! > 0) && ((displayName.text?.count)! > 0){
                
                // create our waiter object
                let waiter = WaiterObject(name: userText.text!, password: passwordText.text!, display: displayName.text!)
                
                let upload = self.restaurantRef.child(self.userID!).child("accounts").childByAutoId().setValue(waiter.ConvertToDictionary())
                // notify the user
    
            }
        }
        alert.addAction(cancel)
        alert.addAction(create)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    // TableView management
    func tableView(_ tableViews: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableViews == tableView){
            return waiters.count
        }else{
            print("tables")
            return tables.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tablesTableView{
            let cell = tablesTableView.dequeueReusableCell(withIdentifier: "cell_Table")
            cell?.textLabel?.text = tables[indexPath.row].tableName
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_Account")
            let waiter:WaiterObject = waiters[indexPath.row]
            cell?.textLabel?.text = "Name: \(waiter.displayName!)  | Username: \(waiter.username!)  | Password: \(waiter.password!)"
            return cell!
        }
    }
    

    
    // deleting accounts
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let confirm = UIAlertAction(title: "Confirm", style: .destructive) { (UIAlertAction) in
            
            if tableView == self.tableView{
                // find the value key in firebase
                self.restaurantRef.child(self.userID!).child("accounts").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snap = snapshot.value as? NSDictionary{
                        for (key,values) in snap {
                            let account = values as! NSDictionary
                            let w:WaiterObject = self.waiters[indexPath.row]
                            if (account.isEqual(w.ConvertToDictionary())){
                                self.waiters.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
                                self.restaurantRef.child(self.userID!).child("accounts").child(key as! String).removeValue()
                                break
                            }
                        }
                    }
                })
            }else{
                self.restaurantRef.child(self.userID!).child("tables").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snap = snapshot.value as? NSDictionary{
                        for (key,values) in snap {
                            let account = values as! NSDictionary
                            let tableName = account["tableName"] as! String
                            let w:TableClass = self.tables[indexPath.row]
                            if (tableName == w.tableName){
                                self.tables.remove(at: indexPath.row)
                                self.tablesTableView.deleteRows(at: [indexPath], with: .fade)
                                self.restaurantRef.child(self.userID!).child("tables").child(key as! String).removeValue()
                                break
                            }
                        }
                    }
                })
            }
        }
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
        
    }

    // table management
    
    @IBAction func createTable(_ sender: UIButton) {
        let popup = UIAlertController(title: "Create table", message: "Create a restaurant table", preferredStyle: .alert)
        popup.addTextField{(textField) in
            textField.placeholder = "Table name"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let create = UIAlertAction(title: "Create", style: .default) { (UIAlertAction) in
            let tableName = popup.textFields![0].text
            if tableName!.count > 0 {
                let newTable = TableClass(tableName: tableName!, waiter: "")
                self.restaurantRef.child(self.userID!).child("tables").childByAutoId().setValue(newTable.convertToDictionary())
            }
        }
        popup.addAction(cancel)
        popup.addAction(create)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    
    
}


