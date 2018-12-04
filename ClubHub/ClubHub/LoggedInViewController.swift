//
//  LoggedInViewController.swift
//  ClubHub
//
//  Created by Sravya Sri Divakarla on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoggedInViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in Loggedin")
    }
    
    
    @IBAction func logoutButton(_ target: UIButton){
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
}
