//
//  PickClubController.swift
//  ClubHub
//
//  Created by Sravya Sri Divakarla on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class PickClubController: UIViewController {
    
    var allClubs: [Club]? = [] // All unfilterd clubs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getClubs();
    }
    
    func getClubs() {
        
        ClubsApi.getClubsIDs(start: nil, limit: nil) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                if let clubIds = data as? [String?] {
                    // add each club to the club list and reload table view
                    for id in clubIds {
                        ClubsApi.getClub(id: id ?? "") { data, error in
                            switch(data, error){
                            case(nil, .some(let error)):
                                print(error)
                            case(.some(let data), nil):
                                let club = data as! Club
                                self.allClubs?.append(club)
                                
                               // self.clubsTableView.reloadData()
                            default:
                                print("Error getting club \(id ?? "")")
                            }
                        }
                    }
                }
            default:
                print("Error getting clubs")
                
            }
            for c in self.allClubs!{
                print(c.name)
            }
        }
        
    }
    
}
