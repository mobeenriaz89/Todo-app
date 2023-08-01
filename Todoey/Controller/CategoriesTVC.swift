//
//  CategoriesTVC.swift
//  Todoey
//
//  Created by Mobeen Riaz on 29/07/2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesTVC: SwipeableTVC {
    
    let realm = try! Realm()
    var categoriesList: Results<CategoryDataModel>!
    let appearance = UINavigationBarAppearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarAppearance(with: UIColor.randomFlat())
        fetchCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchCategories()
    }
    
    func setNavBarAppearance(with color: UIColor){
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance =  navigationController?.navigationBar.standardAppearance
        navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
    }
    
    //MARK: -DATA MANIPULATION
    
    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default){ action in
            let category = CategoryDataModel()
            category.name = textField.text!
            category.bgColour = UIColor.randomFlat().hexValue()
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
        if categoriesList.count > 0, let color = UIColor(hexString: categoriesList[0].bgColour ?? "000000"){
            setNavBarAppearance(with: color)
        }
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
        if let color = UIColor(hexString: categoriesList[indexPath.row].bgColour ?? "ffffff"){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromCollecition", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        if let color = UIColor(hexString: categoriesList[indexPath.row].bgColour ?? "000000"){
            setNavBarAppearance(with: color)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! ItemsTVC
        if let indexPath = tableView.indexPathForSelectedRow {
            vc.selectedCategory =  categoriesList[indexPath.row]
        }
    }
}

