//
//  EventsFeedViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/24/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import Firebase

class EventsFeedViewController: UIViewController, EditEventDelegate, EventDetailsDelegate {
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var allEventsButton: UIButton!
    @IBOutlet weak var myEventButton: UIButton!
    @IBOutlet weak var addEventButton: UIBarButtonItem!
    
    var events: [Event]?  // Events curretly loaded into table
    var filteredEvents = [Event]() // Events filtered by search bar
    var userEventsDisplayed: Bool = false // True if "My Events" tapped
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        viewInit()
        getEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reset the events
        events = Event.allEvents
    }
    
    func viewInit() {
        // hide add event for users
        if User.currentUser?.club == nil {
            addEventButton.isEnabled = false
            addEventButton.tintColor = UIColor.white
        }
        
        // format appearence of dates
        dateFormatter.dateFormat = "EE MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
        // Init selected events view buttons
        allEventsButton.alpha = 1.0
        allEventsButton.layer.cornerRadius =
            allEventsButton.frame.size.height/7
        myEventButton.alpha = 0.5
        myEventButton.layer.cornerRadius =
            myEventButton.frame.size.height/7
        
        // Source: https://www.raywenderlich.com/472-uisearchcontroller-tutorial-getting-started
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // load all events into table and set button appearence
    @IBAction func allEventsButtonTapped(_ sender: Any) {
        searchController.isActive = false // cancel serach
        allEventsButton.alpha = 1.0
        myEventButton.alpha = 0.5
        events = Event.allEvents
        userEventsDisplayed = false
        eventsTableView.reloadData()
    }
    
    // load user events into table and set button appearence
    @IBAction func myEventsButtonTapped(_ sender: Any) {
        if let userEvents = User.currentUser?.events {
            searchController.isActive = false // cancel search
            allEventsButton.alpha = 0.5
            myEventButton.alpha = 1.0
            events = Event.allEvents?.filter{ event in
                userEvents.contains(event.id ?? "") }
            userEventsDisplayed = true
            eventsTableView.reloadData()
        }
    }
    
    @IBAction func addEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "editEventViewController") as! EditEventViewController
        viewController.delegate = self
        viewController.event = nil
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    // EditEventDelegateFunction
    // Event added, reload data
    func editEventCompleted(event: Event?) {
        // close child
        self.navigationController?.popViewController(animated: true)
        // Update events
        getEvents()
    }
    
    // EventDetailsDelegate function
    // Event was edited from the details view
    func eventEditedFromDetails() {
        getEvents()
    }
    
    // Get events loadLimit number of events from database starting from eventLoadDate
    func getEvents() {
        // reset events list
        Event.allEvents = []
        
        EventsApi.getEventsIDs(startDate: nil, limit: nil) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                if let eventIds = data as? [String?] {
                    // add each event to the event list and reload table view
                    for id in eventIds {
                        EventsApi.getEvent(id: id ?? "") { data, error in
                            switch(data, error){
                            case(nil, .some(let error)):
                                print(error)
                            case(.some(let data), nil):
                                let event = data as! Event
                                Event.allEvents?.append(event)
                                
                                // sort events by start time
                                Event.allEvents
                                    = Event.allEvents?.sorted(by: { $0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
                                // remove events that have already passed
                                Event.allEvents = Event.allEvents?.filter {
                                    $0.startTime ?? Date() >= Date() }
                                
                                // Set events to display
                                self.events = Event.allEvents
                                
                                // Filter if currenlty displayin user events
                                if self.userEventsDisplayed,
                                    let userEvents = User.currentUser?.events {
                                    self.events = Event.allEvents?.filter{ event in
                                        userEvents.contains(event.id ?? "") }
                                }
                                
                                self.eventsTableView.reloadData()
                                
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

// TableView funtions
extension EventsFeedViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredEvents.count
        }
        return self.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let events = self.events else {
            return UITableViewCell()
        }
        
        let event: Event
        if isFiltering() {
            event = filteredEvents[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        
        // the identifier is like the type of the cell
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        cell.initEventCell(name: event.name,
                           startTime: event.startTime,
                           club: event.club,
                           image: event.image ?? UIImage(named: "testImage"), //FIXME: for testing
                           dateFormat: "EE MMM dd hh:mm a") 
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

// Search bar
extension EventsFeedViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // Private instance methods
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        guard let events = events else {
            return
        }
        
        // filter events by names and clubs matching the serach text
        filteredEvents = events.filter{ event in
            event.name?.lowercased().contains(searchText.lowercased()) ?? false
                || event.club?.lowercased().contains(searchText.lowercased()) ?? false
        }
        
        // sort filtered events
        filteredEvents =
            filteredEvents.sorted(by:
                {$0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
        
        eventsTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
