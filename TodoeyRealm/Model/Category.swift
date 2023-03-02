//
//  RealmData.swift
//  TodoeyRealm
//
//  Created by Arif Demirkoparan on 1.03.2023.
//

import Foundation
import RealmSwift

class Category:Object{
    
    @objc dynamic  var title:String = ""
    @objc dynamic var date:Date?
    var items = List<Item>()
   
   
}
