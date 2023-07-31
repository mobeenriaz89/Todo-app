//
//  ItemDataModel.swift
//  Todoey
//
//  Created by Mobeen Riaz on 30/07/2023.
//

import Foundation
import RealmSwift

class ItemDataModel: Object{
    
    @objc dynamic var name: String?
    @objc dynamic var isChecked = false
    @objc dynamic var dateAdded: Date?
    var parentCategory = LinkingObjects(fromType: CategoryDataModel.self, property: "itemsList")
    
}
