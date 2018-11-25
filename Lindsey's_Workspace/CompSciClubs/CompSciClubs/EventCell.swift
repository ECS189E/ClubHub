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
    @IBOutlet var clubLabel: UILabel!
    @IBOutlet var eventStartTimeLabel: UILabel!
    
    func initEventCell(name: String?, startTime: Date?, club: String?, image: UIImage?, dateFormat: String?) {
        
        // allow for a dynamic amount of lines for labels
        if nameLabel != nil {
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.numberOfLines = 0
        }
        if clubLabel != nil {
            clubLabel.lineBreakMode = .byWordWrapping
            clubLabel.numberOfLines = 0
        }
        
        if let name = name, let _ = nameLabel {
            nameLabel.text = name
        }
        if let image = image, let _ = eventImageView {
            eventImageView.image = image
        }
        if let club = club, let _ = clubLabel {
            clubLabel.text = club
        }
        if let startTime = startTime, let _ = eventStartTimeLabel {
            let dateFormatter = DateFormatter()
            
            if let dateFormat = dateFormat {
                dateFormatter.dateFormat = dateFormat
            } else {
                dateFormatter.dateFormat = "EE MMM dd hh:mm a"
            }
            eventStartTimeLabel.text = dateFormatter.string(from: startTime)
        }
    }
}
