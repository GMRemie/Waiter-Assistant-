//
//  RestaurantClass.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation
class RestaurantClass {
    
    var name: String?
    var waiters: [String: String]?

    func toDictionary() -> Dictionary<String, Any>{
        var dictionaryRet = Dictionary<String,Any>()
        
        dictionaryRet["name"] = name
        dictionaryRet["waiters"] = waiters
        
        return dictionaryRet
    }

    init(name: String,waiters: [String: String]){
        self.name = name
        self.waiters = waiters
    }
}

