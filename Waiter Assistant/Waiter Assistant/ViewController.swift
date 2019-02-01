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
    
    // Waiter authentication data
    var managerString:String = ""
    var waiterUID:String = ""
    var waiterName:String = ""
    
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
        
        self.managerString = ""
        self.waiterUID = ""
        
        if !(form_username.text?.contains("@"))! {
            print("Attempting signin as waiter")
            waiterLogin(user: form_username.text!, pass: form_password.text!)
            return
        }
        
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
    
    // Handle waiter authentication
    func waiterLogin(user:String,pass:String){
        restaurantRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapdict = snapshot.value as? NSDictionary{
                
                for (key,values) in snapdict {
                    let newValues = values as! NSDictionary
                    if let accounts = newValues["accounts"] as? NSDictionary{
                        
                        
                        for (wUid,values) in accounts{
                            let accountDetails = values as! NSDictionary
                            let username = accountDetails["username"] as! String
                            let password = accountDetails["password"] as! String
                            let displayName = accountDetails["displayname"] as! String
                            if (user == username) && (pass == password){
                                print("Login success!")
                                self.managerString = key as! String
                                self.waiterUID = wUid as! String
                                self.waiterName = displayName
                                self.performSegue(withIdentifier: "segue_Waiter", sender: self)
                                break
                            }
                        }
                    }
                }
            }
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UITabBarController{
            if let top = vc.viewControllers![0] as? WAITER_TableViewController{
                top.managerID = self.managerString
                top.waiterUid = self.waiterUID
                top.waiterName = self.waiterName
            }
            if let orders = vc.viewControllers![1] as? WAITER_OrdersViewController{
                orders.managerID = self.managerString
                orders.waiterUid = self.waiterUID
            }
        }
    }


}

