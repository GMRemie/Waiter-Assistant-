//
//  WaiterObject.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/29/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation

class WaiterObject{
    
    
    var displayName: String?
    var username: String?
    var password: String?
    
    func ConvertToDictionary() -> Dictionary<String, Any>{
        var dictionary = Dictionary<String,Any>()
        dictionary["displayname"] = displayName! as String
        dictionary["username"] = username! as String
        dictionary["password"] = password! as String
        return dictionary
    }
    
    init(name:String,password:String,display:String){
        self.displayName = display
        self.username = name
        self.password = password
    }
}
