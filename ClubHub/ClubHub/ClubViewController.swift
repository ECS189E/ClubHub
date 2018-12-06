//
//  ClubViewController.swift
//  ClubHub
//
//  Created by Srivarshini Ananta on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
import UIKit

class ClubViewController: UIViewController {
    
    @IBOutlet weak var clubName: UILabel!
    @IBOutlet weak var clubImage: UIImageView!
    @IBOutlet weak var aboutClub: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var savedClub: Bool = false
    
    var club: Club?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clubImage.image = club?.image ?? UIImage(named: "testImage")
        clubName.text = club?.name
        aboutClub.text = club?.details
        
        // if user is a club, disable save button
        if User.currentUser?.club != nil {
            saveButton.isEnabled = false
        }

        // init save button if event is saved already
        if User.currentUser?.clubs?
            .contains(club?.id ?? "") ?? false {
            // show save button and change it to a filled star
            saveButton.image = UIImage(named: "icons8-star-filled-36")
            savedClub = true
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if !savedClub {
            UserApi.saveClub(clubID: club?.id) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    let clubs = data as? [String]
                    User.currentUser?.clubs = clubs
                    self.saveButton.image = UIImage(named: "icons8-star-filled-36")
                    self.savedClub = true
                default:
                    print("Error saving clubs")
                }
            }
        } else {
            UserApi.deleteSavedClub(clubID: club?.id) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    let clubs = data as? [String]
                    User.currentUser?.clubs = clubs
                    self.saveButton.image = UIImage(named: "icons8-star-outline-36")
                    self.savedClub = false
                default:
                    print("Error saving clubs")
                }
            }
        }
    }
}
