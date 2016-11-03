//
//  ViewController.swift
//  ChatBox
//
//  Created by Naveen Kumar on 11/2/16.
//  Copyright © 2016 Naveen Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signIn(_ sender: AnyObject) {
        let uname = self.emailId.text
        let pwd = self.password.text
        if uname!.isEmpty || pwd!.isEmpty {
            self.showAlertMessage(title: "Error", message: "Please Enter valid details")
        }else{
            ServiceClass.SharedInstance.performLogin(userName: uname!, password: pwd!, completion: { (response) in
                if let status = response["status"] as! String!{
                    if status == "ok"{
                        let token:String = response["token"] as! String
                        let userFullName = (response["userFname"] as! String) + " " + (response["userLname"] as! String)
                        
                        UserDefaults.standard.set(token, forKey: "token")
                        UserDefaults.standard.set(userFullName, forKey: "fullName")
                        
                        self.showChatWindow()
                        
                    }else{
                        let message = response["message"] as! String
                        self.showAlertMessage(title: "Error", message: message)
                    }
                }
            })
        }
    }
    
    func showAlertMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        performSegue(withIdentifier: "signUp", sender: self)
    }
    
    func showChatWindow() {
        performSegue(withIdentifier: "fromSignIn", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

