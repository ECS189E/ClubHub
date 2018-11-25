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
    
    override func viewDidLoad() {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
