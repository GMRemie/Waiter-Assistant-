//
//  Order.swift
//  
//
//  Created by Joseph Storer on 1/31/19.
//

import Foundation

class Order{
    
    var status: String?
    var orders: String?
    var notes: String?
    var cost: String?
    var tableName: String?
    var tablePath: String?
    
    func compileOrders(items: [ItemClass]){
        var retString: String = "ORDERS: "
        for (item) in items{
            retString.append("\(item.name!)|| ")
        }
        orders = retString
    }
    func calculateCost(items: [ItemClass]){
        var mathArray = [String]()
        for(item) in items{
            mathArray.append(item.price!)
        }
        
        
    }
    
    func convertToDict() -> Dictionary<String, Any>{
        var retDict = Dictionary<String,Any>()
        retDict["status"] = status as! String
        retDict["orders"] = orders as! String
        retDict["notes"] = notes as! String
        retDict["cost"] = cost as! String
        retDict["tableid"] = tablePath as! String
        retDict["tablename"] = tableName as! String
        return retDict
    }
    
    
    
    
    init(status:String,orders:String,notes:String,cost:String,tablename: String,tablepath:String) {
        self.status = status
        self.orders = orders
        self.notes = notes
        self.cost = cost
        self.tableName = tablename
        self.tablePath = tablepath
    }
    
    
    
}
