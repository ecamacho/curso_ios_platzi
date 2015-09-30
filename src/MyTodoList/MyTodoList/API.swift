//
//  API.swift
//  MyTodoList
//
//  Created by Erick Camacho on 8/14/15.
//  Copyright © 2015 Platzi. All rights reserved.
//

import Foundation

class API {
  
  class func uniqueUsername() -> String {
    if let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String{
      return username
    } else {
      let newUsername = generateUsername()
      NSUserDefaults.standardUserDefaults().setObject(newUsername, forKey: "username")
      return newUsername
    }
  }
  
  class func generateUsername() -> String {
    let uuid = NSUUID().UUIDString
    return (uuid as NSString).substringToIndex(5)
  }
  
  class func save(item: TodoItem, todoList: TodoList, responseBlock: (NSError?) -> Void) {
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "https://pendientesapp.herokuapp.com/todo")!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    var dictionary: Dictionary<String, AnyObject> = ["message": item.todo!, "user": self.uniqueUsername()]
    if let date = item.dueDate {
      let formatter = NSDateFormatter()
      formatter.dateFormat = "dd/MM/yyyy HH:mm"
      dictionary["dueDate"] = formatter.stringFromDate(date)
    }
    if let identifier = item.id {
      dictionary["id"] = NSNumber(longLong: identifier)
    }
  
    
    let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options:  NSJSONWritingOptions.PrettyPrinted)
    let  datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
    print("body \(datastring!)")
    request.HTTPBody = data
    let task = session.dataTaskWithRequest(request) {
      (data, response, error) -> Void in
      print("response \(response)")
      if let err = error {
        responseBlock(err)
      } else {
        if let r = data {
          let result = try! NSJSONSerialization.JSONObjectWithData(r, options: NSJSONReadingOptions.AllowFragments)
          if let id = result["id"] as? Int64 {
            item.id = id
            print("id \(id)")
            todoList.saveItems()
          }
        }
        responseBlock(nil)
      }
      
    }
    task.resume()
  }
  
  class func get(todoList: TodoList, responseBlock: (NSError?) -> Void) {
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "https://pendientesapp.herokuapp.com/todo/\(self.uniqueUsername())")!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    let task = session.dataTaskWithRequest(request) {
      (data, response, error) -> Void in      
      if let err = error {
        dispatch_async(dispatch_get_main_queue()) {
          responseBlock(err)
        }
      } else {
        if let r = data {
          let result = try! NSJSONSerialization.JSONObjectWithData(r, options: NSJSONReadingOptions.AllowFragments)
       
          if let r = result as? [Dictionary<String, AnyObject>] {
            let items = TodoItem.parse(r)
            todoList.items = items
            todoList.saveItems()
          }
        }
        dispatch_async(dispatch_get_main_queue()) {
          responseBlock(nil)
        }
        
      }
      
    }
    task.resume()
  }
  
  
}
