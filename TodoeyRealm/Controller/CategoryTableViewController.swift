//
//  CategoryTableViewController.swift
//  TodoeyRealm
//
//  Created by Arif Demirkoparan on 1.03.2023.
//

import UIKit
import RealmSwift


class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var category:Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editNavigationBar()
        load()
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)
    }
    
    func load() {
        category = realm.objects(Category.self)
        category = category?.sorted(byKeyPath: "date", ascending: true)
    }
    
    func editNavigationBar() {
        let apperance = UINavigationBarAppearance()
        apperance.backgroundColor = UIColor.systemBlue
        apperance.titleTextAttributes = [
            .font:UIFont(name: "Palatino Bold", size: 22)!,
            .foregroundColor:UIColor.darkText]
        navigationController?.navigationBar.scrollEdgeAppearance = apperance
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC  = segue.destination as! ItemTableViewController
        if  let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = category?[indexPath.row]
        }else {
            print("İndexPath:Data Not Loaded")
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        alert.addTextField { categoryTextfiled in
            textfield = categoryTextfiled
        }
        
        let backButton = UIAlertAction(title: "Back", style: .destructive) { backButton in
            self.dismiss(animated: true)
        }
        
        let button = UIAlertAction(title: "Add", style: .default) { addButton in
            let newCategory = Category()
            newCategory.title = textfield.text!
            newCategory.date = Date()
            do{
                try self.realm.write {
                    self.realm.add(newCategory)
                }
            }catch{
                print("Error \(error.localizedDescription)")
            }
            self.tableView.reloadData()
        }
        alert.addAction(backButton)
        alert.addAction(button)
        present(alert, animated: true)
        
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.count  ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var context = cell.defaultContentConfiguration()
        if   let  category = category?[indexPath.row]  {
            context.text = category.title
            context.textProperties.color = UIColor.darkText
            context.textProperties.font = UIFont(name: "Palatino Bold", size: 18)!
            
        }else {
            context.text = "Data Not Loaded"
            context.textProperties.color = UIColor.darkText
            context.textProperties.font = UIFont(name: "Palatino Bold", size: 18)!
        }
        cell.contentConfiguration = context
        return cell
    }
    
    // MARK: - Table view data Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItem", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let update  = UIContextualAction(style: .normal, title: "Update", handler: {action,actionView,actionBool  in
            var textfield = UITextField()
            let alert = UIAlertController(title: "Update Category", message: "", preferredStyle: .alert)
            alert.addTextField { updateTextfiled in
                textfield = updateTextfiled
            }
            let backButton = UIAlertAction(title: "Back", style: .destructive) { backButton in
                self.dismiss(animated: true)
            }
            let updateButton = UIAlertAction(title: "Update", style: .default) { updateButton in
                do {
                    try self.realm.write({
                        if   let updateCategory = self.category?[indexPath.row] ,let textfield = textfield.text {
                            updateCategory.title  = textfield
                            self.realm.add(updateCategory)
                        }
                    })
                }catch{
                    print("Update error \(error.localizedDescription)")
                }
                tableView.reloadData()
            }
            alert.addAction(backButton)
            alert.addAction(updateButton)
            self.present(alert, animated: true)
        })
        update.backgroundColor = UIColor.darkGray
        let delete  = UIContextualAction(style: .destructive, title: "Delete", handler: {action,actionView,actionBool  in
            do {
                try self.realm.write({
                    if let deleteCategory = self.category?[indexPath.row] {
                        self.realm.delete(deleteCategory)
                    }
                })
            }catch{
                print("Delete error \(error.localizedDescription)")
            }
            tableView.reloadData()
        })
        delete.backgroundColor = UIColor.orange
        
        let swipe = UISwipeActionsConfiguration.init(actions: [update,delete])
        return swipe
    }
}
