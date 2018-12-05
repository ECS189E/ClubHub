//
//  EventTestingViewController
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/13/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
// Test view controller

import UIKit
import Firebase
import GoogleSignIn


class EventTestingViewController: UIViewController, EditEventDelegate, GIDSignInUIDelegate{
    
    var updateId: String = "DVScwlXbwYDRhj15Gbka"
    var userEvents: [String]?
    var saveUserEvent = "9BPkBiOBDlZWpkLK85DQ"
    var event: Event? = Event(id: nil, name: nil, startTime: nil, endTime: nil, location: nil, club: nil, details: nil, image: nil)
    var delEvent: Event? = Event(id: "9BPkBiOBDlZWpkLK85DQ", name: nil, startTime: nil, endTime: nil, location: nil, club: nil, details: nil, image: nil)
    var events: [Event]?
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        getEvent(id: updateId)
        userEvents = User.currentUser?.events
        
        /*
        UserApi.initUserData() { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("User init successful")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error init user data")
            }
        }
        */
        
        let user = Auth.auth().currentUser?.uid
        print("------------------- User:  \(user ?? "") -------------------")
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

    @IBAction func saveEventTapped(_ sender: Any) {
        UserApi.saveEvent(eventID: saveUserEvent) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("Event Saved")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error saving event")
            }
        }
    }
    
    @IBAction func deleteSavedEventTapped(_ sender: Any) {
        UserApi.deleteSavedEvent(eventID: saveUserEvent) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("User event deleted")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error deleting user event")
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
            dest.allEvents = events
        default:
            return
        }
    }
    
    
    func editEventCompleted() {
        self.navigationController?.popViewController(animated: true)

    }
    
    func editEventStarted() {
        self.navigationController?.popViewController(animated: true)
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
