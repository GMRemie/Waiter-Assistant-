//
//  WAITER_TableViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/31/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class WAITER_TableViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // Firebase references
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    
    
    var managerID: String = ""
    var waiterUid: String = ""
    var waiterName: String = ""
    // collection data
    var tables = [TableClass]()
    
    // segue data to pass on
    var selectedTableName:String = ""
    var selectedTablePath:String = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Loaded WAITER | \(managerID) | \(waiterUid)")
        restaurantRef.child(managerID).child("tables").observe(.value) { (snapshot) in
            if let snapData = snapshot.value as? NSDictionary{
                self.refreshTable(snapshot: snapData)
            }
        }
    }


    func refreshTable(snapshot: NSDictionary){
        tables.removeAll()
        for (key,values) in snapshot{
            let newValues = values as! NSDictionary
            let tName = newValues["tableName"] as! String
            let tWaiter = newValues["waiter"] as! String
            tables.append(TableClass(tableName: tName, waiter: tWaiter))
        }
        collectionView.reloadData()
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tables.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_Table", for: indexPath) as! TableCollectionViewCell
        cell.label_tableName.text = tables[indexPath.row].tableName
        cell.label_waiterName.text = tables[indexPath.row].waiter
        return cell
    }
    // writing thsi up here so i can easily see both
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WAITER_CartViewController{
            vc.managerID = self.managerID
            vc.waiterID = self.waiterUid
            vc.tableName = self.selectedTableName
            vc.tablePath = self.selectedTablePath
        }
        if let vc = segue.destination as? WAITER_OrdersViewController{
            print("loading")
            vc.managerID = self.managerID
            vc.waiterUid = self.waiterUid

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // compare, see if we already have it claimed
        if (tables[indexPath.row].waiter == waiterName){
            self.restaurantRef.child(self.managerID).child("tables").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapdata = snapshot.value as? NSDictionary{
                    for (key,values) in snapdata{
                        let newValues = values as! NSDictionary
                        let tableName = newValues["tableName"] as! String
                        if tableName == self.tables[indexPath.row].tableName{
                            self.selectedTablePath = key as! String
                            self.selectedTableName = tableName
                            self.performSegue(withIdentifier: "segue_Cart", sender: self)
                        }
                    }
                }
            })
            return
        }
        
        let alert = UIAlertController(title: "Claim table", message: "If you click confirm, this table will be claimed as yours", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (UIAlertAction) in
            self.restaurantRef.child(self.managerID).child("tables").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapdata = snapshot.value as? NSDictionary{
                    for (key,values) in snapdata{
                        let newValues = values as! NSDictionary
                        let tableName = newValues["tableName"] as! String
                        if tableName == self.tables[indexPath.row].tableName{
                            self.restaurantRef.child(self.managerID).child("tables").child(key as! String).updateChildValues(["waiter" : self.waiterName])
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
