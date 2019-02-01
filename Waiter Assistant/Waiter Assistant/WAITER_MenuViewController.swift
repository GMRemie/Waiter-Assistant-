//
//  WAITER_MenuViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/31/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class WAITER_MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
 


    //firebase references
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    
    // segue data paths
    var managerID: String = ""
    var waiterUid: String = ""
    var tableName:String = ""
    var tablePath: String = ""

    //Loaded menus
    var menues = [MenuClass]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label_Header: UILabel!
    
    // selected A Menu
    var selectedMenu: MenuClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        restaurantRef.child(managerID).child("menu").observe(.value) { (snapshot) in
            if let snap = snapshot.value as? NSDictionary{
                self.reloadCategories(snapdata: snap)
            }
        }
        
    }
    func reloadCategories(snapdata: NSDictionary){
        menues.removeAll()
        for (_,values) in snapdata{
            let newValues = values as! NSDictionary
            let name = newValues["name"] as! String
            let Menu = MenuClass(name: name, image: "")
            self.loadMenuItems(menu: Menu)
            self.menues.append(Menu)
        }
        self.tableView.reloadData()
    }
    func loadMenuItems(menu: MenuClass){
        //clear our menu list first
        menu.items.removeAll()
        
        // observe firebase and get all menues data
        let menuPath = restaurantRef.child(managerID).child("menu").child(menu.name!).child("items")
        
        menuPath.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                for (_,values) in value{
                    let newItemValues = values as! NSDictionary
                    // load our correct data
                    let name = newItemValues["name"] as! String
                    let price = newItemValues["price"] as! String
                    let description = newItemValues["description"] as! String
                    menu.items.append(ItemClass(name: name, price: price, description: description))
                }
                
                
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu_list") as! MenuTableViewCell
        cell.label_Name.text = menues[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMenu = menues[indexPath.row]
        label_Header.text = selectedMenu?.name!
        collectionView.reloadData()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedMenu != nil{
            print("returning \((selectedMenu?.items.count)!)")
            return (selectedMenu?.items.count)!
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_Item", for: indexPath) as? ShopCollectionViewCell
        cell?.label_Name.text = selectedMenu?.items[indexPath.row].name
        cell?.tag = indexPath.row
        cell?.infoButton.addTarget(self, action: #selector(btnInfo(sender:)), for: .touchUpInside)
        return cell!
    }
    
    @objc public func btnInfo(sender: UIButton){
        let alert = UIAlertController(title: selectedMenu?.items[sender.tag].name, message: "$\(selectedMenu!.items[sender.tag].price!). \(selectedMenu!.items[sender.tag].description!)", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Continue", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        restaurantRef.child(managerID).child("tables").child(tablePath).child("cart").childByAutoId().setValue(selectedMenu?.items[indexPath.row].ConvertToDictionary())
    }
    
    
}
