//
//  TableClass.swift
//  Waiter Assistant
//
//  Created by Joseph Storer on 1/30/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import Foundation

class TableClass{
    
    var tableName: String?
    var waiter: String?
    
    func convertToDictionary() -> Dictionary<String,Any>{
        var tableDict = Dictionary<String,Any>()
        tableDict["tableName"] = tableName as! String
        tableDict["waiter"] = waiter as! String
        return tableDict
    }
    
    init(tableName: String,waiter: String){
        self.tableName = tableName
        self.waiter = waiter
    }
}
