//
//  FriendlistViewController.swift
//  UserLoginAndRegistration
//
//  Created by Pongparit Paocharoen on 12/21/16.
//  Copyright © 2016 Sergey Kargopolov. All rights reserved.
//

import UIKit


class FriendlistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var friendlistTable: UITableView!
    
    var ref: FIRDatabaseReference!
    
    var friendlist: [String] = []
    
    var friendtag: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            
            if FIRAuth.auth()?.currentUser != nil {
                
                self.ref.child("friendlist").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    //                    print(snapshot.value)
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let uid = value["uid"] as! String
                    
                    self.friendlist = uid.characters.split(separator: " ").map(String.init)
                    
                    self.friendlistTable.reloadData()
                    
                })
                
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func doneBtn(_ sender: Any) {
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friendlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.friendlistTable.dequeueReusableCell(withIdentifier: "friendlist", for: indexPath) as! FriendListViewCell
        
        if let user = FIRAuth.auth()?.currentUser {
            
            if FIRAuth.auth()?.currentUser != nil {
                
                self.ref.child("users").child(self.friendlist[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let name = value["name"] as! String
                    
                    
                    cell.name.text = name
                    
                    cell.selecTion.tag = indexPath.row
                    
                    cell.selecTion.isOn = false
                    
                    
                    cell.selecTion.addTarget(self, action: #selector(FriendlistViewController.tagFriend(sender:)), for: UIControlEvents.touchUpInside)
                    
                })
                
            }
        }
        
        
        
        return cell
        
    }
    
    
    @IBAction func tagFriend(sender: UIButton) {
        
        if  self.friendtag.contains(self.friendlist[sender.tag]){
            
            self.friendtag.remove(at: self.friendtag.index(of: self.friendlist[sender.tag])!)
            
        } else {
            
            self.friendtag.append(self.friendlist[sender.tag])
            
        }
        
        print(self.friendtag)
        
    }
    
    
    
}
