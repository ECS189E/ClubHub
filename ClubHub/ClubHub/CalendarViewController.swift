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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let calendar = FSCalendar(frame: CGRect(x: 10, y: 30, width: 400, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
    }
    
    // Display the events for that particular date on the event board below the calendar
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        
    }
    
}

