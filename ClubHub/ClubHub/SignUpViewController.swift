//
//  SignUpViewController.swift
//  ClubHub
//
//  Created by Sravya Sri Divakarla on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // continue button not getting triggered
   
    

    @IBAction func contButton(_ sender: Any) {
        print("Hello there");
    }
    
    func handleSignUp() {
        guard let user = username.text else { return }
        guard let em = email.text else { return }
        guard let pass = password.text else { return }
        
        
        Auth.auth().createUser(withEmail: em, password: pass){ user, error in
            if error == nil && user != nil{
                print("user created");
            }
            else {
                print("Error creating user: \(error!.localizedDescription)")
            }
        }
    }
    
    
}
