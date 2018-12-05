//
//  SenderCell.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class SenderCell: UITableViewCell {

    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.messageBackground.clipsToBounds = true
        self.messageBackground.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
