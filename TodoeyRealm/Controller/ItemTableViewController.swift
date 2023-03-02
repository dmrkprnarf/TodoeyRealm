//
//  ItemTableViewController.swift
//  TodoeyRealm
//
//  Created by Arif Demirkoparan on 1.03.2023.
//

import UIKit
import RealmSwift

class ItemTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var items:Results<Item>?
    var selectedCategory:Category? {
        didSet{
            load()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    func load() {
        items = selectedCategory?.items.sorted(byKeyPath: "ıtemDate", ascending: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        alert.addTextField { itemTextfield in
            textfield = itemTextfield
        }
        
        let backButton = UIAlertAction(title: "Back", style: .destructive) { backButton in
            self.dismiss(animated: true)
        }
        
        let addButton = UIAlertAction(title: "Add", style: .default) { addButton in
            if let selected = self.selectedCategory, let textfield = textfield.text {
                do {
                    try self.realm.write({
                        let newItems = Item()
                        newItems.ıtemDate = Date()
                        newItems.name = textfield
                        selected.items.append(newItems)
                        self.realm.add(newItems)
                    })
                }catch {
                    print("Error selectedCategory \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addAction(backButton)
        alert.addAction(addButton)
        present(alert, animated: true)
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        var context = cell.defaultContentConfiguration()
        if let item = items?[indexPath.row] {
            context.text = item.name
            context.textProperties.color = UIColor.darkText
            context.textProperties.font = UIFont(name: "Palatino Bold", size: 18)!
            cell.accessoryType = item.done ? .checkmark:.none
        }else {
            context.text = "Data Not Loaded"
            context.textProperties.color = UIColor.darkText
            context.textProperties.font = UIFont(name: "Palatino Bold", size: 18)!
        }
        cell.contentConfiguration = context
        return cell
    }
    
    // MARK: - Table view data delete
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        do{
            try realm.write({
                if let item = items?[indexPath.row] {
                    item.done = !item.done
                    realm.add(item)
                }
            })
        }catch {
            print("Error \(error.localizedDescription)")
        }
        tableView.reloadData()
        
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let alert = UIAlertController(title: "Update List", message: "", preferredStyle: .alert)
        let listUpdate = UIContextualAction(style: .normal, title: "Update", handler: {actionList,actionView,actionBool in
            var textfield = UITextField()
            alert.addTextField { listTextfiled in
                textfield = listTextfiled
            }
            let backButton = UIAlertAction(title: "Back", style: .destructive) { backButton in
                self.dismiss(animated: true)
            }
            let listUpdateButton = UIAlertAction(title: "List Update", style: .default) { listUpdateButtonAction in
                do {
                    try self.realm.write({
                        if  let listUpdate = self.items?[indexPath.row] , let textfiled = textfield.text {
                            listUpdate.name = textfiled
                            self.realm.add(listUpdate)
                        }
                    })
                }catch {
                    print("List Update Error \(error.localizedDescription)")
                }
                tableView.reloadData()
            }
            alert.addAction(backButton)
            alert.addAction(listUpdateButton)
            self.present(alert, animated: true)
        })
        listUpdate.backgroundColor = UIColor.darkGray
        let listDelete = UIContextualAction(style: .destructive, title: "Delete", handler: {actionList,actionView,actionBool in
            do {
                try self.realm.write({
                    if  let deleteList = self.items?[indexPath.row] {
                        self.realm.delete(deleteList)
                    }
                })
            }catch {
                
            }
            tableView.reloadData()
        })
        let swipe = UISwipeActionsConfiguration.init(actions: [listUpdate,listDelete])
        return swipe
    }
    
}
// MARK: - SearchBar Delegate
extension ItemTableViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "ıtemDate", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchiText: String) {
        if searchBar.text?.count == 0 {
            load()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
