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
    func eventDeletedFromDetails()
}

// A view controller for displaying event details 
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
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var event: Event?
    var savedEvent: Bool = false
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var delegate: EventDetailsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }
    
    // Load event form staticly stored array of events
    // May have been changed in a different tab
    override func viewWillAppear(_ animated: Bool) {
        let updatedEvent = Event.allEvents?.filter { event in
            event.id?.contains(self.event?.id ?? "") ?? false}
        
        // If event not in array, may have been deleted or being loaded
        guard (updatedEvent?.count ?? 0) > 0 else {
                self.navigationController?.popViewController(animated: true)
                return
        }
        
        // get updated event and load event data
        event = updatedEvent?[0]
        loadEvent(event: event)
    }
    
    func viewInit() {
        // Hide activitiy indicator
        activityIndicator.alpha = 0
        
        // format appearence of dates
        dateFormatter.dateFormat = "EE MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
        
        
        // if user is a club, disable save button
        if User.currentUser?.club != nil {
            saveButton.isEnabled = false
        }
        // if event is not owned by user, hide edit and delete buttons
        if User.currentUser?.club?.id != event?.clubId {
            editButton.alpha = 0
            editButton.isHidden = true
            editButton.isEnabled = false
            
            deleteButton.alpha = 0
            deleteButton.isHidden = true
            deleteButton.isEnabled = false
            
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
    
    @IBAction func deleteTapped(_ sender: Any) {
        EventsApi.deleteEvent(event: event) {data, err in
            switch(data, err) {
            case(.some(_), nil):
                
                // Delete the clubs new event from its user account
                UserApi.deleteSavedClub(clubID: self.event?.id){ data, err in
                    switch(data, err) {
                    case(.some(let data), nil):
                        User.currentUser?.events = data as? [String]
                        self.delegate?.eventDeletedFromDetails()
                        
                        // stop activity indicator
                        self.activityIndicator.alpha = 0
                        self.activityIndicator.stopAnimating()
                    case(nil, .some(let err)):
                        print(err)
                        self.delegate?.eventDeletedFromDetails()
                    default:
                        print("Error: could not update event")
                        self.delegate?.eventDeletedFromDetails()
                    }
                }
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error: could not add event")
            }
        }
        // start activity indicator
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
    }
    
    func loadEvent(event: Event?) {
        eventImageView.image = event?.image ?? UIImage(named: "defaultImage")
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
    // reload data or resing if event deleted
    func editEventCompleted(event: Event?) {
        //close child
        self.navigationController?.popViewController(animated: true)
        
        // reload data and notify delegate
        if let event = event {
            loadEvent(event: event)
            delegate?.eventEditedFromDetails()
        } else {
            self.delegate?.eventDeletedFromDetails()
        }
    }
}
