//
//  WAITER_CartViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/31/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class WAITER_CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Firebase references
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    
    var managerID: String = ""
    var waiterID: String = ""
    var tableName:String = ""
    var tablePath: String = ""

    //UI variables
    @IBOutlet weak var cartTable: UITableView!
    @IBOutlet weak var ordersTable: UITableView!
    @IBOutlet weak var label_Header: UILabel!
    @IBOutlet weak var button_AddItem: UIButton!
    
    //cart items
    var cartItems = [ItemClass]()

    // previous orders
    var orders = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // update header
        label_Header.text = tableName
        
        // customize our ui button
        button_AddItem.layer.cornerRadius = 10
        // observe method for cart additions
        restaurantRef.child(managerID).child("tables").child(tablePath).child("cart").observe(.value) { (snapshot) in
            if let snapdata = snapshot.value as? NSDictionary{
                self.reloadCart(snapdata: snapdata)
            }
        }
        restaurantRef.child(managerID).child("orders").observe(.value){ (snapshot) in
            if let snapdata = snapshot.value as? NSDictionary{
                self.reloadOrders(snapdata: snapdata)
            }
        }
    }
    
    func reloadOrders(snapdata: NSDictionary){
        orders.removeAll()
        for (key, values) in snapdata{
            let newValues = values as! NSDictionary
            let status = newValues["status"] as! String
            let vOrders = newValues["orders"] as! String
            let notes = newValues["notes"] as! String
            let cost = newValues["cost"] as! String
            let tableid = newValues["tableid"] as! String
            let tablename = newValues["tablename"] as! String
            if status == "Delivered" && self.tablePath == tableid{
                orders.append(Order(status: status, orders: vOrders, notes: notes, cost: cost, tablename: tablename, tablepath: tableid))
            }
        }
        ordersTable.reloadData()
    }
    
    func reloadCart(snapdata: NSDictionary){
        cartItems.removeAll()
        for (key,values) in snapdata{
            let newValues = values as! NSDictionary
            let name = newValues["name"] as! String
            let price = newValues["price"] as! String
            cartItems.append(ItemClass(name: name, price: price, description: ""))
        }
        cartTable.reloadData()
    }
    
    

    @IBAction func AddItem(_ sender: UIButton) {
        // do nothing
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WAITER_MenuViewController{
            vc.managerID = managerID
            vc.waiterUid = waiterID
            vc.tableName = tableName
            vc.tablePath = tablePath
        }
    }
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func SubmitOrder(_ sender: UIButton) {
        if cartItems.count > 0{
            var newOrder = Order(status: "Ordered", orders: "", notes: "", cost: "", tablename: tableName, tablepath: tablePath)
            newOrder.compileOrders(items: cartItems)
            
            // push data then clear array.
            restaurantRef.child(managerID).child("orders").childByAutoId().setValue(newOrder.convertToDict())
            cartItems.removeAll()
            restaurantRef.child(managerID).child("tables").child(tablePath).child("cart").removeValue()
            cartTable.reloadData()

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cartTable{
            return cartItems.count
        }else{
            return orders.count
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cartTable{
            let alert = UIAlertController(title: "Remove from list", message: "Are you sure you want to remove from list?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
                
                self.restaurantRef.child(self.managerID).child("tables").child(self.tablePath).child("cart").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snap = snapshot.value as? NSDictionary{
                        for (key,values) in snap {
                            let cart = values as! NSDictionary
                            let tableName = cart["name"] as! String
                            if (tableName == self.cartItems[indexPath.row].name){
                                self.cartItems.remove(at: indexPath.row)
                                self.cartTable.deleteRows(at: [indexPath], with: .fade)
                                self.restaurantRef.child(self.managerID).child("tables").child(self.tablePath).child("cart").child(key as! String).removeValue()
                                break
                            }
                        }
                    }
                })
                
                
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }else{
            // orders selected
            let alert = UIAlertController(title: "Archive", message: "Would you like to archive this order?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let confirm = UIAlertAction(title: "Confirm", style: .default) { (UIAlertAction) in
                // Insertting at the same time!
                self.restaurantRef.child(self.managerID).child("archives").childByAutoId().setValue(self.orders[indexPath.row].convertToDict())
                
                self.restaurantRef.child(self.managerID).child("orders").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapdict = snapshot.value as? NSDictionary{
                        for (key,values) in snapdict{
                            let newValues = values as! NSDictionary
                            let orderInfo = newValues["orders"] as! String
                            let tablePath = newValues["tableid"] as! String
                            if self.orders[indexPath.row].orders == orderInfo && self.orders[indexPath.row].tablePath == tablePath{
                                self.restaurantRef.child(self.managerID).child("orders").child(key as! String).removeValue()
                                self.orders.remove(at: indexPath.row)
                                self.ordersTable.reloadData()
                            }
                        }
                    }
                })
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == cartTable{
            let cell = cartTable.dequeueReusableCell(withIdentifier: "cell_cart")
            let item = cartItems[indexPath.row]
            cell?.textLabel?.text = "$\(item.price!)|  \(item.name!)"
            return cell!

            
        }else{
            let cell = ordersTable.dequeueReusableCell(withIdentifier: "cell_orders")
            cell?.textLabel?.text = orders[indexPath.row].orders
            return cell!
        }
    }
}
