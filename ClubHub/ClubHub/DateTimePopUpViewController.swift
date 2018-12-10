//
//  DateTimePopUpViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/11/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

protocol DateTimePopUpDelegate{
    //func datePopUpCanceled()
    func dateSelected(date: Date?)
}

import UIKit

// A class for pop up view controller for picking a date or time
class DateTimePopUpViewController: UIViewController {
    
    var delegate: DateTimePopUpDelegate?
    var pickerMode: UIDatePicker.Mode?
    var date: Date?

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }
    
    func viewInit() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // set picker mode based on delegate's choice
        if let pickerMode = pickerMode {
            datePicker.datePickerMode = pickerMode
        }
        datePicker.date = date ?? Date()
    }
    
    // Date/Time picker resigned
    @IBAction func cancelTapped(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    // Date/Time chosen
    @IBAction func okTapped(_ sender: Any) {
        self.delegate?.dateSelected(date: datePicker.date)
        self.view.removeFromSuperview()
    }
}
