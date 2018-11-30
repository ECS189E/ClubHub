//
//  EventsFeedViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/24/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class EventsFeedViewController: UIViewController {
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var allEventsButton: UIButton!
    @IBOutlet weak var myEventButton: UIButton!
    
    var userEvents: [String]? // Array of user saved event ids
    var events: [Event]?  // Events curretly loaded into table
    var allEvents: [Event]? = [] // All unfilterd events
    var filteredEvents = [Event]() // Events filtered by search bar
    var eventLoadDate = Date() // Date to load next set of events form
    //FIXME: update for deployment
    var loadLimit: Int = 2 // Number of events to load at time (MUST BE > 1)
    var loadedEvents: Int = 0 // Number of events that have been loaded
    var userEventsDisplayed: Bool = false // True if "My Events" tapped
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        viewInit()
    }
    
    func viewInit() {
        // format appearence of dates
        dateFormatter.dateFormat = "EE MMM dd, yyyy"
        timeFormatter.dateFormat = "hh:mm a"
        // Init selected events view buttons
        allEventsButton.alpha = 1.0
        myEventButton.alpha = 0.5
        
        getEvents()
        
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
        events = allEvents
        userEventsDisplayed = false
        eventsTableView.reloadData()
    }
    
    // load user events into table and set button appearence
    @IBAction func myEventsButtonTapped(_ sender: Any) {
        searchController.isActive = false // cancel search
        allEventsButton.alpha = 0.5
        myEventButton.alpha = 1.0
        events = allEvents?.filter{ event in
            userEvents?.contains(event.id ?? "") ?? false }
        userEventsDisplayed = true
        eventsTableView.reloadData()
    }
    
    // Get events loadLimit number of events from database starting from eventLoadDate
    func getEvents() {
        EventsApi.getEventsIDs(startDate: eventLoadDate, limit: loadLimit) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                if let eventIds = data as? [String?] {
                    self.loadedEvents += eventIds.count
                    
                    for id in eventIds {
                        EventsApi.getEvent(id: id ?? "") { data, error in
                            switch(data, error){
                            case(nil, .some(let error)):
                                print(error)
                            case(.some(let data), nil):
                                let event = data as! Event
                                self.allEvents?.append(event)
                                
                                // sort events by start time
                                self.allEvents
                                    = self.allEvents?.sorted(by: { $0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
                                // remove events that have already passed
                                self.allEvents = self.allEvents?.filter {
                                    $0.startTime ?? Date() >= Date() }
                                
                                self.events = self.allEvents
                                
                                // Filter if currenlty displayin user events
                                if self.userEventsDisplayed {
                                    self.events = self.allEvents?.filter{ event in
                                        self.userEvents?.contains(event.id ?? "") ?? false }
                                }
                                
                                self.eventsTableView.reloadData()
                                
                                // set the next date to load based on last loaded
                                if id == eventIds[eventIds.count - 1],
                                    let startTime = event.startTime{
                                    self.eventLoadDate = startTime.addingTimeInterval(1)
                                }
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
        // FIXME: change "Cindy" to "Main"
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let storyboard = UIStoryboard(name: "Cindy", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "eventDetailsViewController") as! EventDetailsViewController
        viewController.event = self.events.map { $0[indexPath.row] }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Load more events when the bottom of the table is scrolled to
    // Source: https://stackoverflow.com/questions/20269474/uitableview-load-more-when-scrolling-to-bottom-like-facebook-application
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.getEvents()
        }
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
