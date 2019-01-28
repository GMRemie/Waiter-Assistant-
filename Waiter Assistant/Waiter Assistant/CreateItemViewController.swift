//
//  CreateItemViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/26/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit
import Firebase
class CreateItemViewController: UIViewController {

    @IBOutlet weak var button_cancel: UIButton!
    
    @IBOutlet weak var field_name: UITextField!
    @IBOutlet weak var field_price: UITextField!
    @IBOutlet weak var field_description: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // customize our button
        button_cancel.layer.borderWidth = 2
        let blueColor: CGColor = (button_cancel.titleColor(for: .normal)?.cgColor)!
        button_cancel.layer.borderColor = blueColor
        
    }
    
    @IBAction func cancel_button(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func button_create(_ sender: UIButton) {
        // handle errors etc here
        
        self.performSegue(withIdentifier: "segue_UnwindItem", sender: self)
    }
    
}
