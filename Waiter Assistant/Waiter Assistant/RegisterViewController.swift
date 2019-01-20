//
//  RegisterViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/16/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var field_username: UITextField!
    @IBOutlet weak var field_password: UITextField!
    @IBOutlet weak var field_confirmPassword: UITextField!
    @IBOutlet weak var btn_register: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Smoothing the edges on the buttons
        btn_register.layer.cornerRadius = 20
        // SMoothing the fields too!
        field_username.layer.cornerRadius = 20
        field_password.layer.cornerRadius = 20
        field_confirmPassword.layer.cornerRadius = 20

    }

    @IBAction func button_Register(_ sender: UIButton) {
        if field_username.text == nil { return }
        if field_password.text == nil { return }
        if field_confirmPassword == nil { return }
        
        // Check to see if the passwords match
        if field_password.text != field_confirmPassword.text {
            let alert = UIAlertController.init(title: "Error", message: "Passwords do not match!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.field_password.text = ""
                self.field_confirmPassword.text = ""
            }))
            self.present(alert, animated: true)
        }
        
        Auth.auth().createUser(withEmail: field_username.text!, password: field_password.text!){ user, error in
            
            if error == nil && user != nil{
                let alert = UIAlertController.init(title: "Success", message: "Account created successfully", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Complete", style: .default, handler: { action in
                    self.performSegue(withIdentifier: "segue_CreateRestaraunt", sender: self)
                }))
                self.present(alert, animated: true)
            } else{
                let alert = UIAlertController.init(title: "Error", message: "Error creating character, please try again", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true)

            }
        }
    }
    
    @IBAction func button_CloseView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
