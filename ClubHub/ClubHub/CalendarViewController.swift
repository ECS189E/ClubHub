//
//  CalendarViewController.swift
//  SimpleCal
//
//  Created by Srivarshini Ananta on 11/24/18.
//  Copyright © 2018 Srivarshini Ananta. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventBar: UITextView!
    @IBOutlet weak var calendarListedEvents: UITableView!

    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let calendar = FSCalendar(frame: CGRect(x: 10, y: 30, width: 400, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
        
        calendarListedEvents.delegate = self
        calendarListedEvents.dataSource = self
        dateFormatter.dateFormat = "hh:mm a"
        getEvents()
    }
    
    var events: [Event]? = []
    var allEvents: [Event]? = []
    
    // Display the events for that particular date on the event board below the calendar
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        
        events = allEvents?.filter { event in
            Calendar.current.isDate(date, equalTo: event.startTime ?? Date(), toGranularity:.day)
        }
        
        calendarListedEvents.reloadData()
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
                                self.allEvents?.append(data as! Event)
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
        return self.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let events = self.events else {
            return UITableViewCell()
        }
        
        let event = events[indexPath.row]
        
        // the identifier is like the type of the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarEventCell", for: indexPath) as! EventCell
        
        cell.initEventCell(name: event.name, startTime: event.startTime, club: event.club, image: nil, dateFormat: "hh:mm a")  //FIXME: debugging
        
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

