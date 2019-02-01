//
//  WAITER_OrdersViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/31/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class WAITER_OrdersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
 

    //firebase references
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    
    // segue data paths
    var managerID: String = ""
    var waiterUid: String = ""

    
    var orders = [Order]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantRef.child(managerID).child("orders").observe(.value){ (snapshot) in
            if let snapdata = snapshot.value as? NSDictionary{
                self.reloadData(snapshot: snapdata)
            }
        }
    }
    
    func reloadData(snapshot: NSDictionary){
        orders.removeAll()
        for (key, values) in snapshot{
            let newValues = values as! NSDictionary
            let status = newValues["status"] as! String
            let vOrders = newValues["orders"] as! String
            let notes = newValues["notes"] as! String
            let cost = newValues["cost"] as! String
            let tableid = newValues["tableid"] as! String
            let tablename = newValues["tablename"] as! String
            if status == "Ordered"{
                orders.append(Order(status: status, orders: vOrders, notes: notes, cost: cost, tablename: tablename, tablepath: tableid))
            }
        }
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_order", for: indexPath) as? OrderCollectionViewCell
        cell?.status_label.text = orders[indexPath.row].status
        cell?.tableName.text = orders[indexPath.row].tableName
        cell?.order_info.text = orders[indexPath.row].orders
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOrder = orders[indexPath.row]
        let alert = UIAlertController(title: selectedOrder.tableName, message: selectedOrder.orders!, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let deliver = UIAlertAction(title: "Deliver", style: .default) { (UIAlertAction) in
            self.restaurantRef.child(self.managerID).child("orders").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapDict = snapshot.value as? NSDictionary{
                    for (key,values) in snapDict{
                        let newValues = values as! NSDictionary
                        let orderinfo = newValues["orders"] as! String
                        if orderinfo == selectedOrder.orders {
                            self.restaurantRef.child(self.managerID).child("orders").child(key as! String).updateChildValues(["status": "Delivered"])
                            self.orders.remove(at: indexPath.row)
                            self.collectionView.reloadData()
                            return
                        }
                    }
                }
            })
            
        }
        alert.addAction(cancel)
        alert.addAction(deliver)
        self.present(alert, animated: true, completion: nil)
    }
    
}
