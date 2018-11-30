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
    
    var updateId: String = "6FNTgxwQDIwg1By1ua7G"
    var userEvents = ["Hyhm8u7rwxoI5avhbpDu"]
    var event: Event? = Event(id: nil, name: nil, startTime: nil, endTime: nil, location: nil, club: nil, details: nil, image: nil)
    var delEvent: Event? = Event(id: "6FNTgxwQDIwg1By1ua7G", name: nil, startTime: nil, endTime: nil, location: nil, club: nil, details: nil, image: nil)
    var events: [Event]?
    
    func editEventCompleted() {
        //self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getEvent(id: updateId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getEvents()
    }
    
    // Test Api.deleteEvent()
    @IBAction func deleteEventTapped(_ sender: Any) {
        EventsApi.deleteEvent(event: delEvent) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("Event \(self.delEvent?.id ?? "") deleted")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error deleting event \(self.delEvent?.id ?? "")")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier) {
        case("addEvent"):
            let dest = segue.destination as! EditEventViewController
            dest.delegate = self
            dest.event = nil
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
                                self.events?.append(data as! Event)
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
