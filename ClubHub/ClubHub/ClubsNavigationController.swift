//
//  ClubsNavigationController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class ClubsNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lindseyStoryboard = UIStoryboard(name: "Lindsey", bundle: nil)
        let clubsVC = lindseyStoryboard.instantiateViewController(withIdentifier: "clubListViewConroller")
        self.setViewControllers([clubsVC], animated: true)
    }
}
