//
//  EventTestingViewController
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/13/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
// Test view controller

import UIKit

class EventTestingViewController: UIViewController, EditEventDelegate{
    
    var updateId: String = "gQw9MV6xYVPScFjumrgR"
    var deleteId: String = "gQw9MV6xYVPScFjumrgR"
    var userEvents = ["gQw9MV6xYVPScFjumrgR", "FIcpOWlpIziJoxwEmWD0"]
    var event: Event?
    var events: [Event]?
    
    func editEventCompleted() {
        //self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getEvent(id: updateId)
        getEvents()
    }
    
    // Test Api.deleteEvent()
    @IBAction func deleteEventTapped(_ sender: Any) {
        EventsApi.deleteEvent(id: deleteId) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("Event \(self.deleteId) deleted")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error deleting event \(self.deleteId)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier) {
        case("editEvent"):
            let dest = segue.destination as! EditEventViewController
            dest.delegate = self
        case("updateEvent"):
            let dest = segue.destination as! EditEventViewController
            dest.delegate = self
            dest.event = event
        case("allEvents"):
            let dest = segue.destination as! EventsFeedViewController
            dest.userEvents = userEvents
        case("eventsByDay"):
            let dest = segue.destination as! DayEventsViewController
            dest.allEvents = events
        default:
            return
        }
    }

    // test Api.getEvent()
    func getEvent(id: String) {
        EventsApi.getEvent(id: id) { data, err in
            switch(data, err) {
            case(.some(let data), nil):
                self.event = data as? Event
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error getting event \(id)")
            }
        }
    }
    
    func getEvents() {
        // Get events
        EventsApi.getEvents() { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                self.events = data as? [Event]
                
                // sort events by start time
                self.events = self.events?.sorted(by: { $0.startTime?.compare($1.startTime ?? Date()) == .orderedAscending })
                // remove events that have already passed
                self.events = self.events?.filter { $0.startTime ?? Date() >= Date() }
            default:
                print("Error getting events")
                
            }
        }
    }

}
