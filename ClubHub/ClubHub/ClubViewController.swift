//
//  ClubViewController.swift
//  ClubHub
//
//  Created by Srivarshini Ananta on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
import UIKit

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
        
        // init save button if event is saved already
        if User.currentUser?.clubs?
            .contains(club?.id ?? "") ?? false {
            // show save button and change it to a filled star
            saveButton.image = UIImage(named: "icons8-star-filled-36")
            savedClub = true
        }
        getEventsForClub()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if !savedClub {
            UserApi.saveClub(clubID: club?.id) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    let clubs = data as? [String]
                    User.currentUser?.clubs = clubs
                    self.saveButton.image = UIImage(named: "icons8-star-filled-36")
                    self.savedClub = true
                default:
                    print("Error saving clubs")
                }
            }
        } else {
            UserApi.deleteSavedClub(clubID: club?.id) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    let clubs = data as? [String]
                    User.currentUser?.clubs = clubs
                    self.saveButton.image = UIImage(named: "icons8-star-outline-36")
                    self.savedClub = false
                default:
                    print("Error saving clubs")
                }
            }
        }
    }
    func eventEditedFromDetails() {
        self.navigationController?.popViewController(animated: true)
        // Update events
        getEvents()
    }
    func getEvents() {
        Event.allEvents = []
        
        EventsApi.getEventsIDs(startDate: nil, limit: nil) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                if let eventIds = data as? [String?] {
                    for id in eventIds {
                        EventsApi.getEvent(id: id ?? "") { data, error in
                            switch(data, error){
                            case(nil, .some(let error)):
                                print(error)
                            case(.some(let data), nil):
                                Event.allEvents?.append(data as! Event)
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
    
}
extension ClubViewController: UITableViewDelegate, UITableViewDataSource {
    
    func getEventsForClub() {
        events = Event.allEvents?.sorted(by: { $0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
 
        // remove events that have already passed
        Event.allEvents = Event.allEvents?.filter {
            $0.startTime ?? Date() >= Date() }
        
        // Set events to display
        self.events = Event.allEvents
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let events = self.events else {
            return UITableViewCell()
        }
        
        let event = events[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "clubEventCell", for: indexPath) as! EventCell
        
        // the identifier is like the type of the cell
        
        cell.initEventCell(name: event.name, startTime: event.startTime, club: event.club, image: nil, dateFormat: "EE MMM dd")  //FIXME: debugging
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "eventDetailsViewController") as! EventDetailsViewController
        viewController.event = self.events.map { $0[indexPath.row] }
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

