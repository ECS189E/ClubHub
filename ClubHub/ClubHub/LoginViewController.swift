//
//  LoginViewController.swift
//  ClubHub
//
//  Created by Sravya Sri Divakarla on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("in Login")

        if let user  = Auth.auth().currentUser{
            print("is already logged in")
            self.performSegue(withIdentifier: "toLoggedInController", sender: self)
        }
    }
    
    
}
