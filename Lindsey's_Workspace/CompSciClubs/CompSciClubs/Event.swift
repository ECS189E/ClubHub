//
//  Event.swift
//  
//
//  Created by Lindsey Gray on 11/11/18.
//
import UIKit
import Foundation

class Event {
    var id: String?
    var name: String?
    var startTime: Date?
    var endTime: Date?
    var location: String?
    var club: String?  // FIXME: var club: Club? when club class made
    var details: String?
    //var mainPhoto: UIImage?
    //var photos: [UIImage]?
    
    // Default
    init() {
        self.id = nil
        self.name = nil
        self.startTime = nil
        self.endTime = nil
        self.location = nil
        self.club = nil
        self.details = nil
        //self.mainPhoto = nil
        //self.photos = nil
    }
    
    init(id: String?, name: String?, startTime: Date?, endTime: Date?, location: String?, club: String?, details: String?) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.club = club
        self.details = details
        //self.mainPhoto = nil
        //self.photos = nil
    }
    
    func printEvent() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE MMM dd, yyyy hh:mm a"
        
        print("----------------------------")
        print("Event: \(self.name ?? "")")
        print("ID: \(self.id ?? "")")
        print("Start Time: \(self.startTime.map{dateFormatter.string(from: $0)} ?? "")")
        print("End Time: \(self.endTime.map{dateFormatter.string(from: $0)} ?? "")")
        print("Location: \(self.location ?? "")")
        print("Club: \(self.club ?? "")")
        print("Description: \(self.details ?? "")")
        print("----------------------------")
    }
}
