//
//  ClubTestingViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/29/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class ClubTestingViewController: UIViewController, EditClubDelegate {
    
    var updateId: String = "pwWKt7uIV366S2ZUFcgC"
    var userClubs: [String]?
    var saveUserClub = "mNhp7PMaqzuvRq31nCsQ"
    var delClub: Club? = Club(id: "KREGUOnzx4eO1hy2P86U", name: nil, details: nil, image: nil)
    var clubs: [Club]?
    var club: Club?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        getClubs()
        getUserClubs()
        getClub(id: updateId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // Test Api.deleteClub()
    @IBAction func deleteClubTapped(_ sender: Any) {
        ClubsApi.deleteClub(club: delClub) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("Club \(self.delClub?.id ?? "") deleted")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error deleting club \(self.delClub?.id ?? "")")
            }
        }
    }
    
    @IBAction func saveClubTapped(_ sender: Any) {
        UserApi.saveClub(clubID: saveUserClub) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("Club Saved")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error saving club")
            }
        }
    }
    
    @IBAction func deleteSavedClubTapped(_ sender: Any) {
        UserApi.deleteSavedClub(clubID: saveUserClub) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("User club deleted")
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error deleting user club")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier) {
        case("allClubs"):
            let dest = segue.destination as! ClubListViewController
            dest.userClubs = userClubs
        case("addClub"):
            let dest = segue.destination as! EditClubViewController
            dest.club = nil
            dest.delegate = self
        case("updateClub"):
            let dest = segue.destination as! EditClubViewController
            dest.club = club
            dest.delegate = self
        default:
            return
        }
    }
    
    func editClubCompleted() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // test Api.getClub()
    func getClub(id: String) {
        ClubsApi.getClub(id: id) { data, err in
            switch(data, err) {
            case(.some(let data), nil):
                self.club = data as? Club
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error getting club \(id)")
            }
        }
    }
    
    func getClubs() {
        ClubsApi.getClubsIDs(start: nil, limit: nil) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                if let clubIds = data as? [String?] {
                    for id in clubIds {
                        ClubsApi.getClub(id: id ?? "") { data, error in
                            switch(data, error){
                            case(nil, .some(let error)):
                                print(error)
                            case(.some(let data), nil):
                                self.clubs?.append(data as! Club)
                            default:
                                print("Error getting club \(id ?? "")")
                            }
                        }
                    }
                }
            default:
                print("Error getting clubs")
                
            }
        }
    }
    
    func getUserClubs() {
        UserApi.getUserClubs() { data, err in
            switch(data, err) {
            case(.some(let data), nil):
                self.userClubs = data as? [String]
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error getting user clubs")
            }
        }
    }
    
}

