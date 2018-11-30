//
//  ClubTestingViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/29/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class ClubTestingViewController: UIViewController {
    
    var updateId: String = "oWHGwRY5SQeRIWmEIsOT"
    var userClubs: [String] = ["xLeqourzzQXn9efnXHrY", "KREGUOnzx4eO1hy2P86U"]
    var delClub: Club? = Club(id: "xLeqourzzQXn9efnXHrY", name: nil, details: nil, image: nil)
    var clubs: [Club]?
    //var club: Club?
    var club: Club? = Club(id: "xLeqourzzQXn9efnXHrY", name: "Women in Computer Science", details: nil, image: UIImage(named: "testImage"))
    //var club: Club? = Club(id: "oWHGwRY5SQeRIWmEIsOT", name: "UC Davis Computer Science Club", details: "", image: UIImage(named: "testImage"))

    override func viewDidLoad() {
        super.viewDidLoad()
        getClubs()
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
    
    @IBAction func addClubTapped(_ sender: Any) {
        ClubsApi.addClub(club: club) { data, err in
            switch(data, err) {
            case(.some(let data), nil):
                self.club = data as? Club
                print("Club \(self.club?.id ?? "") added")
                self.club?.printClub()
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error adding club \(self.delClub?.id ?? "")")
            }
        }
    }
    
    @IBAction func updateClubTapped(_ sender: Any) {
        ClubsApi.updateClub(club: club) { data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("Club \(self.club?.id ?? "") updated")
                self.club?.printClub()
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error updating club \(self.club?.id ?? "")")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier) {
        case("allClubs"):
            let dest = segue.destination as! ClubListViewController
            dest.userClubs = userClubs
        default:
            return
        }
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
    
}

