//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by MAC on 14.11.2020.
//  Copyright © 2020 Litmax All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add category", message: "Write", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newItem = Category(context: self.context)
            newItem.name = textField.text
            self.categoryArray.append(newItem)
            
            self.saveItems()
        }
        alert.addTextField { (text) in
            textField = text
        }
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
        }
    
    //MARK: TableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let item = categoryArray[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    //MARK: TableViewDataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: DataManipulation
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(from request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error: \(error)")
            //Some comments
        }
        tableView.reloadData()
    }
    
}
