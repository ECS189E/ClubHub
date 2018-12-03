//
//  EventsNavigationController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class EventsNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let lindseyStoryboard = UIStoryboard(name: "Lindsey", bundle: nil)
        let eventsVC = lindseyStoryboard.instantiateViewController(withIdentifier: "eventsFeedViewController")
        self.setViewControllers([eventsVC], animated: true)
    
    }
    
}
