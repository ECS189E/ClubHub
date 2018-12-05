//
//  LoadingViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UserApi.getUserData() { data, err in
            switch(data, err) {
            case(.some(let data), nil):
                User.currentUser = data as? User
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
                self.present(viewController, animated: false, completion: nil)
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error getting user events")
            }
        }
    }
}
