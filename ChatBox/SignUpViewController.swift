//
//  SignUpViewController.swift
//  ChatBox
//
//  Created by Naveen Kumar on 11/3/16.
//  Copyright © 2016 Naveen Kumar. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!

    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var emailId: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var rePassword: UITextField!
    
    @IBAction func signUP(_ sender: Any) {
        let fname = self.firstName.text
        let lname = self.lastName.text
        let email = self.emailId.text
        let pwd = self.password.text
        let rPwd = self.rePassword.text

        if fname!.isEmpty || lname!.isEmpty || email!.isEmpty || pwd!.isEmpty || rPwd!.isEmpty{
            showAlertMessage(title: "Error", message: "Please enter valid details")
        }else{
            if pwd!.characters.count<6 {
                showAlertMessage(title: "Error", message: "Passwords should be atleast 6 characters")
            }
            else if rPwd != pwd {
                showAlertMessage(title: "Error", message: "Passwords doesn't match")
            }else{
                ServiceClass.SharedInstance.performSignUp(userFName: fname!, userLName: lname!, emailId: email!, password: pwd!, completion: { response in
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
    }
    
    func showChatWindow() {
        performSegue(withIdentifier: "fromSignUp", sender: self)
    }
    
    func showAlertMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
