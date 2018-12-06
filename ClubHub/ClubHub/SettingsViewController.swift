//
//  SettingsViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var editClubButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide edit club if user is not a club
        if User.currentUser?.club == nil {
            editClubButton.isEnabled = false
            editClubButton.isHidden = true
        }

    }
    
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        UserApi.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "loginViewController") as! LoginViewController
        present(viewController, animated: false, completion: nil)
    }
    
    
    @IBAction func deleteTapped(_ sender: Any) {
        Auth.auth().currentUser?.delete() {
            error in
            if let error = error {
                // An error happened.
            } else {
                // Account deleted.
            }
        }
    }
    
}
