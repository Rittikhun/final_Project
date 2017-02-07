//
//  pendingViewCell.swift
//  UserLoginAndRegistration
//
//  Created by Pongparit Paocharoen on 12/21/16.
//  Copyright © 2016 Sergey Kargopolov. All rights reserved.
//

import UIKit

class pendingViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var acceptBtnOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
