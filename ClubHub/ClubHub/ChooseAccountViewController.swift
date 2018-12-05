//
//  ChooseAccountViewController
//  ClubHub
//
//  Created by Lindsey Gray on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class ChooseAccountViewController: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        UserApi.initUserData(type: "user", club: nil) { data, err in
            switch(data, err) {
            // User data in database, existing account
            case(.some(let data), nil):
                User.currentUser = data as? User
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(
                    withIdentifier: "tabBarController")
                    as! UITabBarController
                self.navigationController?.pushViewController(viewController, animated: true)
            // No user data in database, new account
            case(nil, .some(_)):
                print("Error initializing user data")
            default:
                print("Error initializing user data")
            }
        }
    }
    
}
