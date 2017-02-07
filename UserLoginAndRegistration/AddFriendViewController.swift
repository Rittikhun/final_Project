//
//  AddFriendViewController.swift
//  UserLoginAndRegistration
//
//  Created by iOS Dev on 12/14/2559 BE.
//  Copyright © 2559 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import FirebaseInstanceID

class AddFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchText: UITextField!
    
    @IBOutlet weak var nameText: UILabel!
    
    var ref: FIRDatabaseReference!
    
    var uid: String = ""
    
    var uidArr: [String] = []
    
    var uidfArr: [String] = []
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        
    self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var addOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            if FIRAuth.auth()?.currentUser != nil {
        
        self.ref.child("friendpending").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
//            print(snapshot.value)
            
            let value = snapshot.value as! NSDictionary
            
            let uid = value["uid"] as! String
            
            self.uidArr = uid.characters.split(separator: " ").map(String.init)
            
            var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: "update", userInfo: nil, repeats: true)
            
            
            
            
        })
                
                self.ref.child("friendlist").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
//                    print(snapshot.value)
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let uid = value["uid"] as! String
                    
                    self.uidfArr = uid.characters.split(separator: " ").map(String.init)
                    
                    self.pendingView.reloadData()
                    
                    print("uidArr: \(self.uidArr)")
        
                    print("uidfArr: \(self.uidfArr)")
                    
                    
                })

            }
        }
        addOutlet.isHidden = true
        nameText.isHidden = true
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: UIButton) {
        
        if let user = FIRAuth.auth()?.currentUser {
            
        ref.child("search").child(searchText.text!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if snapshot.hasChildren() {
            
            let value = snapshot.value as! NSDictionary
            
            let uid = value["uid"] as! String
            
            self.uid = uid
                
            self.ref.child("friendpending").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    //            print(snapshot.value)
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let uidc = value["uid"] as! String
                    
                    let uiduArr = uidc.characters.split(separator: " ").map(String.init)
                
                self.ref.child("users").child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let name = value["name"] as! String
                    
                    self.nameText.text = "Found : \(name) "
                    
                    self.addOutlet.isEnabled = true
                    
                    self.nameText.isHidden = false
                    
                    self.addOutlet.isHidden = false
                    
                    print(uid)
                    
                    if self.uid == user.uid || uiduArr.contains(self.uid) || self.uidfArr.contains(self.uid) {
                        
                        self.addOutlet.isEnabled = false
                        
                        print("uiduArr: \(uiduArr)")
                        
                        print("uidfArr: \(self.uidfArr)")
                        
                        print("uid: \(self.uid)")
                        
                    }
                    
                    
                })

                    
                    
                })
                

            //            self.username.text = usernamef
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        }
    }
    
    @IBAction func add(_ sender: UIButton) {
        print(FIRAuth.auth()?.currentUser)
        
        if let user = FIRAuth.auth()?.currentUser {
        if FIRAuth.auth()?.currentUser != nil {
            
            
            let uid = user.uid
            print("ss")
            
            ref.child("friendpending").child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as! NSDictionary
                
                var fuid = value["uid"] as! String
                
                if fuid != "" {
                    
                    fuid = "\(fuid), \(user.uid)"
                    
                    self.uidfArr = fuid.characters.split(separator: " ").map(String.init)
                    
                }
                    
                else {
                    
                    fuid = "\(user.uid)"
                    
                    self.uidfArr = fuid.characters.split(separator: " ").map(String.init)
                    
                }
                
                let post = ["uid": fuid]
                let childUpdates = ["/friendpending/\(self.uid)/": post ]
                self.ref.updateChildValues(childUpdates)
                
                var myAlert = UIAlertController(title:"Add Friend success", message:"wait for your friend accept", preferredStyle: UIAlertControllerStyle.alert);
                
                let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                    self.dismiss(animated: true, completion:nil);
                }
                
                myAlert.addAction(okAction);
                self.present(myAlert, animated:true, completion:nil);

                
                
            })
            
            
        }
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
    
    //table view
    
    @IBOutlet weak var pendingView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return uidArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = self.pendingView.dequeueReusableCell(withIdentifier: "pending", for: indexPath) as! pendingViewCell
        
        self.ref.child("users").child(self.uidArr[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            
            let name = value["name"] as! String

        
            cell.name.text = name
        
            cell.acceptBtnOutlet.tag = indexPath.row
            
            cell.acceptBtnOutlet.addTarget(self, action: #selector(AddFriendViewController.acceptFriend(sender:)), for: .touchUpInside)
        })
        
        return cell
        
    }
    
    @IBAction func acceptFriend(sender: UIButton) {
        
        if let user = FIRAuth.auth()?.currentUser {
            if FIRAuth.auth()?.currentUser != nil {
                
                let acceptuid = self.uidArr[sender.tag]

                
                self.ref.child("friendlist").child(acceptuid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    //                    print(snapshot.value)
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let uid = value["uid"] as! String
                    
                    var ffriendlist = uid.characters.split(separator: " ").map(String.init)
                    
                    ffriendlist.append(user.uid)
                    
                    self.uidfArr.append(acceptuid)
                    
                    self.uidArr.remove(at: sender.tag)
                    
                    let uidf = self.uidfArr.joined(separator: " ")
                    
                    let uida = self.uidArr.joined(separator: " ")
                    
                    let uidff = ffriendlist.joined(separator: " ")
                    
                    let postf = ["uid": uidf]
                    let childUpdatesf = ["/friendlist/\(user.uid)/": postf ]
                    self.ref.updateChildValues(childUpdatesf)
                    
                    let posta = ["uid": uida]
                    let childUpdatesa = ["/friendpending/\(user.uid)/": posta ]
                    self.ref.updateChildValues(childUpdatesa)
                    
                    let postff = ["uid": uidff]
                    let childUpdatesff = ["/friendlist/\(acceptuid)/": postff ]
                    self.ref.updateChildValues(childUpdatesff)
                    
                    self.pendingView.reloadData()

                    
                    
                })

            }
        }
        
        
        
    }
    
    func update() {
        
        if let user = FIRAuth.auth()?.currentUser {
            if FIRAuth.auth()?.currentUser != nil {
        
        self.ref.child("friendpending").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            //                    print(snapshot.value)
            
            let value = snapshot.value as! NSDictionary
            
            let uid = value["uid"] as! String
            
            self.uidArr = uid.characters.split(separator: " ").map(String.init)
            
            self.pendingView.reloadData()
            
            
            
        })
            }
        }
        
        
    }
    
    
}
