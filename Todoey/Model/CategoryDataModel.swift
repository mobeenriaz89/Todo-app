//
//  CategoryDataModel.swift
//  Todoey
//
//  Created by Mobeen Riaz on 30/07/2023.
//

import Foundation
import RealmSwift

class CategoryDataModel: Object {
    @objc dynamic var name: String?
    var itemsList = List<ItemDataModel>()
}
