//
//  ClubCell.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/29/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class ClubCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var clubImageView: UIImageView!
    
    func initClubCell(name: String?, image: UIImage?) {
        
        // allow for a dynamic amount of lines for labels
        if nameLabel != nil {
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.numberOfLines = 0
        }
        
        if let name = name, let _ = nameLabel {
            nameLabel.text = name
        }
        if let image = image, let _ = clubImageView {
            clubImageView.image = image
        }
    }
}
