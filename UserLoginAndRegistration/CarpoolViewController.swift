//
//  CarpoolViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit

class CarpoolViewController: UIViewController {
    
    @IBOutlet weak var map_item: UITabBarItem!
    let DB = DBProvider();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image : UIImage? = UIImage(named:"map-icon.png")?.withRenderingMode(.alwaysOriginal)
        
        map_item.selectedImage = image

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func passengerBtn(_ sender: Any) {
        
//        DBProvider.statusCarpool("passenger")
        
        DB.statusCarpool(status: "passenger")
        
    }

    @IBAction func driverBtn(_ sender: Any) {
        
        DB.statusCarpool(status: "driver")
        
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
