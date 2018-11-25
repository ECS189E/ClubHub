//
//  ViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/13/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
// Test view controller

import UIKit

class ViewController: UIViewController, EditEventDelegate{
    
    var updateId: String = "FIcpOWlpIziJoxwEmWD0"
    var deleteId: String = "9SiWiJuWv8GdqTbz53E4"
    var userEvents = ["4LCtWNiwjkIt5vPlxDy4", "FIcpOWlpIziJoxwEmWD0"]
    var event: Event?
    
    func editEventCompleted() {
        //self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getEvent(id: updateId) // get event for update test
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

}
