//
//  EventNotiTableViewCell.swift
//  UserLoginAndRegistration
//
//  Created by Pongparit Paocharoen on 12/22/16.
//  Copyright © 2016 Sergey Kargopolov. All rights reserved.
//

import UIKit

class EventNotiTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var acceptBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
