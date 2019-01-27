//
//  ItemClass.Swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/27/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation


class ItemClass{
    
    var name: String?
    var price: String?
    var description: String?
    
    
    func ConvertToDictionary() -> Dictionary<String, Any>{
        var returnDictionary = Dictionary<String,Any>()
        
        returnDictionary["name"] = name!
        returnDictionary["price"] = price!
        returnDictionary["description"] = description!
        return returnDictionary
    }
    
    
    init(name: String, price: String, description: String){
        self.name = name
        self.price = price
        self.description = description
        
    }
}
