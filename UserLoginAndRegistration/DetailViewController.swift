//
//  DetailViewController.swift
//  UserLoginAndRegistration
//
//  Created by iOS Dev on 12/22/2559 BE.
//  Copyright © 2559 Sergey Kargopolov. All rights reserved.
//

import UIKit
import EventKit

class DetailViewController: UIViewController {

    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var placelabel: UILabel!
    
    var calendarView: CalendarView!
    
    
    var detailtitle : String = ""
    var detaildate : Date!
    var detailLocation : String = ""

    
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateformat = DateFormatter()
        dateformat.dateStyle = .none
        dateformat.timeStyle = .short
        
        var startdateString = dateformat.string(from: detaildate)
        
        
        
        namelabel.text = detailtitle
        timelabel.text = startdateString
        placelabel.text = detailLocation

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

}
