//
//  Profile.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/6/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit
import Firebase


/// A model object to be used in place of 'User' for conversations, uses the credentials stored in realtime db
class Profile: NSObject {
    
    let name: String
    let email: String
    let id: String
    var profilePic: UIImage
    
    init(name: String, email: String, id: String, profilePic: UIImage) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = profilePic
    }
    
    class func info(forUserID: String, completion: @escaping (Profile) -> Void) {
        Database.database().reference().child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: String] {
                let name = data["name"]!
                let email = data["email"]!
                let user = Profile.init(name: name, email: email, id: forUserID, profilePic: UIImage(named: "default profile")!)
                completion(user)
            }
        })
    }
    
    class func downloadAllUsers(exceptID: String, completion: @escaping (Profile) -> Void) {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let data = snapshot.value as! [String: Any]
            let credentials = data["credentials"] as! [String: String]
            if id != exceptID {
                let name = credentials["name"]!
                let email = credentials["email"]!
                let user = Profile.init(name: name, email: email, id: id, profilePic: UIImage(named: "default profile")!)
                completion(user)
            }
        })
    }
}
