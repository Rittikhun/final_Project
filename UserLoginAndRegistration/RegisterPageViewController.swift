//
//  RegisterPageViewController.swift
//  UserLoginAndRegistration
//
//  Created by Sergey Kargopolov on 2015-01-13.
//  Copyright (c) 2015 Sergey Kargopolov. All rights reserved.
//

import UIKit
//import Parse
import FirebaseDatabase
import FirebaseAuth
import Foundation

class RegisterPageViewController: UIViewController {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    let db = Database.getSharedInstance()
    var mRootRef:FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mRootRef = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func registerButtonTapped(_ sender: AnyObject) {
        
        let userEmail = userEmailTextField.text;
        let userPassword = userPasswordTextField.text;
        let userRepeatPassword = repeatPasswordTextField.text;
        
        // Check for empty fields
        if((userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userRepeatPassword?.isEmpty)!)
        {
            
            // Display alert message
            
            displayMyAlertMessage("All fields are required");
            
            return;
        }
        
        //Check if passwords match
        if(userPassword != userRepeatPassword)
        {
            // Display an alert message
            displayMyAlertMessage("Passwords do not match");
            
            
            return;
            
        }
            
            
            
            // Store data
            //        let myUser: UserDef! = PFUser();
            //
            //        myUser.username = userEmail
            //        myUser.password = userPassword
            //        myUser.email = userEmail
            //
            //
            //        myUser.signUpInBackgroundWithBlock {
            //            (success:Bool!, error:NSError!) -> Void in
            //
            //                println("User successfully registered")
            //
            //            // Display alert message with confirmation.
            
            
        else{
            
            let userEmail: String = self.userEmailTextField.text!
            
            let Name: String = self.nameTextField.text!
            
            let userPassword: String = self.userPasswordTextField.text!
            
            let userName: String = self.usernameTextField.text!
            
//            print(userName.range(of: "[0-9]", options: .regularExpression))
            
            if userName.range(of: "^(?=.{6,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$", options: .regularExpression) != nil {
                
                self.mRootRef.child("search").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.hasChild(userName){
                        
                        print("username Exist!!")
                        var myAlert = UIAlertController(title:"username can't be used!", message:"username Exist!!", preferredStyle: UIAlertControllerStyle.alert);
                        
                        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                            self.dismiss(animated: true, completion:nil);
                        }
                        
                        myAlert.addAction(okAction);
                        self.present(myAlert, animated:true, completion:nil);
                        
                    }else{
                        
                        FIRAuth.auth()?.createUser(withEmail: userEmail, password: userPassword, completion: { (user, error) in
                            if error == nil {
                                
                                if FIRAuth.auth()?.currentUser != nil {
                                    
                                    let userID = FIRAuth.auth()?.currentUser?.uid
                                    print("sdasds")
                                    self.mRootRef.child("users").child(userID!).setValue(["email":userEmail,"name":Name,"Password":userPassword, "username" : userName])
                                    
                                    DBProvider.Instance.saveUser(ID: userID!, email: userEmail, password: userPassword, name: Name)
                                    
                                    
                                    self.mRootRef.child("search").child(userName).setValue(["uid": "\(userID!)"])
                                    
                                    self.mRootRef.child("friendpending").child(userID!).setValue(["uid": ""])
                                    
                                    self.mRootRef.child("friendlist").child(userID!).setValue(["uid": ""])
                                    
                                    self.mRootRef.child("event pending").child(userID!).setValue(["title": "","location": "","date": "","uid": "","uidevent": ""])
                                    
                                    print("sdasds")
                                    
                                    var myAlert = UIAlertController(title:"Alert", message:"Registration is successful. Thank you!", preferredStyle: UIAlertControllerStyle.alert);
                                    
                                    let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                                        self.dismiss(animated: true, completion:nil);
                                    }
                                    
                                    myAlert.addAction(okAction);
                                    self.present(myAlert, animated:true, completion:nil);
                                    
                                    //                        self.mRootRef.child("location").child(userName).setValue(["location": "0"])
                                    
                                    print("User registered with Firebase")
                                    return
                                }
                                    
                                else {
                                    
                                    //not sign out
                                }}
                        }
                            
                            
                        )}
                })
                
            }
            else {
                
                print("username can't use bacause have special character")
                var myAlert = UIAlertController(title:"username can't be used!", message:"username can't use bacause have special character!", preferredStyle: UIAlertControllerStyle.alert);
                
                let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                    self.dismiss(animated: true, completion:nil);
                }
                
                myAlert.addAction(okAction);
                self.present(myAlert, animated:true, completion:nil);
                
            }
            
            
            
            //            let pushdb = db.addNote(nameTextField.text!, username: userEmailTextField.text!, password: userPasswordTextField.text!)
            //            print("\(pushdb)")
            
            
            
            //        UserDefaults.standard.set(userEmail, forKey: "userEmail")
            //        UserDefaults.standard.set(userPassword, forKey: "userPassword")
            //        UserDefaults.standard.synchronize()
            
            
        }
        //        }
        
        
        
        
    }
    
    
    func displayMyAlertMessage(_ userMessage:String)
    {
        
        let myAlert = UIAlertController(title:"Alert", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil);
        
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated:true, completion:nil);
        
    }
    
    @IBAction func iHaveAnAccountButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


