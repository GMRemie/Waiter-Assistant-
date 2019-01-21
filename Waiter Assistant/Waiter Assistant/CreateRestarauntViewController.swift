//
//  CreateRestarauntViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class CreateRestarauntViewController: UIViewController {

    @IBOutlet weak var form_restarauntName: UITextField!
    @IBOutlet weak var button_register: UIButton!
    
    let rootRef = Database.database().reference()
    let restaurantRef = Database.database().reference(withPath: "created-restaurants")
    
    override func viewDidLoad() {
        super.viewDidLoad()

       button_register.layer.cornerRadius = 20
    }
    
    @IBAction func button_CreateRestaurant(_ sender: UIButton) {
        // check to make sure user is signed in
        if let user = Auth.auth().currentUser{
            let ownerID: String = user.uid

            self.restaurantRef.child(ownerID).setValue(["name": form_restarauntName.text!])

            
            let alert = UIAlertController.init(title: "Success", message: "Restaurant has been created successfully!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
            }))
            
        }
    }
    

}
