//
//  MenuListViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class MenuListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var button_add: UIButton!
    @IBOutlet weak var view_topbar: UILabel!
    
    @IBOutlet weak var label_header: UILabel!
    
    @IBOutlet weak var tableVIew: UITableView!
    //Loaded menus
    var menues = [MenuClass]()
    
    // selected A Menu
    
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    let storage = Storage.storage().reference()
    let userID = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
       refreshDatabase()
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
        label_header.text = menues[indexPath.row].name
        print(menues[indexPath.row].name)
    }
    
    @IBAction func clicked_addButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segue_CreateMenu", sender: self)
       
        
    }
    
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
                    let dlURL = imgPath.downloadURL(completion: { (url, error) in
                        if error != nil{
                            
                        }else{
                            downloadURL = (url?.absoluteString)!
                            
                            let menuSave: MenuClass = MenuClass(name: (source?.field_name.text)!, image: downloadURL)
                            self.restaurantRef.child(self.userID!).child("menu").child((source?.field_name.text)!).setValue(menuSave.ConvertToDictionary())
                            print("Uploaded image and creating Menu-- \(source?.field_name.text!) + \(downloadURL)" )
                            self.refreshDatabase()
                        }
                    })
                    
                }
                    
                }
            }
        

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
                self.menues.append(Menu)
            }
            }
            //print(value!["name"])
           // let name: String = value!["name"] as! String
            //self.menues.append(MenuClass(name: name))
            print("Loading")
            //print(name)
            self.tableVIew.reloadData()

            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
            
    }
    // Creating Items
    @IBAction func button_CreateItem(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segue_CreateItem", sender: self)
    }
    
    
    
    
}
