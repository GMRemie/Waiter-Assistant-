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
    
    override func viewDidLoad() {
        super.viewDidLoad()

       button_register.layer.cornerRadius = 20
    }
    


}
