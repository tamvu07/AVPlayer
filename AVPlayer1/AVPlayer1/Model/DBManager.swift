//
//  DBManager.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 5/5/21.
//

import Foundation
import RealmSwift

class Item: Object {
   
    @objc dynamic var url:String = ""
    @objc dynamic var name:String = ""
    @objc dynamic var imageName:String = ""
}


class DBManage {
    private var database:Realm
    
    static let sharedInstance = DBManage()
    
    private init()
    {
        database = try! Realm()
    }
    
    func getDataFromDB() -> Results<Item> {
        let result: Results<Item> = database.objects(Item.self)
        return result
    }
    
    func addData(object: Item) {
        try! database.write{
            database.add(object)
        }
    }
    
    func deleteAllFromDB() -> Bool {
        do {
            try database.write{
                database.deleteAll()
            }
            return true
        }
        catch {
            return false
        }
    }
}
