//
//  DetailCarpoolTableViewCell.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 4/25/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit

class DetailCarpoolTableViewCell: UITableViewCell {

    @IBOutlet weak var rateText: UILabel!
    
    @IBOutlet weak var commentText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
