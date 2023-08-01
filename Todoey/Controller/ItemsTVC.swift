//
//  ItemsTVC.swift
//  Todoey
//
//  Created by Mobeen Riaz on 29/07/2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemsTVC: SwipeableTVC {
    
    let realm = try! Realm()
    var itemsList: Results<ItemDataModel>?
    
    var selectedCategory = CategoryDataModel(){
        didSet{
            fetchItems()
            title = selectedCategory.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default){ action in
            let item = ItemDataModel()
            item.name = textField.text!
            item.isChecked = false
            item.dateAdded = Date()
            self.addNewItem(for: item)
            self.tableView.reloadData()
        }
        alert.addTextField{ tf in
            tf.placeholder = "Item name here"
            textField = tf
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    func fetchItems(){
        self.itemsList = selectedCategory.itemsList.sorted(byKeyPath: "dateAdded", ascending: true)
        tableView.reloadData()
    }
    
    func addNewItem(for item: ItemDataModel){
        do{
            try realm.write({
                self.selectedCategory.itemsList.append(item)
            })
        } catch{
            print("Error adding new category: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = itemsList?[indexPath.row] {
            cell.textLabel?.text = item.name
            cell.accessoryType = item.isChecked ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory.bgColour ?? "ffffff"){
                let percentage =  Float(indexPath.row)/Float(itemsList?.count ?? 1)
                cell.backgroundColor = color.lighten(byPercentage: CGFloat(percentage))
                cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items added yet"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemsList?[indexPath.row] {
            do{
                try realm.write({
                    item.isChecked = !item.isChecked
                    tableView.reloadData()
                })
            }catch {
                print("Error selecting item: \(error)")
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    override func updateModel(for indexPath: IndexPath) {
        if let item = itemsList?[indexPath.row]{
            do{
                try realm.write({
                    realm.delete(item)
                })
            }catch {
                print("Error deleting item : \(error)")
            }
        }
    }
    
}
