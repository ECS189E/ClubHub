//
//  ChooseAccountViewController
//  ClubHub
//
//  Created by Lindsey Gray on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

/// A view controller for handling the selection of a user account or a club account
class ChooseAccountViewController: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // If canceling new account setup, go to login
    @IBAction func cancelClicked(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide nav bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationItem.hidesBackButton = true
        // Hide navigation bar without messing with constraints and format
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    
    @IBAction func clubAccountChosen(_ sender: Any) {
        self.performSegue(withIdentifier: "createClub", sender: self)
    }
    
    @IBAction func userAccountChosen(_ sender: Any) {
        // Initialize user data
        UserApi.initUserData(type: "user", clubName: nil, clubId: nil) { data, err in
            switch(data, err) {
            // User data in database, existing account
            case(.some(let data), nil):
                User.currentUser = data as? User
                
                // switch to main screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(
                    withIdentifier: "tabBarController")
                    as! UITabBarController
                self.present(viewController, animated: false, completion: nil)
            // No user data in database, new account
            case(nil, .some(_)):
                print("Error initializing user data")
            default:
                print("Error initializing user data")
            }
        }
    }
    
}
