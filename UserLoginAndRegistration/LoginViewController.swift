//
//  LoginViewController.swift
//  UserLoginAndRegistration
//
//  Created by Sergey Kargopolov on 2015-01-13.
//  Copyright (c) 2015 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
//    let db = Database.getSharedInstance()
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
    

    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        print("1")
        
        var userEmail: String = ""
        let userPassword = userPasswordTextField.text;
        
//        let userEmailStored = UserDefaults.standard.string(forKey: "userEmail");
//        
//        let userPasswordStored = UserDefaults.standard.string(forKey: "userPassword");
        
        
        if ((userEmailTextField.text?.range(of: ".+@.+", options: .regularExpression)) != nil){
            print("2.1")
            
            userEmail = userEmailTextField.text!
//            print(userEmail)
            
            loginFun(email: userEmail, password: userPassword!)
            
        }
        
        else {
            print("2.2")
            
            mRootRef.child("search").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                // Get user value
                print("4")
                snapshot
                
                if snapshot.hasChild(self.userEmailTextField.text!){
                    
                    self.mRootRef.child("search").child(self.userEmailTextField.text!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                        // Get user value
                        print("4")
                        
                        let value = snapshot.value as! NSDictionary
                        
                        let uid = value["uid"] as! String
                        
                        
                        self.mRootRef.child("users").child(uid).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                            // Get user value
                            
                            print("5")
                            
                            let value = snapshot.value as! NSDictionary
                            
                            let email = value["email"] as! String
                            
                            
                            
                            userEmail = email
                            print(userEmail)
                            self.loginFun(email: userEmail, password: userPassword!)
                            
                            // ...
                        })
                        { (error) in
                            print(error.localizedDescription)
                        }
                        
                        
                        // ...
                    })
                    { (error) in
                        print(error.localizedDescription)
                    }

                    
                }else{
                    
                    print("3.2")
                    
                    var myAlert = UIAlertController(title:"Error while Login", message:"username is incorrect , or not register", preferredStyle: UIAlertControllerStyle.alert);
                    
                    let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                    }
                    
                    myAlert.addAction(okAction);
                    self.present(myAlert, animated:true, completion:nil);
                    
                    
                    return
                }
            })}

        
        
        print("6")
        
//            print(userEmail)
        
        }
    
    
    func loginFun(email: String, password: String) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion:{ (user, error) in
            
            if error == nil {
                
                print(FIRAuth.auth()?.currentUser?.uid)
                if FIRAuth.auth()?.currentUser != nil {
                    
                    
                    var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    var vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "tabView") as! UIViewController
                    
                    self.present(vc, animated: true, completion: nil)
                    
                } else {
                    // No user is signed in.
                    // ...
                }
                
                
            }
                
            else {
                
                var myAlert = UIAlertController(title:"Error", message:"\((error?.localizedDescription)!)", preferredStyle: UIAlertControllerStyle.alert);
                
                let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                }
                
                myAlert.addAction(okAction);
                self.present(myAlert, animated:true, completion:nil);
                
                print(error)
            }
            
            
        })
        
    }
    
    
}
        
//        let result = db.getNote(self.userEmailTextField.text!)
//        
//        let userEmailStored = result.username
//        
//        print(userEmailStored)
//        
//        let userPasswordStored = result.password
//        
//        print(userPasswordStored)
//        
//        if(userEmailStored == userEmail)
//        {
//            if(userPasswordStored == userPassword)
//            {
////                // Login is successfull
////                UserDefaults.standard.set(true,forKey:"isUserLoggedIn");
////                    UserDefaults.standard.synchronize();
//                
////                self.dismiss(animated: true, completion:nil);
//                
////                self.performSegue(withIdentifier: "homeView", sender: self);
//            }
//        }
//
//        
//    }
    
//    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
//        
//        
//        
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

//}
