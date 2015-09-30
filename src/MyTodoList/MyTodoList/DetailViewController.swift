//
//  DetailViewController.swift
//  MyTodoList
//
//  Created by Erick Camacho on 8/11/15.
//  Copyright © 2015 Platzi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  var item: TodoItem?
  var todoList: TodoList?
  
  @IBOutlet weak var descriptionLabel: UILabel!
  
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var datePicker: UIDatePicker!
  
  @IBOutlet weak var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let date = item?.dueDate {
      self.datePicker.date = date
      let formatter = NSDateFormatter()
      formatter.dateFormat = "dd/MM/yyyy HH:mm"
      self.dateLabel.text = formatter.stringFromDate(date)
    }
    if let image = item?.image {
      self.imageView.image = image
    }
    self.descriptionLabel.text = self.item?.todo
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    tapGestureRecognizer.numberOfTapsRequired = 1
    tapGestureRecognizer.numberOfTouchesRequired = 1
    tapGestureRecognizer.addTarget(self, action: "toggleDatePicker")
    self.dateLabel.addGestureRecognizer(tapGestureRecognizer)
    self.dateLabel.userInteractionEnabled = true
    addGestureRecognizerToImage()
  }
  
  func addGestureRecognizerToImage() {
    let tapGestureRecognizer = UITapGestureRecognizer()
    tapGestureRecognizer.numberOfTapsRequired = 1
    tapGestureRecognizer.numberOfTouchesRequired = 1
    tapGestureRecognizer.addTarget(self, action: "rotate")
    self.imageView.userInteractionEnabled = true
    self.imageView.addGestureRecognizer(tapGestureRecognizer)
  }
  
//  func toggleDatePicker() {
//    self.imageView.hidden = self.datePicker.hidden
//    self.datePicker.hidden = !self.datePicker.hidden
//  }
  
  func toggleDatePicker() {
    if self.datePicker.hidden {
      self.fadeInDatePicker()
    } else {
      self.fadeOutDatePicker()
    }
  }
  
  @IBAction func dateSelected(sender: UIDatePicker) {
    self.dateLabel.text = formatDate(sender.date)
    toggleDatePicker()
  }
  
  @IBAction func addImage(sender: UIBarButtonItem) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imagePickerController.delegate = self
    self.presentViewController(imagePickerController, animated: true, completion: nil)    
  }
  
  
  @IBAction func addNotification(sender: UIBarButtonItem) {
    if let dateString = self.dateLabel.text {
      if let date = parseDate(dateString) {
        self.item?.dueDate = date
//        self.todoList?.saveItems()
        scheduleNotification(self.item!.todo!, date: date)
        API.save(item!, todoList: todoList!, responseBlock: { (error) -> Void in
          dispatch_async(dispatch_get_main_queue(), {
            if let err = error {
              print(err)
              self.showError()
              
            } else {
              self.navigationController?.popToRootViewControllerAnimated(true)
            }
            
          })
        })
      }
    }
  }
  
  func showError() {
    let alert = UIAlertController(title: "Oops!", message:"No pudimos guardar tu tarea en este momento. Revisa tu conexión a internet e intenta más tarde", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default) { _ in
      self.navigationController?.popToRootViewControllerAnimated(true)
    }
    alert.addAction(action)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func scheduleNotification(message: String, date: NSDate) {
    let localNotification = UILocalNotification()
    localNotification.fireDate = date
    localNotification.timeZone = NSTimeZone.defaultTimeZone()
    localNotification.alertBody = message
    localNotification.alertTitle = "Recuerda esta tarea:"
    localNotification.applicationIconBadgeNumber = 1;
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  
  func formatDate(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    return formatter.stringFromDate(date)
  }
  
  func parseDate(string: String) -> NSDate? {
    let parser = NSDateFormatter()
    parser.dateFormat = "dd/MM/yyyy HH:mm"
    return parser.dateFromString(string)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  //MARK: Animaciones
  func fadeInDatePicker() {
    self.datePicker.alpha = 0
    self.datePicker.hidden = false
    UIView.animateWithDuration(1.0) { () -> Void in
      self.datePicker.alpha = 1
      self.imageView.alpha = 0
    }
  }
  
  
  func fadeOutDatePicker() {
    self.datePicker.alpha = 1
    self.datePicker.hidden = false
    UIView.animateWithDuration(1.0, animations: { () -> Void in
      self.datePicker.alpha = 0
      self.imageView.alpha = 1
      }) { (completed: Bool) -> Void in
        if completed {
          self.datePicker.hidden = true
        }
    }
  }
  
  func rotate() {
    
    let animation = CABasicAnimation()
    animation.keyPath = "transform.rotation"
    //animation.keyPath = "transform.rotation.y"
    animation.toValue = M_PI * 2.0
    animation.duration = 1
    //animation.repeatCount = 1
    self.imageView.layer.addAnimation(animation, forKey: "rotateAnimation")
  }
  
  //MARK: Image picker delegate methods
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    self.dismissViewControllerAnimated(true, completion: nil)
    for (k, v) in info {
      print("key \(k) v \(v.self)")
    }
    if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage {
      self.imageView.image = image
      self.item?.image = image
      todoList?.saveItems()

    }    
  }

}
