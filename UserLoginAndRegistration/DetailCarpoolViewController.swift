//
//  DetailCarpoolViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 4/25/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit

class DetailCarpoolViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var name = ""
    
    var comment : [String] = []
    var rate : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datainit()

        // Do any additional setup after loading the view.
    }
    
    private func datainit(){
        DBProvider.Instance.passengerRef.child(name).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as! NSDictionary
            let comment = value[Constants.COMMENT] as! String
            let rate = value[Constants.RATE] as! String
            
            self.comment = comment.components(separatedBy: " ,")
            self.rate = rate.components(separatedBy: " ,")
            
            self.tableview.reloadData()
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailCarpoolTableViewCell
        
        cell.rateText.text = rate[indexPath.row]
        cell.commentText.text = comment[indexPath.row]
        
        return cell
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
