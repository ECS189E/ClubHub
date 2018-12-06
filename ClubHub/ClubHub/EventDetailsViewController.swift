//
//  EventDetailsViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/18/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

protocol EventDetailsDelegate {
    func eventEditedFromDetails()
}


class EventDetailsViewController: UIViewController, EditEventDelegate {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var startTime
    : UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    var event: Event?
    var savedEvent: Bool = false
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var delegate: EventDetailsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // format appearence of dates
        dateFormatter.dateFormat = "EE MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"

        
        // if user is a club, disable save button
        if User.currentUser?.club != nil {
            saveButton.isEnabled = false
        // else hide button
        } else {
            editButton.alpha = 0
            editButton.isHidden = true
            editButton.isEnabled = false
            scrollViewBottomConstraint.constant = 10
        }
        
        // init save button or edit button if event is saved
        if User.currentUser?.events?.contains(event?.id ?? "") ?? false {
            
            // if user is a club and owns this event, enable edit
            if User.currentUser?.club != nil &&
                ((User.currentUser?.club?.name?.compare(event?.name ?? "")) != nil) {
                // show edit button
                editButton.isHidden = false
                editButton.isEnabled = true
            }

            // show save button and change it to a filled star
            saveButton.image = UIImage(named: "icons8-star-filled-36")
            savedEvent = true
        }
        
        loadEvent(event: event)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if !savedEvent {
            UserApi.saveEvent(eventID: event?.id) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                let events = data as? [String]
                User.currentUser?.events = events
                self.saveButton.image = UIImage(named: "icons8-star-filled-36")
                self.savedEvent = true
            default:
                print("Error saving events")
                }
            }
        } else {
            UserApi.deleteSavedEvent(eventID: event?.id) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    let events = data as? [String]
                    User.currentUser?.events = events
                    self.saveButton.image = UIImage(named: "icons8-star-outline-36")
                    self.savedEvent = false
                default:
                    print("Error saving events")
                }
            }
        }
    }
    
    @IBAction func editEventTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "editEventViewController") as! EditEventViewController
        viewController.event = event
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func loadEvent(event: Event?) {
        eventImageView.image = event?.image ?? UIImage(named: "testImage")
        eventNameLabel.text = event?.name ?? "Event Name"
        clubNameLabel.text = event?.club ?? "Club Name"
        startDate.text =
            dateFormatter.string(from: event?.startTime ?? Date())
        endDate.text =
            dateFormatter.string(from: event?.endTime ?? Date())
        startTime.text =
            timeFormatter.string(from: event?.startTime ?? Date())
        endTime.text =
            timeFormatter.string(from: event?.endTime ?? Date())
        locationLabel.text = event?.location ?? "Location"
        descriptionLabel.text = event?.details ??  "Description"
    }
    
    // EditEventDelegate func
    // Once the backend finished updating event
    // Returns updated event if event updated successfully
    // Returns nil if deleted or an error encountered
    func editEventCompleted(event: Event?) {
        // close child
        self.navigationController?.popViewController(animated: true)
        
        if let event = event {
            loadEvent(event: event)
        } else {
            // event deleted, so resign
            self.navigationController?.popViewController(animated: true)
        }
        
        // notify delegate that an event was updated
        delegate?.eventEditedFromDetails()
    }
}
