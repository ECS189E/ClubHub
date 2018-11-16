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
    
    var id: String = "4LCtWNiwjkIt5vPlxDy4"
    var event: Event?
    
    func editEventCompleted() {
        //self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        testGetEvent()

        // Do any additional setup after loading the view.
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
        default:
            return
        }
    }

    func testGetEvent() {
        EventsApi.getEvent(id: id) { data, err in
            switch(data, err) {
            case(.some(let data), nil):
                self.event = data as? Event
            case(nil, .some(let err)):
                print("Error: \(err)")
            default:
                print("Error getting event \(self.id)")
            }
        }
    }

}
