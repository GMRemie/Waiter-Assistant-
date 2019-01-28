//
//  MenuListViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class MenuListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var button_add: UIButton!
    @IBOutlet weak var view_topbar: UILabel!
    @IBOutlet weak var button_CreateItem: UIButton!
    
    
    @IBOutlet weak var label_header: UILabel!
    // reference to our data views (table view and collection view)
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //Loaded menus
    var menues = [MenuClass]()
    
    // selected A Menu
    var selectedMenu: MenuClass?
    
    // colors
    
    
    // Firebase references
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    let storage = Storage.storage().reference()
    let userID = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        button_CreateItem.layer.borderWidth = 2
        button_CreateItem.layer.cornerRadius = 10
        button_CreateItem.layer.borderColor = button_CreateItem.titleColor(for: .normal)?.cgColor
       refreshDatabase()
        
        // hide our create item button
        button_CreateItem.isHidden = true
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
        // update our text header
        button_CreateItem.isHidden = false
        label_header.text = menues[indexPath.row].name
        selectedMenu = menues[indexPath.row]
        collectionView.reloadData()
    }
    
    @IBAction func clicked_addButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segue_CreateMenu", sender: self)
       
        
    }
    // Unwinding from CreateMenu Segue
    @IBAction func UnwindToMain(segue: UIStoryboardSegue){
        let source = segue.source as? MenuPopupViewController
        let image: UIImage = (source?.imageView.image!)!
        let itemPath: String = (source?.field_name.text!)! + ".png"
        let imgPath = storage.child("Images").child("Menus").child(userID!).child(itemPath)
        var downloadURL: String = ""
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        
        if let image:UIImage = image{
            if let data = image.pngData(){
                
                let uploadTask = imgPath.putData(data, metadata: metaData )
                
                uploadTask.observe(.success) { snapshot in
                    print("Completed upload!")
                    // download url now
                    _ = imgPath.downloadURL(completion: { (url, error) in
                        if error != nil{
                            
                        }else{
                            downloadURL = (url?.absoluteString)!
                            
                            let menuSave: MenuClass = MenuClass(name: (source?.field_name.text)!, image: downloadURL)
                            self.restaurantRef.child(self.userID!).child("menu").child((source?.field_name.text)!).setValue(menuSave.ConvertToDictionary())
                            self.refreshDatabase()
                        }
                    })
                }
                }
            }
    }
    
    @IBAction func UnwindFromItemPopup(segue: UIStoryboardSegue){
        let source = segue.source as! CreateItemViewController
        let Item = ItemClass(name: source.field_name.text!, price: source.field_price.text!, description: source.field_description.text!)
        
        // update the firebase menu itself
        let uploadTask = restaurantRef.child(userID!).child("menu").child(selectedMenu!.name!).child("items").childByAutoId().setValue(Item.ConvertToDictionary())
        
        loadMenuItems(menu: selectedMenu!)
        collectionView.reloadData()
        
        
    }
    func refreshDatabase(){
        //Empty our menues array first
        menues.removeAll()
        
        // defining our user path so we can load all the appropriate data
        let userPath = restaurantRef.child(userID!).child("menu")
        
        userPath.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get value

            
            if let value = snapshot.value as? NSDictionary{
            
            
                for (key,values) in value {
                let newValues = values as! NSDictionary
                print(newValues["name"])
                let name = newValues["name"] as! String
                let image = newValues["image"] as! String
                let Menu: MenuClass = MenuClass(name: name, image: image)
                self.loadMenuItems(menu: Menu)
                self.menues.append(Menu)
            }
            }
            self.tableVIew.reloadData()

        }) { (error) in
            print(error.localizedDescription)
        }
            
    }
    // Load All pre-existing items to their correct menues
    func loadMenuItems(menu: MenuClass){
        //clear our menu list first
        menu.items.removeAll()
        
        // observe firebase and get all menues data
        let menuPath = restaurantRef.child(userID!).child("menu").child(menu.name!).child("items")
        
        menuPath.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                for (key,values) in value{
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
    
    
    
    
    // Creating Items
    @IBAction func button_CreateItem(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segue_CreateItem", sender: self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedMenu != nil{
            return (selectedMenu?.items.count)!
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_Item", for: indexPath) as! ItemCollectionViewCell
        cell.label_name.text = selectedMenu?.items[indexPath.row].name
        return cell
        
    }
    
    
    
}
