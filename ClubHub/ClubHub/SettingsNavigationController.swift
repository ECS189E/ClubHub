//
//  SettingsNavigationController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class SettingsNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let sravyaStoryboard = UIStoryboard(name: "Lindsey", bundle: nil)
        let settingsVC = sravyaStoryboard.instantiateViewController(withIdentifier: "editClubViewController")
        self.setViewControllers([settingsVC], animated: true)
    }

}
