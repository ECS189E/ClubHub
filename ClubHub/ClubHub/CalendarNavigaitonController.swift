//
//  CalendarNavigaitonController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class CalendarNavigaitonController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let varshiniStoryboard = UIStoryboard(name: "Varshini", bundle: nil)
        let calendarVC = varshiniStoryboard.instantiateViewController(withIdentifier: "calendarViewController")
        self.setViewControllers([calendarVC], animated: true)
    }
}
