//
//  TextMessageCell.swift
//  ChatBox
//
//  Created by Naveen Kumar on 11/2/16.
//  Copyright © 2016 Naveen Kumar. All rights reserved.
//

import UIKit

class TextMessageCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    
    @IBOutlet weak var senderName: UILabel!
    
    @IBOutlet weak var createdTime: UILabel!
    
    @IBOutlet weak var dataView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
