//
//  ClubViewController.swift
//  ClubHub
//
//  Created by Srivarshini Ananta on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
import UIKit

/// A view controller for a club
class ClubViewController: UIViewController, EventDetailsDelegate {
    
    @IBOutlet weak var clubName: UILabel!
    @IBOutlet weak var clubImage: UIImageView!
    @IBOutlet weak var aboutClub: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var tableview: UITableView!
    var savedClub: Bool = false
    var events: [Event]? = []
    var club: Club?
    var dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getEventsForClub()
        tableview.reloadData()
    }
    
    func viewInit() {
        // Init club info
        clubImage.image = club?.image ?? UIImage(named: "defaultImage")
        clubName.text = club?.name
        aboutClub.text = club?.details
        
        // Init date formatter for table view
        dateFormatter.dateFormat = "EE MMM d"
        
        // if user is a club, disable save button
        if User.currentUser?.club != nil {
            saveButton.isEnabled = false
        }
        tableview.delegate = self
        tableview.dataSource = self
        
        // init save button if club is saved already
        if User.currentUser?.clubs?
            .contains(club?.id ?? "") ?? false {
            // show save button and change it to a filled star
            saveButton.image = UIImage(named: "icons8-star-filled-36")
            savedClub = true
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // If club is not already saved, save it
        if !savedClub {
            // Save club to user data in firebase
            UserApi.saveClub(clubID: club?.id) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    let clubs = data as? [String]
                    
                    // Update current users club list in memory
                    User.currentUser?.clubs = clubs
                    
                    // Change save button appearence to indicate club saved
                    self.saveButton.image = UIImage(named: "icons8-star-filled-36")
                    self.savedClub = true
                default:
                    print("Error saving clubs")
                }
            }
        // Else unsaving a club
        } else {
            // Delete club from user's saved club list
            UserApi.deleteSavedClub(clubID: club?.id) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    let clubs = data as? [String]
                    // Update current users club list in memory
                    User.currentUser?.clubs = clubs
                    
                    // Change save button appearence to indicate club is no longer saved
                    self.saveButton.image = UIImage(named: "icons8-star-outline-36")
                    self.savedClub = false
                default:
                    print("Error saving clubs")
                }
            }
        }
    }
    
    func eventEditedFromDetails() {
        // Update events
        getEvents()
    }
    
    func eventDeletedFromDetails() {
        // close child
        self.navigationController?.popViewController(animated: true)
        // Update events
        getEvents()
    }
    
    
    // Get clubs events from database and reload table view as data is recieved
    func getEvents() {
        Event.allEvents = []
        
        // Get list of events ids from database
        EventsApi.getEventsIDs(startDate: nil, limit: nil) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                if let eventIds = data as? [String?] {
                    for id in eventIds {
                        // Get data for event
                        EventsApi.getEvent(id: id ?? "") { data, error in
                            switch(data, error){
                            case(nil, .some(let error)):
                                print(error)
                            case(.some(let data), nil):
                                // Add event to all events
                                Event.allEvents?.append(data as! Event)
                                
                                // Filter out club events and update table view
                                self.getEventsForClub()
                                self.tableview.reloadData()
                            default:
                                print("Error getting event \(id ?? "")")
                            }
                        }
                    }
                }
            default:
                print("Error getting events")
                
            }
        }
    }
    
    func getEventsForClub() {
        // sort events by start time
        Event.allEvents
            = Event.allEvents?
                .sorted(by: { $0.startTime?.compare($1.startTime ?? Date())
                    == .orderedAscending })
        
        // remove events that have already passed
        Event.allEvents = Event.allEvents?.filter {
            $0.startTime ?? Date() >= Date() }
        
        // Get events for club
        events = Event.allEvents?.filter {
            $0.clubId == self.club?.id}
        
        // Set events to display
        tableview.reloadData()
    }
}

// Table view delegate functions
extension ClubViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let events = self.events else {
            return UITableViewCell()
        }
        
        let event = events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "clubEventCell", for: indexPath) as! EventCell
        
        cell.initEventCell(name: event.name,
                           startTime: event.startTime,
                           club: event.club,
                           image: nil,
                           dateFormat: "EE MMM dd")
        
        return cell
    }
    
    // If events selection, show event details
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "eventDetailsViewController") as! EventDetailsViewController
        viewController.event = self.events.map { $0[indexPath.row] }
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

