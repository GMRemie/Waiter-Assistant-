//
//  MenuPopupViewController.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/23/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class MenuPopupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var field_name: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button_confirm: UIButton!
    @IBOutlet weak var button_cancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        button_cancel.layer.borderWidth = 2
        let blueColor: CGColor = (button_cancel.titleColor(for: .normal)?.cgColor)!
        button_cancel.layer.borderColor = blueColor
    }
    

    
    @IBAction func chooseImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose an image", preferredStyle: .alert)
        
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = self.view.bounds
        
    
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func button_confirm(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
    
    @IBAction func button_Cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
