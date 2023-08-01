//
//  ItemsTVC.swift
//  Todoey
//
//  Created by Mobeen Riaz on 29/07/2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemsTVC: SwipeableTVC, UISearchBarDelegate{
    
    let realm = try! Realm()
    var itemsList: Results<ItemDataModel>?
    @IBOutlet weak var searchbar: UISearchBar!

    var selectedCategory = CategoryDataModel(){
        didSet{
            fetchItems()
            title = selectedCategory.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSearchBarColor()
    }
    
    func setSearchBarColor(){
        if let color = selectedCategory.bgColour{
            searchbar.barTintColor = UIColor(hexString: color)
            searchbar.searchTextField.textColor = ContrastColorOf(UIColor(hexString: color) ?? .black, returnFlat: true)
            searchbar.searchTextField.leftView?.tintColor = ContrastColorOf(UIColor(hexString: color) ?? .black, returnFlat: true)
            searchbar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search item here...", attributes: [NSAttributedString.Key.foregroundColor : ContrastColorOf(UIColor(hexString: color) ?? .black, returnFlat: true)])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default){ action in
            if let text = textField.text, !text.isEmpty{
                let item = ItemDataModel()
                item.name = text
                item.isChecked = false
                item.dateAdded = Date()
                self.addNewItem(for: item)
                self.tableView.reloadData()
            }
        }
        alert.addTextField{ tf in
            tf.placeholder = "Item name here"
            textField = tf
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
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
                cell.tintColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            fetchItems()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty{
            itemsList = itemsList?.filter("name CONTAINS[cd] %@", query)
            tableView.reloadData()
        }
    }
        
    
}
