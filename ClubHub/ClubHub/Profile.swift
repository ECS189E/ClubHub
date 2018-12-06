//
//  Profile.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class Profile {
    static var currentUser: User?
    
    let name: String?
    let email: String?
    let id: String?
    
    init() {
        self.name = nil
        self.email = nil
        self.id = nil
    }
    
    init(name: String?, email: String?, id: String?) {
        self.name = name
        self.email = email
        self.id = id
    }
}
