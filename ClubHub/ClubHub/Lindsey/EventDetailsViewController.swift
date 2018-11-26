//
//  EventDetailsViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/18/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        event?.printEvent()
    }
    

}
