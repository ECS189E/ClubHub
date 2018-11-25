//
//  DayEventsViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/24/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class DayEventsViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventsTableView: UITableView!
    
    var events: [Event]?
    var allEvents: [Event]?
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        super.viewDidLoad()
        viewInit()
        
        // Do any additional setup after loading the view.
    }
    
    func viewInit() {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        dateFormatter.dateFormat = "hh:mm a"
    }
    
    @IBAction func datePicked(_ sender: Any) {
        events = allEvents?.filter{ event in
            Calendar.current.isDate(datePicker.date, equalTo: event.startTime ?? Date(), toGranularity:.day)
        }
        eventsTableView.reloadData()
    }
}

// TableView funtions
extension DayEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.events?.count ?? 0)
        return self.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let events = self.events else {
            return UITableViewCell()
        }
        
        let event = events[indexPath.row]
        
        // the identifier is like the type of the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayEventCell", for: indexPath) as! EventCell
        
        cell.initEventCell(name: event.name, startTime: event.startTime, club: event.club, image: nil, dateFormat: "hh:mm a")  //FIXME: debugging
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "eventDetailsViewController") as! EventDetailsViewController
        viewController.event = self.events.map { $0[indexPath.row] }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
