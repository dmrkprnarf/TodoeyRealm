//
//  Item.swift
//  TodoeyRealm
//
//  Created by Arif Demirkoparan on 1.03.2023.
//

import Foundation
import RealmSwift

class Item:Object{
    @objc dynamic var name:String = ""
    @objc dynamic var done:Bool = false
    @objc dynamic var ıtemDate:Date?
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
   
    
}
