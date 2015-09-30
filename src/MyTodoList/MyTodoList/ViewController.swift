//
//  ViewController.swift
//  MyTodoList
//
//  Created by Norberto Ortigoza on 8/5/15.
//  Copyright © 2015 Platzi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
  @IBOutlet weak var itemTextField: UITextField!
  @IBOutlet weak var tableView: UITableView!
  
  let todoList = TodoList()
  
  var selectedItem: TodoItem?
  
  static let MAX_TEXT_SIZE = 50
  
  @IBAction func addButtonPressed(sender: UIButton) {
      print("Agregando un elemento a la lista: \(itemTextField.text) ")
    let todoItem = TodoItem()
    todoItem.todo = itemTextField.text
    todoList.addItem(todoItem)
    API.save(todoItem, todoList: todoList) {
      error in
      print("error \(error)")
    }
    tableView.reloadData()
    self.itemTextField.text = nil
    self.itemTextField?.resignFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.dataSource = todoList
    tableView.delegate = self
    API.get(self.todoList) {(error) -> Void in
      print("error \(error)")
      if let err = error {
          //TODO show error
      } else {
        self.tableView.reloadData()
      }
      
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  //MARK: Metodos del table view delegate
  func scrollViewDidScroll(scrollView: UIScrollView) {
    self.itemTextField?.resignFirstResponder()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.selectedItem = self.todoList.getItem(indexPath.row)
    self.performSegueWithIdentifier("showItem", sender: self)
//    let detailVC = DetailViewController()
//    detailVC.item = self.selectedItem
//    self.navigationController?.pushViewController(detailVC, animated: true)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let detailViewController = segue.destinationViewController as? DetailViewController {
      detailViewController.item = self.selectedItem
      detailViewController.todoList = self.todoList
    }
  }
  
  //MARK: Metodos del text field delegate
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if let tareaString = textField.text as? NSString {
      let updatedString = tareaString.stringByReplacingCharactersInRange(range, withString: string)
      return updatedString.characters.count <= ViewController.MAX_TEXT_SIZE
    } else {
      return true
    }
  }
  

}

