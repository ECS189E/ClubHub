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
import GoogleSignIn

/// A view controller for displaying the sign in method for Google accounts
class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            GIDSignIn.sharedInstance().uiDelegate = self
    }
    
}
