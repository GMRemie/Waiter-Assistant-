//
//  MenuClass.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/23/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
import UIKit
class MenuClass{
    
    var name: String?
    var image: String?
    
    func ConvertToDictionary() -> Dictionary<String, Any>{
        var returnDictionary = Dictionary<String, Any>()
        returnDictionary["name"] = self.name
        returnDictionary["image"] = self.image
        
        return returnDictionary
    }
    
    init(name: String, image:String){
        
        self.name = name
        self.image = image
    }

}
