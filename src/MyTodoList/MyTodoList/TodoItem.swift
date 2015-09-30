//
//  TodoItem.swift
//  MyTodoList
//
//  Created by Erick Camacho on 8/14/15.
//  Copyright © 2015 Platzi. All rights reserved.
//

import UIKit

class TodoItem : NSObject, NSCoding {
  
  var todo: String?
  
  var dueDate: NSDate?
  
  var image: UIImage?
  
  var id: Int64?
  
  override init() {
    super.init()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init()
    if let item = aDecoder.decodeObjectForKey("todo") as? String {
      self.todo = item
    }
    if let date = aDecoder.decodeObjectForKey("dueDate") as? NSDate {
      self.dueDate = date
    }
    if let i = aDecoder.decodeObjectForKey("image") as? UIImage {
      self.image = i
    }
    let identifier = aDecoder.decodeInt64ForKey("identifier")
    if identifier != 0  {
      self.id = identifier
    }
  }
  
  //MARK: NSCoding methods
  func encodeWithCoder(aCoder: NSCoder) {
    if let item = todo {
      aCoder.encodeObject(item, forKey: "todo")
    }
    if let date = dueDate {
      aCoder.encodeObject(date, forKey: "dueDate")
    }
    if let i = image {
      aCoder.encodeObject(i, forKey: "image")
    }
    if let identifier = self.id {
      aCoder.encodeInt64(identifier, forKey: "identifier")
    }
  }
  
  class func parse(result: [Dictionary<String, AnyObject>]) -> [TodoItem] {
    var items = [TodoItem]()
    for dict in result {
      let item = TodoItem()
      if let message = dict["message"] as? String {
        item.todo = message
      }
      if let identifier = dict["id"] as? NSNumber {
        item.id = identifier.longLongValue
      }
      if let dateStr = dict["dueDate"] as? String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        if let date = dateFormatter.dateFromString(dateStr) {
          item.dueDate = date
        }
      }
      items.append(item)
    }
    return items
  }
  
}