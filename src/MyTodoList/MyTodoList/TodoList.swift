//
//  TodoList.swift
//  MyTodoList
//
//  Created by Norberto Ortigoza on 8/7/15.
//  Copyright © 2015 Platzi. All rights reserved.
//

import UIKit

class TodoList: NSObject {

  var items: [TodoItem] = []
  
  override init() {
    super.init()
    loadItems()
  }
  
  private let fileURL: NSURL = {
    let fileManager = NSFileManager.defaultManager()
    let documentDirectoryURLs = fileManager.URLsForDirectory(.DocumentDirectory,
      inDomains: .UserDomainMask) as [NSURL]
    let documentDirectoryURL = documentDirectoryURLs.first!
    return documentDirectoryURL.URLByAppendingPathComponent("todolist.plist")
//    return documentDirectoryURL.URLByAppendingPathComponent("todolist.items")
  }()
  
  
  func addItem(item: TodoItem) {
    items.append(item)
    saveItems()
  }
  
  func saveItems() {
    print("saveItems")
    let itemsArray = items as NSArray
    //    if !itemsArray.writeToURL(fileURL, atomically: true) {
    //      print("No se pudo guardar la lista")
    //    } else {
    //      print("Lista guardada en \(fileURL)")
    //    }
    NSKeyedArchiver.archiveRootObject(itemsArray, toFile: self.fileURL.path!)
  }

  
  func loadItems() {
    //    if let itemsArray = NSArray(contentsOfURL: fileURL) as? [String] {
    //      items = itemsArray
    //    }
    if let itemsArray = NSKeyedUnarchiver.unarchiveObjectWithFile(self.fileURL.path!) as? NSArray {
      items = itemsArray as! [TodoItem]
    }
  }
  
  func getItem(index: Int) -> TodoItem {
    return items[index]
  }
  
  
}


extension TodoList : UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    let item = items[indexPath.row]
    
    cell.textLabel!.text = item.todo
    return cell
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    items.removeAtIndex(indexPath.row)
    saveItems()
    tableView.beginUpdates()
    tableView.deleteRowsAtIndexPaths([indexPath],
      withRowAnimation: UITableViewRowAnimation.Left)
    tableView.endUpdates()
  }
  
}











