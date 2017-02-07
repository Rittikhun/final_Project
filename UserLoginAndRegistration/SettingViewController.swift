//
//  SettingViewController.swift
//  UserLoginAndRegistration
//
//  Created by Pongparit Paocharoen on 12/12/16.
//  Copyright © 2016 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import FirebaseInstanceID

class SettingViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    
    let userEmail = FIRAuth.auth()?.currentUser?.email

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        
        
        if let user = FIRAuth.auth()?.currentUser {
            
        
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            
            let usernamef = value["name"] as! String
            
            self.nameText.text = usernamef
            
            
            // ...
        }) { (error) in
            var myAlert = UIAlertController(title:"Error", message:"\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert);
            
            let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                self.dismiss(animated: true, completion:nil);
            }
            
            myAlert.addAction(okAction);
            self.present(myAlert, animated:true, completion:nil);
            
            print(error.localizedDescription)
        }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        
          if let user = FIRAuth.auth()?.currentUser {
            
            
        
        FIRAuth.auth()?.currentUser?.updateEmail(emailText.text!) { (error) in
            
            if error != nil {
            
            let myAlert = UIAlertController(title:"Error", message:"\(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert);
            
            let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                
            }
            
            myAlert.addAction(okAction);
            self.present(myAlert, animated:true, completion:nil);
            
            print("error 1 :\(error?.localizedDescription)")
            
            }
            
            else {
                
                FIRAuth.auth()?.currentUser?.updatePassword(self.passText.text!) { (error) in
                    
                    if error != nil {
                        var myAlert = UIAlertController(title:"Error", message:"\(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert);
                    
                        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in

                        }
                    
                        myAlert.addAction(okAction);
                        self.present(myAlert, animated:true, completion:nil);
                    
                        print("error 2 :\(error?.localizedDescription)")
                    
                    }
                    
                    else {
                        
                        let post = ["Password": self.passText.text!,
                                    "email": self.emailText.text!,
                                    "name": self.nameText.text! ]
                        let childUpdates = ["/users/\(user.uid)/": post ]
                        self.ref.updateChildValues(childUpdates)
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                }

                
            }
            
        }
            
        }
        
        
        
    }

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
