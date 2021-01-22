//
//  AppDelegate.swift
//  ToDoList
//
//  Created by MAC on 09.11.2020.
//  Copyright © 2020 Litmax. All rights reserved.
//

import UIKit
import CoreData


class ToDoViewController: UITableViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate {
    
    var itemsArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadData()
            print("Funny comment")
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New note:", message: "Write", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text
            newItem.checkMark = false
            newItem.parent = self.selectedCategory
            self.itemsArray.append(newItem)
            
            self.saveData()
        }
        alert.addTextField { (text) in
            textField = text
        }
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = (item.checkMark == true) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemsArray[indexPath.row].checkMark.toggle()
        context.delete(itemsArray[indexPath.row])
        itemsArray.remove(at: indexPath.row)
        
        saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}

// MARK: SearchBar

extension ToDoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadData(from: request, with: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                self.resignFirstResponder()
            }
        }
    }
}

//MARK: TVDelegate

extension ToDoViewController {
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(from request: NSFetchRequest<Item> = Item.fetchRequest(), with predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parent.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    
}

