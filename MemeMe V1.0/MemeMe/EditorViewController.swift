//
//  ViewController.swift
//  MemeMe
//
//  Created by JING ZHANG on 7/31/16.
//  Copyright © 2016 JING ZHANG. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // Meme image and text
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
  
    //Top Bar
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //Bottom Bar
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    //Setting text field attributes:font style and color
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    //Setting the defaultTextAttributes property
    func setupTextField(string: String, textField: UITextField) {
        let attributedString = NSAttributedString(string: string, attributes: memeTextAttributes)
        textField.attributedText = attributedString
        textField.defaultTextAttributes = memeTextAttributes
        // Text should be center-aligned
        textField.textAlignment = .Center
        textField.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField("TOP", textField: topTextField)
        setupTextField("BOTTOM", textField: bottomTextField)
        shareButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // enable camera button if a device is availble
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        // subscribe to keyboard notifications
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe from keyboard functions
        unsubscribeFromKeyboardNotifications()
    }
    
    //NSNotification subscriptions and selectors
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    // function to move the view and its contents up when the keyboard is shown
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // function that moves the view and its contents back down when the keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            self.view.frame.origin.y = 0
        }
    }
    
    // function that gets the height of the keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Present the image picker depending on the specified sourceType
    func presentImagePickerOfType(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //Launching the image picker from Camera
    @IBAction func pickAnImageFromCamera(sender: AnyObject){
        presentImagePickerOfType(.Camera)
    }
    
    //Launching the image picker from Album
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        presentImagePickerOfType(.PhotoLibrary)
    }
    
    // Receiving an image using a delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //setup editor image and current editor meme.
            imagePickerView.image = originalImage
            shareButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //After the enter is pressed at we dismiss the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //At the begining of Editing if the default text is written We reset it
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == topTextField && topTextField.text == " TOP ") {
            topTextField.text = ""
        } else if (textField == bottomTextField && bottomTextField.text == " BOTTOM ") {
            bottomTextField.text = ""
        }
    }
    
     //Action for the share button. It displayes the activity view and saves the Meme.
    @IBAction func shareMeme(sender: AnyObject) {
        
        //  generate a memed image
        let memedImage = generateMemedImage()
        
        // pass the ActivityViewController a memedImage as an activity item
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                
                //Save the image
                self.save(memedImage)
                
                //Dismiss the view controller
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activityViewController, animated: true, completion:nil)
    }
    
    //Cancel button action, startover
    @IBAction func cancelMeme(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        setupTextField("TOP", textField: topTextField)
        setupTextField("BOTTOM", textField: bottomTextField)
        imagePickerView.image = nil
        shareButton.enabled = false
    }
    
    func toolbarVisible(visible: Bool) {
        toolBar.hidden = !visible
        navBar.hidden = !visible
    }
    
    func generateMemedImage() -> UIImage {
        // hide toolbar
        toolbarVisible(false)
        
        // Render view to image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // show toolbar
        toolbarVisible(true)
        
        return memedImage
    }
    
    // Saves the meme correctly. Is the meme is new it saves a new one in the shared model
    // If the meme already exists the method only updates its values
    func save(memedImage: UIImage) {
        let memedImage = generateMemedImage()
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }

}

