//
//  ArchivedViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/31/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class ArchivedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    // Firebase references
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    let storage = Storage.storage().reference()
    let userID = Auth.auth().currentUser?.uid
    
    
    // archived orders
    var orders = [Order]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantRef.child(userID!).child("archives").observe(.value) { (snapshot) in
            if let snapDict = snapshot.value as? NSDictionary{
                self.reloadTable(snapshot: snapDict)
            }
        }
        
    }
    
    func reloadTable(snapshot: NSDictionary){
        for (key,values) in snapshot{
            let newValues = values as! NSDictionary
            let status = newValues["status"] as! String
            let vOrders = newValues["orders"] as! String
            let notes = newValues["notes"] as! String
            let cost = newValues["cost"] as! String
            let tableid = newValues["tableid"] as! String
            let tablename = newValues["tablename"] as! String
            orders.append(Order(status: status, orders: vOrders, notes: notes, cost: cost, tablename: tablename, tablepath: tableid))
        }
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let o = orders[indexPath.row]
        let info = UIAlertController(title: o.tableName, message: o.orders, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Continue", style: .default)
        info.addAction(confirm)
        self.present(info, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_order")
        cell?.textLabel?.text = "\(orders[indexPath.row].tableName!) - \(orders[indexPath.row].orders!)"
        return cell!
    }
}
