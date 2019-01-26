//
//  MenuTableViewCell.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/25/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var label_Name: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
