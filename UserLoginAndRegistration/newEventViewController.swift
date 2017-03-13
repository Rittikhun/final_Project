//
//  newEventViewController.swift
//  UserLoginAndRegistration
//
//  Created by iOS Dev on 11/3/2559 BE.
//  Copyright © 2559 Sergey Kargopolov. All rights reserved.
//

import UIKit
import EventKit

class newEventViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    @IBOutlet weak var eventText: UITextField!
    
    @IBOutlet weak var eventPicker: UIDatePicker!
    
    @IBOutlet weak var locationText: UITextField!
    
    var ref: FIRDatabaseReference!
    
    var todaydate : Date!
    
    var stringdate: String!
    
    let dateFomatter = DateFormatter()
    
    var uidft: [String] = []
    
    var location: String = ""
    
    @IBOutlet weak var friendText: UITextField!
    
    //create activity list
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventPicker.date = todaydate
        
        ref = FIRDatabase.database().reference()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editTime(_ sender: UIDatePicker) {
        
        
        dateFomatter.dateStyle = .medium
        dateFomatter.timeStyle = .medium
        stringdate = dateFomatter.string(from:eventPicker.date)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion:nil);
    }
    @IBAction func Save(_ sender: Any) {
        
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event = EKEvent(eventStore: eventStore)
                event.title = self.eventText.text!
                event.startDate = self.eventPicker.date
                event.endDate = self.eventPicker.date
                event.location = self.locationText.text!
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
      
        
        if self.uidft.isEmpty != true {
            
            if let user = FIRAuth.auth()?.currentUser {
                if FIRAuth.auth()?.currentUser != nil {
                    
                    
                    let uid = user.uid
                    for e in self.uidft {
                                       
                    ref.child("event pending").child(e).observeSingleEvent(of: .value, with: { (snapshot) in
                        
//                        print(e)
                        
                        let value = snapshot.value as! NSDictionary
                        
                        var fti = value["title"] as! String
                        
                        var flo = value["location"] as! String
                        
                        var fd = value["date"] as! String
                        
                        var fu = value["uid"] as! String
                        
                        if fti != "" {
                            
                            fti = "\(fti), \(self.eventText.text!)"
                            
                            
                        }
                            
                        else {
                            
                            fti = "\(self.eventText.text!)"
                            
                            
                        }
                        
                        if flo != "" {
                            
                            flo = "\(flo), \(self.location)"
                            
                            
                        }
                            
                        else {
                            
                            flo = "\(self.location)"
                            
                            
                        }

                        if fd != "" {
                            
                            fd = "\(fd), \(self.eventPicker.date)"
                            
                            
                        }
                            
                        else {
                            
                            fd = "\(self.eventPicker.date)"
                            
                            
                        }
                        
                        if fu != "" {
                            
                            fu = "\(fu), \(user.uid)"
                            
                            
                        }
                            
                        else {
                            
                            fu = "\(user.uid)"
                            
                            
                        }


                        let post = ["title": fti, "location": flo, "date": fd, "uid": fu]
                        let childUpdates = ["/event pending/\(e)/": post ]
                        self.ref.updateChildValues(childUpdates)
                        print("sdsds")
                        
                        
                        
                    })
                    
                    
                }
            }
            }
            
        }
        
        
        
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "homeView") as! UIViewController
        
        self.present(vc, animated: true, completion: nil)
        
        
    }
    

    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        

        
        let event = segue.source as! MapCalViewController
        
        print(event.location)
        
        self.locationText.text = event.location
        
        self.location = event.location
        
    }
    
    @IBAction func unwindToMenu2(segue: UIStoryboardSegue) {
        
        self.friendText.text = ""
        
        
        let event = segue.source as! FriendlistViewController
        
        self.uidft = event.friendtag
        
        var friendtag: String = ""
        
        for element in self.uidft {
            
            if let user = FIRAuth.auth()?.currentUser {
                
                if FIRAuth.auth()?.currentUser != nil {
                    
                    self.ref.child("users").child(element).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let value = snapshot.value as! NSDictionary
                        
                        let name = value["name"] as! String
                        
                        if friendtag == "" {
                            
                            friendtag = name
                            
                        } else {
                            
                            friendtag = "\(friendtag), \(name)"
                            
                        }
                        
                        self.friendText.text = friendtag
                        
                    })
                }
            }
        }
    }

    
}
