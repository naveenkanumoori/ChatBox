//
//  ChatViewController.swift
//  ChatBox
//
//  Created by Naveen Kumar on 11/2/16.
//  Copyright © 2016 Naveen Kumar. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    var listOfMessages:[Message] = []
    var tokenString:String!
    let imagePicker = UIImagePickerController()
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    //Signout Functionality
    @IBAction func signOut(_ sender: AnyObject) {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "fullName")
        
        let delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window = UIWindow(frame:UIScreen.main.bounds)
        let storyBoard = UIStoryboard(name:"Main", bundle:nil)
        let chatViewController: ViewController = storyBoard.instantiateViewController(withIdentifier: "mainView") as! ViewController
        delegate.window?.rootViewController = chatViewController
        delegate.window?.makeKeyAndVisible()
        
    }
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        let messageText = self.messageTextField.text
        if messageText!.isEmpty{
            
        }else{
            self.messageTextField.text = nil
            self.messageTextField.resignFirstResponder()
            self.sendMessageToServer(type: "TEXT", comment: messageText!, thumbnailId: nil)
        }
    }
    
    //Add Message to Server(Either Text or Image ID)
    func sendMessageToServer(type:String, comment:String?, thumbnailId:String?) {
        ServiceClass.SharedInstance.postMessageToServer(token:self.tokenString ,type: type, comment: comment, thumbnailID: thumbnailId, completion: { response in
            if let status = response["status"] as! String!{
                if status == "ok"{
                    self.getMessages()
                }else{
                    let message = response["message"] as! String
                    self.showAlertMessage(title: "Error", message: message)
                }
            }
        })
    }
    
    //Display Action Sheet to select either Gallery or Camera(If Available)
    @IBAction func sendImage(_ sender: AnyObject) {

        let isCameraAvailable:Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        let uialertController:UIAlertController = UIAlertController(title: "Select", message: nil, preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (_) in
            self.launchImagePicker(type: "gallery")
        }
        uialertController.addAction(galleryAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.launchImagePicker(type: "camera")
        }
        
        if isCameraAvailable {
            uialertController.addAction(cameraAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in}
        uialertController.addAction(cancelAction)
        
        self.present(uialertController, animated: true, completion: {})
    }
    
    //Launch Image picker based on type
    func launchImagePicker(type:String) {
        if type == "gallery" {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }else{
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.sendImageToServerToStore(image:pickedImage)
        }
        
    }
    
    //To add file
    func sendImageToServerToStore(image:UIImage) {
        let imageData = UIImagePNGRepresentation(image)
        ServiceClass.SharedInstance.addImageFileToServer(token: self.tokenString, imageData: imageData!, completion: {
            response in
            if let status = response["status"] as! String!{
                if status == "ok"{
                    let file:NSDictionary = response["file"] as! NSDictionary
                    let filethumbnailId = file["Id"] as! String
                    self.sendMessageToServer(type: "IMAGE", comment: nil, thumbnailId: filethumbnailId)
                }else{
                    self.showAlertMessage(title: "Error", message: "Image failed to add")
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        self.tokenString = UserDefaults.standard.value(forKey: "token") as! String
        let fullName = UserDefaults.standard.value(forKey: "fullName") as! String
        self.welcomeLabel.text = "Hello, "+fullName+"!"
        getMessages()
        
        //Register Custom cell to display image and Text messages separately
        self.messagesTable.register(UINib(nibName:"TextMessageCell", bundle:nil), forCellReuseIdentifier: "textCell")
        self.messagesTable.register(UINib(nibName:"ImageMessageCell", bundle:nil), forCellReuseIdentifier: "imageCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    //Show alert messages
    func showAlertMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = listOfMessages[indexPath.row]
        if message.getType() == "TEXT" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextMessageCell
            cell.senderName.text = message.getUserFName()+" "+message.getUserLName()
            cell.createdTime.text = message.getCreatedAt()
            cell.messageText.text = message.getComment()
            
            cell.dataView.layer.cornerRadius = 10.0
            cell.dataView.layer.borderColor = UIColor.gray.cgColor
            cell.dataView.layer.borderWidth = 0.5
            cell.dataView.clipsToBounds = true
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageMessageCell
            cell.senderName.text = message.getUserFName()+" "+message.getUserLName()
            cell.createdTime.text = message.getCreatedAt()
            cell.imageMessage.image = nil
            ServiceClass.SharedInstance.getImageData(token: self.tokenString, thumbnailID: message.getFileThumbnailId(), completion: { response in
                cell.imageMessage.image = UIImage(data:response)
            })
            
            cell.dataView.layer.cornerRadius = 10.0
            cell.dataView.layer.borderColor = UIColor.gray.cgColor
            cell.dataView.layer.borderWidth = 0.5
            cell.dataView.clipsToBounds = true
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if listOfMessages[indexPath.row].getType() == "TEXT" {
            let width = tableView.frame.width - 24.0
            let message = listOfMessages[indexPath.row]
            return 55.0 + (heightForView(text: message.getComment(), font: UIFont (name: "HelveticaNeue", size: 16)!, width: width))
        }else{
            return 150
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        getMessages()
    }
    
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let frame = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        let label:UILabel = UILabel(frame: frame)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func getMessages(){
        ServiceClass.SharedInstance.getMessages(token: self.tokenString) { (response) in
            self.parseMessages(messages: response)
        }
    }
    
    func parseMessages(messages:NSDictionary) {
        listOfMessages = []
        let messagesArray:NSArray = messages["messages"] as! NSArray
        
        for msg in messagesArray {
            let msgObj:NSDictionary = msg as! NSDictionary //Converting Any to NSDictionary
            
            var fileThumbnailId,comment:String?  //Variables which may remains as nil
            var userFname,userLname,type,createdAt:String
            
            let message = Message()  //Creating new message Object
            type = msgObj["Type"] as! String
            if type == "TEXT" { //Checking the message type
                comment = msgObj["Comment"] as? String
                message.setComment(comment: comment!)
            }else{
                fileThumbnailId = msgObj["FileThumbnailId"] as? String
                message.setFileThumbnailId(fileThumbnailId: fileThumbnailId!)
            }
            
            userFname = msgObj["UserFname"] as! String
            userLname = msgObj["UserLname"] as! String
            createdAt = msgObj["CreatedAt"] as! String
            
            message.setType(type: type)
            message.setUserFName(userFname: userFname)
            message.setUserLName(userLname: userLname)
            message.setCreatedAt(createdAt: createdAt)
            
            self.listOfMessages += [message] //Adding message object to msgArray
        }
        messagesTable.reloadData()
    }
}
