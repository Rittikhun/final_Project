//
//  menuViewController.swift
//  UserLoginAndRegistration
//
//  Created by iOS Dev on 11/3/2559 BE.
//  Copyright © 2559 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseAuth


class menuViewController: UIViewController {
    
    let MenuButton4 = "MenuButton4"

    @IBAction func CloseButton(_ sender: Any) {
        
        self.dismiss(animated: true) { () -> Void in
            
            
            
            
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        
        do {
            
            try FIRAuth.auth()?.signOut()
            
            var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            var vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "loginView") as! UIViewController
            
            self.present(vc, animated: true, completion: nil)
            
            
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
        }
        
        
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
