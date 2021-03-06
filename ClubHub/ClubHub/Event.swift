//
//  Event.swift
//  
//
//  Created by Lindsey Gray on 11/11/18.
//
import UIKit
import Foundation

// Class detailing an event object and its attributes
class Event {
    static var allEvents: [Event]?
    static var loadLock = DispatchSemaphore(value: 1)
    
    var id: String? // id to locate event database
    var name: String?
    var startTime: Date?
    var endTime: Date?
    var location: String?
    var club: String?
    var clubId: String?
    var details: String?
    var image: UIImage?
    
    // Default
    init() {
        self.id = nil
        self.name = nil
        self.startTime = nil
        self.endTime = nil
        self.location = nil
        self.club = nil
        self.clubId = nil
        self.details = nil
        self.image = nil
    }
    
    init(id: String?, name: String?, startTime: Date?, endTime: Date?, location: String?, club: String?, clubId: String?, details: String?, image: UIImage?) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.club = club
        self.clubId = clubId
        self.details = details
        self.image = image
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
