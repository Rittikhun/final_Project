//
//  EventNotiViewController.swift
//  UserLoginAndRegistration
//
//  Created by Pongparit Paocharoen on 12/22/16.
//  Copyright © 2016 Sergey Kargopolov. All rights reserved.
//

import UIKit
import EventKit

class EventNotiViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var notiView: UITableView!
    
    var fti: [String] = []
    
    var flo: [String] = []
    
    var fd: [String] = []
    
    var fu: [String] = []
    
    var fe: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            
            if FIRAuth.auth()?.currentUser != nil {
                
                self.ref.child("event pending").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let title = value["title"] as! String
                    
                    let location = value["location"] as! String
                    
                    let date = value["date"] as! String
                    
                    let uid = value["uid"] as! String
                    
                    let uidevent = value["uidevent"] as! String
                    
                    if title != ""{
                        
                        self.fti = title.components(separatedBy: ", ")
                        
                    }
                    
                    if location != ""{
                        
                        self.flo = location.components(separatedBy: ", ")
                        
                    }
                    
                    if date != "" {
                        
                        self.fd = date.components(separatedBy: ", ")
                        
                    }
                    
                    if uid != "" {
                        
                        self.fu = uid.components(separatedBy: ", ")
                        
                    }
                    
                    if uidevent != "" {
                        
                        self.fe = uidevent.components(separatedBy: ", ")
                        
                    }
                    
                    
                    print("fti: \(self.fti)")
                    
                    print("flo: \(self.flo)")
                    
                    print("fd: \(self.fd)")
                    
                    print("fu: \(self.fu)")
                    
                    print("fe: \(self.fe)")
                    
                    self.notiView.reloadData()
                    
                })
                
            }
        }
        
        var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: "update", userInfo: nil, repeats: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fti.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateformat = DateFormatter()
        
        dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let cell = self.notiView.dequeueReusableCell(withIdentifier: "eventcell", for: indexPath) as! EventNotiTableViewCell
        
        print(fti)
        
        if fti.isEmpty == false {
            if let user = FIRAuth.auth()?.currentUser {
                
                let d = self.fd[indexPath.row]
                
                let t = self.fti[indexPath.row]
                
                let l = self.flo[indexPath.row]
                
                self.ref.child("users").child(self.fu[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let name = value["name"] as! String

                if FIRAuth.auth()?.currentUser != nil {

                    
                    let d = self.fd[indexPath.row]
                    
                    let t = self.fti[indexPath.row]
                    
                    let l = self.flo[indexPath.row]
                    
                    
                    self.ref.child("users").child(self.fu[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let value = snapshot.value as! NSDictionary
                        
                        let name = value["name"] as! String
                        
                        let date = dateformat.date(from: d)
                        
                        dateformat.dateStyle = .short
                        dateformat.timeStyle = .short
                        
                        let dateString = dateformat.string(from: date!)
                        
                        
                        cell.username.text = name
                        
                        cell.title.text = t
                        
                        cell.location.text = l
                        
                        cell.date.text = "\(dateString)"
                        
                        cell.acceptBtn.tag = indexPath.row
                        
                        cell.acceptBtn.addTarget(self, action: #selector(EventNotiViewController.acceptEvent(sender:)), for: .touchUpInside)
                
                    })
                    
                    
                }
            })
        }
            
        }
        
        
        
        return cell
        
    }
    
    @IBAction func acceptEvent(sender: UIButton) {
        
        if let user = FIRAuth.auth()?.currentUser {
            if FIRAuth.auth()?.currentUser != nil {
                
                
                
                let eventStore = EKEventStore()
                
                let dateformat = DateFormatter()
                
                dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                
                let ti = self.fti[sender.tag]
                
                let lo = self.flo[sender.tag]
                
                let d = self.fd[sender.tag]
                
                let ue = self.fe[sender.tag]
                
                DBProvider.Instance.eventRef.child(ue).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let uid = snapshot.key
                    
                    if (ue == uid){
                        let value = snapshot.value as! NSDictionary
                        
                        var fu = value[Constants.UID] as! String
                        
                        if fu != "" {
                            
                            fu = "\(fu), \(user.uid)"
                            
                            
                        }
                            
                        else {
                            
                            fu = "\(user.uid)"
                            
                            
                        }
                        
                        DBProvider.Instance.eventRef.child(ue).updateChildValues(["uid":fu])
                    }
                })
                
                eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                    
                    if (granted) && (error == nil) {
                        print("granted \(granted)")
                        print("error \(error)")
                        
                        print(sender.tag)
                        
                        let event = EKEvent(eventStore: eventStore)
                        event.title = ti
                        let date = dateformat.date(from: d)
                        event.startDate = date!
                        event.endDate = date!
                        event.location = lo
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        
                        var event_id = ""
                        do{
                            try eventStore.save(event, span: .thisEvent)
                            event_id = event.eventIdentifier
                        }
                        catch let error as NSError {
                            print("json error: \(error.localizedDescription)")
                        }
                        
                        if(event_id != ""){
                            print("event added !")
                        }
                    }
                    
                    
                    //sent to friend
                    
                    
                    
                    
                })
                
                
                fti.remove(at: sender.tag)
                flo.remove(at: sender.tag)
                fd.remove(at: sender.tag)
                fu.remove(at: sender.tag)
                fe.remove(at: sender.tag)
                
                let ftiu = fti.joined(separator: ", ")
                let flou = flo.joined(separator: ", ")
                let fdu = fd.joined(separator: ", ")
                let fuu = fu.joined(separator: ", ")
                let feu = fe.joined(separator: ", ")
                
                let post = ["title": ftiu, "location": flou, "date": fdu, "uid": fuu, "uidevent": feu]
                let childUpdates = ["/event pending/\(user.uid)/": post ]
                self.ref.updateChildValues(childUpdates)
                
                self.notiView.reloadData()
                
                ///// create caledar event here ///////
                
                /////// use title with fti[sender.tag]//////
                /////// use location with flo[sender.tag]///////
                ///// use date with fd[sender.tag]/////**** date still string must be convert to Date
                
                
                
                
                
                
                
                
                
            }
        }
    }
    
    
    func update() {
        
        print("fti: \(self.fti)")
        print("floi: \(self.flo)")
        print("fd: \(self.fd)")
        print("fu: \(self.fu)")
        
        if let user = FIRAuth.auth()?.currentUser {
            if FIRAuth.auth()?.currentUser != nil {
                
                self.ref.child("event pending").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    //                    print(snapshot.value)
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let title = value["title"] as! String
                    
                    let location = value["location"] as! String
                    
                    let date = value["date"] as! String
                    
                    let uid = value["uid"] as! String
                    
                    if title != ""{
                        
                        self.fti = title.components(separatedBy: ", ")
                        
                    }
                    
                    if location != ""{
                        
                        self.flo = location.components(separatedBy: ", ")
                        
                    }
                    
                    if date != "" {
                        
                        self.fd = date.components(separatedBy: ", ")
                        
                    }
                    
                    if uid != "" {
                        
                        self.fu = uid.components(separatedBy: ", ")
                        
                    }
                    
                    
                    self.notiView.reloadData()
                    
                    
                    
                    
                })
            }
        }
        
    }

}
    

