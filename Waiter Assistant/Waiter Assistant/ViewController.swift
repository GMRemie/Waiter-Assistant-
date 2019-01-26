//
//  ViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/14/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController {

    
    @IBOutlet weak var form_username: UITextField!
    @IBOutlet weak var form_password: UITextField!
    
    @IBOutlet weak var btn_signIn: UIButton!
    @IBOutlet weak var btn_signUp: UIButton!
    
    // path to our db
    var restaurantRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Updating our Sign In & Sign Up buttons. We're rounding the corners
        btn_signIn.layer.cornerRadius = 20
        btn_signUp.layer.cornerRadius = 20
        btn_signUp.layer.borderWidth = 1
        let blueColor: CGColor = (btn_signUp.titleColor(for: .normal)?.cgColor)!
        btn_signUp.layer.borderColor = blueColor
        
      restaurantRef = Database.database().reference(withPath: "created-restaurants")
        
    }
    
    
    @IBAction func SignIn(_ sender: UIButton) {
        if form_username == nil { return }
        if form_password == nil { return }
        
        
        Auth.auth().signIn(withEmail: form_username.text!, password: form_password.text!){ user, error in
            
            if error == nil && user != nil {
               
                let userID = user!.user.uid
                self.restaurantRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let restaurantName = value?["name"] as? String ?? ""
                    if restaurantName != ""{
                        // has a restaraunt. Take them to home screen
                        self.performSegue(withIdentifier: "segue_Menu", sender: self)
                    }else{
                        //create a new restaraunt!
                        self.performSegue(withIdentifier: "segue_CreateRestaurant", sender: self)
                        
                    }
                    
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
                
            }else{
                let alert = UIAlertController.init(title: "Error", message: "Error signing in, please try again.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.form_username.text = ""
                    self.form_password.text = ""
                }))
                self.present(alert, animated: true)
                
            }
            
            
        }
        
        
        
        
    }
    
    
    


}

