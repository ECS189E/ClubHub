//
//  ViewController.swift
//  AccountSetup
//
//  Created by Sravya Sri Divakarla on 11/19/18.
//  Copyright © 2018 Sravya Sri Divakarla. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate{
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    


}

