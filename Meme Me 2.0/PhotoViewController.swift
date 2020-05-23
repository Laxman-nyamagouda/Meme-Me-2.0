//
//  PhotoViewController.swift
//  Meme Me
//
//  Created by Laxman Nyamagouda on 4/22/20.
//  Copyright © 2020 Laxman Nyamagouda. All rights reserved.
//

import UIKit

struct GoogleSearch {
    static let scheme = "https"
    static let host = "google.com"
    static let path = "/search"
    static let queryName = "query"
    static let udacitySearchTerm = "udacity"
}

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var myToolBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var galleryButton: UIBarButtonItem!
    
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    
    let imagePicker = UIImagePickerController()
    var memeImage: UIImage?
    
    var flagTextField: UITextField?
    var btnShare: UIBarButtonItem?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
         subscribeToKeyboardNotifications()
        
        //Add share button
        btnShare = UIBarButtonItem(barButtonSystemItem:.action, target: self, action: #selector(share))
        self.navigationItem.leftBarButtonItem = btnShare
        btnShare?.isEnabled = false
        
        //Add cancel button
        let btnCancel = UIBarButtonItem(barButtonSystemItem:.cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = btnCancel
        
    }
    
    func addAttributes() -> [NSAttributedString.Key : Any] {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let memeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -3.0,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        
        return memeTextAttributes
    }
    
    @objc func cancel() {
        print("Cancel button clicked")
        dismiss(animated: true, completion: nil)
        imageView.image = nil
        textFieldTop.text = "TOP"
        textFieldBottom.text = "BOTTOM"
    }
    
    @objc func share() {
        print("Share button clicked")
        
        // image to share
        memeImage = generateMemedImage()
        let image = memeImage

        // set up activity view controller
        var imageToShare = [UIImage]()
        if let image = image {
            imageToShare = [ image ]
        }
        
      let activityController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)

        activityController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }

        present(activityController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        textFieldTop.delegate = self
        textFieldBottom.delegate = self
        textFieldTop.backgroundColor = UIColor.clear
        textFieldTop.borderStyle = .none
        textFieldBottom.borderStyle = .none
        
        textFieldTop.defaultTextAttributes = addAttributes()
        textFieldBottom.defaultTextAttributes = addAttributes()
    }

    @IBAction func openCamera(_ sender: Any) {
        enableShareButton()
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    @IBAction func openGallery(_ sender: Any) {
        enableShareButton()
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }

    func enableShareButton() {
        btnShare?.isEnabled = true
    }
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if flagTextField == textFieldBottom {
            view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        if flagTextField == textFieldBottom {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height

    }
    // Mark: - UIImagePickerDelegate implementation
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
          imageView.image = chosenImage
          dismiss(animated:true, completion: nil)
    }
    
    //Mark: - Meme creation
    
    func save() {
        // Create the meme
        if let image = imageView.image {
            let meme = Meme(topText: textFieldTop.text!, bottomText: textFieldBottom.text!, originalImage: image, memedImage: generateMemedImage())
            memeImage = generateMemedImage()
            (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableViewAndCollectionView"), object: nil, userInfo: nil)
        }
    }
    
    func generateMemedImage() -> UIImage {
         
        // TODO: Hide toolbar and navbar
        myToolBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // TODO: Show toolbar and navbar
        myToolBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        return memedImage
    }
}

struct Meme {
    var topText: String?
    var bottomText: String?
    var originalImage: UIImage?
    var memedImage: UIImage
}

enum TextFieldType {
    case top
    case bottom
    
    var rawValue: Int {
        switch self {
            case .top: return 0
            case .bottom: return 1
        }
    }
    
}


extension PhotoViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        flagTextField = textField
        
        if (textField == textFieldTop) {
           textField.text = ""
        }
        else if (textField == textFieldBottom) {
           textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        DispatchQueue.main.async { [weak self] in
            self?.textFieldTop.resignFirstResponder()
            self?.textFieldBottom.resignFirstResponder()
        }

        if textField.tag == TextFieldType.top.rawValue {
            print("textFieldTop")
            textFieldTop.text = textField.text?.uppercased()
            textFieldTop.defaultTextAttributes = addAttributes()
        }
        if textField.tag == TextFieldType.bottom.rawValue {
            print("textFieldBottom")
            textFieldBottom.text = textField.text?.uppercased()
            textFieldBottom.defaultTextAttributes = addAttributes()
        }
        
        return true
    }
    
}
