//
//  CancelEventNotiViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 6/2/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit

class CancelEventNotiViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var event : [String] = []
    var friend : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        var ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            
            if FIRAuth.auth()?.currentUser != nil {
                
                ref.child("cancelevent").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let event = value["event"] as! String
                    
                    let name = value["name"] as! String
                    
                    self.event.append(event)
                    self.friend.append(name)
                    
                    self.tableView.reloadData()
                    
                })
                
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return event.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "eventcell", for: indexPath) as! CancelEventNotiTableViewCell
        
        cell.Nameevent.text = self.event[indexPath.row]
        cell.nameFriend.text = self.friend[indexPath.row]
        
        
        return cell
        
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
