//
//  LoadingViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, EditClubDelegate {
    
    var currentUser: String? = nil
    var nextViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If last signing successful, get data
        if(currentUser != nil) {
            // Get user data from firebas database
            UserApi.getUserData() { data, err in
                switch(data, err) {
                // User data in database, existing account
                case(.some(let data), nil):
                    User.currentUser = data as? User
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
                    self.present(viewController, animated: false, completion: nil)
                // No user data in database, new account
                case(nil, .some(_)):
                    User.currentUser = nil
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "loginViewController")
                    self.present(viewController, animated: false, completion: nil)
                default:
                    print("Error getting user events")
                }
            }
        }
    }
    
    func editClubCompleted() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
        self.present(viewController, animated: false, completion: nil)
    }
    
    func didEndLoad() {
        if let viewController = nextViewController {
            self.present(viewController, animated: false, completion: nil)
        }
    }
}
