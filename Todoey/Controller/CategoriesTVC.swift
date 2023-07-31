//
//  CategoriesTVC.swift
//  Todoey
//
//  Created by Mobeen Riaz on 29/07/2023.
//

import UIKit
import RealmSwift

class CategoriesTVC: SwipeableTVC {
    
    let realm = try! Realm()
    var categoriesList: Results<CategoryDataModel>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategories()
    }
    
    //MARK: -DATA MANIPULATION
    
    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default){ action in
            let category = CategoryDataModel()
            category.name = textField.text!
            self.addCategory(for: category)
            self.tableView.reloadData()
        }
        alert.addTextField{ tf in
            tf.placeholder = "Category name here"
            textField = tf
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    
    private func addCategory(for category: CategoryDataModel){
        do{
            try realm.write({
                realm.add(category)
            })
        } catch{
            print("Error adding new category: \(error)")
        }
    }
    
    private func fetchCategories(){
        categoriesList = realm.objects(CategoryDataModel.self)
        tableView.reloadData()
    }
    
    private func deleteCategory(category: CategoryDataModel){
        do{
            try realm.write {
                realm.delete(category)
            }
        }catch{
            print("Error deleting category: \(error)")
        }
    }
    
    
    override func updateModel(for indexPath: IndexPath) {
        let cat = categoriesList[indexPath.row]
        deleteCategory(category: cat)
    }
    
    //MARK: -TABLE VIEW METHODS
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoriesList[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromCollecition", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! ItemsTVC
        if let indexPath = tableView.indexPathForSelectedRow {
            vc.selectedCategory =  categoriesList[indexPath.row]
        }
    }
}

