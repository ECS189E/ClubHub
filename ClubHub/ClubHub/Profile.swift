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
    
    init() {
        self.name = nil
        self.email = nil
    }
    
    init(name: String?, email: String?) {
        self.name = name
        self.email = email
    }
}
