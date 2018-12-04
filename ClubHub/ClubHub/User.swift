//
//  File.swift
//  ClubHub
//
//  Created by Srivarshini Ananta on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class User {
    static var currentUser: User?
    
    var id: String?
    var club: Club?
    var events: [String]?
    var clubs: [String]?
    
    // Default
    init() {
        self.id = nil
        self.club = nil
        self.events = nil
        self.clubs = nil
        //self.images = nil
    }
    
    init(id: String?, club: Club?, events: [String]?, clubs: [String]?) {
        self.id = id
        self.club = club
        self.events = events
        self.clubs = clubs
        //self.images = nil
    }
}
