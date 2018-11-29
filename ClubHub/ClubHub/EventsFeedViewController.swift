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
    
    var allEvents: [Event]?
    var userEvents: [String]? // Array of user saved event ids
    
    var events: [Event]?
    var filteredEvents = [Event]()
    
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
        
        // Source: https://www.raywenderlich.com/472-uisearchcontroller-tutorial-getting-started
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        allEventsButton.alpha = 1.0
        myEventButton.alpha = 0.5
        
        EventsApi.getEvents() { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                self.allEvents = data as? [Event]
                
                // sort events by start time
                self.allEvents = self.allEvents?.sorted(by: { $0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
                // remove events that have already passed
                self.allEvents = self.allEvents?.filter { $0.startTime ?? Date() >= Date() }
                
                self.events = self.allEvents
                self.eventsTableView.reloadData()
            default:
                print("Error getting events")
                
            }
        }
    }
    
    @IBAction func allEventsButtonTapped(_ sender: Any) {
        searchController.isActive = false // cancel serach
        allEventsButton.alpha = 1.0
        myEventButton.alpha = 0.5
        events = allEvents
        eventsTableView.reloadData()
    }
    
    @IBAction func myEventsButtonTapped(_ sender: Any) {
        searchController.isActive = false // cancel search
        allEventsButton.alpha = 0.5
        myEventButton.alpha = 1.0
        events = allEvents?.filter{ event in
            userEvents?.contains(event.id ?? "") ?? false }
        eventsTableView.reloadData()
    }
    
}

// TableView funtions
extension EventsFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        cell.initEventCell(name: event.name, startTime: event.startTime, club: event.club, image: event.mainImage ?? UIImage(named: "testImage"), dateFormat: "EE MMM dd hh:mm a")  //FIXME: debugging clickable
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // FIXME: change "Lindsey" to "Main"
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let storyboard = UIStoryboard(name: "Cindy", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "eventDetailsViewController") as! EventDetailsViewController
        viewController.event = self.events.map { $0[indexPath.row] }
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
        filteredEvents = filteredEvents.sorted(by: { $0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
        
        eventsTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    
}
