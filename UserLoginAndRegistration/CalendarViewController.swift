//
//  CalendarViewController.swift
//  UserLoginAndRegistration
//
//  Created by iOS Dev on 11/3/2559 BE.
//  Copyright © 2559 Sergey Kargopolov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import FirebaseInstanceID
import EventKit

class CalendarViewController: UIViewController, UIPopoverPresentationControllerDelegate, CalendarViewDataSource, CalendarViewDelegate , UITableViewDelegate , UITableViewDataSource{
    
    
    @IBOutlet weak var calendarView: CalendarView!
    
    var ref: FIRDatabaseReference!
    
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    var usernamenaja: String = ""
    
    var eventlist : [String] = []
    
    var detailDate : [CalendarEvent] = []
    
    var todayis : Date!
    
    var older = Date()
    
    var calendarEventSelect : CalendarEvent!
    
    var menushow = false
    
    @IBOutlet weak var cal_icon: UITabBarItem!
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    
    @IBAction func logout(_ sender: Any) {
//    }
//    @IBAction func logout(_ sender: Any) {
        do {
            
            try FIRAuth.auth()?.signOut()
            
            var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            var vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "loginView") as! UIViewController
            
            self.present(vc, animated: true, completion: nil)
            
            
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBAction func menuAction(_ sender: AnyObject) {
        
        if(menushow){
            leading.constant = -140
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        else{
            leading.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        
        menushow = !menushow
        
    }
    
    @IBAction func newAction(_ sender: AnyObject) {
        
        
        if(todayis == nil){
            
            let alert = UIAlertController(title: "Pick date", message: "Please, Pick a date", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
            
        else{
            calendarView.deselectDate(todayis)
            
            self.dismiss(animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "newEventSegue2", sender: self)
      
            
            
            
        }
        
    }
    
    
    
    @IBOutlet weak var calendar_item: UITabBarItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "newEventSegue2" {
            
            
            
            let event = segue.destination as! newEventViewController
            
            
            event.todaydate = todayis
            
        }
        
        
        if segue.identifier == "menuSegue2" {
            
            var vc = segue.destination as! UIViewController
            var controller = vc.popoverPresentationController
            
            vc.preferredContentSize = CGSize(width: 200, height: 160)
            
            
            if controller != nil {
                
                controller?.delegate = self
                
            }
            
        }
        
        
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        calendarView.setNeedsDisplay()
        tableview.reloadData()
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image : UIImage? = UIImage(named:"calendar-icon.png")?.withRenderingMode(.alwaysOriginal)
        
        cal_icon.selectedImage = image
        
        tableview.delegate = self
        tableview.dataSource = self
        
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        // change the code to get a vertical calender.
        calendarView.direction = .horizontal
        
        
        ref = FIRDatabase.database().reference()
        
        //        print(userID!)
        //
        //
        //        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
        //            // Get user value
        //            let value = snapshot.value as! NSDictionary
        //
        //            let usernamef = value["name"] as! String
        //
        //            self.username.text = usernamef
        //            self.usernamenaja = usernamef
        //
        //            // ...
        //        }) { (error) in
        //            print(error.localizedDescription)
        //        }
        
        
        // The user's ID, unique to the Firebase project.
        // Do NOT use this value to authenticate w®ith your backend server,
        // if you have one. Use getTokenWithCompletion:completion: instead.
        // Do any additional setup after loading the view.
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("\(todayis)")
        
        super.viewDidAppear(animated)
        
        self.loadEventsInCalendar()
        
        var tomorrowComponents = DateComponents()
        tomorrowComponents.day = 1
        
        let today = Date()
        
        
        if let tomorrow = (self.calendarView.calendar as NSCalendar).date(byAdding: tomorrowComponents, to: today, options: NSCalendar.Options()) {
            //    self.calendarView.selectDate(tomorrow)
            //self.calendarView.deselectDate(date)
            
        }
        
        self.calendarView.setDisplayDate(today, animated: false)
        // self.datePicker.setDate(today, animated: false)
        
        
    }
    
    // MARK : KDCalendarDataSource
    
    func startDate() -> Date? {
        
        var dateComponents = DateComponents()
        dateComponents.month = -3
        
        let today = Date()
        
        let threeMonthsAgo = (self.calendarView.calendar as NSCalendar).date(byAdding: dateComponents, to: today, options: NSCalendar.Options())
        
        
        return threeMonthsAgo
    }
    
    func endDate() -> Date? {
        
        var dateComponents = DateComponents()
        
        dateComponents.year = 2;
        let today = Date()
        
        let twoYearsFromNow = (self.calendarView.calendar as NSCalendar).date(byAdding: dateComponents, to: today, options: NSCalendar.Options())
        
        return twoYearsFromNow
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let width = self.view.frame.size.width
        let height = width + 20.0
        self.calendarView.frame = CGRect(x: 0.0, y: 60.0, width: width, height: height)
        
        
    }
    
    
    
    // MARK : KDCalendarDelegate
    
    func calendar(_ calendar: CalendarView, didSelectDate date
        : Date, withEvents events: [CalendarEvent]){
        
        if(older == Date()){
            older = date
        }
        else if(older == date){
            
        }
        else{
            self.calendarView.deselectDate(older)
            older = date
        }
        
        
        setDate(date: date)
        
        
        
        detailDate.removeAll()
        eventlist.removeAll()
        
        let format = DateFormatter()
        let dateformat = DateFormatter()
        
        format.dateStyle = .long
        format.timeStyle = .none
        
        dateformat.dateStyle = .none
        dateformat.timeStyle = .short
        
        let dateString = format.string(from: date)
        
        for event in events {
            
            let startdateString = dateformat.string(from: event.startDate)
            
            detailDate.append(event)
            
            
        }
        
        self.tableview.reloadData()
        
        
        
        
        
    }
    func setDate(date: Date) {
        
        todayis = date
        
        
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
        
        //  self.datePicker.setDate(date, animated: true)
    }
    
    // MARK : Events
    
    func loadEventsInCalendar() {
        
        if let  startDate = self.startDate(),
            let endDate = self.endDate() {
            
            let store = EKEventStore()
            
            let fetchEvents = { () -> Void in
                
                let predicate = store.predicateForEvents(withStart: startDate, end:endDate, calendars: nil)
                
                // if can return nil for no events between these dates
                if var eventsBetweenDates = store.events(matching: predicate) as [EKEvent]? {
                    
                    self.calendarView.events = eventsBetweenDates
                    
                }
                
            }
            
            // let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
            
            if EKEventStore.authorizationStatus(for: EKEntityType.event) != EKAuthorizationStatus.authorized {
                
                store.requestAccess(to: EKEntityType.event, completion: {(granted, error ) -> Void in
                    if granted {
                        fetchEvents()
                    }
                })
                
            }
            else {
                fetchEvents()
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if(detailDate.count == 0){
            return 0
            
        }
        return detailDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventViewCell
        if(detailDate.count == 0){
            cell.label.text = ""
            
            return cell
        }
        else{
            
            let dateformat = DateFormatter()
            
            dateformat.dateStyle = .none
            dateformat.timeStyle = .short
            
            let detail = detailDate[(indexPath.row)]
            
            let startdateString = dateformat.string(from: detail.startDate)
            
            
            cell.label.text = "\(startdateString) : \(detail.title)"
            
            //cell.label.
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        calendarView.deselectDate(todayis)
        
        self.calendarEventSelect = detailDate[(indexPath.row)]
        
        print(self.calendarEventSelect)
        
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var vc = storyboard.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        
        var myStringArr = calendarEventSelect.location.components(separatedBy: "///")
        
        vc.detailtitle = calendarEventSelect.title
        vc.detaildate = calendarEventSelect.startDate
        vc.detailLocation = myStringArr[0]
        vc.uidevent = myStringArr[1]
        
        vc.start = calendarEventSelect.startDate.addingTimeInterval(-60*60*24)
        vc.end = calendarEventSelect.startDate.addingTimeInterval(+60*60*24)
        
        
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    
    

    
    
    
}
