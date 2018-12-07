//
//  CalendarViewController.swift
//  SimpleCal
//
//  Created by Srivarshini Ananta on 11/24/18.
//  Copyright © 2018 Srivarshini Ananta. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, EditEventDelegate, EventDetailsDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarListedEvents: UITableView!

    @IBOutlet weak var addEventButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var events: [Event]? = []
    var filteredEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.calendar.reloadData()
    }

    
    func viewInit() {
        // hide add event for users
        if User.currentUser?.club == nil {
            addEventButton.isEnabled = false
            addEventButton.tintColor = UIColor.white
        }
        
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        
        calendarListedEvents.delegate = self
        calendarListedEvents.dataSource = self
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // Display the events for that particular date on the event board below the calendar
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        // If searching, display matching events
        if isFiltering() {
            // get events for the selected date
            events = filteredEvents.filter { event in
                Calendar.current
                    .isDate(date,
                            equalTo: event.startTime ?? Date(),
                            toGranularity:.day) }
            // sort events by start time
            events
                = filteredEvents.sorted(
                    by: { $0.startTime?.compare($1.startTime ?? Date())
                        == .orderedAscending })
        // Else display all events
        } else {
            // get events for the selected date
            events = Event.allEvents?.filter { event in
                Calendar.current.isDate(date, equalTo: event.startTime ?? Date(), toGranularity:.day) }
            // sort events by start time
            events
                = events?.sorted(by: { $0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
        }
        calendarListedEvents.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        if isFiltering() {
            return filteredEvents.filter { event in
                Calendar.current
                    .isDate(date,
                            equalTo: event.startTime ?? Date(),
                            toGranularity:.day)}.count
        }
        
        return Event.allEvents?.filter { event in
            Calendar.current
                .isDate(date,
                        equalTo: event.startTime ?? Date(),
                        toGranularity:.day)}.count ?? 0
    }
    
    @IBAction func addEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "editEventViewController") as! EditEventViewController
        viewController.delegate = self
        viewController.event = nil
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // if an event was edited, get all events again
    func editEventCompleted(event: Event?) {
        // close child
        self.navigationController?.popViewController(animated: true)
        // Update events
        getEvents()
    }
    
    // EventDetailsDelegate function
    // Event was edited from the details view
    func eventEditedFromDetails() {
        // update events
        getEvents()
    }

    func eventDeletedFromDetails() {
        // close child
        self.navigationController?.popViewController(animated: true)
        // Update events
        getEvents()
    }
    
    // get all events and update calendar as each event is received
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
                                self.calendar.reloadData()
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
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return  // Only for secected date
                filteredEvents.filter { event in
                    Calendar.current
                        .isDate(calendar.selectedDate ?? Date(),
                                equalTo: event.startTime ?? Date(),
                                toGranularity:.day) }.count
        }
        
        return self.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let events = self.events else {
            return UITableViewCell()
        }
        
        let event: Event
        if isFiltering() {
            // Only for secected date
            event = filteredEvents.filter { event in
                    Calendar.current
                        .isDate(calendar.selectedDate ?? Date(),
                                equalTo: event.startTime ?? Date(),
                                toGranularity:.day) }[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        
        // the identifier is like the type of the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarEventCell", for: indexPath) as! EventCell
        
        cell.initEventCell(name: event.name,
                           startTime: event.startTime,
                           club: event.club,
                           image: nil,
                           dateFormat: "h:mm a")
        
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
extension CalendarViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // Private instance methods
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        // filter events by names and events matching the serach text
        filteredEvents = Event.allEvents?.filter{ event in
            event.name?.lowercased().contains(searchText.lowercased()) ?? false
                || event.club?.lowercased().contains(searchText.lowercased()) ?? false
        } ?? []
        
        // sort events by start time
        events
            = filteredEvents.sorted(
                by: { $0.startTime?.compare($1.startTime ?? Date())
                    == .orderedAscending })
        calendar.reloadData()
        calendarListedEvents.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
