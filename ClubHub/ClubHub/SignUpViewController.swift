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
   
    @IBAction func contButton(_ sender: Any) {
        print("Hello there");
        handleSignUp()
    }
    
    func handleSignUp() {
        guard let us = username.text else { return }
        guard let em = email.text else { return }
        guard let pass = password.text else { return }
        
        
        Auth.auth().createUser(withEmail: em, password: pass){ user, error in
            if error == nil && user != nil{
                print("user created");
                //to change display name
                let displayChangeReq = Auth.auth().currentUser?.createProfileChangeRequest()
                displayChangeReq?.displayName = us
                displayChangeReq?.commitChanges { error in
                    if error == nil {
                        print("user display name is changed")
                    }
                }
                self.dismiss(animated: true, completion:nil)
            }
            else {
                print("Error creating user: \(error!.localizedDescription)")
            }
        }
    }
    
    
}
