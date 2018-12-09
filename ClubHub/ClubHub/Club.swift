//
//  Club.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/29/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class Club {
    static var allClubs: [Club]?
    static var loadLock = DispatchSemaphore(value: 1)
    
    var id: String? // id to locate event database
    var name: String?
    var details: String?
    var image: UIImage?
    //var images: [UIImage]?
    
    // Default
    init() {
        self.id = nil
        self.name = nil
        self.details = nil
        self.image = nil
        //self.images = nil
    }
    
    init(id: String?, name: String?, details: String?, image: UIImage?) {
        self.id = id
        self.name = name
        self.details = details
        self.image = image
        //self.images = nil
    }
    
    func printClub() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE MMM dd, yyyy hh:mm a"
        
        print("----------------------------")
        print("Club: \(self.name ?? "")")
        print("ID: \(self.id ?? "")")
        print("Description: \(self.details ?? "")")
        print("----------------------------")
    }
}
