//
//  SettingsViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, EditClubDelegate {

    @IBOutlet weak var editClubButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide edit club if user is not a club
        if User.currentUser?.club == nil {
            editClubButton.isEnabled = false
            editClubButton.isHidden = true
        }

    }
    
    @IBAction func editClubPageTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "editClubViewController") as! EditClubViewController
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        logout()
    }
    
    
    @IBAction func deleteTapped(_ sender: Any) {
        Auth.auth().currentUser?.delete() {
            error in
            if let error = error {
                print(error)
            } else {
                UserApi.deleteUser() { data, err in
                    switch(data, err) {
                        case(.some(_), nil):
                            self.logout()
                        case(nil, .some(let err)):
                            print("Error deleting user's club: \(err)")
                        default:
                            print("Error deleting user's club")
                    }
                }
            }
        }
    }
    
    func editClubCompleted() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func logout() {
        UserApi.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "loginViewController") as! LoginViewController
        present(viewController, animated: false, completion: nil)
    }
}
