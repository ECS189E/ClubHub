//
//  EventCell.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/17/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class EventCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var eventStartTimeLabel: UILabel!
    
    func initEventCell(name: String?, startTime: Date?, image: UIImage?) {
        
        // format cell UI
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 0
        
        if let name = name {
            nameLabel.text = name
        }
        if let image = image {
            eventImageView.image = image
        }
        if let startTime = startTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EE MMM dd hh:mm a"
            eventStartTimeLabel.text = dateFormatter.string(from: startTime)
        }
        
    }
}
