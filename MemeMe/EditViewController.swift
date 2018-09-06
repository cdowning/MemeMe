//
//  ViewController.swift
//  MemeMe
//
//  Created by Caitlin on 8/30/18.
//  Copyright © 2018 Caitlin. All rights reserved.
//
import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    // Meme
    var memeImage: UIImage!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: View Loading Functions
    
    override func viewWillAppear(_ animated: Bool) {
        // UIImagePickerController.isSourceTypeAvailable(.camera) - returns if camera is available on device - if false disable cameraButton
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates to self
        self.topText.delegate = self
        self.bottomText.delegate = self
        
        topText.text = "TOP TEXT"
        bottomText.text = "BOTTOM TEXT"
        
        let memeTextAttributes:[String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0),
            NSAttributedStringKey.foregroundColor.rawValue: UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0),
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 38)!,
            NSAttributedStringKey.strokeWidth.rawValue: 3,
            ]
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
        topText.textAlignment = NSTextAlignment.center
        bottomText.textAlignment = NSTextAlignment.center

    }
    
    
    // MARK: Text Field Interactions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear text if default text
        if textField.text == "TOP TEXT" || textField.text == "BOTTOM TEXT" {
            textField.text = ""
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if topText.text == "" {
            textField.text = "TOP TEXT"
        }
        if bottomText.text == "" {
            textField.text = "BOTTOM TEXT"
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Keyboard Functions
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo // userInfo dictionary
        
        // UIKeyboardFrameEndUserInfoKey is a dictionary within userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Called in viewWillAppear
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // Called in viewWillDisappear
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Image Picker Functions
    
    // Select Image
    // didFinishPickingMediaWithInfo - is passed as an info dictionary contains UIImage objects and is of type string
    // info dictionary contains the image information - path to image, etc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("imagePickerController")
        
        // Value in info dictionary will be an optional type, and so it should be conditionally unwrapped. as?
        // UIImagePickerControllerOriginalImage is in the info dictionary
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Cancel Image Selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Save Meme Image
    
    func saveMeme() {
        
        // Create the meme
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memeImage: memeImage)
        
        // Add it to the memes array in the Application Delegate
//        let object = UIApplication.shared.delegate
//        let appDelegate = object as! AppDelegate
//        AppDelegate.memes.append(meme)
    }
    
    func generateMemeImage() -> UIImage {
        
        // Hide toolbar and navbar
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memeImage
    }
    
    
    // MARK: IBActions
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // Present image picker from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
}

