//
//  EventDetailsViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/18/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

/*
 TODO: Clean up UI, add favorite/saving?
 */
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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var event: Event?
    var savedEvent: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton.isHidden = true
        editButton.isEnabled = false
        
        saveButton.isHidden = false
        saveButton.isEnabled = true
        
        // init save button or edit button if event is saved
        if User.currentUser?.events?.contains(event?.id ?? "") ?? false {
            
            // if user is a club and owns this event
            if User.currentUser?.club != nil &&
                ((User.currentUser?.club?.name?.compare(event?.name ?? "")) != nil) {
                // show edit button
                editButton.isHidden = false
                editButton.isEnabled = true
                // hide save button
                saveButton.isHidden = true
                saveButton.isEnabled = false

            // else event is a user saved event
            } else {
                // show save button and change it to a filled star
                saveButton.setImage(UIImage(named: "icons8-star-filled-36"), for: .normal)
                savedEvent = true
            }
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
                self.saveButton.setImage(UIImage(named: "icons8-star-filled-36"), for: .normal)
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
                    self.saveButton.setImage(UIImage(named: "icons8-star-outline-36"), for: .normal)
                    self.savedEvent = false
                default:
                    print("Error saving events")
                }
            }
        }
    }
    
    @IBAction func editEventTapped(_ sender: Any) {
        // Used only for testing
        let storyboard = UIStoryboard(name: "Lindsey", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "editEventViewController") as! EditEventViewController
        viewController.event = event
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func loadEvent(event: Event?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE MMM dd, yyyy hh:mm a"
        
        eventImageView.image = event?.image ?? UIImage(named: "testImage")
        eventNameLabel.text = event?.name ?? "Event Name"
        clubNameLabel.text = event?.club ?? "Club Name"
        //dateTimeLabel.text = event?.startTime.map{dateFormatter.string(from: $0)} ?? "Date and Time"
        locationLabel.text = event?.location ?? "Location"
        descriptionLabel.text = event?.details ??  "Description"
    }
    
    // EditEventDelegate func
    // Once the backend finished updating event
    // Returns updated event if event updated successfully
    // Returns nil if deleted or an error encountered
    func editEventCompleted(event: Event?) {
        if let event = event {
            loadEvent(event: event)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // EditEventDelegate func
    // Once done is tapped in edit event, but backend not updated yet
    func editEventStarted() {
        self.navigationController?.popViewController(animated: true)
    }
}
