//
//  EventCell.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/17/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit


// Source: https://medium.com/@aapierce0/swift-using-protocols-to-add-custom-behavior-to-a-uitableviewcell-2c1f09610aa1
protocol EventCellDelegate {
    func saveEventTapped(_ sender: EventCell)

}

// Source: https://www.youtube.com/watch?v=YwE3_hMyDZA
class EventCell: UITableViewCell {
    
    @IBOutlet var saveEventButton: UIButton!
    
    var delegate: EventCellDelegate?
    
    var eventImage: UIImage?
    var name: String?
    var startTime: Date?
    
    // init event image view
    var eventImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // init name view
    var nameView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.font = .boldSystemFont(ofSize: 16)
        return textView
    }()
    
    // init start time view
    var startTimeView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        //textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 14)
        return textView
    }()
    
    // init save button
    var saveButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.setTitleColor(UIColor.green, for: .normal)
        //button.setTitle("Save", for: .normal)
        button.setImage(UIImage(named: "gray-outlined-star-35"), for: .normal)
        button.isEnabled = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(eventImageView)
        self.addSubview(nameView)
        self.addSubview(startTimeView)
        self.addSubview(saveButton)
        
        // set image constraints
        eventImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        eventImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        eventImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // set name constraints
        nameView.leftAnchor.constraint(equalTo: self.eventImageView.rightAnchor).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        nameView.bottomAnchor.constraint(equalTo: startTimeView.topAnchor).isActive = true
        nameView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        // FIXME: center text horizontally
          
        // set date constraints
        startTimeView.leftAnchor.constraint(equalTo: self.eventImageView.rightAnchor, constant: 10).isActive = true
        startTimeView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        startTimeView.rightAnchor.constraint(equalTo: saveButton.leftAnchor).isActive = true
        startTimeView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        // FIXME: center text horizontall
        
        // set save button constraints
        saveButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        saveButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let name = self.name {
            nameView.text = name
        }
        
        if let startTime = self.startTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EE MMM dd hh:mm a"
            startTimeView.text = dateFormatter.string(from: startTime)
        }
        
        if let image = eventImage {
            eventImageView.image = image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func saveEventButtonTapped(_ sender: Any) {
        delegate?.saveEventTapped(self)
    }
}
